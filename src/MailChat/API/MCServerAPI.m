//
//  MCMailAPI.m
//  NPushMail
//
//  Created by admin on 1/4/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCServerAPI.h"
#import "NSString+Extension.h"
#import "RSAEncrypt.h"
#import "GTMBase64.h"
#import "NSDate+Category.h"
#import "MCAppSetting.h"

NSString* const kMCMailAPIErrorDomain = @"com.mailchat.error.mail-api";
static NSInteger const kMCMailAPIRequestTimeout = 15;

@interface MCServerAPI ()

@end

@implementation MCServerAPI

#pragma mark - Lifecycle

- (instancetype)init
{
    if (self = [super init]) {
        _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:AppSettings.apiBaseUrl]];
        _manager.requestSerializer.timeoutInterval = kMCMailAPIRequestTimeout;
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"application/octet-stream", @"text/html",nil];
        
        AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        policy.allowInvalidCertificates = YES;
        [policy setValidatesDomainName:NO];
        _manager.securityPolicy = policy;
    }
    
    return self;
}

+ (instancetype)shared
{
    static id instance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[MCServerAPI alloc] init];
    });
    
    return instance;
}

#pragma mark - Private

- (NSMutableDictionary *)authParameters
{
    if (!AppSettings.user) {
        DDLogError(@"Cannot generate auth parameters, should login firstly");
        return nil;
    }
    
    NSTimeInterval timeStamp = [[NSDate new] timeIntervalSince1970];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:AppSettings.user.userId forKey:@"d"];
    [params setObject:AppSettings.user.password forKey:@"p"];
    [params setObject:@(timeStamp) forKey:@"ts"];
    return params;
}

- (NSError *)errorWithResponse:(id)responseObject
{
    NSString *errorStr = [responseObject objectForKey:@"error"];
    if (!errorStr) {
        return nil;
    }
    NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
    NSError *error = [NSError errorWithDomain:kMCMailAPIErrorDomain code:code userInfo:@{@"error" : errorStr}];
    return error;
}

@end
