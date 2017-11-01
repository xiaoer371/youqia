//
//  MCLoginQQAuthViewController.m
//  NPushMail
//
//  Created by swhl on 16/10/19.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCLoginDetailViewController.h"
#import "MCLoginQQAuthViewController.h"
#import "UIView+MCExpand.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "MCContactManager.h"
#import "MCIMConversationManager.h"
#import "MCIMChatViewController.h"
#import "UIView+MCExpand.h"
#import "PQFBallDrop.h"
#import <MessageUI/MessageUI.h>
#import "MCMailManager.h"
#import "MCMailConfig.h"
#import "MCMailConfigManager.h"
#import "MCAvatarHelper.h"
#import "MCAccountManager.h"
#import "UIAlertView+Blocks.h"


@interface MCLoginQQAuthViewController ()<UIWebViewDelegate,MFMessageComposeViewControllerDelegate>
{
    
}

@property (nonatomic, strong) NSString  *email;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIView    *helpView;  //一键开启
@property (nonatomic, strong) UILabel   *helpLabel;
@property (nonatomic, strong) UIButton  *helpButton;
@property (nonatomic, strong) NSString   *password;
@property (nonatomic, strong) NSString   *jsString;
@property (nonatomic, assign) BOOL helpClicked;
@property (nonatomic, assign) BOOL timerTriggered;
@property (nonatomic, assign) BOOL gotoSetting;
@property (nonatomic, strong) UIView  *aniView;
@property (nonatomic, assign) BOOL reSetFrame;
@property (nonatomic, strong) NSTimer  *animationTimer;

@end

@implementation MCLoginQQAuthViewController

-(void)dealloc
{
    [self.webView stopLoading];
    self.webView = nil;

}

- (instancetype)initWithEmail:(NSString*)email
{
    self = [super init];
    if (self) {
        self.email =email;
        self.password = nil;
        self.gotoSetting = NO;
        self.reSetFrame = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadSubViewNar];
    
    [self loadSubViewWebView];
    
}
- (void)loadSubViewNar
{
    self.viewTitle =PMLocalizedStringWithKey(@"PM_Login_QQAuth");
    self.rightNavigationBarButtonItem.title = PMLocalizedStringWithKey(@"PM_Login_HelperName");
}

- (void)loadSubViewWebView
{
    [self clearCookie];
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0, ScreenWidth, ScreenHeigth-64)];
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    [self.view addSubview:_webView];
    
    [SVProgressHUD showWithStatus:@"loading" maskType:SVProgressHUDMaskTypeNone];
    [self loadQQloginPage:_webView];
}

- (void)setupFastAuth
{
    if (!_helpView) {
        
        _helpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
        [self.view addSubview:_helpView];
        [_webView moveToY:44];
        
        _helpLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, 200, 30)];
        _helpLabel.font = [UIFont systemFontOfSize:14.0f];
        _helpLabel.textColor = [UIColor colorWithHexString:@"70757a"];
        [_helpView addSubview:_helpLabel];
        _helpView.backgroundColor = [UIColor colorWithHexString:@"e6e6e6"];
        _helpLabel.text = @"开启客户端授权码登录邮洽";
        
        UIButton *helpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        helpBtn.frame = CGRectMake(ScreenWidth -90, 7, 80, 30);
        helpBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        helpBtn.layer.cornerRadius = 3.0f;
        helpBtn.backgroundColor = AppStatus.theme.tintColor;
        helpBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [helpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [helpBtn setTitle:PMLocalizedStringWithKey(@"PM_Login_QQAuthHelp") forState:UIControlStateNormal];
        [helpBtn addTarget:self action:@selector(helpAction:) forControlEvents:UIControlEventTouchUpInside];
        _helpButton =helpBtn;
        [_helpView addSubview:_helpButton];
        
    }
}

- (void)loadQQloginPage:(UIWebView *)webView
{
//    NSURL *url = [NSURL URLWithString:@"https://w.mail.qq.com/cgi-bin/loginpage?f=xhtml&kvclick=loginpage%7Capp_push%7Center%7Cios&ad=false&"];
    NSURL *url = [NSURL URLWithString:@"https://w.mail.qq.com/cgi-bin/loginpage?ad=false"];

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
}

- (void)clearCookie
{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    DDLogVerbose(@"shouldStartLoadWithRequest = %@",request.URL.absoluteString);
    if ([request.URL.scheme isEqualToString:@"ios"]) {
        
        NSArray *params = [request.URL.absoluteString componentsSeparatedByString:@":"];
        NSString *functionName = params[1];
        NSString *param = params[2];
        // 授权吗
        if ([functionName isEqualToString:@"authcode"]) {
            [self loginWithPassword:param];
        }
        // 检查独立密码
        else if ([functionName isEqualToString:@"password"]) {
            [self checkSeperatePassword:param];
        }
        // 检查关闭按钮
        else if ([functionName isEqualToString:@"close"]) {
            self.helpClicked = NO;
            _helpButton.hidden = NO;
            _helpButton.frame = CGRectMake(ScreenWidth -90, 7, 80, 30);
            [_helpButton setTitle:PMLocalizedStringWithKey(@"PM_Login_QQAuthHelp") forState:UIControlStateNormal];
        }
        
        // 检查登录按钮
        else if ([functionName isEqualToString:@"go"]) {
            [self addAnimationView];
            [self checkAccountEmail:param];
            [MCUmengManager addEventWithKey:mc_qq_webPsd];
        }

        
        return NO;
    }
    
    if ([request.URL.absoluteString containsString:@"t=phone#today"]) {
        [_webView stringByEvaluatingJavaScriptFromString:@"gotoPCMail()"];
    }
   
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self executeScripts];
    
    DDLogVerbose(@"webViewDidFinsihLoad = %@", webView.request.URL.absoluteString);
    if ([webView.request.URL.host isEqualToString:@"ui.ptlogin2.qq.com"]) {
        if (self.email.length > 0) {
            //js 注入已经输入的账号
//            NSString *accountNum  = [self.email componentsSeparatedByString:@"@"][0];
            NSString *inputEmail = [NSString stringWithFormat:@"document.getElementById('u').value='%@';",self.email];
            [_webView stringByEvaluatingJavaScriptFromString:inputEmail];
        }
        [SVProgressHUD dismiss];

    }
    
    // 屏蔽广告页
    if ([webView.request.URL.absoluteString containsString:@"https://w.mail.qq.com/cgi-bin/loginpage?f=xhtml&aliastype=&s=&errtype=4"]) {
        [self removeAnimationView];
        [webView stringByEvaluatingJavaScriptFromString:@"disableADPage()"];
    }
    
    
    //https://w.mail.qq.com/cgi-bin/mobile?sid=
    // 授权码跳转到pc 设置界面
    if ([webView.request.URL.absoluteString containsString:@"https://w.mail.qq.com/cgi-bin/mobile?sid="]) {
        [_webView stringByEvaluatingJavaScriptFromString:@"gotoPCMail()"];
    }
    
    if ([webView.request.URL.absoluteString containsString:@"mail.qq.com/cgi-bin/frame_html"]) {
        if ( self.gotoSetting == NO) {
            [_webView stringByEvaluatingJavaScriptFromString:@"gotoSetting()"];
            [self setupFastAuth];
            self.gotoSetting = YES;
            
            [self.animationTimer invalidate];
            self.animationTimer =nil;
            self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(animationTimer:) userInfo:nil repeats:YES];
        }
    }

    // 点击一键开启后，调整提示框大小 （会执行两次，让他第二次再调用js）
    if (self.helpClicked && [webView.request.URL.absoluteString containsString:@"mail.qq.com/cgi-bin/frame_html"]) {
        if (self.reSetFrame == YES) {
            [webView stringByEvaluatingJavaScriptFromString:@"resetFrame()"];
        }
        self.reSetFrame = YES;
    }
    
    if (!self.timerTriggered && self.helpClicked && [webView.request.URL.absoluteString containsString:@"mail.qq.com/cgi-bin/frame_html"]) {
        self.timerTriggered = YES;
        [webView stringByEvaluatingJavaScriptFromString:@"startCheckAuthCode()"];
    }
}

-(void)animationTimer:(id)sender
{
    [self.animationTimer invalidate];
    self.animationTimer = nil;
    [self removeAnimationView];

}

- (void)checkSeperatePassword:(NSString *)newPassword
{
    [self addAnimationView];
    if (![newPassword isEqualToString:self.password]) {
        self.password = newPassword;
        [[MCMailConfigManager shared] findMailConfigWithEmail:self.email forceUpdate:NO success:^(id response) {
            MCMailConfig *config  = [self qqConfig];
            [MCMailManager loginWithUserName:self.email password:self.password config:config success:^{
                [MCUmengManager addEventWithKey:mc_qq_loginSuc];
                [self.webView stopLoading];
                self.webView = nil;
                [self loginWithPassword:self.password];
                [self removeAnimationView];
            } failure:^(NSError *error) {
                [self removeAnimationView];
                [MCUmengManager addEventWithKey:mc_qq_loginfail];
            }];
        } failure:^(NSError *error) {
            [self removeAnimationView];

        }];
    }
}

- (void)checkAccountEmail:(NSString *)account
{
    ///登录页面和 授权页面账号不一致的情况，   要把self.email 修改成授权页面的
    if (![self.email isEqualToString:account]) {
        NSArray *accounts =[account componentsSeparatedByString:@"@"];
        NSArray *psws =[self.email componentsSeparatedByString:@"@"];
        self.email = [NSString stringWithFormat:@"%@@%@",accounts[0],[psws lastObject]];
    }
}


- (void)executeScripts
{
    NSString *jsPath = [[NSBundle mainBundle] pathForResource:@"qqLogin" ofType:@"js"] ;
    NSString *jsFunction= [NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:NULL];
    [_webView stringByEvaluatingJavaScriptFromString:jsFunction];
}

- (MCAccount *)accountWithEmail:(NSString *)email password:(NSString *)psw andConfig:(MCMailConfig *)config
{
    MCAccount *account = [[MCAccount alloc] init];
    account.authType = MCAccountAuthTypeIMAP;
    account.email = email;
    account.password = psw;
    account.displayName = [email mailName];
    account.type = MCMailTypeQQ;
    NSString *colorString = [MCAvatarHelper randomColorHexString];
    account.color = [UIColor colorWithHexString:colorString];
    account.signature = PMLocalizedStringWithKey(@"PM_Mail_Signature");
    account.config = config;
    
    return account;
}

- (MCMailConfig *)qqConfig
{
    MCMailConfigItem *imap = [MCMailConfigItem new];
    imap.hostName = @"imap.qq.com";
    imap.port = 993;
    imap.ssl = MCMailEncryptSSL;
    
    MCMailConfigItem *smtp = [MCMailConfigItem new];
    smtp.hostName = @"smtp.qq.com";
    smtp.port = 465;
    smtp.ssl = MCMailEncryptSSL;
    
    MCMailConfig *config = [[MCMailConfig alloc] init];
    config.imap = imap;
    config.smtp = smtp;
    config.mailType = MCMailTypeQQ;
    config.mailTypeKey = @"qq";
    
    return config;
}

- (void)loginWithPassword:(NSString *)pwd
{
    [MCUmengManager addEventWithKey:mc_qq_loginSuc];
    MCAccount *account = [self accountWithEmail:self.email password:pwd andConfig:[self qqConfig]];
    [self.delegate authViewController:self didAuthWithAccount:account];
}

#pragma mark - Helper
-(void)leftNavigationBarButtonItemAction:(id)sender
{
    [super leftNavigationBarButtonItemAction:sender];
    [MCUmengManager addEventWithKey:mc_qq_loginBack];
    [self.webView stopLoading];
    [SVProgressHUD dismiss];
}

-(void)rightNavigationBarButtonItemAction:(id)sender
{
    [self.loginManager loginAnonymousUserIfNeeded];
    //友盟统计
    [MCUmengManager addEventWithKey:mc_login_helper attributes:@{@"qq" : @"helper"}];
    MCContactModel *helperContact = [[MCContactManager sharedInstance] helperContact];
    MCIMConversationModel *conversationModel = [[MCIMConversationManager shared] conversationForContact:helperContact];
    MCIMChatViewController *vc =[[MCIMChatViewController alloc] initWithConversationModel:conversationModel];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)showMessageView:(NSArray *)phones title:(NSString *)title body:(NSString *)body
{
    if( [MFMessageComposeViewController canSendText] )
    {
        [MCUmengManager addEventWithKey:mc_qq_loginSMS];
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init];
        controller.recipients = phones;
        controller.body = body;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:^{
            [SVProgressHUD dismiss];

        }];
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:PMLocalizedStringWithKey(@"PM_Login_QQAuthUnSMS")
                                                       delegate:nil
                                              cancelButtonTitle:PMLocalizedStringWithKey(@"PM_Common_Sure")
                                              otherButtonTitles:nil, nil];
        [alert show];
        [SVProgressHUD dismiss];
    }

}

#pragma mark - help Button action
- (void)helpAction:(UIButton *)sender
{
    NSString *isNewAccount = [_webView stringByEvaluatingJavaScriptFromString:@"checkIsNewAccount()"];

    if ([isNewAccount containsString:@"不满14天"]) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 22, 22)];
        imageView.image = [UIImage imageNamed:@"net_err.png"];
        [_helpView addSubview:imageView];
            
        _helpView.backgroundColor = [UIColor colorWithHexString:@"fffadc"];
        [_helpLabel moveToX:50.0f];
        _helpLabel.text = @"账号密码满14天才能开启协议";
        sender.hidden = YES;
        
        RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Login_forgetSure")];
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_Login_AccountValidationFail") message:isNewAccount cancelButtonItem:cancelItem otherButtonItems:nil];
        [alertV show];
        return;
    }
    
    if (self.helpClicked) {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [MCUmengManager addEventWithKey:mc_login attributes:@{@"qq" : @"SMS"}];
        [self showMessageView:@[@"1069070069"] title:@"QQ Auth" body:@"配置邮件客户端"];
        return;
    }
    
    NSString * didClicked = [_webView stringByEvaluatingJavaScriptFromString:@"helpClick()"];
    if ([didClicked isEqualToString:@"true"]) {
        [MCUmengManager addEventWithKey:mc_login attributes:@{@"qq" : @"one helper"}];
        self.helpClicked = YES;
        _helpLabel.text = @"发送验证短信后点击‘我已发送’登录";
        _helpLabel.font = [UIFont systemFontOfSize:12.0f];
        sender.frame = CGRectMake(ScreenWidth -110, 7, 100, 30);
        [sender setTitle:PMLocalizedStringWithKey(@"PM_Login_QQAuthSMS") forState:UIControlStateNormal];
    }

}


-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultSent:{
            //信息发送成功
            [controller dismissViewControllerAnimated:YES completion:nil];
            _helpLabel.text = @"点击我已发送，即可登录邮洽";
        }
        break;
        case MessageComposeResultFailed:{
            //信息传送失败
            _helpLabel.text = @"发送验证短信后点击‘我已发送’登录";
            [controller dismissViewControllerAnimated:YES completion:nil];

        }
        break;
        case MessageComposeResultCancelled:{
        //信息被用户取消传送
            [controller dismissViewControllerAnimated:YES completion:nil];
        }
        break;
        default:
        break;
    }
}

-(UIView *)aniView
{
    return nil;
    if (!_aniView) {
        _aniView = [[UIView alloc] initWithFrame:self.view.bounds];
        _aniView.backgroundColor = [UIColor whiteColor];
        PQFBallDrop *ballDropView = [PQFBallDrop showLoaderOnView:_aniView];
        [ballDropView showLoader];
    }
    return _aniView;
}

- (void)addAnimationView
{
    return;
    [_aniView removeFromSuperview];
    _aniView = nil;
    [self.view addSubview:self.aniView];
}

- (void)removeAnimationView
{
    return;
    [_aniView removeFromSuperview];
    _aniView = nil;
}


#pragma mark - didReceiveMemoryWarning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
