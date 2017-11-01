//
//  UIView+MCExpand.m
//  NPushMail
//
//  Created by swhl on 16/4/12.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "UIView+MCExpand.h"

@implementation UIView (MCExpand)

- (void)moveoffSetX:(CGFloat)x
{
    CGRect rect = self.frame;
    rect.origin.x +=x;
    self.frame = rect;
}

- (void)moveToX:(CGFloat)x
{
    CGRect rect = self.frame;
    rect.origin.x =x;
    self.frame = rect;
}

- (void)moveoffSetY:(CGFloat)y
{
    CGRect rect = self.frame;
    rect.origin.y +=y;
    self.frame = rect;
}

- (void)moveToY:(CGFloat)y
{
    CGRect rect = self.frame;
    rect.origin.y =y;
    self.frame = rect;
}

- (void)setMc_width:(CGFloat)mc_width
{
    CGRect frame = self.frame;
    frame.size.width = mc_width;
    self.frame = frame;
}

- (CGFloat)mc_width
{
    return self.frame.size.width;
}

- (void)setMc_height:(CGFloat)mc_height
{
    CGRect frame = self.frame;
    frame.size.height = mc_height;
    self.frame = frame;
}

- (CGFloat)mc_height
{
    return self.frame.size.height;
}

- (CGSize)mc_size
{
    return self.frame.size;
}

- (void)setMc_size:(CGSize)mc_size
{
        CGRect frame = self.frame;
        frame.size = mc_size;
        self.frame = frame;

}

@end
