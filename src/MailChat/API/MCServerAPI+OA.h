//
//  MCServerAPI+OA.h
//  NPushMail
//
//  Created by wuwenyu on 16/5/30.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCServerAPI.h"

//OA事务类型
typedef NS_ENUM(NSInteger, OAUrlType) {
    OATrans = 0, //待办事务
    OAMypass = 1,//我办过的
    OAMycreate = 2,//我发起的
    OANew = 3,//新建事务
};

@interface MCServerAPI (OA)
/**
 *  oa的跳转页面URL
 *
 *  @param payloadUrl apns的url，可直接跳转
 *  @param isMqtt     MQTT推送的，一般是指在应用内收到OA消息
 *  @param oaUrlType  OA的事务类型
 *
 *  @return
 */
- (NSString *)getOaResultUrlWithPayloadUrl:(NSString*)payloadUrl isMQTT:(BOOL)isMqtt withEndUrlType:(OAUrlType)oaUrlType;
/**
 *  OA的主页URL
 *
 *  @return
 */
- (NSString *)getOaHomePageResultUrl;
/**
 *  判断是否是0A用户
 *
 *  @param email
 *  @param success
 *  @param failure
 */
- (void)isOaUserWithEmail:(NSString*)email success:(SuccessBlock)success failrue:(FailureBlock)failure;
/**
 *  判断邮箱是否绑定过OA账号
 *
 *  @param email
 *  @param success
 *  @param failure
 */
- (void)checkIsBindingOAWithEmail:(NSString *)email success:(SuccessBlock)success failrue:(FailureBlock)failure;
/**
 *  获取OA登录类型（邮洽验证OA登录参数）
 *
 *  @param domin   oa域名（由checkIsBindingOAWithEmail接口返回的）
 *  @param success
 *  @param failure
 */
- (void)getOAUserLoginTypeWithDomin:(NSString *)domin success:(SuccessBlock)success failrue:(FailureBlock)failure;
/**
 *  登录oa(邮洽验证OA登录参数)PS:最新接口，取代getOAUserLoginTypeWithDomin
 *
 *  @param domin   oa域名（由checkIsBindingOAWithEmail接口返回的）
 *  @param success
 *  @param failure
 */
- (void)loginOaWithDomin:(NSString *)domin success:(SuccessBlock)success failrue:(FailureBlock)failure;
/**
 *  登录oa(邮洽验证OA登录参数)PS:最新接口，取代getOAUserLoginTypeWithDomin
 *
 *  @param userName   oa用户名
 *  @param pwd        oa密码
 *  @param success
 *  @param failure
 */
- (void)loginOaWithUserName:(NSString *)userName password:(NSString *)pwd domin:(NSString *)domin success:(SuccessBlock)success failrue:(FailureBlock)failure;
/**
 *  获取oa绑定的邮箱账号
 *
 *  @param success
 *  @param failure
 */
- (void)getOaBindingMailWithMail:(NSString *)mail oaUserName:(NSString *)userName oaPassword:(NSString *)pwd success:(SuccessBlock)success failrue:(FailureBlock)failure;

/**
 获取EIS实际IP地址

 @param success
 @param failure
 */
- (void)getEisRouteAddressWithSuccess:(SuccessBlock)success failrue:(FailureBlock)failure;

/**
 获取EIS的token

 @param act 用户
 @param success
 @param failure
 */
- (void)getEisTokenWithAccount:(MCAccount *)act ip:(NSString *)ip success:(SuccessBlock)success failrue:(FailureBlock)failure;

/**
 获取EIS首页
 */
- (NSString *)getEisHomeUrl;
@end
