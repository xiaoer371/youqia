//
//  MCIMMessageModel.h
//  NPushMail
//
//  Created by swhl on 16/1/27.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMDataModel.h"

typedef enum : NSUInteger {
    MailChatConversationTypeSingle = 0,
    MailChatConversationTypeGroup,
    MailChatConversationTypeApp,      //oa
    MailChatConversationTypeFeiba,    //飞巴商旅
    MailChatConversationTypeEvent,    //35 尾牙活动
    MailChatConversationTypeEventlive,    //35 尾牙活动直播
} MailChatConversationType;

typedef enum : NSUInteger {
    IMMessageTypeText =0,
    IMMessageTypeImage =1,
    IMMessageTypeFile =2,
    IMMessageTypeVoice =3,
    IMMessageTypeLocation = 4,
    IMMessageTypeNotice = 5,
    IMMessageTypeMailReference = 6,
    IMMessageTypeOA = 1001,
} IMMessageType;


typedef enum : NSUInteger {
    IMMessageStateSending = 0,
    IMMessageStateSuccess = 1,
    IMMessageStateFailure = 2,
} IMMessageState;

@class MCContactModel;

@interface MCIMMessageModel : MCIMDataModel

@property (nonatomic,assign) NSInteger uid;

/**
 *  消息id  （消息id  是用uuid ）
 */
@property (nonatomic,copy) NSString *messageId;

/**
 *  所属的对话id
 */
@property (nonatomic,assign) NSInteger conversationId;

/**
 *  对话类型
 */
@property (nonatomic,assign) MailChatConversationType conversationType;

/**
 *  消息类型
 */
@property (nonatomic,assign) IMMessageType type;

/**
 *  来自谁的消息
 */
@property (nonatomic,copy) NSString *from;

/**
 *   发给谁的消息，如果是群聊，即使群id
 */
@property (nonatomic,copy) NSString *to;

/**
 *  消息时间
 */
@property (nonatomic,strong) NSDate *time;

/**
 *  消息内容
 */
@property (nonatomic,strong) NSString *content;

/**
 *  消息发送状态
 */
@property (nonatomic ,assign) IMMessageState state;

/**
 *   是否是自己发送的消息
 */
@property (nonatomic) BOOL isSender;

/**
 *  是否已读
 */
@property (nonatomic) BOOL isRead;

/**
 *  发送的时候mqtt会分配一个本地的msgId，发送成功后可根据这个msgId更新消息的状态
 */
@property (nonatomic,assign) NSInteger sendMsgId;

/**
 *  简单描述，文本消息就是文本内容，图片返回 ［图片］，文件返回 ［文件］等
 */
@property (nonatomic,readonly) NSString *shortDescription;

/**
 *  会话id。单聊：对方的邮件地址；群聊：群组id；OA: oa 的id
 */
@property (nonatomic,readonly) NSString *peerId;

@property (nonatomic,strong) MCContactModel *contactModel;

/**
 *  单元格的高度
 */
@property (nonatomic,assign) CGFloat cellHeight;

/**
 *  是否显示时间
 */
@property (nonatomic,assign) BOOL isShowTime;

@end

