//
//  MCIMMessageHandle.m
//  NPushMail
//
//  Created by admin on 3/9/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCIMMessageHandle.h"
#import "MCIMMessageManager.h"
#import "MCIMConversationManager.h"
#import "MCIMMessageManager.h"
#import "MCNotificationCenter.h"
#import "MCContactManager.h"

@interface MCIMMessageHandle ()

@property (nonatomic,strong) MCIMMessageManager *msgMgr;

@end

@implementation MCIMMessageHandle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _msgMgr = [MCIMMessageManager new];
    }
    return self;
}

- (void)processData:(MCIMDataModel *)data
{
    if (data.serviceType != IMServiceTypeMsgData) {
        return;
    }
    
    MCIMMessageModel *msg = (MCIMMessageModel *)data;
    // 在自己发给群消息的情况下，消息会重复
    if ([self.msgMgr messageExists:msg.messageId]) {
        return;
    }
    
    MCIMConversationManager *conversationMgr = [MCIMConversationManager shared];
    MCIMConversationModel *conversation = [conversationMgr conversationForMessage:msg];
    if (conversation) {
        [conversationMgr updateConversation:conversation withMessage:msg];
        [self.msgMgr insertMessage:msg];
        [MCNotificationCenter postNotification:MCNotificationDidReceiveMessage object:msg];
    }
}

@end
