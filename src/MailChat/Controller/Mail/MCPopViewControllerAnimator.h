//
//  MCPopViewControllerAnimator.h
//  NPushMail
//
//  Created by admin on 9/6/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MCPopViewControllerAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic,strong) UIView *originView;

@end
