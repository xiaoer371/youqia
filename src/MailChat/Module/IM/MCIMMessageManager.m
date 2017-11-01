//
//  MCIMMessageManager.m
//  NPushMail
//
//  Created by admin on 2/25/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCIMMessageManager.h"
#import "MCMsgContentTable.h"

@implementation MCIMMessageManager
{
    MCMsgContentTable *_db;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _db = [MCMsgContentTable new];
    }
    return self;
}

- (void)insertMessage:(MCIMMessageModel *)msg
{
    [_db insertModel:msg];
}
- (void)deleteMessage:(MCIMMessageModel *)msg
{
    [_db deleteMessage:msg];
}

- (void)updateMessage:(MCIMMessageModel *)msg
{
    [_db updateModel:msg];
}

- (void)updateMessageState:(MCIMMessageModel *)msg
{
    [_db updateMessageState:msg];
}

- (NSArray *)getConversationMessages:(NSInteger)conversationId fromId:(NSInteger)fromId number:(NSInteger)number
{
    return [_db getMessagesWithConversationId:conversationId fromId:fromId number:number];
}

- (MCIMMessageModel*)getLastMessageModelWithConversationId:(NSInteger)conversationId
{
    NSArray *array =[self getConversationMessages:conversationId fromId:NSIntegerMax number:1];
    return [array lastObject];
}

- (BOOL)messageExists:(NSString *)messageId
{
    return [_db messageExists:messageId];
}

- (void)updateState:(IMMessageState)state withMqttMsgId:(NSInteger)msgId
{
    [_db updateState:state withMsgId:msgId];
}

- (void)clearMessagesWithConversationId:(NSInteger)conversationId
{
    [_db deleteMessagesWithConversationId:conversationId];
}

- (NSArray*)getVoiceNameWithConversationId:(NSInteger)conversationId
{
    return [_db getVoiceNameWithConversationId:conversationId];
}

- (void)updateFileMessageWithFileId:(NSString*)fileId
{
     [_db updateFileMessageWithFileId:fileId];
}


@end
