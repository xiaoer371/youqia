//
//  MCBaseLoginViewController.m
//  NPushMail
//
//  Created by swhl on 16/11/29.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseLoginViewController.h"
#import "MCAccountManager.h"
#import "MCSetAvatorViewController.h"
#import "MCContactManager.h"
#import "MCAppDelegate.h"
#import "MCAppStatus.h"
#import "MCAccountConfig.h"
#import "MCWorkSpaceManager.h"
#import "MCWebViewController.h"
#import "MCAppSetting.h"
#import "MCBaseNavigationViewController.h"
#import "MCRemoteNoticeViewController.h"

@implementation MCBaseLoginViewController


- (void)loginSuccessAcccount:(MCAccount*)mcAccount {
    if (AppStatus.currentUser.isEIS) {
        [self updateEnterpriseContacts];
    }
    [[MCAccountManager shared] updateAccountFromServer:AppStatus.currentUser success:^(MCAccount *account) {
        if (!account.avatar) {
            //没有设置头像
            MCSetAvatorViewController *vc =[[MCSetAvatorViewController alloc] initWithAccount:account];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else{
            //不需要设置头像，直接跳转
            [self loadMainViewController];
        }
        [SVProgressHUD dismiss];
        
    } failure:^(NSError *error) {
        //请求头像失败 逻辑：直接跳转主界面
        [self loadMainViewController];
        [SVProgressHUD dismiss];
    }];
}

- (void)updateEnterpriseContacts {
    [[MCContactManager sharedInstance] updateEnterpriseContactsSuccess:^{
        
    } failure:nil];
}

- (void)loadMainViewController {
    MCAppDelegate*mcAppDelegate = (MCAppDelegate*)[UIApplication sharedApplication].delegate;
    if (!mcAppDelegate.tabBarController) {
        [mcAppDelegate displayTabBarViewController];
    } else {
        mcAppDelegate.tabBarController.selectedIndex = 0;
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        [MCWorkSpaceManager workSpaceUserCheck];
    }
    
    // TODO: 非35企业邮箱用户每次登录成功后，出现推送提示页
    if (![AppStatus.currentUser.email is35Mail]) {
        
        MCRemoteNoticeViewController *vc = [[MCRemoteNoticeViewController alloc] init];
        UINavigationController *nav1 = mcAppDelegate.tabBarController.viewControllers[mcAppDelegate.tabBarController.selectedIndex];
        [nav1 pushViewController:vc animated:YES];
    }
    
    
    
    //检查流量活动
    [[MCAccountManager shared] checkEvent:AppStatus.currentUser success:^(id response) {
        //
        NSString *strUrl = [NSString stringWithFormat:@"https://a.mailchat.cn/app/event_start?d=%@&p=%@&e=%@",AppSettings.user.userId,AppSettings.user.password,AppStatus.currentUser.email];
        MCWebViewController *webController = [[MCWebViewController alloc] initWithUrl:[NSURL URLWithString:strUrl] title:@"获取流量包" style:MCWebViewStyleEvent];
        MCBaseNavigationViewController *webNav = [[MCBaseNavigationViewController alloc] initWithRootViewController:webController];
        UINavigationController *nav = mcAppDelegate.tabBarController.viewControllers[mcAppDelegate.tabBarController.selectedIndex];
        webController.delegate = nav.viewControllers[0];
        [nav presentViewController:webNav animated:YES completion:nil];
        
    } failure:^(NSError *error) {
        //
    }];
}



@end
