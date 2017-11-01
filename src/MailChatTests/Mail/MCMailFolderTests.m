//
//  MCMailFolderTests.m
//  NPushMail
//
//  Created by admin on 2/3/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCMailManager.h"
#import "MCLoginManager.h"

@interface MCMailFolderTests : XCTestCase

@end

@implementation MCMailFolderTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [self test35Login];
    
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
        
        AppStatus.currentUser = response;
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

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
