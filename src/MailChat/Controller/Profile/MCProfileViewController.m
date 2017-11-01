//
//  MCProfileViewController.m
//  NPushMail
//
//  Created by zhang on 16/1/18.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCProfileViewController.h"
#import "MCMailManager.h"
#import "MCProfileView.h"
#import "MCAccountManager.h"
#import "MCAppDelegate.h"
#import "MCFileCore.h"
#import "MCFileManager.h"
#import "MCFileManagerViewController.h"
#import "MCInviteViewController.h"
#import "MCUserInfoViewController.h"
#import "MCFeedBackViewController.h"
#import "MCMailSignatureViewController.h"
#import "MCAboutMailChatViewController.h"
#import "MCMessageRemindViewController.h"
#import "MCGestuerPassWordViewController.h"
#import "MCGestureSetViewController.h"
#import "PCCircleViewConst.h"
#import "MCAppSetting.h"
#import "MCLoginMainViewController.h"
#import "MCBaseNavigationViewController.h"
#import "UIAlertView+Blocks.h"
#import "MCWorkSpaceManager.h"
#import "MCNotificationCenter.h"
#import "UITabBar+badge.h"
#import "MCAccountConfig.h"
#import "MCWebViewController.h"
#import "MCInviteViewController.h"



@interface MCProfileViewController ()<MCProfileViewDelegate>
@property (nonatomic, strong) MCAccountManager *mCAccountManager;
@property (nonatomic, strong) MCProfileView *mCProfileView;
@property (nonatomic, strong) NSArray *accounts;
@end

static NSString *const kMCPAwardedQuestionnaireUrl = @"https://www.wenjuan.com/s/u26ZBv/";


@implementation MCProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _mCAccountManager = [MCAccountManager shared];
        _mCProfileView = [[MCProfileView alloc]initWithDelegate:self];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _accounts = [_mCAccountManager getAllAccounts];
    _mCProfileView.accounts = _accounts;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.changeAccountArrow setHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navBarTitleLable.text = PMLocalizedStringWithKey(@"PM_Main_Tab_Mine_Email");
    self.leftNavigationBarButtonItem.image = nil;
    [self setRootCtrlNavigationBarTitleView];

    
    [self.view addSubview:_mCProfileView];
}

#pragma mark MCProfileViewDelegate

- (void)profileView:(MCProfileView *)profileView didSelectCellIndexPath:(NSIndexPath *)indexPath title:(NSString *)title{
   
    MCBaseSubViewController *viewController;
    if (indexPath.section == 1) {
        
        switch (indexPath.row) {
            case 0://消息提醒
            {
                //友盟统计
                [MCUmengManager addEventWithKey:mc_me_notice];
                viewController = [MCMessageRemindViewController new];
            }
                break;
            case 1://邮件签名
            {
                viewController = [MCMailSignatureViewController new];
            }
                
                break;
            case 2://手势密码
            {
                viewController = [[MCGestuerPassWordViewController alloc] init];
            }
                break;
            default:
                return;
                break;
        }
        
        
    } else {
        
        switch (indexPath.row) {
            case 0:{
                MCWebViewController *webViewController = [[MCWebViewController alloc]initWithUrl:[NSURL URLWithString:kMCPAwardedQuestionnaireUrl]];
                [self.navigationController pushViewController:webViewController animated:YES];
                return;
            }break;
                
            case 1://我的文档
            {
                viewController = [[MCFileManagerViewController alloc]initWithFromType:MCFileCtrlFromOther selectedFileBlock:nil];
            }break;
            case 2:{//清除缓存
                RIButtonItem *sureButtonItem  = [RIButtonItem  itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Sure") action:^{
                    //友盟统计
                    [MCUmengManager addEventWithKey:mc_me_clear];
                  [SVProgressHUD showWithStatus:@"清理中..." maskType:SVProgressHUDMaskTypeClear];
                  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                      [[MCFileCore sharedInstance].getFileModule clearCacheFiles];
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [profileView reloadData];
                          [SVProgressHUD showInfoWithStatus:@"清理完成!"];
                      });
                  });
                  
                }];
                RIButtonItem *cancelButtonItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Cancel")];
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:PMLocalizedStringWithKey(@"PM_Mine_ClearCache") message:nil cancelButtonItem:cancelButtonItem otherButtonItems:sureButtonItem, nil];
                [alertView show];
               ;
                
                return;
            }break;
                
            case 3://意见反馈
                //友盟统计
                [MCUmengManager addEventWithKey:mc_me_feedbackall];
                viewController = [[MCFeedBackViewController alloc]initWithNibName:nil bundle:nil];
                break;
            case 4://关于邮洽
                viewController = [[MCAboutMailChatViewController alloc]initWithNibName:nil bundle:nil];
                break;
            case 5://邀请朋友使用
                viewController = [MCInviteViewController alloc];
                break;
        }
        
    }
    viewController.viewTitle = title;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)profileView:(MCProfileView *)profileView didChangeAccount:(MCAccount *)account {
    
    // 不切换账号
    MCUserInfoViewController *mCUserViewController = [[MCUserInfoViewController alloc]initWithAccout:account];
    [self.navigationController pushViewController:mCUserViewController animated:YES];
    
    return;
    if ([account isEqual:AppStatus.currentUser]) {
        return;
    }
    //友盟统计
    [MCUmengManager addEventWithKey:mc_me_change];
    [self mcLoginAcount:account];
}

- (void)profileViewAddNewAccount {
    //友盟统计
    [MCUmengManager addEventWithKey:mc_me_add];
    
    MCLoginMainViewController *mCLoginMainViewController = [[MCLoginMainViewController alloc]init];
    mCLoginMainViewController.mcLoginPopType = MCLoginPopOptionCanPop;
    MCBaseNavigationViewController *navigationController = [[MCBaseNavigationViewController alloc]initWithRootViewController:mCLoginMainViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

//TODO:user info
- (void)profileView:(MCProfileView *)profileView didSelectAccountInfo:(MCAccount *)account {
    
    MCUserInfoViewController *mCUserViewController = [[MCUserInfoViewController alloc]initWithAccout:account];
    [self.navigationController pushViewController:mCUserViewController animated:YES];
}

//pravite

- (void)mcLoginAcount:(MCAccount*)account {
    
    [self.loginManager loginWithAccount:account];
    [self.mCProfileView reloadData];
    MCAppDelegate*mcAppDelegate = (MCAppDelegate*)[UIApplication sharedApplication].delegate;
    mcAppDelegate.tabBarController.selectedIndex = 0;
}

- (void)mcAccountDidChange:(NSNotification*)info {
    [super mcAccountDidChange:info];
    NSArray *accounts = [[MCAccountManager shared] getAllAccounts];
    _accounts = accounts;
    _mCProfileView.accounts = _accounts;
    [self.mCProfileView reloadData];
}
#pragma mark - didReceiveMemoryWarning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
