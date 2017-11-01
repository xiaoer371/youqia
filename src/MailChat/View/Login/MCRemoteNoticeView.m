//
//  MCRemoteNoticeView.m
//  NPushMail
//
//  Created by swhl on 17/2/3.
//  Copyright © 2017年 sprite. All rights reserved.
//



#import "MCRemoteNoticeView.h"

@implementation MCRemoteNoticeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpSubViews];
    }
    return self;
}

- (void)setUpSubViews
{
    CGFloat viewHeight = self.bounds.size.height;
    self.backgroundColor = AppStatus.theme.backgroundColor;
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((ScreenWidth-60)/2, 40, 60, 60)];
    // imageView.image = [UIImage imageNamed:@""];
    imageView.backgroundColor = [UIColor redColor];
    [self addSubview:imageView];
    
    UIFont *font = [UIFont systemFontOfSize:16.0f];
    NSString *noticeStr = @"由于开启邮件推送需要进行邮箱服务器注册，导致您可能会收到异地登录提醒，但您的邮箱数据安全不会受到任何影响，请放心使用。";
    CGSize size = [noticeStr boundingRectWithSize:CGSizeMake(ScreenWidth -80 , MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    UILabel *noticeLab = [[UILabel alloc] initWithFrame:CGRectMake(40, 140, size.width, size.height+5)];
    noticeLab.text = noticeStr;
    noticeLab.font = font;
    noticeLab.textColor = AppStatus.theme.fontTintColor;
    noticeLab.numberOfLines = 0;
    [self addSubview:noticeLab];
    
    
    UIButton *openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    openBtn.frame = CGRectMake(40, viewHeight - 140, ScreenWidth - 80, 44);
    openBtn.backgroundColor = AppStatus.theme.tintColor;
    [openBtn setTitle:@"知道了" forState:UIControlStateNormal];
    openBtn.titleLabel.font = font;
    [openBtn addTarget:self action:@selector(registNoticeSet:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:openBtn];
    
    
//    NSDictionary *dic = @{NSFontAttributeName:font,NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle],NSForegroundColorAttributeName:AppStatus.theme.fontTintColor};
//    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    closeBtn.frame = CGRectMake(40, viewHeight - 60, ScreenWidth - 80, 44);
//    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"暂时不开启" attributes:dic];
//    [closeBtn setAttributedTitle:str forState:UIControlStateNormal];
//    closeBtn.backgroundColor = [UIColor clearColor];
//    closeBtn.titleLabel.font = font;
//    [closeBtn addTarget:self action:@selector(logoffNoticeSet:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:closeBtn];

}

- (void)registNoticeSet:(UIButton *)sender
{
    [self removeFromSuperview];
    if (self.delegate && [self.delegate respondsToSelector:@selector(remoteNoticeWithUsable:)]) {
        [self.delegate remoteNoticeWithUsable:YES];
    }
}

- (void)logoffNoticeSet:(UIButton *)sender
{
    [self removeFromSuperview];
    if (self.delegate && [self.delegate respondsToSelector:@selector(remoteNoticeWithUsable:)]) {
        [self.delegate remoteNoticeWithUsable:NO];
    }
}


@end
