//
//  MCIMGroupManager.h
//  NPushMail
//
//  Created by admin on 2/25/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCIMGroupModel.h"
#import "MCIMInvitationModel.h"
#import "MCContactModel.h"

@interface MCIMGroupManager : NSObject

+ (instancetype)shared;

#pragma mark - Group Info

/**
 *  获取本地群组信息
 *
 *  @param groupId 群组编号
 *
 *  @return 群组信息
 */
- (MCIMGroupModel *)getGroupWithGroupId:(NSString *)groupId;

/**
 *  获取待加入的群组
 *
 *  @param success 成功回调，返回群组id列表
 *  @param failure 失败回调，返回错误信息
 */
- (void)getInvitationsSuccess:(SuccessBlock)success failure:(FailureBlock)failure;

/**
 *  更新用户所有群组信息
 *
 *  @param success 成功回调，返回群组信息
 *  @param failure 失败回调，返回失败信息
 */
- (void)updateUserGroupsSuccess:(SuccessBlock)success failure:(FailureBlock)failure;

/**
 *  更新当前群组信息
 *
 *  @param groupId groupId
 *  @param success 成功回调，返回群组信息
 *  @param failure 失败回调，返回失败信息
 */
- (void)updateUserCurrentGroupWithGroupId:(NSString *)groupId  Success:(SuccessBlock)success failure:(FailureBlock)failure;

#pragma mark - 主动群操作

/**
 *  建群
 *
 *  @param groupName 群组名称，必填
 *  @param members   群成员列表, MCContactModel 数组
 *  @param success   成功回调，返回新建群信息
 *  @param failure   失败回调，返回错误信息
 */
- (void)createGroupWithGroupName:(NSString *)groupName members:(NSArray<MCContactModel*> *)members success:(SuccessBlock)success failure:(FailureBlock)failure;


/**
 *  邀请其它成员加入群组
 *
 *  @param contacts 新的群成员
 *  @param group    待加入群组信息
 *  @param success  成功回调
 *  @param failure  失败回调
 */
- (void)inviteContacts:(NSArray<MCContactModel*> *)contacts toGroup:(MCIMGroupModel *)group success:(ActionBlock)success failure:(FailureBlock)failure;

/**
 *  移除群成员
 *
 *  @param contact  要移除的成员
 *  @param group    群组信息
 *  @param success  成功回调
 *  @param failure  失败回调
 */
- (void)removeMembers:(NSArray<MCContactModel*> *)contacts fromGroup:(MCIMGroupModel *)group success:(ActionBlock)success failure:(FailureBlock)failure;


/**
 *  离开群组
 *
 *  @param group   群组
 *  @param success 成功回调，返回离开的群组信息
 *  @param failure 失败回调，返回错误信息
 */
- (void)leaveGroup:(MCIMGroupModel *)group success:(SuccessBlock)success failure:(FailureBlock)failure;

/**
 *  解散群组
 *
 *  @param group   群组
 *  @param success 成功回调，返回解散的群组
 *  @param failure 失败回调
 */
- (void)dismissGroup:(MCIMGroupModel *)group success:(SuccessBlock)success failure:(FailureBlock)failure;

/**
 *  修改群名
 *
 *  @param group   要修改的群
 *  @param newName 新群名
 *  @param success 修改成功
 *  @param failure 失败回调
 */
- (void)changeGroup:(MCIMGroupModel *)group withNewName:(NSString *)newName success:(ActionBlock)success failure:(FailureBlock)failure;

#pragma mark - 被动群操作

/**
 *  当前用户加入群组
 *
 *  @param invite  邀请信息
 *  @param success 成功回调，返回群组信息
 *  @param failure 失败回调，返回错误信息
 */
- (void)joinGroupWithInvitation:(MCIMInvitationModel *)invite success:(SuccessBlock)success failure:(FailureBlock)failure;

/**
 *  加入多个群组
 *
 *  @param invitations  群组邀请信息
 *  @param success      成功回调，返回群组信息数组
 *  @param failure      失败回调，返回错误信息
 */
- (void)joinGroupWithInvitations:(NSArray *)invitations success:(SuccessBlock)success failure:(FailureBlock)failure;

/**
 *  管理员解散的群组
 *
 *  @param groupId 群组id
 *  @param success 成功回调，返回群组信息
 *  @param failure 失败回调，返回失败信息
 */
- (void)groupDeleted:(NSString *)groupId success:(SuccessBlock)success failure:(FailureBlock)failure;

/**
 *  用户离开了群
 *
 *  @param userId  离开群的用户id
 *  @param groupId 群id
 *  @param success 成功回调
 *  @param failure 失败回调，返回错误信息
 */
- (void)user:(NSString *)userId leaveGroup:(NSString *)groupId success:(ActionBlock)success failure:(FailureBlock)failure;

/**
 *  自己被踢出了群
 *
 *  @param groupId 群id
 *  @param success 成功回调，返回群信息
 *  @param failure 失败回调，返回错误信息
 */
- (void)beKickedOffGroup:(NSString *)groupId success:(SuccessBlock)success failure:(FailureBlock)failure;


- (void)checkUnloginMessage:(NSString *)email success:(SuccessBlock)success failure:(FailureBlock)failure;



#pragma mark - 数据存取

- (NSArray *)groupMembersWithGroupuid:(NSInteger)groupuid;

- (void)deleteGroup:(MCIMGroupModel *)group;

- (void)updateGroup:(MCIMGroupModel *)group;

- (NSArray <MCIMGroupModel*> *)getSavedGroupModels;

@end
