//
//  MCOABindingEmailLoginViewController.m
//  NPushMail
//
//  Created by wuwenyu on 16/11/23.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCOABindingEmailLoginViewController.h"
#import "UILabel+Common.h"
#import "MCLoginManager.h"
#import "MCContactManager.h"
#import "MCAppDelegate.h"
#import "MCAccountManager.h"
#import "MCSetAvatorViewController.h"
#import "MCAccountConfig.h"
#import "MCWorkSpaceManager.h"
#import "MCOConstants.h"
#import "UIAlertView+Blocks.h"
#import "MCImapHelpNoteViewController.h"
#import "MCServerViewController.h"
#import "MCLoginQQAuthViewController.h"

@interface MCOABindingEmailLoginViewController ()
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *oaUserName;
@property (nonatomic, strong) NSString *oaPassword;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIImageView *alertBgView;
@property (nonatomic, strong) UILabel *alertLabel;
@property (nonatomic, strong) UIView *passwordLineView;
@property (nonatomic, strong) MCOAConfig *oaConfig;
@end

static const CGFloat titleOriginY = 30;
static const CGFloat textFieldOriginX = 15;
static const CGFloat alertBgViewOriginX = 30;

@implementation MCOABindingEmailLoginViewController

- (id)initWithOaConfig:(MCOAConfig *)oaConfig email:(NSString *)email password:(NSString *)password oaUserName:(NSString *)oaUserName oaPassword:(NSString *)oaPassword {
    self = [super init];
    if (self) {
        _email = email;
        _password = password;
        _oaUserName = oaUserName;
        _oaPassword = oaPassword;
        _oaConfig = oaConfig;
        if ([email isQQEmail]) {
            self.emailType = MCMailTypeQQ;
        }else if ([email isNetEastMail]){
            self.emailType = MCMailType163;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    // Do any additional setup after loading the view from its nib.
}

- (void)loadSubViews {
    self.viewTitle = PMLocalizedStringWithKey(@"PM_OA_LoginTitle");
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, titleOriginY, ScreenWidth, 21)];
    _titleLabel.numberOfLines = 0;
    _titleLabel.font = [UIFont systemFontOfSize:20.0f];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    NSString *title = nil;
    if (!_password) {
        title = PMLocalizedStringWithKey(@"PM_OA_InputOaAccount");
        _titleLabel.font = [UIFont systemFontOfSize:20.0f];

    }else {
        title = PMLocalizedStringWithKey(@"PM_OA_EmailRegisterSuccess");
        _titleLabel.font = [UIFont systemFontOfSize:23.0f];
    }
    _titleLabel.text = title;
    CGSize titleSize = [_titleLabel estimateUISizeByWidth:CGRectGetWidth(_titleLabel.frame)];
    _titleLabel.frame = CGRectMake(0, titleOriginY, ScreenWidth, titleSize.height);
    
    _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_titleLabel.frame), ScreenWidth, 21)];
    _subTitleLabel.numberOfLines = 0;
    _subTitleLabel.font = [UIFont systemFontOfSize:18.0f];
    _subTitleLabel.textAlignment = NSTextAlignmentCenter;
    _subTitleLabel.text = [NSString stringWithFormat:@"(%@)%@", _email, PMLocalizedStringWithKey(@"PM_Login_PassWord")];
    CGSize subTitleSize = [_subTitleLabel estimateUISizeByWidth:CGRectGetWidth(_subTitleLabel.frame)];
    _subTitleLabel.frame = CGRectMake(0, CGRectGetMaxY(_titleLabel.frame), ScreenWidth, subTitleSize.height);

    _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(textFieldOriginX, CGRectGetMaxY(_subTitleLabel.frame) + 10, ScreenWidth - textFieldOriginX*2, 44)];
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField.borderStyle = UITextBorderStyleNone;
    _passwordTextField.placeholder = PMLocalizedStringWithKey(@"PM_OA_EmailLoginPassword");

    _passwordLineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_passwordTextField.frame), CGRectGetMaxY(_passwordTextField.frame) - 1, CGRectGetWidth(_passwordTextField.frame), 1)];
    _passwordLineView.backgroundColor = [UIColor colorWithHexString:@"d8d8d8"];

    _alertBgView = [[UIImageView alloc] initWithFrame:CGRectMake(alertBgViewOriginX, CGRectGetMaxY(_titleLabel.frame) + 42, ScreenWidth - alertBgViewOriginX*2, 0)];
    _alertBgView.image = [[UIImage imageNamed:@"oaRegNoteBg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    
    NSString *str =  [NSString stringWithFormat:@"%@%@\n%@\n%@", PMLocalizedStringWithKey(@"PM_OA_EmailRegisterNote1"), _email, PMLocalizedStringWithKey(@"PM_OA_EmailRegisterNote2"), PMLocalizedStringWithKey(@"PM_OA_EmailRegisterNote3")];
    NSRange emailRange = [str rangeOfString:_email];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:str];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:20];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, str.length)];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15.0f] range:NSMakeRange(0, str.length)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"0x313131"] range:NSMakeRange(0, str.length)];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:emailRange];
    _alertLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, 20, CGRectGetWidth(_alertBgView.frame) - 20*2, 0)];
    _alertLabel.numberOfLines = 0;
    _alertLabel.attributedText = attrStr;
    _alertLabel.textAlignment = NSTextAlignmentCenter;
    [_alertLabel sizeToFit];
    CGSize alertLabelSize = _alertLabel.frame.size;
    if (alertLabelSize.width < (CGRectGetWidth(_alertBgView.frame) - 20*2)) {
        _alertLabel.frame = CGRectMake((CGRectGetWidth(_alertBgView.frame) - alertLabelSize.width)/2, 25, alertLabelSize.width, alertLabelSize.height);
    }
    _alertBgView.frame = CGRectMake(alertBgViewOriginX, CGRectGetMaxY(_titleLabel.frame) + 30, ScreenWidth - alertBgViewOriginX*2, CGRectGetHeight(_alertLabel.frame) + CGRectGetMinY(_alertLabel.frame) + 25);
    
    [_alertBgView addSubview:_alertLabel];
    _alertBgView.hidden = YES;
    
    _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_loginBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    [_loginBtn setTitle:PMLocalizedStringWithKey(@"PM_Login_LoginMail") forState:UIControlStateNormal];
    _loginBtn.layer.cornerRadius = 5.0f;
    _loginBtn.backgroundColor = AppStatus.theme.tintColor;
    if (_password) {
        [_loginBtn setTitle:PMLocalizedStringWithKey(@"PM_Login_MailChat") forState:UIControlStateNormal];
        _alertBgView.hidden = NO;
        _passwordLineView.hidden = YES;
        _subTitleLabel.hidden = YES;
        _passwordTextField.hidden = YES;
        _loginBtn.frame = CGRectMake(CGRectGetMinX(_alertBgView.frame), CGRectGetMaxY(_alertBgView.frame) + 20, ScreenWidth - CGRectGetMinX(_alertBgView.frame)*2, 44);
    }else {
        _loginBtn.frame = CGRectMake(CGRectGetMinX(_passwordTextField.frame), CGRectGetMaxY(_passwordTextField.frame) +20, ScreenWidth - CGRectGetMinX(_passwordTextField.frame)*2, 44);
    }
    
    [self.view addSubview:_titleLabel];
    [self.view addSubview:_subTitleLabel];
    [self.view addSubview:_passwordLineView];
    [self.view addSubview:_alertBgView];
    [self.view addSubview:_passwordTextField];
    [self.view addSubview:_loginBtn];
    
}

- (void)loginAction {
    [SVProgressHUD showWithStatus:PMLocalizedStringWithKey(@"PM_Login_AccountValidation") maskType:SVProgressHUDMaskTypeClear];
    NSString *pwd = _password;
    if (!_password) {
        if ([[_passwordTextField.text trim] length] == 0) {
            [SVProgressHUD showInfoWithStatus:PMLocalizedStringWithKey(@"PM_ReLogin_PasswordWY")];
            return;
        }
        pwd = [_passwordTextField.text trim];
    }
    
    [self.passwordTextField resignFirstResponder];
    
    MCAppDelegate*mcAppDelegate = (MCAppDelegate*)[UIApplication sharedApplication].delegate;
    if (mcAppDelegate.tabBarController) {
        mcAppDelegate.tabBarController.needCheckWorkSpaceWhenAccountChange = NO;
    }
    
    //若本地已经存在该邮箱，则直接切换即可
    NSArray *accounts = [[MCAccountManager shared] getAllAccounts];
    for (MCAccount *account in accounts) {
        if ([account.email isEqualToString:_email]) {
            [self.loginManager loginWithAccount:account];
            [self settingOaConfigWithEmailLoginType:1];
            [self loadMainViewController];
            return;
        }
        //友盟统计
        [MCUmengManager addEventWithKey:mc_me_change];
    }
    [self loginAccountEmail:_email passWord:pwd success:^(id response) {
        [self settingOaConfigWithEmailLoginType:1];
        if (mcAppDelegate.tabBarController) {
            mcAppDelegate.tabBarController.needCheckWorkSpaceWhenAccountChange = YES;
        }
        //插入小助手帐号
        [self loginSuccessAcccount:(MCAccount*)response];
    } failure:^(NSError *error) {
        
    }];
}

- (void)settingOaConfigWithEmailLoginType:(int)emailLoginType {
    MCAccount *act = AppStatus.currentUser;
    int oaUserType = 1;
    if ([act.email isEqualToString:_oaUserName]) {
        oaUserType = 0;
    }
    MCAccountConfig *accountConfig = AppStatus.accountData.accountConfig;
    NSRange range = [_oaUserName rangeOfString:@"@"];
    NSString *domin = [_oaUserName substringFromIndex:(range.location + 1)];
    
    accountConfig.oaAccesstoken = _oaConfig.oaUserLoginTypeType.accesstoken;
    accountConfig.oaAccesstokenExpireinTime = _oaConfig.oaUserLoginTypeType.expireinTime;
    accountConfig.oaAccesstokenCreatetime = _oaConfig.oaUserLoginTypeType.createtime;
    accountConfig.isFirstSyncOAUser = NO;
    accountConfig.oaUserType = oaUserType;
    accountConfig.isOAUser = YES;
    accountConfig.oaDomin = domin;
    accountConfig.oaUserName = _oaUserName;
    accountConfig.oaPassword = _oaPassword;
    accountConfig.emailLoginType = emailLoginType;
    accountConfig.hasWorkspace = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
