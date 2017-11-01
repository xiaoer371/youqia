//
//  BearCutOutView.m
//  TestCutOut
//
//  Created by apple on 16/6/7.
//  Copyright © 2016年 qiantu. All rights reserved.
//

#import "BearCutOutView.h"

@interface BearCutOutView ()

@property (nonatomic, retain) UIColor       *unCutColor;
@property (nonatomic, retain) NSValue       *cutOutFrame;
@property (nonatomic, retain) UIBezierPath  *cutOutBezierPath1;
@property (nonatomic, retain) UIBezierPath  *cutOutBezierPath2;

@end

@implementation BearCutOutView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (self.unCutColor) {
        
        [self.unCutColor setFill];
        UIRectFill(rect);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetBlendMode(context, kCGBlendModeDestinationOut);
        
        UIBezierPath *path1;
        UIBezierPath *path2;
        if (self.cutOutFrame) {
            path1 = [UIBezierPath bezierPathWithRect:[self.cutOutFrame CGRectValue]];
        }
        else if (self.cutOutBezierPath1){
            path1 = self.cutOutBezierPath1;
            [path1 setLineWidth:5.0f];
            [[UIColor whiteColor]setStroke];
            [path1 stroke];
            
            if (self.cutOutBezierPath2) {
                path2 = self.cutOutBezierPath2;
                [path2 fill];
            }
        }
        
        [path1 fill];

        CGContextSetBlendMode(context, kCGBlendModeNormal);
    }
}

- (void)setUnCutColor:(UIColor *)unCutColor cutOutFrame:(CGRect)cutOutFrame
{
    self.unCutColor = unCutColor;
    self.cutOutFrame = [NSValue valueWithCGRect:cutOutFrame];
    
    [self setNeedsDisplay];
}

- (void)setUnCutColor:(UIColor *)unCutColor cutOutPath1:(UIBezierPath *)cutOutPath1  cutOutPath1:(UIBezierPath *)cutOutPath2
{
    self.unCutColor = unCutColor;
    self.cutOutBezierPath1 = cutOutPath1;
    self.cutOutBezierPath2 = cutOutPath2;
    [self setNeedsDisplay];
}

@end
