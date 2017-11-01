//
//  UIView+MCExtension.m
//  NPushMail
//
//  Created by wuwenyu on 16/3/10.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "UIView+MCExtension.h"
#import "MCMailSentErrorView.h"
#import "MCNotificationCenter.h"
@implementation UIView (MCExtension)

- (void)roundView {
    /**
     *  裁成圆角
     */
    self.layer.cornerRadius=self.frame.size.width/2;
    /**
     *  隐藏裁剪掉的部分
     */
    self.layer.masksToBounds=YES;
}


//错误信息条
static const NSInteger kMCErroNoteViewTag = 222223;
static const CGFloat   kMCErroNoteViewHeight = 44;

- (MCMailSentErrorView*)setUpErrorNoteView {
    
    MCMailSentErrorView *errorNoteView = (MCMailSentErrorView*)[self viewWithTag:kMCErroNoteViewTag];
    if (!errorNoteView) {
        CGRect frame = CGRectMake(0, - kMCErroNoteViewHeight, ScreenWidth, kMCErroNoteViewHeight);
        errorNoteView = [[MCMailSentErrorView alloc] initWithFrame:frame needClearItem:NO];
        errorNoteView.tag = kMCErroNoteViewTag;
        [self addSubview:errorNoteView];
        [self bringSubviewToFront:errorNoteView];
        errorNoteView.didSelectedPendingBox =^{
            [MCNotificationCenter postNotification:MCNotificationSentMailFailure object:@(YES)];
        };
    }
    return errorNoteView;
}
//错误提示
- (void)showErrorNote
{
    MCMailSentErrorView *errorView = [self setUpErrorNoteView];
    [UIView animateWithDuration:0.5 animations:^{
        CGRect rect = errorView.frame;
        rect.origin.y = 0;
        errorView.frame = rect;
    } completion:^(BOOL finished) {
        [self delayDismiss];
    }];
}

- (void)dimissErrorNoteAnimate:(BOOL)animate {
    
    MCMailSentErrorView *errorView = (MCMailSentErrorView*)[self viewWithTag:kMCErroNoteViewTag];
    if (!errorView) {
        return;
    }
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
