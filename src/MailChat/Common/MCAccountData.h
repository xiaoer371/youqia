//
//  MCAccountData.h
//  NPushMail
//
//  Created by admin on 5/10/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCAccountDatabase;
@class MCAccountConfig;
@class MCContactManager;
@class MCIMConversationManager;
@class MCIMClient;
@class MCIMService;
@class MCIMGroupManager;
@class MCIMMessageSender;

/**
 *  每个账户下相关的数据，切换账户的时候直接重新创建此对象即可。
 *  必须把账户相关的数据都从这边取，否则切换账户的时候切换不过去
 */
@interface MCAccountData : NSObject

@property (nonatomic,strong) MCAccount *account;

- (instancetype)initWithAccount:(MCAccount *)account;

@property (nonatomic,readonly) MCAccountDatabase *accountDb;

@property (nonatomic,readonly) MCAccountConfig *accountConfig;

@property (nonatomic,readonly) MCContactManager *contactManager;

@property (nonatomic,readonly) MCIMClient *imClient;

@property (nonatomic,readonly) MCIMService *imService;

@property (nonatomic,readonly) MCIMMessageSender *imMessageSender;

@property (nonatomic,readonly) MCIMConversationManager *imConversationManager;

@property (nonatomic,readonly) MCIMGroupManager *imGroupManager;


@end
