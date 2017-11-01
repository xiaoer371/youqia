//
//  MCGroupsTable.h
//  NPushMail
//
//  Created by wuwenyu on 16/1/15.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAccountTableBase.h"

@interface MCGroupsTable : MCAccountTableBase
/**
 *  增加默认分组
 *
 *  @param accountId
 */
- (void)addDefaultGroups;
/**
 *  获取分组列表
 *
 *  @param accountId
 *
 *  @return 
 */
- (NSMutableArray *)getGroups;
/**
 *  删除分组
 *
 *  @param groupId
 *  @param accountId
 */
- (void)deleteGroupWithGroupId:(NSString *)groupId;
/**
 *  获取分组名称
 *
 *  @param groupId
 *  @param accountId
 *
 *  @return
 */
- (NSString *)getGroupNameWithGroupId:(NSString *)groupId;
/**
 *  获取分组ID
 *
 *  @param groupName
 *  @param accountId
 *
 *  @return 
 */
- (NSString *)getGroupIdWithGroupName:(NSString *)groupName;

/**
 *  获取最大groupId
 *
 *  @return 
 */
- (int)getGroupMaxSortId;
/**
 *  获取分组id
 *
 *  @return 
 */
- (NSString *)getGroupId;

@end
