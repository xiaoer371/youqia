//
//  MCProgressView.m
//  NPushMail
//
//  Created by zhang on 16/7/7.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCProgressView.h"

@interface MCProgressView ()

@property (nonatomic,strong)CAShapeLayer *progressLayer;
@property (nonatomic,strong)CAShapeLayer *trackLayer;

@end

@implementation MCProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _trackLayer = [CAShapeLayer new];
        _trackLayer.frame = self.bounds;
        
        UIBezierPath *path = [UIBezierPath new];
        [path moveToPoint:CGPointMake(0, frame.size.height/2)];
        [path addLineToPoint:CGPointMake(frame.size.width, frame.size.height/2)];
        _trackLayer.path = path.CGPath;
        _trackLayer.lineCap = kCALineCapRound;
        [self.layer addSublayer:_trackLayer];
        
        _progressLayer = [CAShapeLayer new];
        _progressLayer.frame = self.bounds;
        _progressLayer.lineCap = kCALineCapRound;
        [self.layer addSublayer:_progressLayer];
        
    }
    return self;
}

//set
- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    CGFloat width = self.frame.size.width *progress;
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(0, self.frame.size.height/2)];
    [path addLineToPoint:CGPointMake(width, self.frame.size.height/2)];
    _progressLayer.path = path.CGPath;
}

- (void)setProgressWidth:(CGFloat)progressWidth {
    
    _progressLayer.lineWidth = progressWidth;
    _trackLayer.lineWidth = progressWidth;
}

- (void)setProgressColor:(UIColor *)progressColor {
    
    _progressLayer.strokeColor = progressColor.CGColor;
}

- (void)setTrackColor:(UIColor *)trackColor {
    _trackLayer.strokeColor = trackColor.CGColor;
}
@end
