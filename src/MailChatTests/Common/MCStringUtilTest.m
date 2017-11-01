//
//  MCStringUtilTest.m
//  NPushMail
//
//  Created by admin on 4/6/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+Extension.h"

@interface MCStringUtilTest : XCTestCase

@end

@implementation MCStringUtilTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTrim {
    NSString *str = @"  I am the one  ";
    NSString *trimedStr = [str trim];
    BOOL isEqual = [trimedStr isEqualToString:@"I am the one"];
    XCTAssertTrue(isEqual,@"Trim string error");
}

- (void)testIsPureInt
{
    NSString *intStr = @"10023";
    XCTAssertTrue([intStr isPureInt]);
}

- (void)testIsNotPureInt
{
    NSString *intStr = @"abc123";
    BOOL isPureInt = [intStr isPureInt];
    XCTAssertFalse(isPureInt);
}

@end
