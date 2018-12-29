//
//  NSValue+XDebugHelper.h
//  XDebugHelper
//
//  Created by Ricky on 2018/12/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSValue (XDebugHelper)
@property (nonatomic, readonly, copy, nullable) NSString *xdh_stringRepresentation;
@end

NS_ASSUME_NONNULL_END
