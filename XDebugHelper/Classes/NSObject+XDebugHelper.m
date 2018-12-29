//
//  NSObject+XDebugHelper.m
//  XDebugHelper
//
//  Created by Ricky on 2018/12/28.
//

#import <objc/runtime.h>
#import "NSObject+XDebugHelper.h"
#import "NSValue+XDebugHelper.h"
#import "XDHIvar.h"

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

@implementation NSObject (XDebugHelper)

- (id)debugQuickLookObject
{
    IvarINFO info = {0};
    NSArray <XDHIvar *> *ivars = IvarsOfObject(self, &info);
    NSString *formatingString = [NSString stringWithFormat:@"%%%ds %%%ds = %%@", info.maxLengthOfTypeName + 1, info.maxLengthOfName + 1];
    NSMutableArray *strings = [NSMutableArray arrayWithCapacity:ivars.count];
    for (XDHIvar *ivar in ivars) {
        [strings addObject:[NSString stringWithFormat:formatingString, ivar.typeName.UTF8String, ivar.name.UTF8String, ivar.value.xdh_stringRepresentation]];
    }
    return [[NSAttributedString alloc] initWithString:[strings componentsJoinedByString:@"\n"]
                                           attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Countier" size:12],
                                                        NSForegroundColorAttributeName: [UIColor darkTextColor],
                                                        }];
}

@end
