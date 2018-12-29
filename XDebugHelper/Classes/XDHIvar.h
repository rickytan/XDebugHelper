//
//  XDHIvar.h
//  XDebugHelper
//
//  Created by Ricky on 2018/12/28.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface XDHIvar : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, readonly, strong) NSString *typeName;
@property (nonatomic, assign) size_t offset;
@property (nonatomic, assign) size_t size;
@property (nonatomic, assign) const char *typeEncoding;
@property (nonatomic, strong) NSValue *value;

+ (instancetype)IvarWithIvar:(Ivar)ivar;
@end

NS_ASSUME_NONNULL_END
