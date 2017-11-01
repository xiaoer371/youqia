//
//  MCAuthExpireApi.m
//  NPushMail
//
//  Created by admin on 12/12/2016.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCAuthExpireApi.h"
#import "MCWorkSpaceManager.h"
#import "MCAccountConfig.h"
#import "MCOAConfig.h"
#import "MCAppDelegate.h"
#import "MCWorkspaceViewController.h"

@implementation MCAuthExpireApi

- (NSString *)name
{
    return @"authexpire";
}

- (void)processWithParameters:(id)params success:(JSSuccessBlock)success failure:(JSFailureBlock)failure
{
    int errorCode = [[params objectForKey:@"reason"] intValue];
    switch (errorCode) {
        case 0:
            //token过期
            [self tokenExpire];
            break;
        case 1:
            //oa密码修改
            [self oaPasswordModify];
            break;
        case 2:
            //解绑oa
            [self mailUnBindingOa];
            break;
        default:
            break;
    }
}

- (void)tokenExpire {
    MCAccountConfig *accountConfig = AppStatus.accountData.accountConfig;
    BOOL isEis = AppStatus.currentUser.isEIS;
    if (isEis) {
        
    }else {
        [MCOAWorkSpaceManager loginOaWithDomin:accountConfig.oaDomin accountConfig:accountConfig success:^(id response) {
            MCOAConfig *oaConfig = (MCOAConfig *)response;
            BOOL needUnBinding = [MCOAWorkSpaceManager isUnBindingWithAccountConfig:oaConfig];
            if (!needUnBinding) {
                if (oaConfig.oaUserLoginTypeType.errorcode == 0){
                    DDLogVerbose(@"重新登录获取accesstoken成功");
                    if (!oaConfig.oaUserLoginTypeType.bindmail) {
                        //如果绑定的mail为空，且当前是第三方账号登录oa的情况,代表已经解绑当前帐号的oa权限
                        if (accountConfig.oaUserType == 1) {
                            accountConfig.isFirstSyncOAUser = YES;
                            accountConfig.oaPassword = nil;
                        }
                    }
                    [MCOAWorkSpaceManager oaWorkSpaceShowCheckWithAccountConfig:accountConfig];
                }else {
                    accountConfig.isFirstSyncOAUser = YES;
                    accountConfig.oaPassword = nil;
                    [MCOAWorkSpaceManager oaWorkSpaceShowCheckWithAccountConfig:accountConfig];
                }
                
            }else {
                //解绑
                [self mailUnBindingOa];
            }
            
        } failrue:^(NSError *error) {
            DDLogWarn(@"oa登录失败:%@", error);
            accountConfig.isFirstSyncOAUser = YES;
            [MCOAWorkSpaceManager oaWorkSpaceShowCheckWithAccountConfig:accountConfig];
        }];
    }
}

- (void)oaPasswordModify {
    MCAppDelegate *del = (MCAppDelegate*)[UIApplication sharedApplication].delegate;
    UINavigationController *workSapceNav = del.tabBarController.workSpaceNav;
    MCWorkspaceViewController *v = (MCWorkspaceViewController *)[workSapceNav.viewControllers firstObject];
    [v oaPasswordWrong];
}

- (void)mailUnBindingOa {
    MCAccountConfig *accountConfig = AppStatus.accountData.accountConfig;
    if (accountConfig.oaUserIs35Mail) {
        //如果oa本身也是35的邮箱的话，则只需要重新获取token即可。
        if (accountConfig.oaUserType == 0) {
            //因为35域的话个人邮箱也会返回oaUserIs35Mail为true，所以增加一层判断是否是个人邮箱，个人邮箱的话则继续解绑，否则重新请求token
            [self tokenExpire];
            return;
        }
    }
    accountConfig.isFirstSyncOAUser = YES;
    accountConfig.hasWorkspace = NO;
    accountConfig.isOAUser = NO;
    accountConfig.oaPassword = nil;
    MCAppDelegate *del = (MCAppDelegate*)[UIApplication sharedApplication].delegate;
    UINavigationController *workSapceNav = del.tabBarController.workSpaceNav;
    MCWorkspaceViewController *v = (MCWorkspaceViewController *)[workSapceNav.viewControllers firstObject];
    [v oaUnBindingAlert];
}


@end
