//
//  XDHProperty.m
//  XDebugHelper
//
//  Created by Ricky on 2019/1/22.
//

#import "XDebugHelper.h"
#import "XDHProperty.h"

@implementation XDHProperty

+ (instancetype)PropertyWithProperty:(objc_property_t)property
{
    XDHProperty *object = [self new];
    object.name = [NSString stringWithUTF8String:property_getName(property)];
    object.attributes = [NSString stringWithUTF8String:property_getAttributes(property)];
    
    uint32_t count = 0;
    objc_property_attribute_t *attributes = property_copyAttributeList(property, &count);
    for (uint32_t i = 0; i < count; ++ i) {
        objc_property_attribute_t attr = attributes[i];
        switch (attr.name[0]) {
            case 'T':
            {
                object.typeEncoding = strdup(attr.value);
                object.typeName = XDHTypeNameFromTypeEncoding(attr.value);
            }
                break;
            case 'G':
                object.getter = sel_registerName(attr.value);
                break;
            case 'N':
            case 'R':
            case 'S':
            case 'D':
            case '&':
                break;
            default:
                break;
        }
    }
    free(attributes);
    return object;
}

- (void)dealloc
{
    free(self.typeEncoding);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p name=%@, attributes=%@, typeName=%@>", NSStringFromClass(self.class), self, self.name, self.attributes, self.typeName];
}

@end
