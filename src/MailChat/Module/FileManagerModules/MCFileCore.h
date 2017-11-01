//
//  MCFileCore.h
//  NPushMail
//
//  Created by wuwenyu on 15/12/29.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCFileCommonHeader.h"

@interface MCFileCore : NSObject

+ (MCFileCore *)sharedInstance;
/**
 *  获取子模块
 */
- (MCFileManager *)getFileModule;
/**
 *  保存文件到数据库
 *
 *  @param model 文件Model(消息或者邮件的文件Model)
 */
- (MCFileBaseModel * )saveFileInDbWithModel:(id)model;
/**
 *  获取所有文件
 *
 *  @return
 */
- (NSMutableArray *)getAllFiles;
/**
 *  删除文件
 *
 *  @param model
 */
- (BOOL)deleteFileWithModel:(id)model;
/**
 *  文件重名简单处理(同名文件采取（+1）方式保存和显示)
 *
 *  @param sourceName 源文件名称
 *
 *  @return
 */
- (NSString *)getFileDisplayNameWithSourceName:(NSString *)sourceName;

- (MCFileBaseModel *)getFileModelWithId:(NSInteger)uid;

/**
 *  根据文件id 去file model
 *
 *  @param fileId 文件id
 */
- (MCFileBaseModel *)getFileModelWithFileId:(NSString *)fileId;


@end
