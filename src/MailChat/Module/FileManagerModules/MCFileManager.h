//
//  MCFileManager.h
//  NPushMail
//
//  Created by wuwenyu on 15/12/29.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCFileBaseModule.h"

static NSString* const allFileDirectory = @"allFile";
static NSString* const mailFileDirectory = @"mailFile";
static NSString* const msgFileDirectory = @"msgFile";
static NSString* const msgImageFileDirectory = @"msgImageFile";
static NSString* const collectFileDirectory = @"collectFile";
static NSString* const contactImageFileDirectory = @"contactImageFileDirectory";
static NSString* const inlineAttachMentFileDirectory = @"inlineAttachMentFileDirectory";
static NSString* const fileLaunch = @"PMLaunch";

@interface MCFileManager : MCFileBaseModule

// 初始化
- (id)init;
- (id)initWithFileCore:(MCFileCore *) core;

//获取目录信息
- (NSString *)getFileFolderPath;
- (NSString *)getMailFilePath;
- (NSString *)getMsgFilePath;
- (NSString *)getMsgImageFilePath;
- (NSString *)getAllFilePath;
- (NSString *)getCollectFilePath;
/**
 *  保存文件
 *
 *  @param data     文件数据
 *  @param folder   要保存到的文件夹
 *  @param fileName 要保存的文件名
 *  @param account  当前用户
 *
 *  @return 文件的短路径（PMFile后面的路径）
 */
- (NSString *)saveFileWithData:(NSData *)data folder:(NSString *)folder fileName:(NSString *)fileName;
/**
 *  保存或替换文件
 *
 *  @param data     文件数据
 *  @param folder   要保存到的文件夹
 *  @param fileName 要保存的文件名
 *
 *  @return 文件的短路径（PMFile后面的路径）
 */
- (NSString *)saveOrReplaceFileWithData:(NSData *)data folder:(NSString *)folder fileName:(NSString *)fileName;
/**
 *  保存或替换文件
 *
 *  @param data     文件数据
 *  @param shortPath   要保存到的路径
 *  @param fileName 要保存的文件名
 *
 *  @return 文件的短路径（PMFile后面的路径）
 */
- (NSString *)saveOrReplaceFileWithData:(NSData *)data shortPath:(NSString *)shortPath fileName:(NSString *)fileName;
/**
 *  保存邮件内嵌文件
 *
 *  @param data
 *  @param fileName
 *  @param account
 *
 *  @return
 */
- (NSString *)saveInlineFileWithData:(NSData *)data fileName:(NSString *)fileName;

/**
 *  获取对应用户对应文件夹下的所有文件名（不包含子文件夹）
 *
 *  @param account 用户标示
 *  @param folder  文件夹
 *
 *  @return 该文件夹下的所有文件名
 */
- (NSArray *)getFilesWithFolder:(NSString *)folder;
/**
 *  根据文件名和文件夹位置获取对应的文件全路径
 *
 *  @param account
 *  @param folder   文件夹
 *  @param fileName 文件名
 *
 *  @return 返回文件的全路径
 */
- (NSString *)getFilePathWithFolder:(NSString *)folder fileName:(NSString *)fileName;
/**
 *  根据文件名获取到相应的文件数据
 *
 *  @param account  当前用户
 *  @param folder   哪个文件夹的
 *  @param fileName 文件名
 *
 *  @return
 */
- (NSData *)getFileDataWithFolder:(NSString *)folder fileName:(NSString *)fileName;
- (NSString *)getFileShortPathWithFolder:(NSString *)folder fileName:(NSString *)fileName;
/**
 *  根据路径获取文件
 *
 *  @param shortPath 短路径
 *
 *  @return
 */
- (NSData *)getFileDataWithShortPath:(NSString *)shortPath;
/**
 *  根据短路径获取到全路径（保存短路径是因为有时候系统重装Documents的路径会发生改变）
 *
 *  @param shortPath
 *
 *  @return
 */
- (NSString *)getFileFullPathWithShortPath:(NSString *)shortPath;
//移动文件
- (BOOL)moveFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath;
//删除文件
- (BOOL)deleteFileWithPath:(NSString *)shortPath;

+ (NSString *)saveVoiceData:(NSData *)voiceData withName:(NSString *)voiceName;
+ (NSString *)voiceFullPathWithName:(NSString *)voiceName;

//文件是否存在
- (BOOL)fileIsExistsAtPath:(NSString*)shotPath;
/**
 *  缓存文件大小
 */
- (NSString*)getAllCacheFilsSize;

/**
 *  清除缓存文件
 */

- (void)clearCacheFiles;

/**
 获取启动页路径 ...\Caches\PMLaunch\path......

 @return 获取启动页路径 ...\Caches\PMLaunch\path......
 */
- (NSString *)getCachesFilePath;

@end
