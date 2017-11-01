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
@interface MCNickChangeViewController ()

@property (nonatomic,strong)MCAccount *account;

@property (nonatomic,strong)UITextField *mcTextField;
@end

@implementation MCNickChangeViewController

- (id)initNickViewWithAccount:(MCAccount *)account {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _account = account;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
}

- (void)setUp {
    
    self.viewTitle = PMLocalizedStringWithKey(@"PM_Mine_nameTitle");
    self.rightNavigationBarButtonItem.title = PMLocalizedStringWithKey(@"PM_Msg_GroupNameSave");
    _mcTextField = [[UITextField alloc]initWithFrame:CGRectMake(0, 20, ScreenWidth, 44)];
    _mcTextField.textColor = AppStatus.theme.titleTextColor;
    _mcTextField.font = [UIFont systemFontOfSize:15.0];
    _mcTextField.text = _account.displayName;
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
    
   //TODO:保存昵称修改
    _account.displayName = _mcTextField.text;
    [SVProgressHUD showErrorWithStatus:@"正在保存..." maskType:SVProgressHUDMaskTypeClear];
    [[MCAccountManager shared] updateAccount:_account withNickName:_mcTextField.text company:_account.company dept:_account.department title:_account.title success:^{
        DDLogDebug(@"修改昵称成功--");
        [SVProgressHUD showSuccessWithStatus:@"保存成功"];
    } failure:^(NSError *error) {
        [SVProgressHUD showSuccessWithStatus:@"保存失败"];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
