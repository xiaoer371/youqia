//
//  PHAsset+MCLastImage.h
//  MTTestDemo
//
//  Created by swhl on 16/7/12.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Photos/Photos.h>

@interface PHAsset (MCLastImage)
/**
 *  ios 8.0 以后
 *
 *  @return  返回最新 最后一张照片
 */
+ (PHAsset *)latestAsset;

@end
