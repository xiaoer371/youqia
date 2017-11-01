//
//  MCContactManager.h
//  NPushMail
//
//  Created by wuwenyu on 16/2/25.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCContactModel.h"
#import "MCBranchInfo.h"
#import "MCContactTable.h"
#import "MCGroupsTable.h"
#import "MCContactWeights.h"

// 重要联系人的权重，大于等于这个权重的才算重要联系人
static NSInteger const kMailChatContactImportantWeight = 50;

@interface MCContactManager : NSObject

+ (MCContactManager *)sharedInstance;



/**
 小助手
 */
@property (nonatomic,strong,readonly) MCContactModel *helperContact;

/**
 * 同部门领导
 */
@property (nonatomic,strong,readonly) MCContactModel *leader;

/**
 *  获取所有联系人
 *
 *  @return 所有联系人列表
 */
- (NSArray *)getContacts;

/**
 *  获取或创建一个新的联系人。如果联系人不存在，则创建一个新的，否则，返回原有联系人信息
 *
 *  @param email 电子邮件地址
 *  @param name  联系人名称
 *
 *  @return 联系人信息
 */
- (MCContactModel *)getOrCreateContactWithEmail:(NSString *)email name:(NSString *)name;

/**
 *  根据邮件地址获取联系人
 *
 *  @param email 邮件地址
 *
 *  @return 联系人，nil表示没有获取到
 */
- (MCContactModel *)getContactWithEmail:(NSString *)email;

/**
 *  新增一个普通联系人
 *
 *  @param model
 */
- (void)insertContact:(MCContactModel *)model;
/**
 *  删除联系人
 *
 *  @param contacts
 */
- (void)deleteContacts:(NSArray *)contacts;
/**
 *  删除缓存中的联系人，不删除数据库中的。
 *
 *  @param contacts
 */
- (void)deleteCacheContacts:(NSArray *)contacts;
/**
 *  更新联系人
 *
 *  @param model
 */
- (void)updateContact:(MCContactModel *)model;

/**
 *  给某个联系人添加权重
 *
 *  @param weight 要添加的权重值
 *  @param model  联系人
 */
- (void)addWeight:(NSInteger)weight toContact:(MCContactModel *)model;

/**
 *  获取重要联系人
 *
 *  @param importFlag 是否重要联系人
 *
 *  @return
 */
- (NSMutableArray *)getImportantContactsWithImportFlag:(BOOL)importFlag;
/**
 *  更新是否重要联系人
 *
 *  @param email
 *  @param importFlag
 */
- (void)updateImportFlagWithEmail:(NSString *)email importFlag:(BOOL)importFlag;
/**
 *  更新联系人备注信息
 */
- (void)updateContactWithNoteInfo:(MCContactModel *)model;

/**
 *  获取权重值高的联系人
 *
 *  @return 取得权重值高的联系人
 */
- (NSArray *)getTopWeightedContacts;


#pragma mark - 个人联系人

/**
 *  获取个人联系人
 *
 *  @return 个人联系人数组
 */
- (NSArray *)getPersonalContacts;

/**
 *  更新个人联系人的信息
 *
 *  @param contacts 需要更新的联系人信息
 *  @param success  成功回调
 *  @param failure  失败回调，返回错误信息
 */
- (void)updatePersonalContacts:(NSArray *)contacts success:(ActionBlock)success failure:(FailureBlock)failure;

#pragma mark - 企业联系人模块

/**
 *  更新企业联系人
 *
 *  @param success 更新成功
 *  @param failure 更新失败
 */
- (void)updateEnterpriseContactsSuccess:(ActionBlock)success failure:(FailureBlock)failure;


/**
 *  得到部门
 *
 *  @return
 */
- (NSArray *)getAllEnterpriseBranchs;
/**
 *  得到部门成员关系
 *
 *  @return
 */
- (NSArray *)getAllEnterpriseBranchEmplyoees;

/**
 *  得到部门下的员工数量
 *
 *  @param branchId
 *
 *  @return
 */
- (int)getBranchEmplyoeesCountWithBranchId:(NSString *)branchId;

/**
 *  根据部门id获取部门员工关系
 *
 *  @param branchId
 *
 *  @return
 */
- (NSArray *)getEnterpriseBranchEmployeeInfosByBranchId:(NSString*)branchId;

/**
 *  根据部门id的到部门信息
 *
 *  @param email
 *
 *  @return
 */
- (MCBranchInfo *)getEnterpriseBranchInfoWithBranchId:(NSString *)branchId;

/**
 *  获取所有的企业联系人
 *
 *  @return 企业联系人列表
 */
- (NSArray *)getAllEnterpriseEmployees;

/**
 *  获取同域的联系人
 *
 *  @param domin
 *
 *  @return
 */
- (NSArray *)getSameDominContactInfoByDomin:(NSString *)domin;

#pragma mark - 分组模块

/**
 *  获取分组列表
 *
 *  @param
 *
 *  @return
 */
- (NSMutableArray *)getGroups;

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
 *  添加默认分组
 */
- (void)addDefaultGroups;
@end
