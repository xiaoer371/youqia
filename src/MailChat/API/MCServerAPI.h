//
//  MCMailAPI.h
//  NPushMail
//
//  Created by admin on 1/4/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "MCMailConfig.h"
#import "MCMail35Info.h"
#import "MCAvatorInviteModel.h"

typedef enum : NSUInteger {
    MCAPIErrorCodeNoError = 0,
    MCAPIErrorCodeEmailAlreadyBinded = 2001,
    MCAPIErrorCodeEmailNotFound = 2002,
    MCAPIErrorCodeEmailNotBinded = 2003,
    MCAPIErrorCodeEnterpriseContactDisabled = 3002
} MCAPIErrorCode;

extern NSString* const kMCMailAPIErrorDomain;

//为了方便调用而定义的宏
#define ServerAPI [MCServerAPI shared]

@interface MCServerAPI : NSObject

@property (nonatomic,strong) AFHTTPSessionManager *manager;

+ (instancetype)shared;


#pragma mark - PUSH

#pragma mark - Encrypt


- (NSMutableDictionary *)authParameters;

- (NSError *)errorWithResponse:(id)responseObj;

@end
