//
//  MCMailConfigManager.h
//  NPushMail
//
//  Created by admin on 1/7/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCMailConfig.h"

@interface MCMailConfigManager : NSObject

+ (instancetype)shared;

/**
 *  根据用户名查找到正确的配置
 *
 *  @param email   邮箱地址
 *  @param forceUpdate 是否强制获取最新的mx纪录，用于mx纪录变更时进行更新
 *  @param success 成功回调，返回 MCMailConfig 或 nil，nil表示找不到正确的配置，需要用户手动设置
 *  @param failure 失败回调
 */
- (void)findMailConfigWithEmail:(NSString *)email
                    forceUpdate:(BOOL)forceUpdate
                        success:(SuccessBlock)success
                        failure:(FailureBlock)failure;

/**
 *  保存邮件配置到本地和服务器，必须在登录成功后才能提交，避免保存错误的配置
 *
 *  @param config  邮件配置
 *  @param email   邮件地址
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)saveMailConfig:(MCMailConfig *)config
               forMail:(NSString *)email
               success:(SuccessBlock)success
               failure:(FailureBlock)failure;

+ (MCMailConfig *)defaultConfigForMail:(NSString *)mail ssl:(BOOL)ssl;

+ (NSDictionary *)getOldMailConfigs;

@end
