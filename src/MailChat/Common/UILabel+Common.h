//
//  UILabel+Common.h
//  NPushMail
//
//  Created by wuwenyu on 16/7/7.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Common)

typedef enum {
    UILabelResizeType_constantHeight = 1,
    UILabelResizeType_constantWidth,
} UILabelResizeType;

// 调整UILabel尺寸
- (void)resize:(UILabelResizeType)type;

// 返回估计的尺寸
- (CGSize)estimateUISizeByHeight:(CGFloat)height;
- (CGSize)estimateUISizeByWidth:(CGFloat)width;

@end
