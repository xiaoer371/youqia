
//
//  PHAsset+MCLastImage.m
//  MTTestDemo
//
//  Created by swhl on 16/7/12.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "PHAsset+MCLastImage.h"

@implementation PHAsset (MCLastImage)

+ (PHAsset *)latestAsset {
    // 获取所有资源的集合，并按资源的创建时间排序
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    return [assetsFetchResults firstObject];
}

@end
