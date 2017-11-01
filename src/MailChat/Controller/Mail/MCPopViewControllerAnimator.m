//
//  MCPopViewControllerAnimator.m
//  NPushMail
//
//  Created by admin on 9/6/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCPopViewControllerAnimator.h"

@implementation MCPopViewControllerAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.6;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    CGRect originFrame = self.originView.frame;
    CGRect initialFrame = CGRectMake(0, 66, originFrame.size.width,originFrame.size.height);
    CGRect finalFrame = [transitionContext finalFrameForViewController:toViewController];
    
    UIView *snapshot = [self.originView snapshotViewAfterScreenUpdates:YES];
    snapshot.frame = initialFrame;
    
    [containerView addSubview:toViewController.view];
    [containerView addSubview:snapshot];
    toViewController.view.hidden = YES;
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        //snapshot.frame = finalFrame;
    } completion:^(BOOL finished) {
        toViewController.view.hidden = NO;
        [snapshot removeFromSuperview];
    }];
    
}

@end
