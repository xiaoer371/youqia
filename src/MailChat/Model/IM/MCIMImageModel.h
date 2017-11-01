//
//  MCIMImageModel.h
//  NPushMail
//
//  Created by swhl on 16/1/27.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCIMMessageModel.h"

@interface MCIMImageModel : MCIMMessageModel

@property (nonatomic, copy) NSString *checksum;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) UIImage *thumbnailImg;

/**
 *  图片的路径
 */
@property (nonatomic, readonly) NSString *path;

/**
 *  小图的路径
 */
@property (nonatomic, readonly) NSString *thumbnailPath;

/**
 *  本地图片路径，用于读取缓存
 */
@property (nonatomic,readonly) NSString *localPath;

/**
 *  图片占用的空间大小
 */
@property (nonatomic ,assign) NSUInteger size;

/**
 *  图片大小
 */
@property (nonatomic,assign) CGSize imageSize;

@end
