//
//  MCOALoginViewController.m
//  NPushMail
//
//  Created by wuwenyu on 16/5/31.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCOALoginViewController.h"
#import "NSString+Extension.h"
#import "MCAccountConfig.h"
#import "MCServerAPI+OA.h"
#import "MCOAConfig.h"
#import "MCOAWebViewController.h"
#import "MCAppSetting.h"
#import "MCWorkSpaceManager.h"
#import "UIAlertView+Blocks.h"
#import "MCAppDelegate.h"

#define Alert(TITLE,MSG) [[[UIAlertView alloc] initWithTitle:(TITLE) \
message:(MSG) \
delegate:nil \
cancelButtonTitle:@"确认" \
otherButtonTitles:nil] show]

@interface MCOALoginViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *showPasswordBtn;
@property (weak, nonatomic) IBOutlet UILabel *showPwdTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (strong, nonatomic) NSString *domin;
@property (assign ,nonatomic) controllerSourceType ctrlType;
- (IBAction)loginAction:(id)sender;
- (IBAction)showPasswordAction:(id)sender;

@end

@implementation MCOALoginViewController {
    NSString *_oaName;
    BOOL _keyBoardIsShow;
}

- (id)initWithOaUserName:(NSString *)oaName domin:(NSString *)domin controllerSourceType:(controllerSourceType)ctrlType {
    if (self = [super init]) {
        _oaName = oaName;
        _domin = domin;
        _ctrlType = ctrlType;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerKeyBoardNotification];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeKeyBoardNotification];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewTitle = @"登录OA";
    [self loadSubViews];
}

#pragma mark - 键盘事件处理
//注册键盘事件通知,之后在之类无需在处理类似的通用事件
- (void)registerKeyBoardNotification{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillChangeFrame:)
                                                 name:@"UIKeyboardWillChangeFrameNotification" object:nil];
    
}

//注销键盘通知
- (void)removeKeyBoardNotification{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIKeyboardWillChangeFrameNotification"
                                                  object:nil];
    
}

- (void)loadSubViews {
    _loginInfoLabel.text = [NSString stringWithFormat:@"当前邮箱已绑定OA账号:%@", _oaName];
    _passwordTextField.placeholder = @"请输入OA密码";
    _passwordTextField.delegate = self;
    _passwordTextField.textColor = AppStatus.theme.fontTintColor;
    _showPwdTitleLabel.text = @"显示密码";
    _showPwdTitleLabel.textColor = AppStatus.theme.fontTintColor;
    
    _loginBtn.layer.cornerRadius = 5.0f;
    _loginBtn.backgroundColor = AppStatus.theme.tintColor;
    [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginAction:(id)sender {
    [_passwordTextField resignFirstResponder];
    if ([_passwordTextField.text length] == 0) {
        Alert(@"提示", @"请输入密码");
        [_passwordTextField becomeFirstResponder];
        return;
    }
    [self loginOa];
}

- (IBAction)showPasswordAction:(id)sender {
    [_showPasswordBtn setSelected:!_showPasswordBtn.isSelected];
    _passwordTextField.secureTextEntry = YES;
    if (_showPasswordBtn.isSelected) {
        _passwordTextField.secureTextEntry = NO;
    }
}

- (void)loginOa {
    [SVProgressHUD showWithStatus:PMLocalizedStringWithKey(@"PM_Msg_MessageLoading")];
    
    MCAccountConfig *accountConfig = AppStatus.accountData.accountConfig;
    accountConfig.oaPassword = self.passwordTextField.text;
    __weak MCOALoginViewController *weakSelf = self;
    [MCOAWorkSpaceManager loginOaWithDomin:self.domin accountConfig:accountConfig success:^(id response) {
        [SVProgressHUD dismiss];
        MCOAConfig *oaConfig = (MCOAConfig *)response;
        if ([MCOAWorkSpaceManager isUnBindingWithAccountConfig:oaConfig]) {
            //解绑
            RIButtonItem *sureItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Sure") action:^{
                if (weakSelf.ctrlType == fromWorkSpaceType) {
                    MCAccountConfig *accountConfig = AppStatus.accountData.accountConfig;
                    accountConfig.isFirstSyncOAUser = YES;
                    accountConfig.hasWorkspace = NO;
                    accountConfig.isOAUser = NO;
                    accountConfig.oaPassword = nil;
                    accountConfig.oaAccesstoken = nil;
                    [MCOAWorkSpaceManager resetOaWorkSpaceStatusWithAccount:AppStatus.currentUser];
                    //当前设置为4个tab
                    MCAppDelegate *del = (MCAppDelegate*)[UIApplication sharedApplication].delegate;
                    [del setTabbarWithWorkspaceFlag:NO];
                }else {
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
                
            }] ;
            UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_Common_Notice") message:PMLocalizedStringWithKey(@"PM_OA_CurrentUnBindingOa") cancelButtonItem:nil otherButtonItems:sureItem, nil];
            [alertV show];
            return;
        }
        if (oaConfig.oaUserLoginTypeType) {
            if (oaConfig.oaUserLoginTypeType.errorcode != 0) {
                //校验失败
                Alert(@"提示", oaConfig.oaUserLoginTypeType.message);
            }else {
                accountConfig.isFirstSyncOAUser = NO;
                accountConfig.isOAUser = YES;
                accountConfig.hasWorkspace = YES;
                if (weakSelf.ctrlType == fromWorkSpaceType) {
                    [MCOAWorkSpaceManager refreshWorkSpaceData];
                    [weakSelf willMoveToParentViewController:nil];
                    [weakSelf.view removeFromSuperview];
                    [weakSelf removeFromParentViewController];
                }else {
                    MCOAWebViewController *v = [[MCOAWebViewController alloc] init];
                    //如果是OA用户
                    v.destinationUrl = [ServerAPI getOaResultUrlWithPayloadUrl:nil isMQTT:YES withEndUrlType:OATrans];
                    v.needBackRootCtrl = YES;
                    [weakSelf.navigationController pushViewController:v animated:YES];
                }
            }
        }else {
            Alert(@"提示", @"登录出错请重试");
        }

    } failrue:^(NSError *error) {
        Alert(@"提示", @"接口调用失败,请重试");
        [SVProgressHUD dismiss];
    }];
}

- (void)onKeyboardWillShow:(NSNotification *)note {
    if (!_keyBoardIsShow) {
        if (iPhone4) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            CGRect frame = self.view.frame;
            frame.origin.y -= 50;
            self.view.frame = frame;
            [UIView commitAnimations];
            _keyBoardIsShow = YES;
        }
    }
}

- (void)onKeyboardWillHide:(NSNotification *)note {
    if (iPhone4) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        CGRect frame = self.view.frame;
        frame.origin.y += 50;
        self.view.frame = frame;
        [UIView commitAnimations];
        _keyBoardIsShow = NO;
    }
}

- (void)onKeyboardWillChangeFrame:(NSNotification *)note {
    
}

#pragma mark - Touches events.

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return TRUE;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [[self findFirstResponder:self.view]  resignFirstResponder];
}

- (UIView *)findFirstResponder:(UIView *)baseView {
    if (baseView == nil)
        baseView = self.view;
    
    if (baseView.isFirstResponder)
        return baseView;
    for (UIView *subview in baseView.subviews) {
        UIView *firstResponder = [self findFirstResponder:subview];
        if (firstResponder != nil)
            return firstResponder;
    }
    return nil;
}

- (void)leftNavigationBarButtonItemAction:(id)sender {
    if (_ctrlType == fromWorkSpaceType) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
