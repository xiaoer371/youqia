//
//  UINavigationController +MCExtestion.m
//  SGNavigationProgress
//
//  Created by zhang on 2016/10/31.
//  Copyright © 2016年 Shawn Gryschuk. All rights reserved.
//

#import "UINavigationController +MCExtestion.h"
#import "MCMailSentErrorView.h"
#import <objc/runtime.h>
static const NSInteger kMCProgressViewTag = 222222;
static const NSInteger kMCSendImageViewTag = 2222224;
static const NSInteger kMCErroNoteViewTag = 222223;
static const CGFloat   kMCErroNoteViewHeight = 44;

static NSString *const kMCAnimateKey = @"animateKey";
static NSString *const kMCProgressKey = @"progressKey";
@implementation UINavigationController(MCExtestion)

//set up views

- (UIView*)setUpProgressViewWithColor:(UIColor*)color {
    CGFloat y = CGRectGetHeight(self.navigationBar.frame);
    UIView* progressView = [self.navigationBar viewWithTag:kMCProgressViewTag];
    UIImageView *imageView = (UIImageView*)[self.navigationBar viewWithTag:kMCSendImageViewTag];
    if (!progressView) {
        CGFloat height = 2;
        progressView = [UIView new];
        progressView.tag = kMCProgressViewTag;
        progressView.frame = CGRectMake(0, y, 0, height);
        progressView.backgroundColor = color;
        [self.navigationBar addSubview:progressView];
        
        imageView = [UIImageView new];
        imageView.image = [UIImage imageNamed:@"mc_sendMail_image.png"];
        imageView.frame = CGRectMake(0, y -10, 24, 20);
        imageView.tag = kMCSendImageViewTag;
        [self.navigationBar addSubview:imageView];
        
        objc_setAssociatedObject(self, &kMCAnimateKey, @(1), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, &kMCProgressKey, @"0.00", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
    } else {
        CGRect rect = progressView.frame;
        rect.origin.y = y;
        progressView.frame = rect;
        
        rect = imageView.frame;
        rect.origin.y = y - 10;
        imageView.frame = rect;
    }
    
    return progressView;
}

- (MCMailSentErrorView*)setUpErrorNoteView {
    
    MCMailSentErrorView *errorNoteView = (MCMailSentErrorView*)[self.navigationBar viewWithTag:kMCErroNoteViewTag];
    if (!errorNoteView) {
        CGRect frame = CGRectMake(0, CGRectGetHeight(self.navigationBar.frame) - kMCErroNoteViewHeight, ScreenWidth, kMCErroNoteViewHeight);
        errorNoteView = [[MCMailSentErrorView alloc] initWithFrame:frame needClearItem:NO];
        errorNoteView.tag = kMCErroNoteViewTag;
        [self.navigationBar insertSubview:errorNoteView atIndex:0];
        [self.navigationBar sendSubviewToBack:errorNoteView];
    }
    return errorNoteView;
}


//显示进度条
- (void)showMCProgress:(CGFloat)progress {
    [self showMCProgress:progress withProgressColor:[UIColor greenColor]];
}
- (void)showMCProgress:(CGFloat)progress withProgressColor:(UIColor*)color {
    
    if ([NSThread isMainThread]) {
        [self viewUpdateProgress:progress withProgressColor:color];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self viewUpdateProgress:progress withProgressColor:color];
        });
    }
}

- (void)viewUpdateProgress:(CGFloat)progress withProgressColor:(UIColor*)color {
    
    UIView *progressView = [self setUpProgressViewWithColor:color];
    UIImageView *imageView = (UIImageView*)[self.navigationBar viewWithTag:kMCSendImageViewTag];
    NSString *progressStr = [NSString stringWithFormat:@"%f",progress];
    objc_setAssociatedObject(self, &kMCProgressKey, progressStr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSNumber *nub = objc_getAssociatedObject(self, &kMCAnimateKey);
    if (![nub boolValue]) {
        return;
    }
    objc_setAssociatedObject(self, &kMCAnimateKey, @(0), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self animateView:progressView imageView:imageView progress:progress];
}

- (void)animateView:(UIView*)progressView imageView:(UIImageView*)imageView progress:(CGFloat)progress {
    CGFloat width = CGRectGetWidth(self.navigationBar.frame);
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        CGRect rect = progressView.frame;
        rect.size.width = width*progress+2;
        progressView.frame = rect;
        
        rect = imageView.frame;
        rect.origin.x = width*progress;
        imageView.frame = rect;
        
    } completion:^(BOOL finished) {
        NSString* prString = objc_getAssociatedObject(self, &kMCProgressKey);
        CGFloat pr = [prString floatValue];
        if (progress == 1) {
            [UIView animateWithDuration:0.5 animations:^{
                progressView.alpha = 0;
            } completion:^(BOOL finished) {
                
                [progressView removeFromSuperview];
                [imageView removeFromSuperview];
            }];
        } else {
            [self animateView:progressView imageView:imageView progress:pr];
        }
    }];
}

- (void)dismissMCProgress {
    UIView *progressView = [self setUpProgressViewWithColor:[UIColor greenColor]];
    UIImageView *imageView = (UIImageView*)[self.navigationBar viewWithTag:kMCSendImageViewTag];
    [progressView removeFromSuperview];
    [imageView removeFromSuperview];
}

//错误提示
- (void)showErrorNote
{
    MCMailSentErrorView *errorView = [self setUpErrorNoteView];
    [UIView animateWithDuration:0.5 animations:^{
        CGRect rect = errorView.frame;
        rect.origin.y = CGRectGetHeight(self.navigationBar.frame);
        errorView.frame = rect;
    } completion:^(BOOL finished) {
        [self delayDismiss];
    }];
}

- (void)dimissErrorNoteAnimate:(BOOL)animate {
    MCMailSentErrorView *errorView = [self setUpErrorNoteView];
    [UIView animateWithDuration:animate?0.5:0 animations:^{
        CGRect rect = errorView.frame;
        rect.origin.y = - rect.size.height;
        errorView.frame = rect;
    } completion:^(BOOL finished) {
        [errorView removeFromSuperview];
    }];
}

- (void)delayDismiss {
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self dimissErrorNoteAnimate:YES];
    });
}

@end
