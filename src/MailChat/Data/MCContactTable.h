//
//  MCContactTable.h
//  NPushMail
//
//  Created by wuwenyu on 16/1/7.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAccountTableBase.h"
@class MCContactModel;
@class MCBranchInfo;
@class MCBranchEmplyoeeInfo;
@interface MCContactTable : MCAccountTableBase

/**
 *  插入一个普通联系人
 *
 *  @param model
 */
- (void)insertOrReplaceContact:(MCContactModel *)model;
/**
 *  插入一个普通联系人,不会覆盖
 *
 *  @param model
 */
- (void)insertContact:(MCContactModel *)model;
/**
 *  获取相应账号下的所有联系人
 *
 *
 *  @return 相应账号下的所有联系人
 */
- (NSMutableArray *)getContacts;

- (void)deleteContacts:(NSArray *)contacts;

- (void)insertContacts:(NSArray *)contacts;

- (void)updateContacts:(NSArray *)contacts;

- (void)updateWeight:(MCContactModel *)model;

/**
 *  获取权重联系人
 *
 *  @return 权重大于1且从高到低前100
 */
-(NSArray *)getWeightContacts;

/**
 *  获取往来联系人
 *
 *  @return
 */
- (NSArray *)getOfftenCommunicationContacts;
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
 *  获取某个联系人
 *
 *  @param email     要获取的联系人的邮箱
 *
 *  @return model
 */
- (MCContactModel *)getContactModelWithEmail:(NSString *)email;
/**
 *  更新是否使用过邮洽
 *
 *  @param youQiaFlag
 *  @param email
 */
- (void)updateYouQiaFlag:(BOOL)youQiaFlag email:(NSString *)email;
/**
 *  更新联系人昵称
 *
 *  @param name
 */
- (void)updateContactDisplayName:(NSString *)name email:(NSString *)email;
/**
 *  更新联系人的邮箱昵称
 *
 *  @param name
 *  @param email
 */
- (void)updateContactEmailNickName:(NSString *)name email:(NSString *)email;
/**
 *  更新联系人信息
 *
 *  @param email
 *  @param groupId      分组ID
 *  @param important    是否常用联系人
 *  @param phoneNumbers 备注电话号码
 *  @param delFlag      是否删除标志
 *  @param note         备注信息
 */
- (void)updateContactInfoWithEmail:(NSString*)email groupId:(NSString*)groupId important:(BOOL)important notePhoneNumbers:(NSString*)phoneNumbers deleteFlag:(BOOL)delFlag note:(NSString*)note;
/**
 *  更新联系人备注信息
 *
 *  @param model
 */
- (void)updateContactWithNoteInfo:(MCContactModel *)model;
/**
 *  同步联系人信息
 *
 *  @param contacts 服务器返回的联系人信息
 */
- (void)synContactsInfoWithContacts:(NSArray *)contacts;

#pragma mark - 企业联系人模块
/**
 *  插入/更新部门信息
 *
 *  @param branchInfos 
 */
- (void)updateBranchWithBranchList:(NSArray *)branchInfos;

/**
 *  插入/更新部门联系人关系信息
 *
 *  @param branchEmplyoeeInfos
 */
- (void)updateBranchEmployeeWithBranchEmplyoeeList:(NSArray *)branchEmplyoeeInfos;
/**
 *  获取所有部门数据
 *
 *  @return
 */
- (NSArray *)getAllEnterpriseBranch;
/**
 *  得到部门下的员工数量
 *
 *  @param branchId
 *
 *  @return
 */
- (int)getBranchEmplyoeesCountWithBranchId:(NSString *)branchId;
/**
 *  得到所有企业联系人
 *
 *  @return
 */
- (NSArray *)getAllEnterpriseEmplyoees;

/**
 *  获取部门员工关系
 *
 *  @return
 */
- (NSArray *)getAllEnterpriseBranchEmplyoeeInfo;
/**
 *  根据部门id获取部门员工关系
 *
 *  @param branchId
 *
 *  @return
 */
- (NSArray *)getEnterpriseBranchEmployeeInfosByBranchId:(NSString*)branchId;
/**
 *  获取同域的联系人
 *
 *  @param domin
 *
 *  @return
 */
- (NSArray *)getSameDominContactInfoByDomin:(NSString *)domin;

/**
 *  清空企业表
 */
- (void)deleteEnterpriseData;
/**
 *  得到联系人表最后的更新时间
 *
 *  @return 
 */
-(int64_t) getContactLastUpdateTimeWithEmail:(NSString *)email;
/**
 *  是否是领导
 *
 *  @param email
 *
 *  @return
 */
- (BOOL)getEnterpriseEmplyoeeIsLeaderWithEmail:(NSString *)email;
/**
 *  根据部门id的到部门信息
 *
 *  @param email
 *
 *  @return
 */
- (MCBranchInfo *)getEnterpriseBranchInfoWithBranchId:(NSString *)branchId;


- (MCBranchEmplyoeeInfo *)getLeaderWithEmail:(NSString *)email;

@end
