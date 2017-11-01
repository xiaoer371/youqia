//
//  MCLoginManager.h
//  NPushMail
//
//  Created by admin on 1/15/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCAccount.h"

static NSString* const kMailChatLoginErrorDomain = @"com.mailchat.error.login";

typedef enum : NSUInteger {
    MailChatLoginErrorCodeUnknown = 0,
    MailChatLoginErrorCodeQQAuthenticationCode = 1,
    MailChatLoginErrorCode126AuthenticationCode = 2,
} MailChatLoginErrorCode;

@interface MCLoginManager : NSObject

/**
 *  登录上次的用户
 *
 *  @return NO 表示是新的账号，没有登录过
 */
- (BOOL)loginLastUser;


/**
 创建一个新的用户

 @param success 创建成果
 @param failure 失败回调
 */
- (void)authenticateNewUserSuccess:(SuccessBlock)success failure:(FailureBlock)failure;

/**
 *  每次程序打开的时候，调用此接口会刷新当前登录用户（一个设备只有一个用户）的状态
 *  用户名和密码到  AppSettings 里面查看
 *
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)authenticateUserSuccess:(SuccessBlock)success failure:(FailureBlock)failure;

/**
 *  登录系统，系统会自动判断imap设置等，尝试可能的登录
 *
 *  @param userName 用户名，通常为email
 *  @param password 密码
 *  @param success  成功回调，返回 MCAccount 对象
 *  @param failure  失败回调，返回错误信息
 */
- (void)loginWithUserName:(NSString *)userName
                 password:(NSString *)password
                  success:(SuccessBlock)success
                  failure:(FailureBlock)failure;

/**
 *  使用自定义的配置登录，如果成功，会保持配置到服务器
 *
 *  @param userName 用户名，即email
 *  @param password 密码
 *  @param config   自定义配置
 *  @param success  成功回调
 *  @param failure  失败回调
 */
- (void)loginWithUserName:(NSString *)userName
                 password:(NSString *)password
             customConfig:(MCMailConfig *)config
                  success:(SuccessBlock)success
                  failure:(FailureBlock)failure;

/**
 *  对于Gmail或 QQ邮箱之类的，已经验证过了，这边给加入到当前用户，并登录
 */
- (void)loginWithValidatedAccount:(MCAccount *)account
                          success:(SuccessBlock)success
                          failure:(FailureBlock)failure;


/**
 更新邮箱账号的认证信息

 @param newAccount 新的账号
 @param success 成功，返回新的 MCAccount
 @param failure 失败，返回错误信息
 */
- (void)updateAccountInfo:(MCAccount *)newAccount
                  success:(SuccessBlock)success
                  failure:(FailureBlock)failure;

/**
 *  使用已有帐号登录，一般用户帐号切换
 *
 *  @param account 需要登陆的账号
 *  @param success 登录成功回调
 *  @param failure 登录失败回调
 */

/**
 *  登录一个账号，会发出登录账号的相关通知。一定要在主线程调用此方法。
 *
 *  @param account         要登录的账号
 */
- (void)loginWithAccount:(MCAccount *)account;

/**
 *  登录匿名用户
 */
- (void)loginAnonymousUserIfNeeded;

/**
 *  退出账户 account
 *
 *  @param success 成功回调，
 *  @param failure 失败回调，返回错误信息
 */
- (void)logoutAccount:(MCAccount*)account
              Success:(SuccessBlock)success
              failure:(FailureBlock)failure;


/**
 *  验证邮箱和密码是否正确
 *
 *  @param email    邮箱地址
 *  @param password 邮箱对应的密码
 *
 *  @return 是否验证成功
 */
- (BOOL)validateUserWithEmail:(NSString *)email password:(NSString *)password;


@end
