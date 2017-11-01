//
//  MCLoginDetailViewController.h
//  NPushMail
//
//  Created by zhang on 16/1/18.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseSubViewController.h"
#import "MCLoginViewController.h"

@interface MCLoginDetailViewController : MCLoginViewController

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;      //邮件账号
@property (weak, nonatomic) IBOutlet UITextField *passWordTextField;      //邮件密码
@property (weak, nonatomic) IBOutlet UIView      *lineSp1;
@property (weak, nonatomic) IBOutlet UIView      *lineSp2;
@property (weak, nonatomic) IBOutlet UIButton    *loginButton;
@property (weak, nonatomic) IBOutlet UILabel     *helpNoteText;
@property (weak, nonatomic) IBOutlet UIButton    *showPassWordButton;
@property (strong, nonatomic) UIButton    *authButton;

/**
 是否从oa升级页面进入的，这种情况不需要有返回的按钮
 */
@property (assign, nonatomic) BOOL pushFromOaUpgradeCtrl;
@property (nonatomic,assign)  NSInteger  selectIndex;

- (IBAction)showPassWord:(UIButton*)sender;
- (IBAction)loginMailAccount:(UIButton *)sender;

- (void)loginMail;

@end
