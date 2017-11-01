//
//  MCServerAPI+Stats.m
//  NPushMail
//
//  Created by admin on 8/10/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCServerAPI+Stats.h"

@implementation MCServerAPI(Stats)

- (void)reportLoginStatus:(BOOL)isSuccess withEmail:(NSString *)email error:(NSError *)error success:(ActionBlock)success failure:(FailureBlock)failure
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"email"] = email;
    params[@"client"] = @"ios";
    params[@"ok"] = @(isSuccess);
    if (!isSuccess) {
        params[@"code"] = @(error.code);
        params[@"info"] = [error description];
    }
    
    [self.manager POST:@"app/report" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        DDLogVerbose(@"%@",responseObject);
        if (success) {
            success();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"%@",error);
        if (failure) {
            failure(error);
        }
    }];
}

@end
