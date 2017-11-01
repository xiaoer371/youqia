//
//  MCAdEventView.m
//  NPushMail
//
//  Created by swhl on 17/1/12.
//  Copyright © 2017年 sprite. All rights reserved.
//

#import "MCAdEventView.h"

@interface MCAdEventView ()<UIGestureRecognizerDelegate>

//@property (nonatomic, assign) MCAdEventType type;
@property (nonatomic, strong) UIImageView  *feiBaView;
@property (nonatomic, strong) UIButton *cancleBtn;

@end

@implementation MCAdEventView

+ (MCAdEventView*)sharedView {
    static dispatch_once_t once;
    static MCAdEventView *sharedView;
    dispatch_once(&once, ^ { sharedView = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; });
    return sharedView;
}

+ (MCAdEventView *)showWithAdEventType:(MCAdEventType)type
{
    MCAdEventView *dispalyView = [MCAdEventView sharedView];
    if (dispalyView.hidden) {
        
          [dispalyView adEventViewHidden:NO];
        return dispalyView;
    }
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    dispalyView.backgroundColor = [[UIColor colorWithHexString:@"171717"] colorWithAlphaComponent:0.5];
    [window addSubview:dispalyView];
    
    UITapGestureRecognizer* singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:dispalyView action:@selector(singleTap:)];
    singleRecognizer.delegate = dispalyView;
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    [dispalyView addGestureRecognizer:singleRecognizer];
    
    switch (type) {
        case MCAdEventTypeDefault:
        case MCAdEventTypeFeiBa:
        case MCAdEventTypeOther:{
            
            dispalyView.feiBaView = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth-225)/2,-300,225,300)];
            dispalyView.feiBaView.userInteractionEnabled = YES;
            dispalyView.feiBaView.image = [UIImage imageNamed:@"feibabj.jpg"];
            
            UITapGestureRecognizer* singleRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:dispalyView action:@selector(singleTap:)];
            singleRecognizer1.delegate = dispalyView;
            singleRecognizer1.numberOfTapsRequired = 1; // 单击
            [dispalyView.feiBaView addGestureRecognizer:singleRecognizer1];

            [dispalyView addSubview:dispalyView.feiBaView];
            
            
            dispalyView.cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            dispalyView.cancleBtn.frame = CGRectMake((ScreenWidth-225)/2 + 180, -300, 36, 36);
            dispalyView.cancleBtn.backgroundColor = [UIColor redColor];
            [dispalyView.cancleBtn addTarget:dispalyView action:@selector(cancleBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            [dispalyView addSubview:dispalyView.cancleBtn];

            [dispalyView adEventViewHidden:NO];
            
        }
            break;
        default:
            break;
    }
    return dispalyView;

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view != self && touch.view !=self.feiBaView ) {
        return NO;
    }
    return YES;
}

- (void)singleTap:(UITapGestureRecognizer *)sender
{
    if (sender.view == self.feiBaView) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectADEventType:)]) {
            [self.delegate didSelectADEventType:MCAdEventTypeFeiBa];
        }
    }
    [self adEventViewHidden:YES];
}

- (void)cancleBtnAction:(UIButton *)sender
{
    MCAdEventView *dispalyView = [MCAdEventView sharedView];
    [dispalyView adEventViewHidden:YES];
}

- (void)adEventViewHidden:(BOOL)isHidden
{
    MCAdEventView *dispalyView = [MCAdEventView sharedView];
    dispalyView.hidden = isHidden;
    [UIView animateWithDuration:0.5f // 动画时长
                          delay:0.0f // 动画延迟
         usingSpringWithDamping:0.7f // 类似弹簧振动效果 0~1
          initialSpringVelocity:2.0f // 初始速度
                        options:UIViewAnimationOptionCurveEaseInOut // 动画过渡效果
                     animations:^{
                         // code...
                         [dispalyView.feiBaView moveToY:isHidden?-300:((ScreenHeigth-300)/2)];
                         [dispalyView.cancleBtn moveToY:isHidden?-300:((ScreenHeigth-300)/2+5)];
                     } completion:^(BOOL finished) {
                         // code...
                     }];

}


@end


/*
@implementation MCFeiBaView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpFeiBaViews];
    }
    return self;
}

- (void)setUpFeiBaViews
{
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    bgImageView.image = [UIImage imageNamed:@"feibabj.jpg"];
    bgImageView.userInteractionEnabled = YES;
    [self addSubview:bgImageView];
    
    UITapGestureRecognizer* singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleRecognizer.delegate = self;
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    [bgImageView addGestureRecognizer:singleRecognizer];

}

- (void)singleTap:(id)sender
{
    
}

@end
*/



