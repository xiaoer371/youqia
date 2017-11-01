//
//  UIImageView+MCCorner.m
//  NPushMail
//
//  Created by zhang on 16/4/28.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "UIImageView+MCCorner.h"

@implementation UIImageView(MCCorner)

//覆盖view 实现切圆
- (void)cornerRadius{
    UIImageView *cornerImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mc_cornerImage.png"]];
    cornerImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width);
    [self addSubview:cornerImageView];
}

//RoundMask
- (void)cornerRadiusWithMask {
    
    UIBezierPath *rectPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(self.frame.size.width/2, self.frame.size.width/2)];
    CAShapeLayer *shapeLayer = [CAShapeLayer new];
    shapeLayer.path = rectPath.CGPath;
    self.layer.mask = shapeLayer;
}
@end
