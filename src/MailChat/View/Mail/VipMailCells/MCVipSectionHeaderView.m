//
//  MCVipSectionHeaderView.m
//  NPushMail
//
//  Created by zhang on 2017/2/16.
//  Copyright © 2017年 sprite. All rights reserved.
//

#import "MCVipSectionHeaderView.h"

@implementation MCVipSectionHeaderView

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.frame= CGRectMake(15, 0, ScreenWidth - 40, 40);
    titleLabel.font = [UIFont systemFontOfSize:14.0f];
    titleLabel.textColor = AppStatus.theme.titleTextColor;
    titleLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:titleLabel];
    titleLabel.text = PMLocalizedStringWithKey(@"PM_Mail_UnReadAndVipMail");
    titleLabel.tag = 10000;
    
    UIView *line = [UIView new];
    line.frame = CGRectMake(0, 0, ScreenWidth, 0.5);
    line.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
    [self addSubview:line];
    
    UIButton *vipMailNoteAction = [UIButton  buttonWithType:UIButtonTypeCustom];
    vipMailNoteAction.frame = CGRectMake(ScreenWidth - 45, 0, 40, 40);
    vipMailNoteAction.tag = 10001;
    [vipMailNoteAction addTarget:self action:@selector(showVipMailsNoteAction:) forControlEvents:UIControlEventTouchUpInside];
    [vipMailNoteAction setImage:[UIImage imageNamed:@"mc_vipMailNoteAction.png"] forState:UIControlStateNormal];
    [self addSubview:vipMailNoteAction];
}

- (void)setTitle:(NSString *)title {
    UILabel *titleLable = (UILabel*)[self viewWithTag:10000];
    titleLable.text = title;
}

- (void)setShowVipNoteItem:(BOOL)showVipNoteItem {
    UIButton *button = (UIButton*)[self viewWithTag:10001];
    button.hidden = showVipNoteItem;
}

- (void)showVipMailsNoteAction:(UIButton*)sender {
    if (self.showVipNoteCallBack) {
        self.showVipNoteCallBack();
    }
}

@end
