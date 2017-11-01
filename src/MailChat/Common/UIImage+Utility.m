//
//  UIImage+Utility.m
//  NPushMail
//
//  Created by wuwenyu on 15/5/14.
//  Copyright (c) 2015年 sprite. All rights reserved.
//

#import "UIImage+Utility.h"

static const CGFloat maxSizeValue = 300;

@implementation UIImage(Utility)
+ (UIImage *)imageWithPureColor:(UIColor *)tintColor
                        andSize:(CGSize)imgSize{
    UIGraphicsBeginImageContextWithOptions(imgSize, NO, 0.0f);
    
    if(imgSize.width==0) {
        return nil;
    }
    
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, imgSize.width, imgSize.height);
    UIRectFill(bounds);
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return tintedImage;
}

//压缩图片大小
+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    CGFloat scaleValue = 1.0f;
    if (size.width==0 || size.height == 0) {
        return nil;
    }else{
        if (size.width > size.height) {
            if (size.width > maxSizeValue) {
                scaleValue = maxSizeValue/size.width;
            }
        }else{
            if (size.height > maxSizeValue) {
                scaleValue = maxSizeValue/size.height;
            }
        }
    }
    CGSize newSize = CGSizeMake(size.width*scaleValue, size.height*scaleValue);
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

+(UIImage*) getScaleSizeWithImg:(UIImage*)img andMaxSize:(CGSize)maxSize {
    CGSize imgSize = img.size;
    if (imgSize.width == 0) {
        return nil;
    }
    CGFloat scaleValue = 1.0f;
    if (imgSize.height > imgSize.width) {
        //若超过最大限制尺寸,则需要剪裁
        if (imgSize.height > maxSize.height) {
            scaleValue = maxSize.height/imgSize.height;
        }
    }else{
        if (imgSize.width > maxSize.width) {
            scaleValue = maxSize.width/imgSize.width;
        }
    }
    imgSize = CGSizeMake(imgSize.width*scaleValue, imgSize.height*scaleValue);
    //使用以下方法才能解决截取的图片比原图模糊的情况
    UIGraphicsBeginImageContextWithOptions(imgSize, NO, 0.0);
    [img drawInRect:CGRectMake(0, 0, imgSize.width, imgSize.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (UIImage *)fixOrientation {
    if (self.imageOrientation == UIImageOrientationUp) return self;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (self.imageOrientation) {
                     case UIImageOrientationDown:
                     case UIImageOrientationDownMirrored:
                         transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
                         transform = CGAffineTransformRotate(transform, M_PI);
                         break;
            
                     case UIImageOrientationLeft:
                     case UIImageOrientationLeftMirrored:
                         transform = CGAffineTransformTranslate(transform, self.size.width, 0);
                         transform = CGAffineTransformRotate(transform, M_PI_2);
                         break;
            
                     case UIImageOrientationRight:
                     case UIImageOrientationRightMirrored:
                         transform = CGAffineTransformTranslate(transform, 0, self.size.height);
                         transform = CGAffineTransformRotate(transform, -M_PI_2);
                         break;
                     case UIImageOrientationUp:
                     case UIImageOrientationUpMirrored:
                         break;
             }
    
         switch (self.imageOrientation) {
                     case UIImageOrientationUpMirrored:
                     case UIImageOrientationDownMirrored:
                         transform = CGAffineTransformTranslate(transform, self.size.width, 0);
                         transform = CGAffineTransformScale(transform, -1, 1);
                         break;
            
                     case UIImageOrientationLeftMirrored:
                     case UIImageOrientationRightMirrored:
                         transform = CGAffineTransformTranslate(transform, self.size.height, 0);
                         transform = CGAffineTransformScale(transform, -1, 1);
                         break;
                     case UIImageOrientationUp:
                     case UIImageOrientationDown:
                     case UIImageOrientationLeft:
                     case UIImageOrientationRight:
                         break;
             }
    
         // Now we draw the underlying CGImage into a new context, applying the transform
         // calculated above.
         CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                                                                                  CGImageGetBitsPerComponent(self.CGImage), 0,
                                                                                                  CGImageGetColorSpace(self.CGImage),
                                                                                                  CGImageGetBitmapInfo(self.CGImage));
         CGContextConcatCTM(ctx, transform);
         switch (self.imageOrientation) {
                     case UIImageOrientationLeft:
                     case UIImageOrientationLeftMirrored:
                     case UIImageOrientationRight:
                     case UIImageOrientationRightMirrored:
                         // Grr...
                         CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
                         break;
            
                     default:
                         CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
                         break;
             }
    
         // And now we just create a new UIImage from the drawing context
         CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
         UIImage *img = [UIImage imageWithCGImage:cgimg];
         CGContextRelease(ctx);
         CGImageRelease(cgimg);
         return img;
}

//
- (UIImage *) renderAtSize:(const CGSize) size
{
    UIGraphicsBeginImageContext(size);
    const CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    const CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *renderedImage = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    UIGraphicsEndImageContext();
    
    return renderedImage;
}

- (UIImage *) maskWithImage:(const UIImage *) maskImage
{
    const CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    const CGImageRef maskImageRef = maskImage.CGImage;
    
    const CGContextRef mainViewContentContext = CGBitmapContextCreate (NULL, maskImage.size.width, maskImage.size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    
    if (! mainViewContentContext)
    {
        return nil;
    }
    
    CGFloat ratio = maskImage.size.width / self.size.width;
    
    if (ratio * self.size.height < maskImage.size.height)
    {
        ratio = maskImage.size.height / self.size.height;
    }
    
    const CGRect maskRect  = CGRectMake(0, 0, maskImage.size.width, maskImage.size.height);
    
    const CGRect imageRect  = CGRectMake(-((self.size.width * ratio) - maskImage.size.width) / 2,
                                         -((self.size.height * ratio) - maskImage.size.height) / 2,
                                         self.size.width * ratio,
                                         self.size.height * ratio);
    
    CGContextClipToMask(mainViewContentContext, maskRect, maskImageRef);
    CGContextDrawImage(mainViewContentContext, imageRect, self.CGImage);
    
    CGImageRef newImage = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    
    UIImage *theImage = [UIImage imageWithCGImage:newImage];
    
    CGImageRelease(newImage);
    
    return theImage;
    
}

/*
 maskWithColor
 takes a (grayscale) image and 'tints' it with the supplied color.
 */
- (UIImage *) maskWithColor:(UIColor *) color
{
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    CGRect bounds = CGRectMake(0,0,width,height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, width, height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextClipToMask(bitmapContext, bounds, self.CGImage);
    CGContextSetFillColorWithColor(bitmapContext, color.CGColor);
    CGContextFillRect(bitmapContext, bounds);
    
    CGImageRef cImage = CGBitmapContextCreateImage(bitmapContext);
    UIImage *coloredImage = [UIImage imageWithCGImage:cImage];
    
    CGContextRelease(bitmapContext);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(cImage);
    
    return coloredImage;
    
}


@end

