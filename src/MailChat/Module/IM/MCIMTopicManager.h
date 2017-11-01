//
//  MCIMTopicManager.h
//  NPushMail
//
//  Created by admin on 3/30/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCIMGroupManager.h"

@interface MCIMTopicManager : NSObject

@property (nonatomic,strong,readonly) NSArray *privateTopics;

@property (nonatomic,strong,readonly) MCAccount *account;

@property (nonatomic,strong) NSMutableArray *inviteTopics;

- (instancetype)initWithAccount:(MCAccount *)account;

/**
 *  从服务器获取待加入和已有的群组id，然后和个人的topics进行合并，返回需要订阅的topics
 *
 *  @param success 成功回调，返回需要订阅的topics列表
 *  @param failure 失败回调，返回错误信息
 */
- (void)updateTopicsSuccess:(SuccessBlock)success failure:(FailureBlock)failure;

@end
