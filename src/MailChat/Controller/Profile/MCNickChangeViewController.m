//
//  MCNickChangeViewController.m
//  NPushMail
//
//  Created by zhang on 16/5/13.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCNickChangeViewController.h"
#import "MCAccountManager.h"
#import "MCContactManager.h"
#import "MCAccountConfig.h"

@interface MCNickChangeViewController ()

@property (nonatomic,strong)MCAccount *account;
@property (nonatomic,strong)UITextField *mcTextField;
@property (nonatomic,assign)infoSettingType settingType;
@property (nonatomic,strong)MCAccountConfig *accountConfig;
@end

@implementation MCNickChangeViewController

- (id)initNickViewWithAccount:(MCAccount *)account {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _account = account;
        _settingType = settingNickName;
    }
    return self;
}

- (id)initWithAccount:(MCAccount *)account settingType:(infoSettingType)type {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _account = account;
        _settingType = type;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _accountConfig = AppStatus.accountData.accountConfig;
    [self setUp];
}

- (void)setUp {
    
    self.viewTitle = PMLocalizedStringWithKey(@"PM_Mine_nameTitle");
    self.rightNavigationBarButtonItem.title = PMLocalizedStringWithKey(@"PM_Msg_GroupNameSave");
    _mcTextField = [[UITextField alloc]initWithFrame:CGRectMake(0, 20, ScreenWidth, 44)];
    _mcTextField.textColor = AppStatus.theme.titleTextColor;
    _mcTextField.font = [UIFont systemFontOfSize:15.0];
    if (_settingType == settingNickName) {
        _mcTextField.text = _account.displayName;
    }else if (_settingType == settingOaServer) {
        self.viewTitle = PMLocalizedStringWithKey(@"PM_OA_ServerSetting_set");
        if (_accountConfig.oAProxyServer) {
            _mcTextField.text = _accountConfig.oAProxyServer;
        }
    }
    _mcTextField.backgroundColor = [UIColor whiteColor];
    UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 44)];
    leftView.backgroundColor = [UIColor clearColor];
    _mcTextField.leftViewMode = UITextFieldViewModeAlways;
    _mcTextField.leftView = leftView;
    _mcTextField.clearButtonMode = UITextFieldViewModeAlways;
    [_mcTextField becomeFirstResponder];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 20, ScreenWidth, 0.5)];
    line.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, _mcTextField.frame.size.height+20, ScreenWidth, 0.5)];
    line2.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
    [self.view addSubview:_mcTextField];
    [self.view addSubview:line];
    [self.view addSubview:line2];
}

- (void)rightNavigationBarButtonItemAction:(id)sender {
    if (_settingType == settingNickName) {
        _account.displayName = _mcTextField.text;
        [SVProgressHUD showWithStatus:PMLocalizedStringWithKey(@"PM_Common_Saving") maskType:SVProgressHUDMaskTypeClear];
        [[MCAccountManager shared] updateAccount:_account withNickName:_mcTextField.text company:_account.company dept:_account.department title:_account.title success:^{
            DDLogDebug(@"修改昵称成功--");
            [SVProgressHUD showSuccessWithStatus:PMLocalizedStringWithKey(@"PM_Common_Save_Success")];
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_Common_Save_Failure")];
        }];
    }else if (_settingType == settingOaServer) {
        NSString *oaServer = [_mcTextField.text trim];
        [_accountConfig setOAProxyServer:oaServer];
        [SVProgressHUD showSuccessWithStatus:PMLocalizedStringWithKey(@"PM_Common_Save_Success")];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
