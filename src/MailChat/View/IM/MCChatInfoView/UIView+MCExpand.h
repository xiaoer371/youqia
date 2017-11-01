//
//  UIView+MCExpand.h
//  NPushMail
//
//  Created by swhl on 16/4/12.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MCExpand)

@property (assign, nonatomic) CGFloat mc_width;
@property (assign, nonatomic) CGFloat mc_height;
@property (assign, nonatomic) CGSize  mc_size;

- (void)moveoffSetX:(CGFloat)x;

- (void)moveToX:(CGFloat)x;

- (void)moveoffSetY:(CGFloat)y;

- (void)moveToY:(CGFloat)y;

@end
