//
//  MCIMConversationModel.h
//  NPushMail
//
//  Created by admin on 2/22/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCIMMessageModel.h"
#import "MCContactModel.h"
#import "MCIMPeerModelProtocol.h"

typedef enum : NSUInteger {
    MailChatConversationStateNormal = 0,
    MailChatConversationStateDeleted,
} MailChatConversationState;

@interface MCIMConversationModel : NSObject

@property (nonatomic,assign) NSInteger uid;

@property (nonatomic,assign) MailChatConversationType type;

/**
 *  会话id。单聊：对方的邮件地址；群聊：群组id；OA: oa 的id
 */
@property (nonatomic,strong) NSString *peerId;

@property (nonatomic,strong) NSDate *lastMsgTime;

@property (nonatomic,strong) NSString *content;

@property (nonatomic,strong) NSString *draft;

@property (nonatomic,assign) NSInteger unreadCount;

/**
 *  设置置顶的时间，如果没有置顶，默认为0
 */
@property (nonatomic,assign) NSTimeInterval onTopTime;

/**
 *  是否屏蔽消息
 */
@property (nonatomic,assign) BOOL isShield;

/**
 *  是否正在聊天，如果是的话，就不要增加未读数
 */
@property (nonatomic,assign) BOOL isChatting;

@property (nonatomic,assign) MailChatConversationState state;

@property (nonatomic,strong) MCIMMessageModel *lastMessage;



/**
 *  对方对象
 */
@property (nonatomic,strong) id<MCIMPeerModelProtocol> peer;

@end
