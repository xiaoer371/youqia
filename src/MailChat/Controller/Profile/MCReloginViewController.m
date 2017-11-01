//
//  MCReloginViewController.m
//  NPushMail
//
//  Created by wuwenyu on 16/5/24.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCReloginViewController.h"
#import "MCDownMenuView.h"
#import "MCAccountManager.h"
#import "MCAppDelegate.h"
#import "MCLoginManager.h"
#import "UIAlertView+Blocks.h"
#import "MCAppSetting.h"
#import "PCCircleViewConst.h"
#import "MCAccountConfig.h"

#define	__max(a, b)	(a > b ? a : b)

@interface MCReloginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UIButton *selectedAccountBtn;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *showPasswordBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIView *userNameView;
@property (nonatomic, assign) BOOL isDown;
@property (nonatomic,assign)  KeyboardSlideMode   keybordSlideMode;
- (IBAction)selectedAccountAction:(id)sender;
- (IBAction)showPasswordAction:(id)sender;
- (IBAction)loginAction:(id)sender;

@end

@implementation MCReloginViewController {
    MCDownMenuView *_downMenuV;
    KeyboardSlideMode  _slideMode;
    BOOL				_keyboardIsShown;
    float				_verticalOffset;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationBar setHidden:YES];
    [self registerKeyBoardNotification];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeKeyBoardNotification];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _slideMode = KeyboardSlideMode_FitToFirstResponder;
    _accountTextField.enabled = NO;
    MCAccount *curAccount = AppStatus.currentUser;
    if (curAccount) {
        _accountTextField.text = curAccount.email;
    }
    [self loadSubViews];
    // Do any additional setup after loading the view from its nib.
}

- (void)loadSubViews {
    __weak MCReloginViewController *weakSelf = self;
    _accountTextField.placeholder = PMLocalizedStringWithKey(@"PM_Login_Account");
    _passwordTextField.placeholder = PMLocalizedStringWithKey(@"PM_ReLogin_PasswordWY");
    _passwordTextField.delegate = self;
    _loginBtn.backgroundColor = AppStatus.theme.tintColor;

    NSArray *accounts = [[MCAccountManager shared] getAllAccounts];
    CGRect frame = CGRectMake(20, 265, ScreenWidth - 50, ScreenHeigth - 265);
    _downMenuV = [[MCDownMenuView alloc] initWithFrame:frame dataArray:accounts selectedMenuBlock:^(id obj, NSIndexPath *index) {
        MCAccount *act = (MCAccount *)obj;
        if (![act.email isEqualToString:weakSelf.accountTextField.text]) {
            weakSelf.passwordTextField.text = @"";
        }
        weakSelf.accountTextField.text = act.email;
        weakSelf.isDown = !weakSelf.isDown;
        if (weakSelf.isDown) {
            //收回去
            [weakSelf.selectedAccountBtn setImage:[UIImage imageNamed:@"selectedArrowUp.png"] forState:UIControlStateNormal];
        }else {
            //展开
            [weakSelf.selectedAccountBtn setImage:[UIImage imageNamed:@"selectedArrowDown.png"] forState:UIControlStateNormal];
        }

        DDLogInfo(@"%@", act.email);
    } cellIdentifier:@"MCGestureManagerCell"];
    _downMenuV.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_downMenuV];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)leftNavigationBarButtonItemAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)selectedAccountAction:(id)sender {
    [self.view bringSubviewToFront:_downMenuV];
    if (_isDown) {
        //收回去
        [_downMenuV dismiss];
        [_selectedAccountBtn setImage:[UIImage imageNamed:@"selectedArrowDown.png"] forState:UIControlStateNormal];
    }else {
        //展开
        [_downMenuV show];
        [_selectedAccountBtn setImage:[UIImage imageNamed:@"selectedArrowUp.png"] forState:UIControlStateNormal];
    }
    _isDown = !_isDown;
}

- (IBAction)showPasswordAction:(id)sender {
    [_showPasswordBtn setSelected:!_showPasswordBtn.selected];
    if (_showPasswordBtn.selected) {
        _passwordTextField.secureTextEntry = NO;
    }else {
        _passwordTextField.secureTextEntry = YES;
    }
}

- (IBAction)loginAction:(id)sender {
    if ([_passwordTextField.text length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请输入密码" cancelButtonItem:[RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Sure")] otherButtonItems:nil,nil];
        [alertView show];
        return;
    }else {
        [_passwordTextField resignFirstResponder];
        if ([[MCLoginManager new] validateUserWithEmail:_accountTextField.text password:_passwordTextField.text]) {
            if (_touchIdLoginSuccess) {
                AppSettings.touchIdFlag = NO;
                _touchIdLoginSuccess();
            }else {
                [PCCircleViewConst saveGesture:nil Key:gestureOneSaveKey];
                [PCCircleViewConst saveGesture:nil Key:gestureFinalSaveKey];
                [AppSettings setIsPassGesturePwd:YES];
                [AppSettings setGesturePasswordFlag:NO];
                if (_gestureLoginSuccess) {
                    _gestureLoginSuccess();
                }
            }
            MCAppDelegate *mcAppDelegate = (MCAppDelegate*)[UIApplication sharedApplication].delegate;
            if (!mcAppDelegate.tabBarController) {
                [mcAppDelegate displayTabBarViewController];
            }else {
                UIViewController *rootViewController = [self.navigationController.viewControllers firstObject];
                [rootViewController dismissViewControllerAnimated:NO completion:nil];
                MCAccountConfig *accountConfig = AppStatus.accountData.accountConfig;
                BOOL showWorkspaceFlag =  accountConfig.hasWorkspace && AppSettings.isShowWorkspace;
                [mcAppDelegate.tabBarController setTabbarWithWorkspaceFlag:showWorkspaceFlag];
                mcAppDelegate.tabBarController.selectedIndex = AppSettings.lastTabbarSelectIndex;
            }
        }else {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:PMLocalizedStringWithKey(@"PM_Login_AccountValidationFail") message:nil cancelButtonItem:[RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Sure")] otherButtonItems:nil,nil];
            [alertView show];

        }
    }
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

- (void) slideShiftView:(NSDictionary *)userInfo {
    if (!_keyboardIsShown)
        return;
    if (_slideMode == KeyboardSlideMode_FitToFirstResponder) {
        CGRect keyboardFrame;
        [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
        float keyboardStartY = CGRectGetMinY(keyboardFrame);
        
        UIView* field = [self findFirstResponder:[self.view window]];
        CGRect fieldFrame = [[self.view window] convertRect:field.bounds fromView:field];
        float fieldEndY = CGRectGetMaxY(fieldFrame);
        
        float verticalOffset = fieldEndY - keyboardStartY;
        if (_verticalOffset + verticalOffset > 0) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            CGRect frame = self.view.frame;
            frame.origin.y -= verticalOffset;
            self.view.frame = frame;
            _verticalOffset += verticalOffset;
            [UIView commitAnimations];
        }
    }
    else if (_slideMode == KeyboardSlideMode_ResizeFrame) {
        CGRect keyboardFrame;
        [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
        float verticalOffset = CGRectGetHeight(keyboardFrame);
        
        int adjustedOffset = verticalOffset - _verticalOffset;
        if (adjustedOffset == 0)
            return;
        CGRect frame = self.view.frame;
        _verticalOffset = verticalOffset;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        frame.size.height -=  adjustedOffset;
        self.view.frame = frame;
        [UIView commitAnimations];
    }
}

- (void)slideUpView:(NSDictionary *)userInfo {
    if (_keyboardIsShown)
        return;
    _keyboardIsShown = YES;
    
    if (_slideMode == KeyboardSlideMode_FitToFirstResponder) {
        CGRect keyboardFrame;//包含键盘的位置信息
        [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
        //UIKeyboardFrameBeginUserInfoKey,UIKeyboardFrameEndUserInfoKey对应的Value是个NSValue对象，内部包含CGRect结构，分别为键盘起始时和终止时的位置信息
        float keyboardStartY = CGRectGetMinY(keyboardFrame);//返回矩形底部的坐标,此高度即是键盘的原点y坐标
        
        UIView* field = [self findFirstResponder:[self.view window]];
        CGRect fieldFrame = [[self.view window] convertRect:field.bounds fromView:field];
        float fieldEndY = CGRectGetMaxY(fieldFrame);//textfield 或者 textview的结束点，即view的原点加上view自身的高度
        float verticalOffset = __max(fieldEndY - keyboardStartY, 0);//用当前的view（输入框或者是textview）的最下面的高度和键盘的原点y作比较，要是当前的view的高度大于键盘的原点y，则当前的view应该向上位移，以防键盘挡住
        
        if (verticalOffset > 0) {
            _verticalOffset = verticalOffset + 1;	// 1 pixel extra space
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];	// if you want to slide up the view
            CGRect frame = self.view.frame;
            frame.origin.y -= _verticalOffset;//上去的时候位置变化
            self.view.frame = frame;
            [UIView commitAnimations];
        }
    }
    else if (_slideMode == KeyboardSlideMode_ResizeFrame) {
        [self slideShiftView:userInfo];
    }
}

- (void)slideDownView {
    if (!_keyboardIsShown)
        return;
    _keyboardIsShown = NO;
    
    if (_slideMode == KeyboardSlideMode_FitToFirstResponder) {
        if (_verticalOffset > 0) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            CGRect frame = self.view.frame;
            frame.origin.y += _verticalOffset;//下来的时候位置变化
            self.view.frame = frame;
            [UIView commitAnimations];
            _verticalOffset = 0;
        }
    }
    else if (_slideMode == KeyboardSlideMode_ResizeFrame) {
        if (_verticalOffset > 0) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
            CGRect frame = self.view.frame;
            frame.size.height += _verticalOffset;
            self.view.frame = frame;
            [UIView commitAnimations];
            _verticalOffset = 0;
        }
    }
}


- (void)onKeyboardWillShow:(NSNotification *)note {
    [self slideUpView:[note userInfo]];
}

- (void)onKeyboardWillHide:(NSNotification *)note {
    [self slideDownView];
}

- (void)onKeyboardWillChangeFrame:(NSNotification *)note {
    [self slideShiftView:[note userInfo]];
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


- (void)setKeybordSlideMode:(KeyboardSlideMode)keybordslideMode {
    [[self findFirstResponder:nil] resignFirstResponder];
    _slideMode = keybordslideMode;
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [textView resignFirstResponder];
        
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    // For any other character return TRUE so that the text gets added to the view
    return YES;
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

@end
