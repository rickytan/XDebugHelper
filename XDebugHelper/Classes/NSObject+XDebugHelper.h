//
//  NSObject+XDebugHelper.h
//  XDebugHelper
//
//  Created by Ricky on 2018/12/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (XDebugHelper)
- (void)ivarDump;
- (void)propertyDump;
@end

NS_ASSUME_NONNULL_END
