//
//  ALAssetsLibrary+MCLastImage.h
//  MTTestDemo
//
//  Created by swhl on 16/7/12.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetsLibrary (MCLastImage)

 - (void)latestAsset:(void(^_Nullable)(ALAsset * _Nullable asset,NSError *_Nullable error)) block;

@end
