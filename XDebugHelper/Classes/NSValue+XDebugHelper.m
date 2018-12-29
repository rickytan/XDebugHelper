//
//  NSValue+XDebugHelper.m
//  XDebugHelper
//
//  Created by Ricky on 2018/12/29.
//

#import "NSValue+XDebugHelper.h"

@implementation NSValue (XDebugHelper)

- (NSString *)xdh_stringRepresentation
{
    const char *type = self.objCType;
    switch (type[0]) {
        case '#':
        {
            __unsafe_unretained Class value = Nil;
            [self getValue:&value];
            return NSStringFromClass(value);
        }
            break;
        case '@':
        {
            __unsafe_unretained id value = nil;
            [self getValue:&value];
            return [NSString stringWithFormat:@"%@", value ?: @"nil"];
        }
            break;
        case 'b':
        {
            void *value = NULL;
            [self getValue:&value];
            return [NSString stringWithFormat:@"%p", value];
        }
            break;
        case 'B':
        {
            BOOL value = NO;
            [self getValue:&value];
            return value ? @"YES" : @"NO";
        }
            break;
        case 'c':
        {
            char value = 0;
            [self getValue:&value];
            return [NSString stringWithFormat:@"%c", value];
        }
            break;
        case 'C':
        {
            uint8_t value = 0;
            [self getValue:&value];
            return [NSString stringWithFormat:@"%0x", value];
        }
            break;
        case 's':
        case 'i':
        case 'q':
        {
            int64_t value = 0;
            [self getValue:&value];
            return [NSString stringWithFormat:@"%lld", value];
        }
            break;
        case 'S':
        case 'I':
        case 'Q':
        {
            uint64_t value = 0;
            [self getValue:&value];
            return [NSString stringWithFormat:@"%llu", value];
        }
            break;
        case 'f':
        {
            float value = 0;
            [self getValue:&value];
            return [NSString stringWithFormat:@"%f", value];
        }
            break;
        case 'd':
        {
            double value = 0;
            [self getValue:&value];
            return [NSString stringWithFormat:@"%lf", value];
        }
            break;
        case '*':
        {
            void *value = NULL;
            [self getValue:&value];
            return [NSString stringWithFormat:@"%p", value];
        }
            break;
        case '{':
        {
            char *pos = strchr(type, '=');
            if (!pos) {
                return @"{}";
            }
            size_t size = pos - type;
            if (strncmp(type, @encode(UIEdgeInsets), size) == 0) {
                UIEdgeInsets value = {0};
                [self getValue:&value];
                return NSStringFromUIEdgeInsets(value);
            } else if (strncmp(type, @encode(CGRect), size) == 0) {
                CGRect value = {0};
                [self getValue:&value];
                return NSStringFromCGRect(value);
            } else if (strncmp(type, @encode(CGSize), size) == 0) {
                CGSize value = {0};
                [self getValue:&value];
                return NSStringFromCGSize(value);
            } else if (strncmp(type, @encode(CGPoint), size) == 0) {
                CGPoint value = {0};
                [self getValue:&value];
                return NSStringFromCGPoint(value);
            } else if (strncmp(type, @encode(CGVector), size) == 0) {
                CGVector value = {0};
                [self getValue:&value];
                return NSStringFromCGVector(value);
            } else if (strncmp(type, @encode(NSRange), size) == 0) {
                NSRange value = {0};
                [self getValue:&value];
                return NSStringFromRange(value);
            } else {
                return @"{}";
            }
        }
            break;
        default:
            break;
    }
    return nil;
}

@end
