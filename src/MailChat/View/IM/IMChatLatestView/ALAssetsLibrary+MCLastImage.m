//
//  ALAssetsLibrary+MCLastImage.m
//  MTTestDemo
//
//  Created by swhl on 16/7/12.
//  Copyright © 2016年 sprite. All rights reserved.
//
/**
 *  ios 9.0 已经弃用
 *
 *  @param MCLastImage ALAssetsLibrary
 *
 *  @return  返回最新 最后一张照片
 */
#import "ALAssetsLibrary+MCLastImage.h"

@implementation ALAssetsLibrary (MCLastImage)

- (void)latestAsset:(void (^)(ALAsset * _Nullable, NSError *_Nullable))block {
    [self enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [group enumerateAssetsWithOptions:NSEnumerationReverse/*遍历方式*/ usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    if (block) {
                        block(result,nil);
                    }
                    *stop = YES;
                }
            }];
            *stop = YES;
        }
    } failureBlock:^(NSError *error) {
        if (error) {
            if (block) {
                block(nil,error);
            }
        }
    }];
}

@end
