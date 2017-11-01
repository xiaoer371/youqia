//
//  MCMsgContentTable.h
//  NPushMail
//
//  Created by swhl on 16/1/26.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAccountTableBase.h"
#import "MCIMMessageModel.h"
#import "MCIMImageModel.h"
#import "MCIMFileModel.h"
#import "MCIMVoiceModel.h"
#import "MCIMAppModel.h"
#import "MCIMOAMessageModel.h"

@interface MCMsgContentTable : MCAccountTableBase

/**
 *  分页获取制定会话的消息记录
 *
 *  @param conversationId 会话id
 *  @param fromIndex      开始索引（不包括自身）
 *  @param number         获取的数量
 *
 *  @return 返回消息记录，如果没有记录，则返回count为0的array
 */
- (NSArray *)getMessagesWithConversationId:(NSInteger)conversationId fromId:(NSInteger)fromId number:(NSInteger)number;

- (BOOL)messageExists:(NSString *)messageId;

- (void)updateMessageState:(MCIMMessageModel *)model;

- (void)updateState:(IMMessageState)state withMsgId:(NSInteger)msgId;

- (void)deleteMessage:(MCIMMessageModel *)model;
/**
 *  清除会话的消息历史记录
 *
 *  @param conversationId 会话id
 */
- (void)deleteMessagesWithConversationId:(NSInteger)conversationId;


- (NSArray *)getVoiceNameWithConversationId:(NSInteger)conversationId;

- (void)updateFileMessageWithFileId:(NSString *)fileId;


@end
