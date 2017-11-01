//
//  MCServerAPI+EIS.h
//  NPushMail
//
//  Created by admin on 3/23/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCServerAPI.h"
#import "MCEnterpriseSyncConfig.h"
#import "MCContactInfoConfig.h"

@interface MCServerAPI (EIS)

/**
 *  用户获取联系人信息
 *
 *  @param contacts （联系人列表）格式json string：{'data': [{e:邮箱,ts:时间戳},...{e:邮箱,ts:时间戳}....]}
 *  @param success
 *  @param failure
 */
- (void)syncContacts:(NSArray *)contacts success:(SuccessBlock)success failure:(FailureBlock)failure;

/**
 *  获取用户的企业联系人信息
 *
 *  @param email   邮件地址
 *  @param lastSyncTimestamp  上次更新时间
 *  @param success 成功回调，返回 MCEnterpriseSyncConfig
 *  @param failure 失败回调，返回错误信息
 */
- (void)getEnterpriseContactsWithEmail:(NSString*)email lastSyncTimestamp:(NSTimeInterval)lastTimestamp success:(SuccessBlock)success failrue:(FailureBlock)failure;

@end
