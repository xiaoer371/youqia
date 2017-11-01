//
//  MCWorkspaceViewController.m
//  NPushMail
//
//  Created by wuwenyu on 16/7/19.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCWorkspaceViewController.h"
#import "MCJSApiManager.h"
#import "MCWorkSpaceManager.h"
#import "MCAccountConfig.h"
#import "MCServerAPI+OA.h"
#import "MCAppSetting.h"
#import "MCNotificationCenter.h"
#import "MCWebViewController.h"
#import "MCOALoginViewController.h"
#import "MCBaseNavigationViewController.h"
#import "MCOAConfig.h"
#import "MCAppDelegate.h"
#import "UIAlertView+Blocks.h"

@interface MCWorkspaceViewController ()<UIWebViewDelegate>

@property(nonatomic,strong)UIWebView *mainWebView;
@property(nonatomic,strong) MCJSApiManager *apiManager;
@property(nonatomic,strong) UIView *alertV;
@property(nonatomic,strong) UIButton *loginOaBtn;
@property(nonatomic,strong) UILabel *loadLabel;
@property(nonatomic,assign) BOOL currentCtrlShow;
@property(nonatomic,assign) BOOL oaUnBinding;
@property(nonatomic,strong) MCOALoginViewController *oaLoginCtrl;
@end

@implementation MCWorkspaceViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Load url
        [self commonInit];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.leftNavigationBarButtonItem setImage:nil];
    self.rightNavigationBarButtonItem.image = [[UIImage imageNamed:@"navbarReloadBtnBg.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.currentUserLable.text = AppStatus.currentUser.email;
    self.navBarTitleLable.text = PMLocalizedStringWithKey(@"PM_WorkSpace_Item");
    [self setRootCtrlNavigationBarTitleView];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.changeAccountArrow setHidden:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.currentCtrlShow = YES;
    MCAccountConfig *accountConfig = AppStatus.accountData.accountConfig;
    if (AppStatus.currentUser.isEIS) {
        if (!accountConfig.eisAccessToken) {
            _alertV.hidden = NO;
            _loadLabel.text = @"加载错误，请刷新重试";
        }
    }else {
        if (self.oaUnBinding) {
            [self oaUnBindingAlert];
        }
        if (!accountConfig.oaAccesstoken) {
            if (!accountConfig.isFirstSyncOAUser) {
                if (accountConfig.isOAUser) {
                    if (accountConfig.oaUserName && accountConfig.oaPassword) {
                        return;
                    }
                }
            }
            //需要去登录oa账号
            [self oapasswordNoInput];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.currentCtrlShow = NO;
}

//如果是还未登录的用户，则到登录页面
- (void)goToLoginOaCtrl {
    [self.view addSubview:self.oaLoginCtrl.view];
    [self addChildViewController:self.oaLoginCtrl];
}

- (MCOALoginViewController *)oaLoginCtrl {
    if (!_oaLoginCtrl) {
        MCAccountConfig *accountConfig = AppStatus.accountData.accountConfig;
        _oaLoginCtrl = [[MCOALoginViewController alloc] initWithOaUserName:accountConfig.oaUserName domin:accountConfig.oaDomin controllerSourceType:fromWorkSpaceType];
        _oaLoginCtrl.view.frame = self.view.bounds;
    }
    return _oaLoginCtrl;
}

- (void)refreshData {
    DDLogDebug(@"load workspace url");
    if (_oaLoginCtrl) {
        [_oaLoginCtrl willMoveToParentViewController:nil];
        [_oaLoginCtrl.view removeFromSuperview];
        [_oaLoginCtrl removeFromParentViewController];
        _oaLoginCtrl = nil;
    }
    MCAccountConfig *accountConfig = AppStatus.accountData.accountConfig;
    if (AppStatus.currentUser.isEIS) {
        //加载EIS首页
        [self loadEisHomePage];
    }else {
        //加载OA首页
        if (accountConfig.oaAccesstoken) {
            [self refreshOaHomeData];
        }else if (accountConfig.oaUserName && accountConfig.oaPassword) {
            [self oaLoginCheck];
        }
    }
}

- (void)refreshOaHomeData {
    _alertV.hidden = NO;
    _loadLabel.text = PMLocalizedStringWithKey(@"PM_Msg_MessageLoading");
    _loginOaBtn.hidden = YES;
    [self loadHomePage];
}

//WebView
- (UIWebView*)mainWebView
{

    if (!_mainWebView) {
        _mainWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth,ScreenHeigth - 64 - TOOLBAR_HEIGHT)];
        _mainWebView.delegate = self;
        _mainWebView.scalesPageToFit = YES;
        _mainWebView.backgroundColor = [UIColor clearColor];
    }
    return _mainWebView;
}

#pragma mark - webViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    _alertV.hidden = NO;
    _loadLabel.text = PMLocalizedStringWithKey(@"PM_Msg_MessageLoading");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    _alertV.hidden = YES;
    [SVProgressHUD dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    _loadLabel.text = PMLocalizedStringWithKey(@"PM_OA_LoadingFailMessage");
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL isHandled = [self.apiManager handleRequest:request];
    if (isHandled) {
        return NO;
    }
    
    NSString *requestString = [[request URL] absoluteString];
    NSRange range = [requestString rangeOfString:@"downloadAction.do"];
    if (range.location != NSNotFound) {
        MCWebViewController *webController = [[MCWebViewController alloc] initWithUrl:request.URL];
        [self.navigationController pushViewController:webController animated:YES];
        return NO;
    }
    
    if ([requestString hasSuffix:@"mailchaterror.html"]) {
        MCAccountConfig *config = AppStatus.accountData.accountConfig;
        config.isOAUser = NO;
        config.isFirstSyncOAUser = YES;
    }
    return YES;
}

- (void)rightNavigationBarButtonItemAction:(id)sender {
    _alertV.hidden = NO;
    _loginOaBtn.hidden = YES;
    _loadLabel.text = PMLocalizedStringWithKey(@"PM_Msg_MessageLoading");
    [self loginCheck];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MCNotificationDidChangeAccount object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)commonInit
{
    [self.view addSubview:self.mainWebView];
    self.apiManager = [[MCJSApiManager alloc] initWithWebView:self.mainWebView];
    
    _alertV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeigth)];
    _alertV.backgroundColor = [UIColor whiteColor];
    _loadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, ScreenWidth, 21)];
    _loadLabel.text = PMLocalizedStringWithKey(@"PM_Msg_MessageLoading");
    _loadLabel.textAlignment = NSTextAlignmentCenter;
    _loadLabel.textColor = [UIColor lightGrayColor];
    [_alertV addSubview:_loadLabel];
    [self.view addSubview:_alertV];
    
    _loginOaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _loginOaBtn.layer.cornerRadius = 5.0f;
    [_loginOaBtn setBackgroundColor:AppStatus.theme.tintColor];
    [_loginOaBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginOaBtn setTitle:PMLocalizedStringWithKey(@"PM_Login_LoginMail") forState:UIControlStateNormal];
    [_loginOaBtn addTarget:self action:@selector(goToLoginOaCtrl) forControlEvents:UIControlEventTouchUpInside];
    _loginOaBtn.frame = CGRectMake(20, CGRectGetMaxY(_loadLabel.frame) + 10, ScreenWidth - 20*2, 45);
    _loginOaBtn.hidden = YES;
    [_alertV addSubview:_loginOaBtn];
    
    DDLogDebug(@"load workspace url");
    [self loginCheck];
}

- (void)loginCheck {
    if (AppStatus.currentUser.isEIS) {
        [self eisReloginCheck];
    }else {
        [self oaLoginCheck];
    }
}

- (void)oaLoginCheck {
    MCAccountConfig *accountConfig = AppStatus.accountData.accountConfig;
    if (accountConfig.oaAccesstoken) {
        [MCOAWorkSpaceManager accesstokenExpireinProcessComplite:^(BOOL expirein) {
            if (expirein) {
                [MCOAWorkSpaceManager loginOaWithDomin:accountConfig.oaDomin accountConfig:accountConfig success:^(id response) {
                    //TODO 先判断错误码，如果需要重新到登录页面则到oa登录页面
                    MCOAConfig *oaConfig = (MCOAConfig *)response;
                    BOOL needUnBinding = [MCOAWorkSpaceManager isUnBindingWithAccountConfig:oaConfig];
                    if (!needUnBinding) {
                        if (oaConfig.oaUserLoginTypeType.errorcode == 12901) {
                            //密码错误，到重新绑定页面
                            DDLogInfo(@"OA密码错误，需重新登录");
                            [self oaPasswordWrong];
                        }else if(oaConfig.oaUserLoginTypeType.errorcode == 0){
                            DDLogVerbose(@"重新登录获取accesstoken成功");
                                [self loadHomePage];
                        }else {
                            NSString *errorMsg = [NSString stringWithFormat:@"%@%@",PMLocalizedStringWithKey(@"PM_OA_OaLoginFailed"), oaConfig.oaUserLoginTypeType.message];
                            DDLogWarn(@"%@", errorMsg);
                            _alertV.hidden = NO;
                            _loadLabel.text = errorMsg;
                        }

                    }else {
                        [self oaUnBindingAlert];
                    }
                    
                } failrue:^(NSError *error) {
                    _alertV.hidden = NO;
                    _loadLabel.text = @"登录错误，请刷新重试";
                }];
            }else {
                [self loadHomePage];
            }
        }];
    }else {
//        if (!accountConfig.isFirstSyncOAUser) {
//            
//        }
        if (accountConfig.isOAUser) {
            if (accountConfig.oaUserName && accountConfig.oaPassword) {
                //已经有oa账号，只是还未登录，直接去登录
                [self loginOaWithAccountConfig:accountConfig];
                return;
            }
        }
        //需要去登录oa账号
        [self oapasswordNoInput];
    }
}

- (void)loginOaWithAccountConfig:(MCAccountConfig *)accountConfig {
    //重新登录
    [MCOAWorkSpaceManager loginOaWithDomin:accountConfig.oaDomin accountConfig:accountConfig success:^(id response) {
        //TODO 先判断错误码，如果需要重新到登录页面则到oa登录页面
        MCOAConfig *oaConfig = (MCOAConfig *)response;
        BOOL needUnBinding = [MCOAWorkSpaceManager isUnBindingWithAccountConfig:oaConfig];
        if (!needUnBinding) {
            
            if (oaConfig.oaUserLoginTypeType.errorcode == 12901) {
                //密码错误，到重新绑定页面
                DDLogInfo(@"OA密码错误，需重新登录");
                [self oaPasswordWrong];
            } else if (oaConfig.oaUserLoginTypeType.errorcode == 0) {
                if (oaConfig.oaUserLoginTypeType.accesstoken) {
                    accountConfig.isFirstSyncOAUser = NO;
                    [self loadHomePage];
                }
            }else {
                //弹出错误提示
                NSString *errorMsg = [NSString stringWithFormat:@"OA登录失败:%@", oaConfig.oaUserLoginTypeType.message];
                DDLogWarn(@"%@", errorMsg);
            }
            
        }else {
            [self oaUnBindingAlert];
        }
        
    } failrue:^(NSError *error) {
        //错误提示：登录过期，请重试
    }];
}

- (void)oaPasswordWrong {
    self.oaLoginCtrl.loginInfoLabel.text = PMLocalizedStringWithKey(@"PM_OA_OaPasswordModify");
    [self goToLoginOaCtrl];
}

- (void)oapasswordNoInput {
    [self goToLoginOaCtrl];
//    _alertV.hidden = NO;
//    _loadLabel.text = PMLocalizedStringWithKey(@"PM_OA_OaNoLogin");
//    _loginOaBtn.hidden = NO;
}

- (void)oaUnBindingAlert {
    self.oaUnBinding = YES;
    if (self.currentCtrlShow) {
        __weak MCWorkspaceViewController *weakSelf = self;
        RIButtonItem *sureItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Sure") action:^{
            MCAccountConfig *accountConfig = AppStatus.accountData.accountConfig;
            accountConfig.isFirstSyncOAUser = YES;
            accountConfig.hasWorkspace = NO;
            accountConfig.isOAUser = NO;
            accountConfig.oaPassword = nil;
            accountConfig.oaAccesstoken = nil;
            weakSelf.oaUnBinding = NO;
            //重置OA状态
            [MCOAWorkSpaceManager resetOaWorkSpaceStatusWithAccount:AppStatus.currentUser];
            //当前设置为4个tab
            MCAppDelegate *del = (MCAppDelegate*)[UIApplication sharedApplication].delegate;
            [del setTabbarWithWorkspaceFlag:NO];
        }] ;
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_Common_Notice") message:PMLocalizedStringWithKey(@"PM_OA_CurrentUnBindingOa") cancelButtonItem:nil otherButtonItems:sureItem, nil];
        [alertV show];
    }
}   

- (void)loadHomePage {
    [self.mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[ServerAPI getOaHomePageResultUrl]]]];
}

#pragma  mark - EIS加载处理

- (void)eisReloginCheck {
    MCAccountConfig *accountConfig = AppStatus.accountData.accountConfig;
    MCAccount *currentAct = AppStatus.currentUser;
    [MCEisWorkSpaceManager accesstokenExpireinProcessComplite:^(BOOL expirein) {
        if (expirein) {
            [MCEisWorkSpaceManager reLoginEisWithAccountConfig:accountConfig act:currentAct success:^(id response) {
                [self loadEisHomePage];
            } failrue:^(NSError *error) {
                _alertV.hidden = NO;
                _loadLabel.text = @"加载错误，请刷新重试";
            }];
        }else {
            [self loadEisHomePage];
        }
    }];
}

- (void)loadEisHomePage {
    [self.mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[MCEisWorkSpaceManager getEisHomeUrl]]]];
}

@end
