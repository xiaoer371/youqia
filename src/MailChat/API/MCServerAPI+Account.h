//
//  MCServerAPI+Account.h
//  NPushMail
//
//  Created by admin on 3/23/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCServerAPI.h"
#import "MCUserInfo.h"
#import "MCAccount.h"

@interface MCServerAPI (Account)

#pragma mark - User

- (void)authenticateUser:(NSString *)userName
                   password:(NSString *)password
                   clientId:(NSString *)clientId
                 deviceName:(NSString *)deviceName
                  apnsToken:(NSString *)apnsToken
                  clientVer:(NSString *)clientVer
                    success:(SuccessBlock)success
                    failure:(FailureBlock)failure;


/**
 *  更新用户的APNS  token，在获取apns token的时候调用
 *
 *  @param token    本地的apns token
 *  @param clientId 本机clientId
 *  @param success  成功回调
 *  @param failure  失败回调
 */
- (void)updateAPNSToken:(NSString *)token
           withClientId:(NSString *)clientId
                success:(ActionBlock)success
                failure:(FailureBlock)failure;

/**
 *  添加邮箱到当前用户，服务器会进行邮箱的认证，返回认证结果
 *
 *  @param email    要添加的邮箱
 *  @param password 邮箱密码
 *  @param authCode 本参数为客户端通过验证后传递给服务器使用的oauth验证码（和password 2选1）
 *  @param shouldValidate 服务器是否需要对邮箱的用户名密码进行验证
 *  @param success  成功回调，返回认证结果
 *  @param failure  失败回调，返回错误信息
 */
- (void)addMailToUser:(NSString *)email
         withPassword:(NSString *)password
             authCode:(NSString *)authCode
       shouldValidate:(BOOL)shouldValidate
              success:(SuccessBlock)success
              failure:(FailureBlock)failure;

/**
 *  将邮件移除当前用户，用于退出登录
 *
 *  @param email   要退出的邮件地址
 *  @param success 成功回调
 *  @param failure 失败回调，返回错误信息
 */
- (void)deleteMail:(NSString *)email
           success:(ActionBlock)success
           failure:(FailureBlock)failure;

- (void)getAuthenticationStatusWithEmail:(NSString *)email
                                 success:(SuccessBlock)success
                                 failure:(FailureBlock)failure;

/**
 *  获取所有的邮件账号信息
 *
 *  @param success 成功回调，返回 MCAccount 数组
 *  @param failure 失败回调，返回错误信息
 */
- (void)getAllEmailAccountsSuccess:(SuccessBlock)success
                           failure:(FailureBlock)failure;
/**
 *  获取用户的相关信息（比如绑定的邮箱，设备，和对应的token信息等等。。。）
 *
 *  @param user 用户名
 *  @param deviceId 设备Id
 *  @param success 成功回调，返回用户信息
 *  @param failure 失败回调，返回错误信息
 */
- (void)getUserInfoUser:(NSString *)user
               deviceId:(NSString *)deviceId
                success:(SuccessBlock)success
                failure:(FailureBlock)failure;

#pragma mark - Mail

/**
 *  获取邮件的配置信息
 *
 *  @param email       邮箱地址
 *  @param forceUpdate 是否强制更新，如果是YES表示重新从mx纪录获取，用于那些邮箱变更的。
 *  @param success     成功回调，返回配置信息
 *  @param failure     失败回调，返回错误信息
 */
- (void)getMailConfigWithEmail:(NSString *)email
                   forceUpdate:(BOOL)forceUpdate
                       success:(SuccessBlock)success
                       failure:(FailureBlock)failure;

- (void)updateMailConfig:(MCMailConfig *)config
               withEmail:(NSString *)email
                 success:(SuccessBlock)success
                 failure:(FailureBlock)failure;

/**
 *  检查是否是35邮箱
 *
 *  @param email   带检查邮件
 *  @param success 成功回调，返回 MCMail35Info
 *  @param failure 失败回调，返回错误信息
 */
- (void)checkIs35Mail:(NSString *)email
              success:(SuccessBlock)success
              failrue:(FailureBlock)failure;

#pragma mark - 联系人
/**
 *  获取用户数据
 *
 *  @param email   用户邮箱
 *  @param success 正确：{ result: 1, name: '昵称', url: '头像', checksum: '头像checksum' }
 *  @param failure 错误：{ result: 0, error: '错误信息' }
 */
- (void)getUserInfoWithEmail:(NSString *)email success:(SuccessBlock)success failrue:(FailureBlock)failure;

/**
 *  更新帐号信息，如果成功，会修改帐号对应的字断
 *
 *  @param account    要更新的帐号
 *  @param nickName   昵称
 *  @param company    公司
 *  @param department 部门
 *  @param title      职位
 *  @param success    成功回调
 *  @param failure    失败回调
 */
- (void)updateAccount:(NSString *)email withNickName:(NSString *)nickName company:(NSString *)company department:(NSString *)department title:(NSString *)title success:(ActionBlock)success failure:(FailureBlock)failure;

/**
 *  更新账户头像
 *
 *  @param email      要更新的邮件地址
 *  @param avatarImage 头像（小于1M）
 *  @param success    成功回调，返回头像checksum
 *  @param failure    失败回调，返回错误信息
 */
- (void)updateAccount:(NSString *)email avatar:(UIImage *)avatarImage success:(SuccessBlock)success failure:(FailureBlock)failure;


@end
