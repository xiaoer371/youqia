//
//  MCIMAuthView.m
//  NPushMail
//
//  Created by swhl on 16/4/6.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMAuthView.h"

static const CGFloat MCAuthSubViewPaddingLeft = 30.0f;

@interface MCIMAuthView ()

@end

@implementation MCIMAuthView


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self _initSubviews];
    }
    return self;
}

-(void)_initSubviews
{
    CGFloat  padding_top1,padding_top2,padding_top3,padding_top4,padding_top5;
    if (ScreenHeigth >568 /* 6 以上屏幕*/) {
        padding_top1 = 61.0f;
        padding_top2 = 49.0f;
        padding_top3 = 73.0f;
    }else{
        padding_top1 = 11.0f;
        padding_top2 = 18.0f;
        padding_top3 = 32.0f;
    }
    padding_top4 = 20.0f;
    padding_top5 = 5.0f;
    
    
    UIImageView *imgView =[[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth-93)/2, padding_top1, 93, 80)];
    imgView.image = [UIImage imageNamed:@"authFailure.png"];
    [self addSubview:imgView];
    
    CGFloat originY = CGRectGetMaxY(imgView.frame) + padding_top2;
    UILabel *lab1 =[[UILabel alloc] initWithFrame:CGRectMake(0, originY, ScreenWidth, 20)];
    lab1.text = PMLocalizedStringWithKey(@"PM_IMChat_AuthFailure");
    lab1.textAlignment = NSTextAlignmentCenter;
    lab1.font = [UIFont systemFontOfSize:16.0f];
    lab1.textColor = [UIColor colorWithHexString:@"9a9aa0"];
    [self addSubview:lab1];
    
    
    CGFloat originY1 = CGRectGetMaxY(lab1.frame) + padding_top3;
    UILabel *titleLab =[[UILabel alloc] initWithFrame:CGRectMake(MCAuthSubViewPaddingLeft, originY1, ScreenWidth-2*MCAuthSubViewPaddingLeft, 20)];
    titleLab.text = PMLocalizedStringWithKey(@"PM_IMChat_AuthSolve");
    titleLab.font = [UIFont systemFontOfSize:15.0f];
    titleLab.textColor = [UIColor colorWithHexString:@"333333"];
    [self addSubview:titleLab];
    
    CGFloat originY2 = CGRectGetMaxY(titleLab.frame)+padding_top4;
    UILabel *titleLab2 =[[UILabel alloc] initWithFrame:CGRectMake(MCAuthSubViewPaddingLeft, originY2, ScreenWidth-2*MCAuthSubViewPaddingLeft, 40)];
    titleLab2.numberOfLines = 2;
    NSString *string = PMLocalizedStringWithKey(@"PM_IMChat_AuthNoticeOne");
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:string];
    NSRange range =[string rangeOfString:PMLocalizedStringWithKey(@"PM_Mail_FolderOptionInbox")];
    [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"42b0c7"] range:range];
    titleLab2.textColor = [UIColor colorWithHexString:@"333333"];
    titleLab2.attributedText = attriString;
    titleLab2.font = [UIFont systemFontOfSize:15.0f];
    [self addSubview:titleLab2];
    
    CGFloat originY3 = CGRectGetMaxY(titleLab2.frame)+padding_top5;
    UILabel *titleLab3 =[[UILabel alloc] initWithFrame:CGRectMake(MCAuthSubViewPaddingLeft, originY3, ScreenWidth-2*MCAuthSubViewPaddingLeft, 20)];
    titleLab3.text = PMLocalizedStringWithKey(@"PM_IMChat_AuthNoticeOneSub");
    titleLab3.font = [UIFont systemFontOfSize:12.0f];
    titleLab3.textColor = [UIColor colorWithHexString:@"333333"];
    [self addSubview:titleLab3];
    
    
    
    CGFloat originY4 = CGRectGetMaxY(titleLab3.frame)+padding_top4;
    
     UILabel *titleLab4 =[[UILabel alloc] initWithFrame:CGRectMake(MCAuthSubViewPaddingLeft, originY4, ScreenWidth-2*MCAuthSubViewPaddingLeft, 20)];
    NSString *string2 = PMLocalizedStringWithKey(@"PM_IMChat_AuthNoticeTwo");
    NSMutableAttributedString *attriString2 = [[NSMutableAttributedString alloc] initWithString:string2];
    NSRange range2 =[string2 rangeOfString:PMLocalizedStringWithKey(@"PM_IMChat_AuthResend")];
    [attriString2 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"42b0c7"] range:range2];
    titleLab4.textColor = [UIColor colorWithHexString:@"333333"];
    titleLab4.attributedText = attriString2;
    titleLab4.font = [UIFont systemFontOfSize:15.0f];
    [self addSubview:titleLab4];
    
    UIButton *reAuthBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    reAuthBtn.frame = titleLab4.frame;
    reAuthBtn.backgroundColor =[UIColor clearColor];
    [reAuthBtn addTarget:self action:@selector(reAuthAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:reAuthBtn];
    
}

-(void)reAuthAction:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(reAuth)]) {
        [self.delegate reAuth];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
