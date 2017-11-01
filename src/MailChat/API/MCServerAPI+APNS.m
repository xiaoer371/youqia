//
//  MCServerAPI+APNS.m
//  NPushMail
//
//  Created by admin on 3/23/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCServerAPI+APNS.h"
#import "MCApnsPushConfig.h"

static NSString* const kMCEisAPIErrorDomain = @"com.mailchat.error.mail-api";

@implementation MCServerAPI (APNS)

- (void)setTopicPushOnOrOffWithParameters:(NSDictionary *)parameters
                                  success:(SuccessBlock)success
                                  failrue:(FailureBlock)failure
{
    NSString *path = @"push/set";

    [self.manager POST:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if (responseObject) {
            if ([[responseObject objectForKey:@"result"] intValue] == 1) {
                if (success) {
                    success(responseObject);
                }else {
                    failure(nil);
                }
            }else {
                if (failure) {
                    DDLogWarn(@"%@",[responseObject objectForKey:@"error"]);
                    NSError *error = [NSError errorWithDomain:kMCEisAPIErrorDomain code:[[responseObject objectForKey:@"code"] intValue] userInfo:@{@"error" : [responseObject objectForKey:@"error"]}];
                    failure(error);
                }
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

- (void)getPushDetailsWithDic:(NSDictionary *)dic success:(SuccessBlock)success failrue:(FailureBlock)failure {
    NSString *path = @"push/details";
    [self.manager GET:path parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        if (responseObject) {
            if ([[responseObject objectForKey:@"result"] intValue] == 1) {
                MCApnsPushConfig *pushConfig = [[MCApnsPushConfig alloc] initWithDictionary:responseObject pushConfigType:pushDetailsType];
                if (success) {
                    success(pushConfig);
                }else {
                    failure(nil);
                }
            }else {
                if (failure) {
                    DDLogWarn(@"%@",[responseObject objectForKey:@"error"]);
                    NSError *error = [NSError errorWithDomain:kMCEisAPIErrorDomain code:[[responseObject objectForKey:@"code"] intValue] userInfo:@{@"error" : [responseObject objectForKey:@"error"]}];
                    failure(error);
                }
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];

}

- (void)updatePushSettingWithDic:(NSDictionary *)dic success:(SuccessBlock)success failrue:(FailureBlock)failure {
    NSString *path = @"push/update";
    [self.manager POST:path parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        if (responseObject) {
            MCApnsPushConfig *pushConfig = [[MCApnsPushConfig alloc] initWithDictionary:responseObject pushConfigType:pushUpdateType];
            if (success) {
                success(pushConfig);
            }else {
                failure(nil);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];

}

@end
