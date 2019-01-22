//
//  XDHIvar.m
//  XDebugHelper
//
//  Created by Ricky on 2018/12/28.
//

#import "XDebugHelper.h"
#import "XDHIvar.h"

@implementation XDHIvar
@synthesize typeName = _typeName;

+ (instancetype)IvarWithIvar:(Ivar)ivar
{
    XDHIvar *object = [self new];
    object.name = [NSString stringWithUTF8String:ivar_getName(ivar)];
    object.offset = ivar_getOffset(ivar);
    object.typeEncoding = ivar_getTypeEncoding(ivar);
    return object;
}

- (NSString *)typeName
{
    if (!_typeName) {
        _typeName = XDHTypeNameFromTypeEncoding(_typeEncoding);
    }
    
    return _typeName;
}

- (size_t)size
{
    if (_size == 0) {
        if (_typeEncoding[0] != 'b') {
            NSUInteger size, align;
            NSGetSizeAndAlignment(_typeEncoding, &size, &align);
            _size = size;
        }
        else {
            _size = 1;
        }
    }
    return _size;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p name=%@, offset=%lu, size=%lu, typeName=%@, encoding=%s>", NSStringFromClass(self.class), self, self.name, self.offset, self.size, self.typeName, self.typeEncoding];
}

@end
