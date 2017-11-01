//
//  MCIMFileModel.h
//  NPushMail
//
//  Created by swhl on 16/1/27.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCIMMessageModel.h"

typedef enum : NSUInteger {
    IMFileDownloadNone = 0,
    IMFileDownloading = 1,
    IMFileDownloaded = 2,
} IMFileDownloadState;


@interface MCIMFileModel : MCIMMessageModel

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *checksum;
@property (nonatomic, assign) NSUInteger size;

@property (nonatomic, assign) IMFileDownloadState downloadState;

/**
 *  对应的本地文件对象id
 */
@property (nonatomic,strong) NSString *fileId;

@property (nonatomic,strong) NSString *localPath;

@end
