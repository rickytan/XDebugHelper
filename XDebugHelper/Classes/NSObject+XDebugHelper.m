//
//  NSObject+XDebugHelper.m
//  XDebugHelper
//
//  Created by Ricky on 2018/12/28.
//

#import <objc/runtime.h>
#import <objc/message.h>
#import "NSObject+XDebugHelper.h"
#import "NSValue+XDebugHelper.h"
#import "XDHIvar.h"
#import "XDHProperty.h"

typedef struct {
    size_t maxLengthOfName;
    size_t maxLengthOfTypeName;
    size_t maxLengthOfTypeEncoding;
} IvarINFO;

static void IvarsOfClass(__unsafe_unretained Class cls, NSObject *instance, NSMutableArray <XDHIvar *> * arrayOfIvars, IvarINFO *info) {
    if (!cls) {
        return;
    }
    Class superCls = class_getSuperclass(cls);
    IvarsOfClass(superCls, instance, arrayOfIvars, info);
    
    uint32_t count = 0;
    Ivar *firstIvar = class_copyIvarList(cls, &count);
    for (uint32_t i = 0; i < count; ++i) {
        Ivar ivar = firstIvar[i];
        XDHIvar *currentIvar = [XDHIvar IvarWithIvar:ivar];
        
        if (info) {
            info->maxLengthOfName = MAX(info->maxLengthOfName, currentIvar.name.length);
            info->maxLengthOfTypeName = MAX(info->maxLengthOfTypeName, currentIvar.typeName.length);
            info->maxLengthOfTypeEncoding = MAX(info->maxLengthOfTypeEncoding, strlen(currentIvar.typeEncoding));
        }
        
        XDHIvar *lastIvar = arrayOfIvars.lastObject;
        if (lastIvar) {
            lastIvar.size = currentIvar.offset - lastIvar.offset;
            if (lastIvar.size > sizeof(void *)) {
                void *value = calloc(1, lastIvar.size);
                memcpy(value, (__bridge void *)instance + lastIvar.offset, lastIvar.size);
                lastIvar.value = [NSValue value:value withObjCType:lastIvar.typeEncoding];
                free(value);
            }
            else {
                void *value = NULL;
                memcpy(&value, (__bridge void *)instance + lastIvar.offset, lastIvar.size);
                // ???: bit field will return nil
                lastIvar.value = [NSValue valueWithBytes:&value objCType:lastIvar.typeEncoding];
            }
        }
        
        [arrayOfIvars addObject:currentIvar];
    }
    free(firstIvar);
    
    XDHIvar *lastIvar = arrayOfIvars.lastObject;
    if (lastIvar) {
        lastIvar.size = class_getInstanceSize(cls) - lastIvar.offset;
        if (lastIvar.size > 8) {
            void *value = calloc(1, lastIvar.size);
            memcpy(value, (__bridge void *)instance + lastIvar.offset, lastIvar.size);
            lastIvar.value = [NSValue value:value withObjCType:lastIvar.typeEncoding];
            free(value);
        }
        else {
            void *value = NULL;
            memcpy(&value, (__bridge void *)instance + lastIvar.offset, lastIvar.size);
            lastIvar.value = [NSValue value:&value withObjCType:lastIvar.typeEncoding];
        }
    }
}

static NSArray <XDHIvar *> * IvarsOfObject(NSObject *instance, IvarINFO *info)
{
    Class objectClass = [instance class];
    NSMutableArray <XDHIvar *> *array = [NSMutableArray arrayWithCapacity:class_getInstanceSize(objectClass) / sizeof(void *)];
    IvarsOfClass(objectClass, instance, array, info);
    return [array copy];
}

static void PropertyOfClass(__unsafe_unretained Class cls, NSObject *instance, NSMutableArray <XDHProperty *> * arrayOfIvars, IvarINFO *info) {
    if (!cls) {
        return;
    }
    Class superCls = class_getSuperclass(cls);
    PropertyOfClass(superCls, instance, arrayOfIvars, info);
    
    uint32_t count = 0;
    objc_property_t *firstProp = class_copyPropertyList(cls, &count);
    for (uint32_t i = 0; i < count; ++i) {
        objc_property_t prop = firstProp[i];
        XDHProperty *property = [XDHProperty PropertyWithProperty:prop];
        if (![property.typeName isEqualToString:@"void *"]) {
            id value = nil;
            @try {
                value = [instance valueForKey:property.name];
            } @catch (NSException *exception) {
                if (property.getter) {
                    __unsafe_unretained id result = [instance performSelector:property.getter withObject:nil];
                    value = [NSValue value:&result withObjCType:property.typeEncoding];
                }
                else {
                    value = nil;
                }
            } @finally {
                if ([value isKindOfClass:[NSValue class]]) {
                    property.value = value;
                }
                else {
                    property.value = [NSValue valueWithNonretainedObject:value];
                }
            }
        }
        
        if (info) {
            info->maxLengthOfName = MAX(info->maxLengthOfName, property.name.length);
            info->maxLengthOfTypeName = MAX(info->maxLengthOfTypeName, property.typeName.length);
        }

        [arrayOfIvars addObject:property];
    }
    free(firstProp);
}

static NSArray <XDHProperty *> * PropertyOfObject(NSObject *instance, IvarINFO *info)
{
    Class objectClass = [instance class];
    NSMutableArray <XDHProperty *> *array = [NSMutableArray arrayWithCapacity:class_getInstanceSize(objectClass) / sizeof(void *)];
    PropertyOfClass(objectClass, instance, array, info);
    return [array copy];
}

@implementation NSObject (XDebugHelper)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method m1 = class_getInstanceMethod(self, @selector(xdh_debugQuickLookObject));
        if (class_addMethod(self, @selector(debugQuickLookObject), _objc_msgForward, method_getTypeEncoding(m1))) {
            Method m0 = class_getInstanceMethod(self, @selector(debugQuickLookObject));
            method_exchangeImplementations(m0, m1);
        }
    });
}

- (NSString *)ivarDump
{
    IvarINFO info = {0};
    NSArray <XDHIvar *> *ivars = IvarsOfObject(self, &info);
    NSString *formatingString = [NSString stringWithFormat:@"%%%lus %%%lus = %%@", info.maxLengthOfTypeName + 1, info.maxLengthOfName + 1];
    NSMutableArray *strings = [NSMutableArray arrayWithCapacity:ivars.count + 1];
    [strings addObject:@""];
    for (XDHIvar *ivar in ivars) {
        [strings addObject:[NSString stringWithFormat:formatingString, ivar.typeName.UTF8String, ivar.name.UTF8String, ivar.value.xdh_stringRepresentation]];
    }
    NSLog(@"%@", [strings componentsJoinedByString:@"\n"]);
}

- (NSString *)propertyDump
{
    IvarINFO info = {0};
    NSArray <XDHProperty *> *properties = PropertyOfObject(self, &info);
    NSString *formatingString = [NSString stringWithFormat:@"%%%lus %%%lus = %%@", info.maxLengthOfTypeName + 1, info.maxLengthOfName + 1];
    NSMutableArray *strings = [NSMutableArray arrayWithCapacity:properties.count + 1];
    [strings addObject:@""];
    for (XDHProperty *property in properties) {
        [strings addObject:[NSString stringWithFormat:formatingString, property.typeName.UTF8String, property.name.UTF8String, property.value.xdh_stringRepresentation]];
    }
    NSLog(@"%@", [strings componentsJoinedByString:@"\n"]);
}

- (id)xdh_debugQuickLookObject
{
    id object = [self xdh_debugQuickLookObject];
    if (object) {
        return object;
    }
    
    IvarINFO info = {0};
    NSArray <XDHIvar *> *ivars = IvarsOfObject(self, &info);
    NSString *formatingString = [NSString stringWithFormat:@"%%%lus %%%lus = %%@", info.maxLengthOfTypeName + 1, info.maxLengthOfName + 1];
    NSMutableArray *strings = [NSMutableArray arrayWithCapacity:ivars.count];
    for (XDHIvar *ivar in ivars) {
        [strings addObject:[NSString stringWithFormat:formatingString, ivar.typeName.UTF8String, ivar.name.UTF8String, ivar.value.xdh_stringRepresentation]];
    }
    return [[NSAttributedString alloc] initWithString:[strings componentsJoinedByString:@"\n"]
                                           attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Courier" size:12],
                                                        NSForegroundColorAttributeName: [UIColor darkTextColor],
                                                        }];
}

@end
