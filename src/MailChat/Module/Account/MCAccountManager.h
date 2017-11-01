//
//  MCAccountManager.h
//  NPushMail
//
//  Created by admin on 12/29/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCAccount.h"
#import "MCMailConfig.h"
#import "MCMail35Info.h"

@interface MCAccountManager : NSObject

#pragma mark - Lifecycle

+ (instancetype)shared;

#pragma mark - Local

@property (nonatomic,readonly) BOOL isNewUser;

/**
 *  获取所有的用户
 *
 *  @return 用户列表，不存在返回nil
 */
- (NSArray *)getAllAccounts;

/**
 *  获取除当前账号外的所有的用户
 *
 *  @return 用户列表，不存在返回nil
 */
- (NSArray *)getAllAccountsRemoveCurrrent;

- (MCAccount *)accountWithId:(NSInteger)accountId;
- (MCAccount *)accountWithEmail:(NSString *)email;

- (void)deleteAccount:(MCAccount *)account;
- (void)insertAccount:(MCAccount *)account;
- (void)updateAccount:(MCAccount *)account;

#pragma mark - Server

/**
 *  从服务器更新所有的账号信息
 *
 *  @param success 获取成功，返回账号列表
 *  @param failure 失败回调，返回错误信息
 */
- (void)updateAccountsSuccess:(SuccessBlock)success failure:(FailureBlock)failure;

/**
 *  更新账号的认证状态，更新成功后直接设置account的状态，并修改数据库
 *
 *  @param account 要更新的账号
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)getAccountStatus:(MCAccount *)account success:(ActionBlock)success failure:(FailureBlock)failure;

/**
 *  修改账号的头像
 *
 *  @param account     要修改的账号
 *  @param avatarImage 头像数据
 *  @param success     成功回调
 *  @param failure     失败回调
 */
- (void)changeAccount:(MCAccount *)account avatar:(UIImage *)avatarImage success:(ActionBlock)success failure:(FailureBlock)failure;

/**
 *  更新当前用户信息
 *
 *  @param account  要更新的账号
 *  @param nickName 昵称
 *  @param company  公司
 *  @param dept     部门
 *  @param title    职位
 *  @param success  更新成功
 *  @param failure  失败回调，返回错误信息
 */
- (void)updateAccount:(MCAccount *)account withNickName:(NSString *)nickName company:(NSString *)company dept:(NSString *)dept title:(NSString *)title success:(ActionBlock)success failure:(FailureBlock)failure;

/**
 *  从服务器获取账号的信息，并更新本地
 *
 *  @param account 要更新的账号
 *  @param success 成功回调，返回账号信息
 *  @param failure 失败回调，返回错误信息
 */
- (void)updateAccountFromServer:(MCAccount *)account success:(SuccessBlock)success failure:(FailureBlock)failure;


/**
 *  检查用户   参加流量活动
 *  @param account 账户
 *  @param success 成功回调，返回账号信息
 *  @param failure 失败回调，返回错误信息
 */
- (void)checkEvent:(MCAccount *)account success:(SuccessBlock)success failure:(FailureBlock)failure;

@end
