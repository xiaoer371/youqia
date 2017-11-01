//
//  MCOAConfig.h
//  NPushMail
//
//  Created by wuwenyu on 16/5/31.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

//初始化OA配置的类型
typedef NS_ENUM(NSInteger, initOaConfigType) {
    IsOaUserType = 0, //是否OA用户
    CheckIsBindingOaType = 1,//是否绑定过OA
    OAUserLoginTypeType = 2,//OA登录的类型
};

@interface IsOaUser : NSObject

@property (nonatomic, assign) BOOL oaUserFlag;
//服务器返回的信息
@property (nonatomic, strong) NSString *message;
- (instancetype)initWithDictionary:(id)dict;

@end

@interface CheckIsBindingOa : NSObject

@property (nonatomic, assign) BOOL bindingOaFlag;
@property (nonatomic, strong) NSString *oaDomin;
@property (nonatomic, strong) NSString *oaUserName;
- (instancetype)initWithDictionary:(id)dict;

@end

@interface OAUserLoginType : NSObject
//服务器返回是否正确
@property (nonatomic, assign) BOOL success;
//服务器返回的信息
@property (nonatomic, strong) NSString *message;
//免登录验证的accesstoken
@property (nonatomic, strong) NSString *accesstoken;
//免登录验证的accesstoken的创建时间(格式为yyyy-MM-dd HH:mm:ss)
@property (nonatomic, strong) NSString *createtime;
//免登录验证的accesstoken的过期时间(单位秒)， (秒为单位,默认为2个小时，7200秒)
@property (nonatomic, assign) NSInteger expireinTime;
//OA用户名(完整的用户账号，如huangwj@35.cn)
@property (nonatomic, strong) NSString *oausername;
//OA用户ID
@property (nonatomic, strong) NSString *userid;
//OA用户绑定的邮箱(完整的邮箱,如huangwj@35.cn)
@property (nonatomic, strong) NSString *bindmail;
@property (nonatomic, assign) BOOL is35mail;
//错误码
/*
 * 0=验证成功
 * 1=加密的字符串过期
 * 2=该OA账号不存在
 * 12901=登录失败，用户名或密码错误
 * 12902=登录失败，该域不存在
 * 12908=登录已过期!
 * 20001=该域已经被关闭!
 * 20002=该域已经被暂停使用!
 * 20003=该域暂时被管理员暂停进行系统调整
 * 20004=该域暂时被管理员暂停进行系统调整
 * 20005=该域正在进行数据恢复操作，请稍后再重新登录
 * 21005=该域已过期
 * 12010=用户数已达最大
 * 12015=用户登录时,账户未激活
 * 12904=用户处于登录限制状态
 * 12905=用户处于限制IP登录状态
 * 12909=以imap方式登录时,imap参数丢失
 * 12910=在outerpost时,decode失败
 * 12911=登录模式非法
 * 12912=以IMAP方式登录时，服务器报错
 * 12913=以IMAP方式登录时，timeout
 * 12913=以IMAP方式登录时，timeout
 * 12920=获取用户的ACCESSTOKEN出错！
 * -202=参数不存在
 * -205=参数非法
 */
@property (nonatomic, assign) int errorcode;
- (instancetype)initWithDictionary:(id)dict;

@end

@interface MCOAConfig : NSObject

- (instancetype)initWithDictionary:(id)dict oaConfigType:(initOaConfigType)type;
@property (nonatomic ,strong) IsOaUser *isOaUser;
@property (nonatomic ,strong) CheckIsBindingOa *checkBindingOa;
@property (nonatomic ,strong) OAUserLoginType *oaUserLoginTypeType;

@end
