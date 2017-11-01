//
//  UIImage+Utility.h
//  NPushMail
//
//  Created by wuwenyu on 15/5/14.
//  Copyright (c) 2015年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utility)
+ (UIImage*)imageWithPureColor:(UIColor *)tintColor//生成一个纯颜色的图像
                       andSize:(CGSize)imgSize;
+ (UIImage*)scaleToSize:(UIImage *)img size:(CGSize)size;

+ (UIImage*)getScaleSizeWithImg:(UIImage*)img andMaxSize:(CGSize)maxSize;
- (UIImage *)fixOrientation;


// 新增 图片渲染
- (UIImage *) renderAtSize:(const CGSize) size;
- (UIImage *) maskWithImage:(const UIImage *) maskImage;
- (UIImage *) maskWithColor:(UIColor *) color;

@end
