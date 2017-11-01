//
//  UIView+Image.m
//  NPushMail
//
//  Created by wuwenyu on 16/2/16.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "UIView+Image.h"

@implementation UIView (Image)

-(UIImage*)convertViewToImage{
    CGSize s = self.bounds.size;
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale*1);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
