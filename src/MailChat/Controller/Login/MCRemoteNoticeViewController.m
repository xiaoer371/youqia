//
//  MCRemoteNoticeViewController.m
//  NPushMail
//
//  Created by swhl on 17/2/14.
//  Copyright © 2017年 sprite. All rights reserved.
//

#import "MCRemoteNoticeViewController.h"

@interface MCRemoteNoticeViewController ()


@end

@implementation MCRemoteNoticeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpSubViews];

}
- (void)setUpSubViews
{
    self.viewTitle = PMLocalizedStringWithKey(@"PM_Remote_title");
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((ScreenWidth-99)/2, 40, 99, 77)];
     imageView.image = [UIImage imageNamed:@"remoteNotice.png"];
    [self.view addSubview:imageView];
    
    UIFont *font = [UIFont systemFontOfSize:16.0f];
    NSString *noticeStr = PMLocalizedStringWithKey(@"PM_Remote_content");
    CGSize size = [noticeStr boundingRectWithSize:CGSizeMake(ScreenWidth -80 , MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    UILabel *noticeLab = [[UILabel alloc] initWithFrame:CGRectMake(40, 160, size.width, size.height+5)];
    noticeLab.text = noticeStr;
    noticeLab.font = font;
    noticeLab.textColor = AppStatus.theme.fontTintColor;
    noticeLab.numberOfLines = 0;
    [self.view addSubview:noticeLab];
    
    CGFloat y = CGRectGetMaxY(noticeLab.frame)+50;
    UIButton *openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    openBtn.frame = CGRectMake(55, y, ScreenWidth - 110, 44);
    openBtn.backgroundColor = AppStatus.theme.tintColor;
    openBtn.layer.cornerRadius = 5.0f;
    [openBtn setTitle:PMLocalizedStringWithKey(@"PM_Login_forgetSure") forState:UIControlStateNormal];
    openBtn.titleLabel.font = font;
    [openBtn addTarget:self action:@selector(registNoticeSet:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openBtn];
    
}

- (void)registNoticeSet:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
