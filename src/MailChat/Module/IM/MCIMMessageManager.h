//
//  MCIMMessageManager.h
//  NPushMail
//
//  Created by admin on 2/25/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCIMMessageModel.h"

@interface MCIMMessageManager : NSObject

- (void)insertMessage:(MCIMMessageModel *)msg;

- (void)deleteMessage:(MCIMMessageModel *)msg;

- (void)updateMessage:(MCIMMessageModel *)msg;

- (void)updateMessageState:(MCIMMessageModel *)msg;

- (NSArray *)getConversationMessages:(NSInteger)conversationId fromId:(NSInteger)fromId number:(NSInteger)number;

- (MCIMMessageModel*)getLastMessageModelWithConversationId:(NSInteger)conversationId;

- (BOOL)messageExists:(NSString *)messageId;

/**
 *  更新消息的状态
 *
 *  @param state  要更新的状态
 *  @param msgId mqtt库发送时候赋予消息的id
 */
- (void)updateState:(IMMessageState)state withMqttMsgId:(NSInteger)msgId;


/**
 *  清除聊天记录
 *
 *  @param msg 消息model
 */
- (void)clearMessagesWithConversationId:(NSInteger)conversationId;


/**
 *  获取会话的所有语音文件 models
 *
 *  @param conversationId 会话id
 *
 *  @return 返回语音文件消息  models
 */
- (NSArray*)getVoiceNameWithConversationId:(NSInteger)conversationId;


/**
 *  更新文件消息的状态
 *
 *  @param fileId 文件id
 */
- (void)updateFileMessageWithFileId:(NSString *)fileId;

@end
