//
//  XDebugHelper.m
//  XDebugHelper
//
//  Created by Ricky on 2019/1/22.
//

#import "XDebugHelper.h"

NSString *XDHTypeNameFromTypeEncoding(const char *typeEncoding) {
    NSString *typeName = nil;
    size_t length = strlen(typeEncoding);
    switch (typeEncoding[0]) {
        case '#':
            typeName = @"Class";
            break;
        case '@':
        {
            if (length > 3 && typeEncoding[1] == '"' && typeEncoding[length - 1] == '"') {
                if (length > 5 && typeEncoding[2] == '<' && typeEncoding[length - 2] == '>') {
                    typeName = [NSString stringWithFormat:@"id%@", [[NSString alloc] initWithBytes:typeEncoding + 2
                                                                                            length:length - 3
                                                                                          encoding:NSASCIIStringEncoding]];
                    typeName = [typeName stringByReplacingOccurrencesOfString:@"><" withString:@", "];
                }
                else {
                    typeName = [NSString stringWithFormat:@"%@ *", [[NSString alloc] initWithBytes:typeEncoding + 2
                                                                                            length:length - 3
                                                                                          encoding:NSASCIIStringEncoding]];
                }
            }
            else {
                typeName = @"id";
            }
        }
            break;
        case 'v':
            typeName = @"void";
            break;
        case 'b':
            typeName = [NSString stringWithFormat:@"int:%s", typeEncoding + 1];
            break;
        case 'B':
            typeName = @"BOOL";
            break;
        case 'c':
            typeName = @"char";
            break;
        case 'C':
            typeName = @"byte";
            break;
        case 's':
            typeName = @"int16_t";
            break;
        case 'S':
            typeName = @"uint16_t";
            break;
        case 'i':
#if __LP64__
            typeName = @"int32_t";
#else
            typeName = @"NSInteger";
#endif
            break;
        case 'I':
#if __LP64__
            typeName = @"uint32_t";
#else
            typeName = @"NSUInteger";
#endif
            break;
        case 'q':
#if __LP64__
            typeName = @"NSInteger";
#else
            typeName = @"int64_t";
#endif
            break;
        case 'Q':
#if __LP64__
            typeName = @"NSUInteger";
#else
            typeName = @"uint64_t";
#endif
            break;
        case 'f':
#if CGFLOAT_IS_DOUBLE
            typeName = @"float";
#else
            typeName = @"CGFloat";
#endif
            break;
        case 'd':
#if CGFLOAT_IS_DOUBLE
            typeName = @"CGFloat";
#else
            typeName = @"double";
#endif
            break;
        case ':':
            typeName = @"SEL";
            break;
        case '^':
            typeName = [XDHTypeNameFromTypeEncoding(typeEncoding + 1) stringByAppendingString:@" *"];
            break;
        case '*':
            typeName = @"char *";
            break;
        case '{':
        {
            if (length > 1) {
                if (typeEncoding[1] == '?') {
                    typeName = @"(Anonymous struct)";
                }
                else {
                    char *pos = strchr(typeEncoding, '=');
                    if (pos) {
                        typeName = [[NSString alloc] initWithBytes:typeEncoding + 1
                                                            length:pos - typeEncoding - 1
                                                          encoding:NSASCIIStringEncoding];
                    }
                    else {
                        typeName = @"struct";
                    }
                }
            }
            else {
                typeName = @"struct";
            }
        }
            break;
        case '?':
            typeName = @"function";
            break;
        default:
            typeName = @"id";
            break;
    }
    
    return typeName;
}
