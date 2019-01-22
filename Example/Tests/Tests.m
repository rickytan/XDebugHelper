//
//  XDebugHelperTests.m
//  XDebugHelperTests
//
//  Created by rickytan on 12/28/2018.
//  Copyright (c) 2018 rickytan. All rights reserved.
//

#import <XDebugHelper/XDebugHelper.h>
@import XCTest;
@import UIKit;

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    UIView *view = [UIView new];
    [view ivarDump];
}

@end

