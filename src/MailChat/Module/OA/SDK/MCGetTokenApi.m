//
//  MCGetTokenApi.m
//  NPushMail
//
//  Created by wuwenyu on 2017/1/16.
//  Copyright © 2017年 sprite. All rights reserved.
//

#import "MCGetTokenApi.h"
#import "MCAccountConfig.h"

@implementation MCGetTokenApi

- (NSString *)name {
    return @"gettoken";
}

- (void)processWithParameters:(id)params success:(JSSuccessBlock)success failure:(JSFailureBlock)failure {
    DDLogInfo(@"获取token参数:");
    NSString *token = AppStatus.accountData.accountConfig.eisAccessToken;
    if (token) {
        if (success) {
            success(@[token]);
        }
    }else {
        if (failure) {
            failure(@"token不存在");
        }
    }
    
}

@end
