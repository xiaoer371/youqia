//
//  MCIMMoreMsgAlertView.m
//  NPushMail
//
//  Created by swhl on 16/6/20.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMMoreMsgAlertView.h"

static const CGFloat mcIMMoreMsgAlertViewWidth  = 27.0f;
static const CGFloat mcIMMoreMsgAlertViewHeight = 30.0f;


@interface MCIMMoreMsgAlertView ()

@property (nonatomic ,strong) UILabel *textLab;

@end

@implementation MCIMMoreMsgAlertView

- (instancetype)initWithNumString:(NSString *)numStr
{
    CGRect frame = CGRectMake(ScreenWidth - 50+3, ScreenHeigth - TOOLBAR_HEIGHT - NAVIGATIONBARHIGHT- 35 - 15, mcIMMoreMsgAlertViewWidth, mcIMMoreMsgAlertViewHeight);
    self = [super initWithFrame:frame];
    if (self) {
        self.newNum = 0;
        self.backgroundColor = [UIColor clearColor];
        [self _initSubViews:numStr];
    }
    return self;
}

- (void)_initSubViews:(NSString *)numStr
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.image = [UIImage imageNamed:@"tagBubble.png"];
    [self addSubview:imageView];
    
    _textLab = [[UILabel alloc] initWithFrame:CGRectMake(1,2, 25, 20)];
    _textLab.text = [NSString stringWithFormat:@"%@",numStr];
    _textLab.textColor = [UIColor whiteColor];
    _textLab.font = [UIFont systemFontOfSize:13.0f];
    _textLab.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_textLab];
    
    UIButton *btn =[UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor clearColor];
    [btn addTarget:self action:@selector(didSelectView:) forControlEvents:UIControlEventTouchUpInside];
    CGRect frame = self.bounds;
    btn.frame = frame;
    [self addSubview:btn];
    

}

-(void)didSelectView:(id)sender
{
    self.hidden = YES;
    if (self.delegate &&[self.delegate respondsToSelector:@selector(lookNewMessages)]) {
        [self.delegate lookNewMessages];
    }
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    if (hidden ==YES) {
        self.newNum = 0;
    }
}

- (void)refreshData:(NSInteger )num 
{
    if (num <1) {
        self.hidden =YES;
    }else self.hidden = NO;
    _textLab.text = [NSString stringWithFormat:@"%ld",(long)num];
}

@end
