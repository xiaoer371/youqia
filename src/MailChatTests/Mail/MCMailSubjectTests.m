//
//  MCMailSubjectTests.m
//  NPushMail
//
//  Created by admin on 24/11/2016.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCMailSubject.h"

@interface MCMailSubjectTests : XCTestCase

@end

@implementation MCMailSubjectTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testParseReplySubject {
    
    NSString *subjectStr = @"Re:回复:转发: 明天会更好";
    MCMailSubject *subject = [[MCMailSubject alloc] initWithSubject:subjectStr];

    XCTAssertTrue(subject.isReply,@"Reply check error");
    XCTAssert([subject.realSubject isEqualToString:@" 明天会更好"], @"Parse subject error");
}

- (void)testSubjectWithSplitCharacter
{
    NSString *subjectStr = @"Re: 回复 :转发 : 明天[: ]会更好";
    MCMailSubject *subject = [[MCMailSubject alloc] initWithSubject:subjectStr];
    XCTAssert([subject.realSubject isEqualToString:@" 明天[: ]会更好"], @"Parse subject with split character error");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
