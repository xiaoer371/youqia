//
//  MCIMSessionManager.h
//  NPushMail
//
//  Created by admin on 2/29/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCIMConversationModel.h"
#import "MCIMMessageModel.h"
#import "MCIMGroupModel.h"
#import "MCContactModel.h"

@protocol MCIMConversationProtocol <NSObject>

- (void)conversationDidDeleted:(MCIMConversationModel *)conversation;

@end

@interface MCIMConversationManager : NSObject

@property (nonatomic,weak) id<MCIMConversationProtocol> delegate;

+ (instancetype)shared;

/**
 *  根据消息获取或创建一个会话，如果是创建，此时还没有插入到数据库
 *
 *  @param msg 消息对象
 *
 *  @return 会话对象
 */
- (MCIMConversationModel *)conversationForMessage:(MCIMMessageModel *)msg;

/**
 *  根据最后一条消息更新会话内容
 *
 *  @param conversation 会话对象
 *  @param msg          最后一条消息
 */
- (void)updateConversation:(MCIMConversationModel *)conversation withMessage:(MCIMMessageModel *)msg;

/**
 *  根据群组找到或创建一个新的会话，如果是新建，这时候的会话还不会插入到数据库中，要等到收到消息才会真正的创建这个会话
 *
 *  @param group 群组信息
 *
 *  @return 会话对象
 */
- (MCIMConversationModel *)conversationForGroup:(MCIMGroupModel *)group;

/**
 *  根据联系人查找或创建一个会话，这时候的会话还不会插入到数据库中，要等到收到消息才会真正的创建这个会话
 *
 *  @param contact 联系人信息
 *
 *  @return 会话信息
 */
- (MCIMConversationModel *)conversationForContact:(MCContactModel *)contact;

/**
 *  新增会话
 *
 *  @param model 要新增的会话
 */
- (void)insertConversation:(MCIMConversationModel *)model;

/**
 *  更新会话状态
 *
 *  @param model 要更新的会话
 */
- (void)updateConversation:(MCIMConversationModel *)model;

/**
 *  标志删除当前会话，不在会话列表显示
 *
 *  @param model 需要删除的会话
 */
- (void)removeConversation:(MCIMConversationModel *)model;

/**
 *  永久删除会话，用于退出群等操作
 *
 *  @param peerId 发送方id
 */
- (void)deleteConversationPermantelyWithPeerId:(NSString *)peerId;

/**
 *  获取所有的会话
 *
 *  @return 所有会话列表
 */
- (NSArray *)getAllConversations;

/**
 *  根据对方id获取会话
 *
 *  @param peerId 对方id
 *
 *  @return 会话对象
 */
- (MCIMConversationModel *)getConversationWithPeerId:(NSString *)peerId;

/**
 *  获取会话的对方信息
 *
 *  @param peerId 对方id
 *  @param type   会话类型
 *
 *  @return 对方对象
 */
- (id<MCIMPeerModelProtocol>)getPeerWithPeerId:(NSString *)peerId conversationType:(MailChatConversationType)type;



/**
 * 添加默认会话列表
 */
- (void)addFeiBaConversation;

- (void)addWeiYaConversation;

- (void)addHelperConversation;

- (void)addOAConversation;

@end
