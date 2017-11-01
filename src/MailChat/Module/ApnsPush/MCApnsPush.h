//
//  MCApnsPush.h
//  NPushMail
//
//  Created by wuwenyu on 16/1/21.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCApnsPushConfig.h"

static NSInteger const kMailChatApnsVersion = 2; //用于每次重装时push状态的设置(每次修改只能递增)

typedef void(^ResultBlock)(BOOL result);
typedef void(^pushSettingModel)(MCPushSettingModel *model);

@interface MCApnsPush : NSObject


- (instancetype)initWithToken:(NSString *)token clientId:(NSString *)clientId;

/**
 推送新接口
 */


/**
 获取设备推送设置，进入应用时获取，显示群组或私聊提醒屏蔽状态，或进入推送设置页面时，显示当前设置信息
 */
- (void)getPushDetailsWithSuccess:(SuccessBlock)success failure:(FailureBlock)failure;

/**
 更新设备推送设置，使用场景：在设置中调整配置

 @param email 指定的邮箱，需要有绑定这个邮箱。不传递邮箱为总配置。
 @param settingModel
 @param success
 @param failure
 */
- (void)updatePushSettingWithPushSettingModel:(MCPushSettingModel *)pushSettingModel success:(SuccessBlock)success failure:(FailureBlock)failure;

-(void)setPushOnOrOffWithTopic:(NSString *)topic
                            on:(BOOL)onOrOff
                   resultBlock:(ResultBlock)result;
- (void)setPushSettingConfigWithSettingModel:(MCPushSettingModel *)model;
- (MCPushSettingModel *)getPushSettingModelWithEmail:(NSString *)email;
+ (BOOL)isOaUserWithEmail:(NSString *)email;

@end
