//
//  MCTouchIdViewController.m
//  NPushMail
//
//  Created by wuwenyu on 16/5/13.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCTouchIdViewController.h"
#import "MCTouchIdHelper.h"
#import "UIImageView+MCCorner.h"
#import "UIImageView+WebCache.h"
#import "MCAvatarHelper.h"
#import "MCReloginViewController.h"

@interface MCTouchIdViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *avatorImgView;
@property (weak, nonatomic) IBOutlet UIButton *touchIdLoginBtn;
@property (weak, nonatomic) IBOutlet UILabel *touchIdLoginLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginByOtherWaysBtn;
- (IBAction)loginByTouchId:(id)sender;

@end

@implementation MCTouchIdViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpViewsStyle];
    // Do any additional setup after loading the view from its nib.
}

- (void)setUpViewsStyle {
    _avatorImgView.clipsToBounds = YES;
    _avatorImgView.layer.cornerRadius = 40;
    MCAccount *act = AppStatus.currentUser;
    if (act) {
        [_avatorImgView sd_setImageWithURL:[NSURL URLWithString:act.avatarUrl] placeholderImage:act.avatarPlaceHolder options:SDWebImageAllowInvalidSSLCertificates];
    }
    _touchIdLoginLabel.textColor = AppStatus.theme.tintColor;
    _touchIdLoginLabel.font = [UIFont systemFontOfSize:14.0f];
    _touchIdLoginLabel.text = @"点击进行指纹解锁";
    [_touchIdLoginBtn setImage:[UIImage imageNamed:@"touchIdIcon.png"] forState:UIControlStateNormal];
    [_loginByOtherWaysBtn setTitle:@"使用其它方式登录" forState:UIControlStateNormal];
    [_loginByOtherWaysBtn setTitleColor:AppStatus.theme.tintColor forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginByTouchId:(id)sender {
    __weak MCTouchIdViewController *weakSelf = self;
    [[MCTouchIdHelper shared] verificationTouchIdWithOpenGesturePwd:NO title:PMLocalizedStringWithKey(@"PM_Mine_touchIdLoginVerificationTitle") reply:^(BOOL success, NSError *error) {
        if (weakSelf.result) {
            weakSelf.result(success, error);
        }
    }];
}

- (IBAction)loginByOtherWays:(id)sender {
    __weak MCTouchIdViewController *weakSelf = self;
    MCReloginViewController *v = [[MCReloginViewController alloc] init];
    v.touchIdLoginSuccess = ^{
        if (weakSelf.result) {
            weakSelf.result(YES, nil);
        }
    };
    [self.navigationController pushViewController:v animated:YES];
}

@end
