//
//  MCLoginDetailViewController.m
//  NPushMail
//
//  Created by zhang on 16/1/18.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCLoginDetailViewController.h"
#import "MCImapHelpNoteViewController.h"
#import "MCServerViewController.h"
#import "MCLoginExtensionView.h"
#import "UIAlertView+Blocks.h"
#import "MCAppDelegate.h"
#import "MCLoginManager.h"
#import "MCAppStatus.h"
#import "MCSetAvatorViewController.h"
#import "MCAvatorInviteModel.h"
#import "MCServerAPI+Account.h"
#import "MailCore.h"
#import "MCMailManager.h"
#import "MCIMService.h"
#import "MCAppSetting.h"
#import "MCContactManager.h"
#import "MCIMChatViewController.h"
#import "MCIMConversationManager.h"
#import "MCAccountManager.h"
#import "MCAccountConfig.h"
#import "MCWebViewController.h"
#import "UIAlertView+Blocks.h"
#import "MCLoginQQAuthViewController.h" 
#import "UIView+MCExpand.h"
#import "MCGmailLoginViewController.h"
#import "MCOAConfig.h"
#import "MCWorkSpaceManager.h"
#import "MCServerAPI+OA.h"
#import "MCOABindingMailConfig.h"
#import "MCOABindingEmailLoginViewController.h"

static NSString * const kMCCMailRegistUrl = @"http://mail.35.com/guide/";

@interface MCLoginDetailViewController () <UITextFieldDelegate,MCLoginExtensionViewDelegate,MCLoginAuthViewControllerDelegate>

@property (nonatomic,strong) MCLoginExtensionView * mcLoginExtensionView;
@property (nonatomic,assign) BOOL isSecureTextEntry;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIImageView *accountImgView;
@property (weak, nonatomic) IBOutlet UIImageView *passwordImgView;
@property (weak, nonatomic) IBOutlet UIButton *clearAccounttf;
@property (strong, nonatomic) IBOutlet UILabel *showPWLabel;
@property (weak, nonatomic) IBOutlet UIButton *forgetBtn;
@property (weak, nonatomic) IBOutlet UIButton *showPWbtn;


@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UIView *loginButtonView;
@property (weak, nonatomic) IBOutlet UIButton *separatePasswrdBtn;
@property (weak, nonatomic) IBOutlet UIButton *helpBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginButtonViewYConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *helperXrConstraint;

@property (nonatomic,assign) BOOL useQQPassword; // 使用QQ独立密码登录

@end

@implementation MCLoginDetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    
}

- (void)setUp {
//    if (self.pushFromOaUpgradeCtrl) {
//        self.navigationController.
//        [self.leftNavigationBarButtonItem setImage:[UIImage imageNamed:@"sadsad.png"]];
//    }
    _accountImgView.image = AppStatus.theme.accountImage;
    _passwordImgView.image = AppStatus.theme.passwordImage;
    [_clearAccounttf setImage: AppStatus.theme.accountClearImage forState:UIControlStateNormal];
    
    _lineSp1.backgroundColor       = [UIColor colorWithHexString:@"d8d8d8"];
    _lineSp2.backgroundColor       = [UIColor colorWithHexString:@"d8d8d8"];
    _userNameTextField.placeholder = PMLocalizedStringWithKey(@"PM_Login_Account");
    
    if(self.emailType == MCMailType163)
    {   _passWordTextField.placeholder = PMLocalizedStringWithKey(@"PM_Login_PasswordWY");
    }else if(self.emailType == MCMailTypeQQ){
        _passWordTextField.placeholder = PMLocalizedStringWithKey(@"PM_Login_QQPWPlaceholder");
    }else if(self.emailType == MCMailTypeOALogin){
        _userNameTextField.placeholder = PMLocalizedStringWithKey(@"PM_Login_OA_Placeholder");
        _passWordTextField.placeholder = PMLocalizedStringWithKey(@"PM_Login_OA_InputPassword");
        [_forgetBtn setHidden:YES];
    }else {
        _passWordTextField.placeholder = PMLocalizedStringWithKey(@"PM_Login_PassWord");
    }
    
    _showPWLabel.text = PMLocalizedStringWithKey(@"PM_Login_showPassword");
    _userNameTextField.textColor   = [UIColor colorWithHexString:@"343434"];
    _passWordTextField.textColor   = [UIColor colorWithHexString:@"343434"];
    _helpNoteText.textColor        = AppStatus.theme.fontTintColor;
    [_forgetBtn setTitle:PMLocalizedStringWithKey(@"PM_Login_forgetPassword") forState:UIControlStateNormal];
    [_forgetBtn setTitleColor:AppStatus.theme.tintColor forState:UIControlStateNormal];
    _forgetBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    _showPassWordButton.adjustsImageWhenHighlighted = NO;
    [_showPassWordButton setImage:AppStatus.theme.passwordHidImage forState:UIControlStateNormal];
    _loginButton.layer.cornerRadius = 5.0f;
    [_loginButton setTitle:PMLocalizedStringWithKey(@"PM_Login_LoginMail") forState:UIControlStateNormal];
    
    _loginButton.backgroundColor = AppStatus.theme.tintWeakColor;
    _loginButton.enabled = NO;
    
    _userNameTextField.delegate = self;
    [_userNameTextField becomeFirstResponder];
    _passWordTextField.delegate = self;
    _passWordTextField.clearsOnBeginEditing = NO;
    self.viewTitle = PMLocalizedStringWithKey(@"PM_Login_LoginMail");
    
    NSString *string =PMLocalizedStringWithKey(@"PM_Login_HelperText");
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:string];
    NSRange range =[string rangeOfString:PMLocalizedStringWithKey(@"PM_Login_Helper")];
    [attriString addAttribute:NSForegroundColorAttributeName value:AppStatus.theme.tintColor range:range];
    _helpBtn.titleLabel.textColor = AppStatus.theme.fontTintColor;
    [_helpBtn setAttributedTitle:attriString forState:(UIControlStateNormal)];
    _helpBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    
    [_separatePasswrdBtn setTitle:PMLocalizedStringWithKey(@"PM_Login_QQPassWordLogin") forState:UIControlStateNormal];
    [_separatePasswrdBtn setTitleColor:AppStatus.theme.tintColor forState:UIControlStateNormal];
    
    self.rightNavigationBarButtonItem.title = PMLocalizedStringWithKey(@"PM_IMLogin_regist");
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //注册UITextFieldTextDidChangeNotification
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:_userNameTextField];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.emailType == MCMailTypeQQ) {
        [self showQQOAuthAnimatied:YES];
    }
}


- (void)showQQOAuthAnimatied:(BOOL)animated
{
    if (!self.passwordView.hidden) {
        self.loginButtonViewYConstraint.constant = -self.passwordView.bounds.size.height;
        self.helperXrConstraint.constant = 120;
        _helpBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    
    self.passwordView.hidden = YES;
    self.separatePasswrdBtn.hidden = NO;
    [self.loginButton setTitle:PMLocalizedStringWithKey(@"PM_Login_QQAuthLogin") forState:UIControlStateNormal];
    [self.separatePasswrdBtn setTitle:PMLocalizedStringWithKey(@"PM_Login_PassWordLogin") forState:UIControlStateNormal];
    
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    else {
        [self.view layoutIfNeeded];
    }
}

- (void)showQQPasswordAnimated:(BOOL)animated
{
    self.passwordView.hidden = NO;
    
    self.loginButtonViewYConstraint.constant = 0;
    [self.separatePasswrdBtn setTitle:PMLocalizedStringWithKey(@"PM_Login_AuthLogin") forState:UIControlStateNormal];
    
    self.separatePasswrdBtn.hidden = NO;
    self.helperXrConstraint.constant = 120;
    _helpBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    [self.loginButton setTitle:PMLocalizedStringWithKey(@"PM_Login_LoginMail") forState:UIControlStateNormal];
    self.loginButton.backgroundColor = AppStatus.theme.tintColor;
    self.loginButton.enabled = YES;
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    else {
        [self.view layoutIfNeeded];
    }
    
    
    [MCUmengManager addEventWithKey:mc_login attributes:@{@"qq" : @"separate"}];
}

- (void)showGmailOAuthAnimated:(BOOL)animated
{
    self.loginButtonViewYConstraint.constant = -self.passwordView.bounds.size.height;
    self.helperXrConstraint.constant = 30;
    _helpBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    
    self.passwordView.hidden = YES;
    self.separatePasswrdBtn.hidden = YES;
    [self.loginButton setTitle:PMLocalizedStringWithKey(@"PM_Login_GmailAuth") forState:UIControlStateNormal];
   
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    else {
        [self.view layoutIfNeeded];
    }
}


- (void)showNormalView:(BOOL)animated
{
    self.passwordView.hidden = NO;
    self.loginButtonViewYConstraint.constant = 0;
    self.separatePasswrdBtn.hidden = YES;
    
    self.helperXrConstraint.constant = 30;
    _helpBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    [self.loginButton setTitle:PMLocalizedStringWithKey(@"PM_Login_LoginMail") forState:UIControlStateNormal];
    self.passWordTextField.placeholder = PMLocalizedStringWithKey(@"PM_Login_PassWord");
    self.loginButton.backgroundColor = AppStatus.theme.tintColor;
    self.loginButton.enabled = YES;
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    else {
        [self.view layoutIfNeeded];
    }
}

#pragma mark - buttonAction

- (IBAction)showPassWord:(UIButton*)sender {
    
    sender.selected = !sender.selected;
    _passWordTextField.secureTextEntry = _isSecureTextEntry;
    _isSecureTextEntry = !_isSecureTextEntry;
}
- (IBAction)forgetPasswordAction:(UIButton *)sender {
    
    [self.view endEditing:YES];
    NSString * message;
    if (self.emailType == MCMailType35_30) {
        message = PMLocalizedStringWithKey(@"PM_Login_passwordNoticeE");
    }else{
        message = PMLocalizedStringWithKey(@"PM_Login_passwordNoticep");
    }

    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Login_forgetSure")];
    UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_Common_Notice") message:message cancelButtonItem:cancelItem otherButtonItems:nil];
    [alertV show];

    //友盟统计
    [MCUmengManager addEventWithKey:mc_login_forget];

}

- (IBAction)onHelper:(id)sender
{
    [self connectHelp];
}

#pragma mark - MCLoginAuthViewControllerDelegate
- (void)authViewController:(UIViewController *)vc didAuthWithAccount:(MCAccount *)account
{
    MCLoginManager *loginManager = [[MCLoginManager alloc] init];
    [loginManager loginWithValidatedAccount:account success:^(id response) {
        if ([account.email isQQEmail]) {
            [MCUmengManager addEventWithKey:mc_login attributes:@{@"qq" : @"success"}];
        }
        [self loginSuccessAcccount:account];
    } failure:^(NSError *error) {
        [self.navigationController popToViewController:self animated:YES];
        [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_Login_LoginError")];
    }];
}

- (void)authViewController:(UIViewController *)vc didFailedWithError:(NSError *)error
{
    [self.navigationController popToViewController:self animated:YES];
    [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_Login_LoginError")];
}

#pragma mark - 登录账户
- (IBAction)loginMailAccount:(UIButton *)sender {
    
    [self.view endEditing:YES];
    
    NSString *email = self.userNameTextField.text;
    // QQ  授权码
    if ([sender.currentTitle isEqualToString:PMLocalizedStringWithKey(@"PM_Login_QQAuthLogin")]) {
        self.emailType = MCMailTypeQQ;
        [MCUmengManager addEventWithKey:mc_qq_loginAuth];
        MCLoginQQAuthViewController *vc = [[MCLoginQQAuthViewController alloc] initWithEmail:self.userNameTextField.text];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([email isGmailEmail]) {
        self.emailType = MCMailTypeGmail;
        [self loginGmailEmail:email];
    }
    else {
        [self loginMail];
    }
}




- (IBAction)useqqPW:(UIButton *)sender {
    
    self.useQQPassword = !self.useQQPassword;
    if (self.useQQPassword) {
        [self showQQPasswordAnimated:YES];
    }
    else {
        [self showQQOAuthAnimatied:YES];
    }
    
}

- (void)loginMail
{
    //账号或密码不能为空
    if ([_userNameTextField.text trim].length == 0
        ||[_passWordTextField.text trim].length == 0) {
        [SVProgressHUD showInfoWithStatus:PMLocalizedStringWithKey(@"PM_Login_AccountOrPassWordNil")];
        return;
    }
    //判断邮箱格式是否正确
    if (![self.userNameTextField.text isEmail]) {
        [SVProgressHUD showInfoWithStatus:PMLocalizedStringWithKey(@"PM_MailAccontCKNote")];
        return;
    }
    
    if (self.emailType == MCMailTypeOALogin) {
        if ([MCOAWorkSpaceManager isExistOaUserInLocalSpaceWithOaUserName:[self.userNameTextField.text trim]]) {
            [SVProgressHUD showInfoWithStatus:@"本地已存在该OA账号，请勿重复登录."];
            return;
        }
        //登录oa,获取accesstoken和绑定的邮箱，用绑定的邮箱登录邮洽
        [SVProgressHUD showWithStatus:PMLocalizedStringWithKey(@"PM_Login_AccountValidation") maskType:SVProgressHUDMaskTypeClear];
        NSRange range = [self.userNameTextField.text rangeOfString:@"@"];
        NSString *domin = [self.userNameTextField.text substringFromIndex:(range.location + 1)];
        [ServerAPI loginOaWithUserName:self.userNameTextField.text password:self.passWordTextField.text domin:domin success:^(id response) {
            MCOAConfig *oaConfig = (MCOAConfig *)response;
            if (oaConfig.oaUserLoginTypeType.success) {
                NSString *bindMail = oaConfig.oaUserLoginTypeType.bindmail;
                if (oaConfig.oaUserLoginTypeType.is35mail) {
                    //如果oa账号本身也是邮箱账号，就不再注册新的邮箱了.
                    bindMail = self.userNameTextField.text;
                }
                //登录成功，获取oa用户绑定的邮箱(无论是否已经绑定过邮箱，都需调用以下验证接口)，登录邮洽
                [ServerAPI getOaBindingMailWithMail:bindMail oaUserName:self.userNameTextField.text oaPassword:self.passWordTextField.text  success:^(id response) {
                    MCOABindingMailConfig *oaBindingConfig = (MCOABindingMailConfig *)response;
                    if (bindMail && bindMail.length > 0) {
                        [SVProgressHUD dismiss];
                        //已经有邮箱了，则去登录
                        [self goLoginOaBindingEmailWithOaConfig:oaConfig email:bindMail password:nil];
                    }else {
                        //没有邮箱则服务器创建一个临时邮箱登录
                        if (oaBindingConfig.email) {
                            //创建邮箱成功，密码与oa账号的密码一致.
                            [SVProgressHUD dismiss];
                            [self goLoginOaBindingEmailWithOaConfig:oaConfig email:oaBindingConfig.email password:self.passWordTextField.text];
                        }else {
                            DDLogError(@"临时邮箱获取失败，请重试");
                            [SVProgressHUD showInfoWithStatus:@"临时邮箱获取失败，请重试"];
                        }
                    }
                    
                } failrue:^(NSError *error) {
                    NSString *message = error.userInfo[MCOIMAPResponseKey];
                    [SVProgressHUD showInfoWithStatus:message];
                }];

            }else {
                //登录失败
                DDLogWarn(@"oa登录失败，错误码:%d", oaConfig.oaUserLoginTypeType.errorcode);
                [SVProgressHUD showInfoWithStatus:oaConfig.oaUserLoginTypeType.message];
            }
            
        } failrue:^(NSError *error) {
            DDLogWarn(@"oa登录失:%@", error);
            [SVProgressHUD showInfoWithStatus:@"验证失败，请检查用户名和密码"];
        }];
        return;
    }
    
    [self loginAccountEmail:self.userNameTextField.text passWord:self.passWordTextField.text success:^(id response) {
        [self loginSuccessAcccount:response];
    } failure:^(NSError *error) {
        
    }];
}

- (void)goLoginOaBindingEmailWithOaConfig:(MCOAConfig *)oaConfig email:(NSString *)email password:(NSString *)pwd {
    MCOABindingEmailLoginViewController *v = [[MCOABindingEmailLoginViewController alloc] initWithOaConfig:oaConfig email:email password:pwd oaUserName:self.userNameTextField.text oaPassword:self.passWordTextField.text];
    [self.navigationController pushViewController:v animated:YES];
}

#pragma mark-UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([string isEqualToString:@"\n"]){
        
        if (_userNameTextField == textField) {
            if (_mcLoginExtensionView) {
                _mcLoginExtensionView.hidden = YES;
            }
            [_passWordTextField becomeFirstResponder];
        } else {
            [self loginMailAccount:nil];
        }
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if(textField == _userNameTextField){
        _passWordTextField.text = @"";
    }
    return YES;
}
- (void)textFieldDidChange:(NSNotification*)notification {
    NSString *emailString = self.userNameTextField.text;
    if(self.emailType != MCMailTypeOALogin) {
        if (!_mcLoginExtensionView) {
            _mcLoginExtensionView = [[MCLoginExtensionView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_userNameTextField.frame)+12, ScreenWidth, ScreenHeigth - (self.userNameTextField.frame.origin.y + self.userNameTextField.frame.size.height + 65)) EmailType:self.selectIndex];
            _mcLoginExtensionView.delegate = self;
            [self.view addSubview:_mcLoginExtensionView];
        }
        _mcLoginExtensionView.email = self.userNameTextField.text;
    }
    
    if (![emailString isEmail]) {
        _loginButton.backgroundColor = AppStatus.theme.tintWeakColor;
        _loginButton.enabled = NO;
    }
    else {
        if(self.emailType != MCMailTypeOALogin) {
            [self changeViewViaEmail:emailString];
        }else {
            _loginButton.backgroundColor = AppStatus.theme.tintColor;
            _loginButton.enabled = YES;
        }
    }
}

- (void)changeViewViaEmail:(NSString *)email
{
    _loginButton.backgroundColor = AppStatus.theme.tintColor;
    _loginButton.enabled = YES;
    
    if ([email isQQEmail] ) {
        if (!self.useQQPassword) {
            [self showQQOAuthAnimatied:YES];
        }
        else {
            [self showQQPasswordAnimated:YES];
        }
    }
    else if ([email isGmailEmail]) {
        [self showGmailOAuthAnimated:YES];
    }
    else {
        [self showNormalView:YES];
    }
}

#pragma mark - MCLoginExtensionViewDelegate 

- (void)mcLoginExtensionView:(MCLoginExtensionView *)extensionView didSelectEmail:(NSString *)email {
    self.userNameTextField.text = email;
    [self changeViewViaEmail:email];
    
    [self.userNameTextField becomeFirstResponder];
}

//back
#pragma mark - left/right  NavigationBarButtonItemAction
- (void)leftNavigationBarButtonItemAction:(id)sender {
    if (self.pushFromOaUpgradeCtrl) {
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightNavigationBarButtonItemAction:(id)sender
{
//    跳转至35企业邮箱宣传页
    MCWebViewController *webController = [[MCWebViewController alloc] initWithUrl:[NSURL URLWithString:kMCCMailRegistUrl]];
    [self.navigationController pushViewController:webController animated:YES];
    
    [MCUmengManager addEventWithKey:mc_login_regist];
}

#pragma mark - error


@end
