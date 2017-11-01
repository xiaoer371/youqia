//
//  MCMailBoxManager.h
//  NPushMail
//
//  Created by admin on 1/18/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCMailBox.h"
#import "MCMailProviderProtocol.h"

@interface MCMailBoxManager : NSObject


- (MCMailBox *)getBoxWithId:(NSInteger)boxId;

/**
 *  根据帐号和文件夹路径获取文件夹对象
 *
 *  @param accountId 帐号id
 *  @param boxPath   文件夹的路径，如 INBOX
 *
 *  @return 文件夹对象
 */
- (MCMailBox *)getMailBoxWithAccount:(NSInteger)accountId path:(NSString *)boxPath;

- (MCMailBox *)getMailBoxWithAccount:(NSInteger)accountId type:(MCMailFolderType)type;

/**
 *  根据文件名称及级别获取文件夹
 *
 *  @param accountId 账号id
 *  @param name      文件夹名称
 *  @param level     级别
 *
 *  @return MCMailBox
 */
- (MCMailBox *)getMailBoxWithAccount:(NSInteger)accountId folderName:(NSString *)name level:(NSInteger)level;

/**
 *  获取文件夹（根据账号）
 *
 *  @param userId 账号id
 *
 *  @return NSArray
 */
- (NSArray *)getLocalFoldersForUser:(NSInteger)userId;

// 排序后的本地文件夹
- (NSArray *)getSortLocalFoldersForUser:(NSInteger)userId;

/**
 *  同步服务器和本地的文件夹，同步原则是以服务器的为准，本地不存在就增加，多余的就删除。
 *  对于特殊的文件夹，如收件箱，发件箱等，不会进行删除操作。
 *  同步操作后，会建立文件夹的层次关系
 *
 *  @param userId  需要同步的用户账号
 *  @param success 成功回调，返回同步后的文件夹列表
 *  @param failure 失败回调
 */
- (void)syncMailBoxesForUser:(NSInteger)userId success:(SuccessBlock)success failure:(FailureBlock)failure;

/**
 *  更新文件夹的状态
 *
 *  @param folder  需要更新的文件夹
 *  @param success 成功回调，返回更新后的 MCMailStatus
 *  @param failure 失败回调，返回错误信息
 */
- (void)getFolderInfo:(MCMailBox *)folder success:(SuccessBlock)success failure:(FailureBlock)failure;

- (void)updateFolder:(MCMailBox *)folder withInfo:(MCMailBoxInfo *)folderInfo;

@end
