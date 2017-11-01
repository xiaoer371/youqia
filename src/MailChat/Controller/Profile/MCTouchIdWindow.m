//
//  MCTouchIdWindow.m
//  NPushMail
//
//  Created by wuwenyu on 16/5/13.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCTouchIdWindow.h"
#import "MCTouchIdViewController.h"
#import "MCTouchIdHelper.h"
#import "MCBaseNavigationViewController.h"
#import "MCReloginViewController.h"
#import "MCAppSetting.h"
#import "UIAlertView+Blocks.h"
#import <LocalAuthentication/LAContext.h>
#import <LocalAuthentication/LAError.h>

@interface MCTouchIdWindow()

@property(nonatomic, strong) MCTouchIdViewController *touchIdCtrl;

@end

@implementation MCTouchIdWindow {
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.windowLevel = UIWindowLevelAlert;
        _touchIdCtrl = [MCTouchIdViewController new];
        __weak MCTouchIdWindow *weakSelf = self;
        _touchIdCtrl.result = ^(BOOL success, NSError *error){
            if (success) {
                [weakSelf dismiss];
            }else {
                //验证失败情况
                switch (error.code) {
                    case LAErrorUserFallback: {
                        //用户点击输入密码
                        dispatch_async(dispatch_get_main_queue(), ^{
                            MCReloginViewController *v = [[MCReloginViewController alloc] init];
                            v.touchIdLoginSuccess = ^{
                                [weakSelf dismiss];
                            };
                            [weakSelf.touchIdCtrl.navigationController pushViewController:v animated:YES];
                        });
                        break;
                    }
                    case LAErrorTouchIDNotEnrolled: {
                        //设备没有进行Touch ID 指纹注册
                        [weakSelf touchIdCloseStatusWaring];
                        break;
                    }
                    case LAErrorPasscodeNotSet: {
                        //用户没有在设备Settings中设定密码
                        [weakSelf touchIdCloseStatusWaring];
                        break;
                    }
                    case LAErrorSystemCancel: {
                        // 系统终止了验证
                        break;
                    }
                    default:
                        break;
                }
            }
        };
        MCBaseNavigationViewController *nav = [[MCBaseNavigationViewController alloc] initWithRootViewController:_touchIdCtrl];
        self.rootViewController = nav;
    }
    
    return self;
}

- (BOOL)isIsShow {
    return _isShow;
}

- (void)show
{
    [self makeKeyAndVisible];
    _isShow = YES;
    self.hidden = NO;
    __weak MCTouchIdWindow *weakSelf = self;
    [[MCTouchIdHelper shared] verificationTouchIdWithOpenGesturePwd:NO title:PMLocalizedStringWithKey(@"PM_Mine_touchIdLoginVerificationTitle") reply:^(BOOL success, NSError *error) {
        if (success) {
            [weakSelf dismiss];
        }else {
            //验证失败情况
            switch (error.code) {
                case LAErrorUserFallback: {
                    //用户点击输入密码
                    dispatch_async(dispatch_get_main_queue(), ^{
                        MCReloginViewController *v = [[MCReloginViewController alloc] init];
                        v.touchIdLoginSuccess = ^{
                            [weakSelf dismiss];
                        };
                        [weakSelf.touchIdCtrl.navigationController pushViewController:v animated:YES];
                    });
                    break;
                }
                case LAErrorTouchIDNotEnrolled: {
                    //设备没有进行Touch ID 指纹注册
                    [weakSelf touchIdCloseStatusWaring];
                    break;
                }
                case LAErrorPasscodeNotSet: {
                    //用户没有在设备Settings中设定密码
                    [weakSelf touchIdCloseStatusWaring];
                    break;
                }
                case LAErrorSystemCancel: {
                    // 系统终止了验证
                    break;
                }
                default:
                    break;
            }
        }
    }];
}

- (void)touchIdCloseStatusWaring {
    __weak MCTouchIdWindow *weakSelf = self;
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Cancel") action:^{
        
    }];
    RIButtonItem *sureItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Mine_touchIdLoginPasswordVerification") action:^{
        MCReloginViewController *v = [[MCReloginViewController alloc] init];
        v.touchIdLoginSuccess = ^{
            [weakSelf dismiss];
        };
        [weakSelf.touchIdCtrl.navigationController pushViewController:v animated:YES];
    }] ;
    UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_Common_Notice") message:PMLocalizedStringWithKey(@"PM_Mine_touchIdLoginCloseWaring") cancelButtonItem:cancelItem otherButtonItems:sureItem, nil];
    [alertV show];

}

- (void)dismiss
{
    [self resignKeyWindow];
    self.hidden = YES;
    _isShow = NO;
}

@end
