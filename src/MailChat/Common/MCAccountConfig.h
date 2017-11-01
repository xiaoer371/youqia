//
//  MCAccountConfig.h
//  NPushMail
//
//  Created by wuwenyu on 16/3/23.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCAccountConfig : NSObject

- (instancetype)initWithAccount:(MCAccount *)account;

@property (nonatomic, strong)MCAccount *account;

/**
 *  公司名称
 */
@property (nonatomic, strong) NSString *company;

/**
 *  上次同步EIS的时间，默认为0
 */
@property (nonatomic, assign) NSTimeInterval eisSyncTimestamp;

@property (nonatomic, assign) BOOL isOAUser;

@property (nonatomic, assign) BOOL isFirstSyncOAUser;
/**
 *  oa的代理服务器设置
 */
@property (nonatomic, strong) NSString *oAProxyServer;

/**
 oa用户是否也是35邮箱
 */
@property (nonatomic, assign) BOOL oaUserIs35Mail;
/**
 *  oa的域名
 */
@property (nonatomic, strong) NSString *oaDomin;
/**
 *  oa的用户名
 */
@property (nonatomic, strong) NSString *oaUserName;
/**
 *  oa的密码
 */
@property (nonatomic, strong) NSString *oaPassword;

/**
 eis免登录验证的accesstoken
 */
@property (nonatomic, strong) NSString *eisAccessToken;

/**
 eis免登录验证的accesstoken的创建时间
 */
@property (nonatomic, strong) NSString *eisAccesstokenCreatetime;

/**
 eis免登录验证的accesstoken的剩余过期时间(秒为单位)
 */
@property (nonatomic, assign) NSInteger eisAccesstokenExpireinTime;
/**
 eden的实际IP地址
 */
@property (nonatomic, strong) NSString *eisRouteIpAddress;
/**
 *  免登录验证的accesstoken
 */
@property (nonatomic, strong) NSString *oaAccesstoken;
/**
 *  免登录验证的accesstoken的创建时间
 */
@property (nonatomic, strong) NSString *oaAccesstokenCreatetime;
/**
 *  免登录验证的accesstoken的过期时间间隔(秒为单位)
 */
@property (nonatomic, assign) NSInteger oaAccesstokenExpireinTime;
/**
 *  oa用户类型（比如第三方绑定的OA用户,0为oa用户，1为个人邮箱用户）
 */
@property (nonatomic, assign) int oaUserType;
/**
 *  邮箱登录类型（0为传统邮箱登录，1为oa账号绑定的邮箱登录(有可能绑定的邮箱已经登录了，这时候不需要输入密码直接进入主页即可)）
 */
@property (nonatomic, assign) int emailLoginType;
/**
 *  是否有工作台权限（只要是oa用户都有工作台权限，绑定的第三方邮箱也有）
 */
@property (nonatomic,assign) BOOL hasWorkspace;

/**
 *  是否禁用企业联系人
 */
@property (nonatomic,assign) BOOL isBusinessContactDisabled;

/**
 *  是否已经提取了已发送的重要邮件信息
 */
@property (nonatomic,assign) BOOL isSentMailAnalysised;

/**
 *  重置oa请求状态
 */
- (void)resetOaStatus;

#pragma mark - push setting

/**
 *  新消息提醒开关
 */
@property (nonatomic, assign) BOOL msgPushFlag;
/**
 *  新邮件提醒开关
 */
@property (nonatomic, assign) BOOL mailPushFlag;
/**
 *  oa提醒开关
 */
@property (nonatomic, assign) BOOL oaPushFlag;
/**
 *  通知是否显示详情
 */
@property (nonatomic, assign) BOOL pushDetailFlag;

/***邮件设置***/
/**
 *  写信是否抄送自己
 */
@property (nonatomic, assign) BOOL ccForYourself;
/**
 *  发送邮件错误
 */
@property (nonatomic, assign) BOOL sentErrorNote;

@end
