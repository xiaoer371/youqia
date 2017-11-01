//
//  MCMailTagManager.h
//  NPushMail
//
//  Created by admin on 9/6/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCMailModel.h"
#import "MCMailBox.h"

@interface MCMailTagManager : NSObject

/**
 *  获取邮件的状态
 *
 *  @param mail 邮件对象
 *
 *  @return 邮件的状态
 */
- (MCMailTags)mailTagForMail:(MCMailModel *)mail;


/**
 分析发件箱，以提取重要联系人的权重

 @param sentBox 发件箱
 @param success 成功回调，分析完成
 @param failure 失败回调，返回错误信息
 */
- (void)analysisSentBox:(MCMailBox *)sentBox success:(ActionBlock)success
                  failure:(FailureBlock)failure;

@end
