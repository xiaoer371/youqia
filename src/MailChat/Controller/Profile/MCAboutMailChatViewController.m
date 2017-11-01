//
//  MCAboutMailChatViewController.m
//  NPushMail
//
//  Created by zhang on 16/4/13.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAboutMailChatViewController.h"
#import "MCWebViewController.h"
#import "MCDebugViewController.h"
#import "NSString+Extension.h"
#import "CustomIOSAlertView.h"
#import "MCAppSetting.h"
#import "MCVersionUpdateView.h"
#import "MCIMConversationManager.h"

#import "MCWebViewController.h"
@interface MCAboutMailChatViewController ()

// 76  23
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *evaluationLayoutTop;


@end

//static NSString *const kMCAboutMailChatAppStoreUrl = @"https://itunes.apple.com/cn/app/wei-mei-35pushmail/id592687646?mt=8";
static NSString *const kMCAboutMailChatAppStoreUrl = @"https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=592687646&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8";  // 评价界面
static NSString *const kMCAboutMailChatPrivacyUrl = @"http://www.mailchat.cn/xieyi.html";

static NSString *const kMCAboutMailChatInfoUrl = @"http://www.mailchat.cn/newsinfo.aspx?Id=16";

@implementation MCAboutMailChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
}

- (void)setUp {
    
    _mcVersonLable.textColor = AppStatus.theme.titleTextColor;
    NSString*versionStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    _mcVersonLable.text = [NSString stringWithFormat:@"%@ V%@",PMLocalizedStringWithKey(@"PM_Mine_Version"),versionStr];
    [_evaluationButton setTitle:PMLocalizedStringWithKey(@"PM_Mine_SetScore") forState:UIControlStateNormal];
    [_infoButton setTitle:PMLocalizedStringWithKey(@"PM_Setting_IntroducedFunction") forState:UIControlStateNormal];
    
    [_privacyButton setTitle:PMLocalizedStringWithKey(@"PM_Mine_Privacy") forState:UIControlStateNormal];
    [_privacyButton setTitleColor:AppStatus.theme.tintColor forState:UIControlStateNormal];
    
        
    UIView  *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, _mcIconBackgroundView.frame.size.height - 0.5, ScreenWidth, 0.5)];
    line1.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
    [_mcIconBackgroundView addSubview:line1];
    
    for (UIView *view in @[self.mcEvaluationBackgroundView,self.mcInfoView]) {
        UIView  *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.5)];
        line2.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
        [view addSubview:line2];
        UIView  *line3 = [[UIView alloc]initWithFrame:CGRectMake(0, view.frame.size.height, ScreenWidth, 0.5)];
        line3.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
        [view addSubview:line3];
    }
    _mcLogoImgeView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
    longPressGr.minimumPressDuration = 2.0;
    [_mcLogoImgeView addGestureRecognizer:longPressGr];
}

#pragma mark -  长按手势进入 DEBUG调试界面
- (void)longPressToDo:(UILongPressGestureRecognizer *)sender
{
    if(sender.state == UIGestureRecognizerStateBegan)
    {
        MCDebugViewController  *vc;
        if (![AppStatus.currentUser.email mcContainsString:@"35.cn"] && ![AppStatus.currentUser.email isHelperAccount]) {
            vc = [[MCDebugViewController alloc] initWithDebugType:MCDDEBUGTYPE_other];
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
        vc = [[MCDebugViewController alloc] initWithDebugType:MCDDEBUGTYPE_35Mail];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//TODO:隐私协议
- (IBAction)notePrivacyForUser:(id)sender {
    
    /* ps 飞巴显示出来 */
    MCIMConversationModel *feiBaConversation = [[MCIMConversationManager shared] getConversationWithPeerId:kMailChatFeiBa];
    if (feiBaConversation.state == MailChatConversationStateDeleted) {
        feiBaConversation.state = MailChatConversationStateNormal;
        [[MCIMConversationManager shared] updateConversation:feiBaConversation];
    }

    MCWebViewController *webController = [[MCWebViewController alloc] initWithUrl:[NSURL URLWithString:kMCAboutMailChatPrivacyUrl]];
    [self.navigationController pushViewController:webController animated:YES];
}
//TODO:评分
- (IBAction)gotoEvautionForMailChat:(id)sender {
    
    //友盟统计
    [MCUmengManager addEventWithKey:mc_me_score];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kMCAboutMailChatAppStoreUrl]];
}

- (IBAction)aboutMailChat:(id)sender {
    MCWebViewController *webViewController = [[MCWebViewController alloc]initWithUrl:[NSURL URLWithString:kMCAboutMailChatInfoUrl] title:PMLocalizedStringWithKey(@"PM_Setting_IntroducedFunction")];
    [self.navigationController pushViewController:webViewController animated:YES];
}

// 更新版本
- (IBAction)updateApp:(UIButton *)sender {
    
    UIAlertView *alert;
    if (![self isNewVersion]) {
        
        [MCVersionUpdateView show:NO];
    }else
    {
       alert = [[UIAlertView alloc] initWithTitle:nil message:PMLocalizedStringWithKey(@"PM_MC_CanUpdateApp") delegate:nil cancelButtonTitle:PMLocalizedStringWithKey(@"PM_Common_Sure") otherButtonTitles:nil, nil];
    }
    [alert show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex != buttonIndex) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/wei-mei-35pushmail/id592687646?mt=8"]];
    }
}

- (BOOL)isNewVersion
{
    NSString*currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSInteger oldVersion = [[currentVersion stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue];
    NSInteger newVersion = [[AppSettings.lastUpdateVersion stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue];
    if (newVersion > oldVersion) {
        return NO;
    }else return YES;
}

@end
