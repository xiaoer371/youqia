//
//  MCEisWorkSpaceManager.m
//  NPushMail
//
//  Created by wuwenyu on 2017/2/9.
//  Copyright © 2017年 sprite. All rights reserved.
//

#import "MCEisWorkSpaceManager.h"
#import "MCAccountConfig.h"
#import "MCServerAPI+OA.h"
#import "MCAppDelegate.h"
#import "MCAppSetting.h"
#import "MCEisServerConfig.h"

@implementation MCEisWorkSpaceManager

+ (void)eisWorkSpaceCheckWithAccountConfig:(MCAccountConfig *)accountConfig act:(MCAccount *)currentAct {
    [self accesstokenExpireinProcessComplite:^(BOOL expirein) {
        if (expirein) {
            [self reLoginEisWithAccountConfig:accountConfig act:currentAct];
        }else {
            [self workSpaceShow];
        }
    }];
}

#pragma mark - 判断accesstoken是否过期,过期需重新登录获取.
+ (void)accesstokenExpireinProcessComplite:(expireinTime)expireinTimeBlock {
    MCAccountConfig *accountConfig = AppStatus.accountData.accountConfig;
    BOOL expirein = NO;
    NSTimeInterval timeInterval = 0;
    NSInteger expireinTime = 0;
    if (accountConfig.eisAccesstokenCreatetime) {
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSDate *createtime = [fmt dateFromString:accountConfig.eisAccesstokenCreatetime];
        timeInterval = -[createtime timeIntervalSinceNow];
        expireinTime = accountConfig.eisAccesstokenExpireinTime;
    }
    //过期前10分钟重新请求accesstoken
    if (timeInterval > (expireinTime - 10*60)) {
        expirein = YES;
    }else {
        expirein = NO;
    }
    if (expireinTimeBlock) {
        expireinTimeBlock(expirein);
    }
}

+ (NSString *)eisCreateTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *str = [formatter stringFromDate:[NSDate date]];
    return str;
}

//重新登录EIS
+ (void)reLoginEisWithAccountConfig:(MCAccountConfig *)accountConfig act:(MCAccount *)currentAct {
    //todo:重新从EIS获取token
    [self reLoginEisWithAccountConfig:accountConfig act:currentAct success:^(id response) {
        [self workSpaceShow];
    } failrue:^(NSError *error) {
        [self workSpaceShow];
    }];
}

+ (void)workSpaceShow {
    MCAppDelegate *del = (MCAppDelegate*)[UIApplication sharedApplication].delegate;
    //有工作台
    [del setTabbarWithWorkspaceFlag:AppSettings.isShowWorkspace];
    [self refreshWorkSpaceData];
}

+ (void)reLoginEisWithAccountConfig:(MCAccountConfig *)accountConfig act:(MCAccount *)currentAct success:(SuccessBlock)success failrue:(FailureBlock)failure {
    [ServerAPI getEisRouteAddressWithSuccess:^(id response) {
        MCEisRouteConfig *routeConfig = (MCEisRouteConfig *)response;
        if (routeConfig) {
            if (routeConfig.list.count > 0) {
                MCEisRouteModel *routeModel = [routeConfig.list objectAtIndex:0];
                accountConfig.eisRouteIpAddress = routeModel.ip;
                [ServerAPI getEisTokenWithAccount:currentAct ip:routeModel.ip  success:^(id response) {
                    MCEisTokenConfig *tokenConfig = (MCEisTokenConfig *)response;
                    if (tokenConfig.token) {
                        accountConfig.eisAccessToken = tokenConfig.token;
                        //token剩余的过期时间
                        if (tokenConfig.expireTime) {
                            accountConfig.eisAccesstokenExpireinTime = tokenConfig.expireTime;
                        }
                        //token创建时间为当前时间
                        accountConfig.eisAccesstokenCreatetime = [self eisCreateTime];
                        if (success) {
                            success(tokenConfig);
                        }
                    }else {
                        //获取token失败
                        DDLogInfo(@"EIS token获取失败:%@", tokenConfig.errorMsg);
                        if (failure) {
                            failure(nil);
                        }
                    }
                } failrue:^(NSError *error) {
                    //获取token失败
                    DDLogInfo(@"EIS token获取失败:%@", error);
                    if (failure) {
                        failure(error);
                    }
                }];
            }
        }
    } failrue:^(NSError *error) {
        //获取路由失败
        DDLogInfo(@"EIS 路由地址获取失败:%@", error);
        if (failure) {
            failure(error);
        }
    }];
}

+ (NSString *)getEisHomeUrl {
    return [ServerAPI getEisHomeUrl];
}

@end
