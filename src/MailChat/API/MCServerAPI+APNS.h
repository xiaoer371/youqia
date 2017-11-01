//
//  MCServerAPI+APNS.h
//  NPushMail
//
//  Created by admin on 3/23/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCServerAPI.h"

@interface MCServerAPI (APNS)

/**
 *  开启、屏蔽来自群组、个人的消息提醒
 *
 *  @param success
 *  @param failure
 */
- (void)setTopicPushOnOrOffWithParameters:(NSDictionary *)parameters
                                  success:(SuccessBlock)success
                                  failrue:(FailureBlock)failure;

/**
 
 获取设备推送设置，进入应用时获取，显示群组或私聊提醒屏蔽状态，或进入推送设置页面时，显示当前设置信息

 @param success
 @param failure 
 */
- (void)getPushDetailsWithDic:(NSDictionary *)dic success:(SuccessBlock)success failrue:(FailureBlock)failure;

/**
 更新设备推送设置，使用场景：在设置中调整配置

 @param dic 参数
 @param success
 @param failure
 */
- (void)updatePushSettingWithDic:(NSDictionary *)dic success:(SuccessBlock)success failrue:(FailureBlock)failure;
@end
