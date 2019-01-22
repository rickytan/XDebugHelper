//
//  XDHProperty.h
//  XDebugHelper
//
//  Created by Ricky on 2019/1/22.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface XDHProperty : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *attributes;
@property (nonatomic, copy) NSString *typeName;
@property (nonatomic, assign) const char *typeEncoding;
@property (nonatomic, assign) SEL getter;
@property (nonatomic, strong) NSValue *value;

+ (instancetype)PropertyWithProperty:(objc_property_t)property;
@end

NS_ASSUME_NONNULL_END
