//
//  MCApnsPushTest.m
//  NPushMail
//
//  Created by wuwenyu on 16/9/13.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MCServerAPI+APNS.h"
#import "MCServerAPI+Account.h"
#import "MCServerAPI+testAccoount.h"
#import "NSDate+Category.h"
#import "MCUDID.h"
#import "MCTool.h"

@interface MCApnsPushTest : XCTestCase

@end

static NSString *userName = @"57bffec2fa0d1aa5ef8b0ef8";
static NSString *token = @"05a5bf8b17e00df93b94c27358b8bb380b14f2a6eed5a91aeedde83e49354393";
static NSString *cid = @"67DC607E-3967-463E-9B7B-812393212F2D";
static const int msgPushFlag = 1;
static const int mailPushFlag = 1;
static const int oaPushFlag = 1;
static const int detailPushFlag = 1;
static const int debugFlag = 1;

@implementation MCApnsPushTest {
    NSString *_clientId;
    NSString *_password;
}

- (void)setUp {
    [super setUp];
    _clientId = [MCUDID newUUID];
    _password = [MCUDID newUUID];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//测试添加用户
- (void)testAddUser {
    XCTestExpectation *expection = [self expectationWithDescription:@"addUser"];
    NSString *deviceName = [[UIDevice currentDevice] name];

    _password = @"2A3F9FC3-830A-4978-8D1C-3D5C77CDCF23";
    _clientId = @"6965877E-CB15-4311-A3BD-7FF0ABFC357B";
    
    /*
    [ServerAPI authenticateNewUser:userName password:_password clientId:_clientId deviceName:deviceName apnsToken:token success:^(id response) {
        XCTAssertNotNil(response, @"错误:返回值为空");
        MCUserInfo *user = (MCUserInfo *)response;
        DDLogInfo(@"成功添加用户:%@", user.userId);
        [expection fulfill];
    } failure:^(NSError *error) {
        XCTFail(@"%@",error);
        [expection fulfill];
    }];
     */
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        if (error) {
            DDLogError(@"ERROR:%@",error);
        }
    }];
}

//更新用户的token
- (void)testUpdateUserToken {
    XCTestExpectation *expection = [self expectationWithDescription:@"updateUserToken"];
    [ServerAPI updateAPNSToken:token withClientId:_clientId success:^{
        [expection fulfill];
    } failure:^(NSError *error) {
        XCTFail(@"%@",error);
        [expection fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        if (error) {
            DDLogError(@"ERROR:%@",error);
        }
    }];
}

//添加正确的邮箱到用户
- (void)testAddRightMailToUser {
    XCTestExpectation *expection = [self expectationWithDescription:@"updateUserToken"];
    NSString *email = @"wuwy@35.cn";
    NSString *pwd = @"wwy7456911";
    
    _password = @"2A3F9FC3-830A-4978-8D1C-3D5C77CDCF23";

    [ServerAPI addMailToUser:userName pwd:_password email:email withPassword:pwd shouldValidate:NO success:^(id response) {
        XCTAssertNotNil(response, @"错误:返回值为空");
        [expection fulfill];
    } failure:^(NSError *error) {
        XCTFail(@"%@",error);
        [expection fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        if (error) {
            DDLogError(@"ERROR:%@",error);
        }
    }];
}

//添加错误的邮箱到用户
- (void)testWrongMailToUser {
    XCTestExpectation *expection = [self expectationWithDescription:@"updateUserToken"];
    NSString *email = @"wuwy111@35.cn";
    NSString *pwd = @"1111";
    
    [ServerAPI addMailToUser:email withPassword:pwd authCode:nil shouldValidate:NO success:^(id response) {
        XCTAssertNotNil(response, @"错误:返回值为空");
        [expection fulfill];
    } failure:^(NSError *error) {
        XCTFail(@"%@",error);
        [expection fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        if (error) {
            DDLogError(@"ERROR:%@",error);
        }
    }];
}

//删除用户绑定的一个邮箱
- (void)deleteMail {
    XCTestExpectation *expection = [self expectationWithDescription:@"updateUserToken"];
    NSString *email = @"wuwy@35.cn";
    [ServerAPI deleteMail:email success:^{
        DDLogInfo(@"成功删除邮箱%@", email);
        [expection fulfill];
    } failure:^(NSError *error) {
        XCTFail(@"%@",error);
        [expection fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        if (error) {
            DDLogError(@"ERROR:%@",error);
        }
    }];
}

//获取用户的相关信息（包含绑定的邮箱，设备，token等等。）
- (void)testGetUserInfo {
    XCTestExpectation *expection = [self expectationWithDescription:@"getUserInfo"];
    _clientId = @"6965877E-CB15-4311-A3BD-7FF0ABFC357B";
    [ServerAPI getUserInfoUser:@"" deviceId:userName success:^(id response) {
        XCTAssertNotNil(response, @"错误:返回值为空");
        int result = [[response objectForKey:@"result"] intValue];
        XCTAssertTrue(result, @"获取用户信息不正确");
        
        //apns 和对应的频道信息
        NSDictionary *apnsInfo = [response objectForKey:@"apns"];
        XCTAssertNotNil(apnsInfo, @"apns为空");
        NSString *apns = [apnsInfo.allKeys firstObject];
        NSArray *apnsTopics = [apnsInfo.allValues firstObject];
        
        //绑定的设备信息
        NSArray *devices = [response objectForKey:@"devices"];
        XCTAssertNotNil(devices, @"devices为空");
        
        //绑定的邮箱
        NSArray *emails = [response objectForKey:@"emails"];
        XCTAssertNotNil(devices, @"该用户暂未绑定邮箱");
        
        //用户的相关信息
        NSDictionary *userInfo = [response objectForKey:@"user"];
        int64_t create_date = [[userInfo objectForKey:@"create_date"] intValue];
        NSDate *createDate = [[MCTool shared] getDateFromTimeSeconds:create_date];
        NSString *createDateStr = [createDate minuteDescription];
        
        NSString *passwd = [userInfo objectForKey:@"passwd"];
        NSString *reg_date = [userInfo objectForKey:@"reg_date"];
        
        NSString *userId = [userInfo objectForKey:@"_id"];
        NSString *user_name = [userInfo objectForKey:@"user_name"];
        NSString *device_id = [userInfo objectForKey:@"device_id"];
        
        NSLog(@"apns:%@", apns);
        NSLog(@"apnsTopics:%@", apnsTopics);
        NSLog(@"devices:%@", devices);
        NSLog(@"emails:%@", emails);
        NSLog(@"createDate:%@", createDateStr);
        NSLog(@"passwd:%@", passwd);
        NSLog(@"reg_date:%@", reg_date);
        NSLog(@"userId:%@", userId);
        NSLog(@"user_name:%@", user_name);
        NSLog(@"device_id:%@", device_id);
        [expection fulfill];
    } failure:^(NSError *error) {
        XCTFail(@"%@",error);
        [expection fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        if (error) {
            DDLogError(@"ERROR:%@",error);
        }
    }];
}

- (void)testApnsOn {
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    BOOL identifierEqual = [identifier isEqualToString:@"com.c35.ptc.pushmail"];
    XCTAssert(identifierEqual, @"identifier不正确, 不能开启推送");
    XCTestExpectation *expection = [self expectationWithDescription:@"apnsPushOn"];
    NSMutableDictionary *params = [ServerAPI authParameters];
    params[@"to"] = token;
    params[@"cid"] = cid;
    params[@"ver"] = [self getVerInfo];
    params[@"pt"] = [NSString stringWithFormat:@"%d10101", detailPushFlag];
    params[@"debug"] = @(debugFlag);
    params[@"badge"] = @(0);
    params[@"m"] = @(mailPushFlag);
    params[@"g"] = @(msgPushFlag);
    params[@"a"] = @(oaPushFlag);
    [ServerAPI pushOnApnsWithDic:params success:^(id response) {
        XCTAssertNotNil(response);
        [expection fulfill];
    } failrue:^(NSError *error) {
        XCTFail(@"%@",error);
        [expection fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        if (error) {
            DDLogError(@"ERROR:%@",error);
        }
    }];

}

//测试消息推送开启
- (void)testApnsMsgOn {
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    BOOL identifierEqual = [identifier isEqualToString:@"com.c35.ptc.pushmail"];
    XCTAssert(identifierEqual, @"identifier不正确, 不能开启推送");
    XCTestExpectation *expection = [self expectationWithDescription:@"apnsPushOn"];
    NSMutableDictionary *params = [ServerAPI authParameters];
    params[@"to"] = token;
    params[@"cid"] = cid;
    params[@"ver"] = [self getVerInfo];
    params[@"pt"] = [NSString stringWithFormat:@"%d10101", detailPushFlag];
    params[@"debug"] = @(debugFlag);
    params[@"badge"] = @(0);
    params[@"m"] = @(mailPushFlag);
    params[@"g"] = @(1);
    params[@"a"] = @(oaPushFlag);
    [ServerAPI pushOnApnsWithDic:params success:^(id response) {
        XCTAssertNotNil(response);
        [expection fulfill];
    } failrue:^(NSError *error) {
        XCTFail(@"%@",error);
        [expection fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        if (error) {
            DDLogError(@"ERROR:%@",error);
        }
    }];
}

//测试消息推送关闭
- (void)testApnsMsgOff {
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    BOOL identifierEqual = [identifier isEqualToString:@"com.c35.ptc.pushmail"];
    XCTAssert(identifierEqual, @"identifier不正确, 不能开启推送");
    XCTestExpectation *expection = [self expectationWithDescription:@"apnsPushOn"];
    NSMutableDictionary *params = [ServerAPI authParameters];
    params[@"to"] = token;
    params[@"cid"] = cid;
    params[@"ver"] = [self getVerInfo];
    params[@"pt"] = [NSString stringWithFormat:@"%d10101", detailPushFlag];
    params[@"debug"] = @(debugFlag);
    params[@"badge"] = @(0);
    params[@"m"] = @(mailPushFlag);
    params[@"g"] = @(0);
    params[@"a"] = @(oaPushFlag);
    [ServerAPI pushOnApnsWithDic:params success:^(id response) {
        XCTAssertNotNil(response);
        [expection fulfill];
    } failrue:^(NSError *error) {
        XCTFail(@"%@",error);
        [expection fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        if (error) {
            DDLogError(@"ERROR:%@",error);
        }
    }];
}

//测试邮件推送开启
- (void)testMailPushOn {
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    BOOL identifierEqual = [identifier isEqualToString:@"com.c35.ptc.pushmail"];
    XCTAssert(identifierEqual, @"identifier不正确, 不能开启推送");
    XCTestExpectation *expection = [self expectationWithDescription:@"apnsPushOn"];
    NSMutableDictionary *params = [ServerAPI authParameters];
    params[@"to"] = token;
    params[@"cid"] = cid;
    params[@"ver"] = [self getVerInfo];
    params[@"pt"] = [NSString stringWithFormat:@"%d10101", detailPushFlag];
    params[@"debug"] = @(debugFlag);
    params[@"badge"] = @(0);
    params[@"m"] = @(1);
    params[@"g"] = @(msgPushFlag);
    params[@"a"] = @(oaPushFlag);
    [ServerAPI pushOnApnsWithDic:params success:^(id response) {
        XCTAssertNotNil(response);
        [expection fulfill];
    } failrue:^(NSError *error) {
        XCTFail(@"%@",error);
        [expection fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        if (error) {
            DDLogError(@"ERROR:%@",error);
        }
    }];
}

//测试邮件推送关闭
- (void)testMailPushOff {
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    BOOL identifierEqual = [identifier isEqualToString:@"com.c35.ptc.pushmail"];
    XCTAssert(identifierEqual, @"identifier不正确, 不能开启推送");
    XCTestExpectation *expection = [self expectationWithDescription:@"apnsPushOn"];
    NSMutableDictionary *params = [ServerAPI authParameters];
    params[@"to"] = token;
    params[@"cid"] = cid;
    params[@"ver"] = [self getVerInfo];
    params[@"pt"] = [NSString stringWithFormat:@"%d10101", detailPushFlag];
    params[@"debug"] = @(debugFlag);
    params[@"badge"] = @(0);
    params[@"m"] = @(0);
    params[@"g"] = @(msgPushFlag);
    params[@"a"] = @(oaPushFlag);
    [ServerAPI pushOnApnsWithDic:params success:^(id response) {
        XCTAssertNotNil(response);
        [expection fulfill];
    } failrue:^(NSError *error) {
        XCTFail(@"%@",error);
        [expection fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        if (error) {
            DDLogError(@"ERROR:%@",error);
        }
    }];
}

//测试OA推送开启
- (void)testOaPushOn {
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    BOOL identifierEqual = [identifier isEqualToString:@"com.c35.ptc.pushmail"];
    XCTAssert(identifierEqual, @"identifier不正确, 不能开启推送");
    XCTestExpectation *expection = [self expectationWithDescription:@"apnsPushOn"];
    NSMutableDictionary *params = [ServerAPI authParameters];
    params[@"to"] = token;
    params[@"cid"] = cid;
    params[@"ver"] = [self getVerInfo];
    params[@"pt"] = [NSString stringWithFormat:@"%d10101", detailPushFlag];
    params[@"debug"] = @(debugFlag);
    params[@"badge"] = @(0);
    params[@"m"] = @(mailPushFlag);
    params[@"g"] = @(msgPushFlag);
    params[@"a"] = @(1);
    [ServerAPI pushOnApnsWithDic:params success:^(id response) {
        XCTAssertNotNil(response);
        [expection fulfill];
    } failrue:^(NSError *error) {
        XCTFail(@"%@",error);
        [expection fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        if (error) {
            DDLogError(@"ERROR:%@",error);
        }
    }];
}

//测试OA推送关闭
- (void)testOaPushOff {
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    BOOL identifierEqual = [identifier isEqualToString:@"com.c35.ptc.pushmail"];
    XCTAssert(identifierEqual, @"identifier不正确, 不能开启推送");
    XCTestExpectation *expection = [self expectationWithDescription:@"apnsPushOn"];
    NSMutableDictionary *params = [ServerAPI authParameters];
    params[@"to"] = token;
    params[@"cid"] = cid;
    params[@"ver"] = [self getVerInfo];
    params[@"pt"] = [NSString stringWithFormat:@"%d10101", detailPushFlag];
    params[@"debug"] = @(debugFlag);
    params[@"badge"] = @(0);
    params[@"m"] = @(mailPushFlag);
    params[@"g"] = @(msgPushFlag);
    params[@"a"] = @(0);
    [ServerAPI pushOnApnsWithDic:params success:^(id response) {
        XCTAssertNotNil(response);
        [expection fulfill];
    } failrue:^(NSError *error) {
        XCTFail(@"%@",error);
        [expection fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        if (error) {
            DDLogError(@"ERROR:%@",error);
        }
    }];
}

//测试推送内容详情开启
- (void)testDetailPushOn {
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    BOOL identifierEqual = [identifier isEqualToString:@"com.c35.ptc.pushmail"];
    XCTAssert(identifierEqual, @"identifier不正确, 不能开启推送");
    XCTestExpectation *expection = [self expectationWithDescription:@"apnsPushOn"];
    NSMutableDictionary *params = [ServerAPI authParameters];
    params[@"to"] = token;
    params[@"cid"] = cid;
    params[@"ver"] = [self getVerInfo];
    params[@"pt"] = [NSString stringWithFormat:@"%d10101", 1];
    params[@"debug"] = @(debugFlag);
    params[@"badge"] = @(0);
    params[@"m"] = @(mailPushFlag);
    params[@"g"] = @(msgPushFlag);
    params[@"a"] = @(oaPushFlag);
    [ServerAPI pushOnApnsWithDic:params success:^(id response) {
        XCTAssertNotNil(response);
        [expection fulfill];
    } failrue:^(NSError *error) {
        XCTFail(@"%@",error);
        [expection fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        if (error) {
            DDLogError(@"ERROR:%@",error);
        }
    }];
}

//测试推送内容详情关闭
- (void)testDetailPushOff {
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    BOOL identifierEqual = [identifier isEqualToString:@"com.c35.ptc.pushmail"];
    XCTAssert(identifierEqual, @"identifier不正确, 不能开启推送");
    XCTestExpectation *expection = [self expectationWithDescription:@"apnsPushOn"];
    NSMutableDictionary *params = [ServerAPI authParameters];
    params[@"to"] = token;
    params[@"cid"] = cid;
    params[@"ver"] = [self getVerInfo];
    params[@"pt"] = [NSString stringWithFormat:@"%d10101", 0];
    params[@"debug"] = @(debugFlag);
    params[@"badge"] = @(0);
    params[@"m"] = @(mailPushFlag);
    params[@"g"] = @(msgPushFlag);
    params[@"a"] = @(oaPushFlag);
    [ServerAPI pushOnApnsWithDic:params success:^(id response) {
        XCTAssertNotNil(response);
        [expection fulfill];
    } failrue:^(NSError *error) {
        XCTFail(@"%@",error);
        [expection fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        if (error) {
            DDLogError(@"ERROR:%@",error);
        }
    }];
}

//测试是否正常关闭推送
- (void)clearApnsToken {
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    BOOL identifierEqual = [identifier isEqualToString:@"com.c35.ptc.pushmail"];
    XCTAssert(identifierEqual, @"identifier不正确, 不能开启推送");
    XCTestExpectation *expection = [self expectationWithDescription:@"clearApnsToken"];
    NSMutableDictionary *params = [ServerAPI authParameters];
    params[@"to"] = token;
    
    [ServerAPI pushClearApnsWithDic:params success:^(id response) {
        XCTAssertNotNil(response);
        [expection fulfill];
        DDLogInfo(@"关闭APNS成功");
    } failrue:^(NSError *error) {
        XCTFail(@"%@",error);
        [expection fulfill];
        DDLogInfo(@"关闭APNS失败");
    }];
}


-(NSString*) getVerInfo {
    NSString* ver = nil;
    NSString* versionStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (Debug_Flag == 1) {
        //debug版本
        ver = [NSString stringWithFormat:@"R:%@:D",versionStr];
    }else {
        //release版本
        ver = [NSString stringWithFormat:@"R:%@",versionStr];
    }
    return ver;
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
