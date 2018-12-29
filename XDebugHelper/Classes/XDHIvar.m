//
//  XDHIvar.m
//  XDebugHelper
//
//  Created by Ricky on 2018/12/28.
//

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
    if (_typeName) {
        return _typeName;
    }
    
    size_t length = strlen(_typeEncoding);
    switch (_typeEncoding[0]) {
        case '#':
            _typeName = @"Class";
            break;
        case '@':
        {
            if (length > 3 &&_typeEncoding[1] == '"' && _typeEncoding[length - 1] == '"') {
                if (length > 5 && _typeEncoding[2] == '<' && _typeEncoding[length - 2] == '>') {
                    _typeName = [NSString stringWithFormat:@"id%@", [[NSString alloc] initWithBytes:_typeEncoding + 2
                                                                                             length:length - 3
                                                                                           encoding:NSASCIIStringEncoding]];
                }
                else {
                    _typeName = [NSString stringWithFormat:@"%@ *", [[NSString alloc] initWithBytes:_typeEncoding + 2
                                                                                             length:length - 3
                                                                                           encoding:NSASCIIStringEncoding]];
                }
            }
            else {
                _typeName = @"id";
            }
        }
            break;
        case 'b':
            _typeName = [NSString stringWithFormat:@"int:%s", _typeEncoding + 1];
            break;
        case 'B':
            _typeName = @"BOOL";
            break;
        case 'c':
            _typeName = @"char";
            break;
        case 'C':
            _typeName = @"byte";
            break;
        case 's':
            _typeName = @"int16_t";
            break;
        case 'S':
            _typeName = @"uint16_t";
            break;
        case 'i':
#if __LP64__
            _typeName = @"int32_t";
#else
            _typeName = @"NSInteger";
#endif
            break;
        case 'I':
#if __LP64__
            _typeName = @"uint32_t";
#else
            _typeName = @"NSUInteger";
#endif
            break;
        case 'q':
#if __LP64__
            _typeName = @"NSInteger";
#else
            _typeName = @"int64_t";
#endif
            break;
        case 'Q':
#if __LP64__
            _typeName = @"NSUInteger";
#else
            _typeName = @"uint64_t";
#endif
            break;
        case 'f':
#if CGFLOAT_IS_DOUBLE
            _typeName = @"float";
#else
            _typeName = @"CGFloat";
#endif
            break;
        case 'd':
#if CGFLOAT_IS_DOUBLE
            _typeName = @"CGFloat";
#else
            _typeName = @"double";
#endif
            break;
        case '*':
            _typeName = @"void *";
            break;
        case '{':
        {
            if (length > 1) {
                if (_typeEncoding[1] == '?') {
                    _typeName = @"(Anonymous struct)";
                }
                else {
                    char *pos = strchr(_typeEncoding, '=');
                    if (pos) {
                        _typeName = [[NSString alloc] initWithBytes:_typeEncoding + 1
                                                             length:pos - _typeEncoding - 1
                                                           encoding:NSASCIIStringEncoding];
                    }
                    else {
                        _typeName = @"struct";
                    }
                }
            }
            else {
                _typeName = @"struct";
            }
        }
            break;
        default:
            _typeName = @"id";
            break;
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
