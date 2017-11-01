//
//  MCAdjustFontSizeView.m
//  NPushMail
//
//  Created by swhl on 16/12/7.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAdjustFontSizeView.h"
#import "UIView+MCExpand.h"

@interface MCAdjustFontSizeView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UIView   *view;

@end

@implementation MCAdjustFontSizeView

+ (MCAdjustFontSizeView*)sharedView {
    static dispatch_once_t once;
    static MCAdjustFontSizeView *sharedView;
    dispatch_once(&once, ^ { sharedView = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; });
    return sharedView;
}

+ (MCAdjustFontSizeView *)ShowWithValue:(CGFloat )value adjustFontBlock:(adjustFont)adjustFont
{
    MCAdjustFontSizeView *dispalyView = [MCAdjustFontSizeView sharedView];

    if (dispalyView.hidden) {
        dispalyView.slider.value = value;
        [dispalyView adjustViewHidden:NO];
        if (adjustFont) {
            dispalyView.adjustFont = adjustFont;
        }
        return dispalyView;
    }
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    dispalyView.backgroundColor = [[UIColor colorWithHexString:@"171717"] colorWithAlphaComponent:0.5];
    [window addSubview:dispalyView];
    
    UITapGestureRecognizer* singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:dispalyView action:@selector(singleTap:)];
    singleRecognizer.delegate = dispalyView;
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    [dispalyView addGestureRecognizer:singleRecognizer];
    
    dispalyView.view = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeigth, ScreenWidth, 60)];
    dispalyView.view.backgroundColor = [UIColor whiteColor];
    [dispalyView addSubview:dispalyView.view];
    
    for (int i = 0 ; i < 3; i++) {
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth/3)*i, 5, ScreenWidth/3, 20)];
        lab.text = @"A";
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = [UIFont systemFontOfSize:(8*(i+1))];
        [dispalyView.view addSubview:lab];
    }
    
    dispalyView.slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 30, ScreenWidth-40, 20)];
    [dispalyView.slider addTarget:dispalyView action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [dispalyView.slider addTarget:dispalyView action:@selector(sliderFiAction:) forControlEvents:UIControlEventTouchUpInside];
    dispalyView.slider.minimumValue = 0.5f;
    dispalyView.slider.maximumValue = 1.5f;
    dispalyView.slider.value = value;
    [dispalyView.view addSubview:dispalyView.slider];
    
    [dispalyView adjustViewHidden:NO];
    if (adjustFont) {
        dispalyView.adjustFont = adjustFont;
    }
    return dispalyView;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view != self) {
        return NO;
    }
    return YES;
}

- (void)sliderFiAction:(UISlider *)sender
{
    NSString * str = [NSString stringWithFormat:@"%.1f%@", sender.value *100,@"%"];
    AppSettings.mailAdjust = str;
}

- (void)sliderAction:(UISlider*)sender
{
    NSString * str = [NSString stringWithFormat:@"%.1f%@", sender.value *100,@"%"];
    if (self.adjustFont) {
        self.adjustFont(str);
    }
    if (self.delegate &&[self.delegate respondsToSelector:@selector(adjustFontSizeView:)]) {
        [self.delegate adjustFontSizeView:str];
    }
}

- (void)singleTap:(id)sender
{
    MCAdjustFontSizeView *dispalyView = [MCAdjustFontSizeView sharedView];
    dispalyView.adjustFont = nil;
    [dispalyView adjustViewHidden:YES];
    return;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    for (UIView *view in window.subviews) {
        if ([view isKindOfClass:[MCAdjustFontSizeView class]]) {
            view.hidden = YES;
            [view removeFromSuperview];
            break;
        }
    }
}

- (void)adjustViewHidden:(BOOL)isHidden
{
    MCAdjustFontSizeView *dispalyView = [MCAdjustFontSizeView sharedView];
    [UIView animateWithDuration:0.3f animations:^{
        dispalyView.hidden = isHidden;
        [dispalyView.view moveToY:isHidden?ScreenHeigth:(ScreenHeigth-60)];
    }];
}

/**
 NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'",
 textFontSize];
 [web stringByEvaluatingJavaScriptFromString:jsString];
 
 */

@end
