//
//  MCAccount.h
//  NPushMail
//
//  Created by admin on 12/24/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCMailConfig.h"

@class MCMailManager;
/**
 邮箱账号的状态
 */
typedef enum : NSUInteger {
    MCAccountStatusInitialized = 0,       // 邮箱已经初始化，可以收发邮件
    MCAccountStatusValidated   = 1,       // 邮箱已经通过认证，可以收发消息
    MCAccountStatusUnValidated   = 2,     // 邮箱未通过认证，不可以收发消息
    MCAccountStatusOAUnValidated   = 3    // OA账户未通过验证，OA功能不可用。
} MCAccountStatus;


typedef enum : NSUInteger {
    MCAccountAuthTypeIMAP = 0,
    MCAccountAuthTypeOAuth = 1,
} MCAccountAuthType;


@interface MCAccount : NSObject

/**
 *  账户ID
 */
@property (nonatomic,assign) NSInteger accountId;

/**
 *  邮箱地址
 */
@property (nonatomic,copy) NSString *email;

/**
 *  登录密码
 */
@property (nonatomic,copy) NSString *password;

/**
 *  签名
 */
@property (nonatomic,copy) NSString *signature;

/**
 *  是否是eis用户
 */
@property (nonatomic,assign) BOOL isEIS;

/**
 *  邮箱类型
 */
@property(nonatomic,assign) MCMailType type;

/**
 *  昵称
 */
@property(nonatomic,strong) NSString *displayName;

/**
 *  无头像时候的填充颜色
 */
@property(nonatomic,strong) UIColor *color;

/**
 *  头像checksum
 */
@property (nonatomic,copy) NSString *avatar;

/**
 *  头像地址
 */
@property(nonatomic,readonly) NSString *avatarUrl;

@property (nonatomic,readonly) UIImage *avatarPlaceHolder;

/**
 *  公司名称
 */
@property (nonatomic,copy) NSString *company;

/**
 *  部门
 */
@property (nonatomic,copy) NSString *department;

/**
 *  职务
 */
@property (nonatomic,copy) NSString *title;

/**
 *  是否删除
 */
@property(nonatomic,assign) BOOL deleted;

/**
 *  是否是35邮箱
 */
@property (nonatomic,readonly) BOOL is35Mail;

/**
 *  账号状态
 */
@property (nonatomic,assign) MCAccountStatus status;


/**
 认证类型，默认是imap
 */
@property (nonatomic,assign) MCAccountAuthType authType;


/**
 认证数据， 当 authType 为 OAuth 的时候有效
 */
@property (nonatomic,copy) NSData *authData;


/**
 *  该账号的数据存储路径
 */
@property (nonatomic,readonly) NSString *dataFolder;

/**
 *  是否是免费邮箱
 */
@property (nonatomic,assign,readonly) BOOL isFreeMail;

/**
 *  邮箱帐号的登录配置
 */
@property (nonatomic,strong) MCMailConfig *config;

/**
 *  Gmail 认证的时候传给服务器获取access token 的交换码，只有 Gmail 有用
 */
@property (nonatomic,copy) NSString *serverCode;

@end
