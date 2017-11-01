//
//  MCServerAPI+Event.h
//  NPushMail
//
//  Created by swhl on 16/12/15.
//  Copyright © 2016年 sprite. All rights reserved.
//

/**
 *  邮洽活动API
 */

#import "MCServerAPI.h"

@interface MCServerAPI (Event)

/*
 * u=[用户名]&d=[临时帐号]&p=[密码]&e=[邮箱] 
 * 结果返回：
 * {'result': 1} //用户邮箱有参加流量活动，且未领取流量
 * {'result': 0} //不需要显示或参数错误（缺少e参数或邮箱没有绑定，有code及message字段）
 */
- (void)checkEventWithEmail:(NSString *)e
                    success:(SuccessBlock)success
                    failure:(FailureBlock)failure;

@end
