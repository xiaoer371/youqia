//
//  MCBaseSubViewController.m
//  NPushMail
//
//  Created by zhang on 16/1/4.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseSubViewController.h"

@interface MCBaseSubViewController ()

@property (nonatomic,strong)UILabel*titleLablel;

@end

@implementation MCBaseSubViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self resetNagationTitle];
}
//prative
- (void)resetNagationTitle {
    
    CGFloat width = ScreenWidth - 120;
    _titleLablel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, kMCBaseViewNavBarTitleViewHight)];
    _titleLablel.font = [UIFont boldSystemFontOfSize:kMCBaseViewNavBarTitleFont];
    _titleLablel.textAlignment = NSTextAlignmentCenter;
    _titleLablel.backgroundColor = [UIColor clearColor];
    _titleLablel.textColor = AppStatus.theme.navgationBarTitleTextColor;
    _titleLablel.text = _viewTitle;
    self.navigationItem.titleView = _titleLablel;
}

//viewTitle
- (void)setViewTitle:(NSString *)viewTitle{
    _viewTitle = viewTitle;
    self.titleLablel.text = viewTitle;
}


@end
