//
//  MCLoginTest.m
//  NPushMail
//
//  Created by admin on 2/3/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCLoginManager.h"

@interface MCLoginTest : XCTestCase

@end

@implementation MCLoginTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test35Login
{
    XCTestExpectation *expection = [self expectationWithDescription:@"Login"];
    MCLoginManager *loginManager = [MCLoginManager new];
    [loginManager loginWithUserName:@"gaoyq@35.cn" password:@"Yongqing@35.cn" success:^(id response) {
        XCTAssertNotNil(response);
        [expection fulfill];
    } failure:^(NSError *error) {
        XCTFail(@"%@",error);
        [expection fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if (error) {
            DDLogError(@"ERROR:%@",error);
        }
    }];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
