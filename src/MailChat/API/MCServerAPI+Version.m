//
//  MCServerAPI+Version.m
//  NPushMail
//
//  Created by zhang on 16/6/7.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCServerAPI+Version.h"
#import "MCFeatureReleaseConfig.h"

@implementation MCServerAPI(Version)

- (void)getAppVersionSuccess:(SuccessBlock)success failuer:(FailureBlock)failure {
    NSString *url = @"https://api.mailchat.cn:80/app/ios";
    [self.manager GET:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}


- (void)getAppNewVersionWithParams:(NSDictionary *)params success:(SuccessBlock)success failuer:(FailureBlock)failure
{
    [self.manager POST:@"app/newios" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}


- (void)checkFeatureReleaseWithParams:(NSDictionary *)params success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *path = @"app/igrayupdate";
    [self.manager POST:path parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if (responseObject) {
            DDLogVerbose(@"responseObject: %@", responseObject);
            if ([[responseObject objectForKey:@"result"] intValue] == 1) {
                NSDictionary *configDic = [responseObject objectForKey:@"data"];
                MCFeatureReleaseConfig *config = [[MCFeatureReleaseConfig alloc] initWithDictionary:configDic];
                if (success) {
                    success(config);
                }else {
                    DDLogWarn(@"回调没有传入");
                    failure(nil);
                }
            }else {
                //
                int errorCode = [[responseObject objectForKey:@"code"] intValue];
                if (errorCode) {
                    NSString *errorMsg = [responseObject objectForKey:@"error"];
                    if (errorMsg) {
                        DDLogWarn(@"灰度发布接口失败，错误码:%d 错误信息:%@", errorCode, errorMsg);
                    }
                }
                
                if (failure) {
                    failure(nil);
                }
            }

        }else {
            DDLogWarn(@"灰度发布接口失败，无返回值信息");
            if (failure) {
                failure(nil);
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            DDLogWarn(@"灰度发布接口失败:%@", error);
            failure(error);
        }
    }];
}

@end
