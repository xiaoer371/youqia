//
//  MCIMMessageSender.h
//  NPushMail
//
//  Created by admin on 4/8/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCIMMessageModel.h"
#import "MCIMCommandModel.h"
#import "MCIMConversationModel.h"
#import "MCFileCore.h"
#import "MCFileBaseModel.h"

@interface MCIMMsgData : NSObject

@property (nonatomic,assign) UInt16 msgId;
@property (nonatomic,assign) NSInteger qos;
@property (nonatomic,strong) NSData *data;

@end

@interface MCIMMessageSender : NSObject

/**
 *  Timeout in seconds, Default is 10 seconds.
 */
@property (nonatomic,assign) NSInteger timeout;

+ (instancetype)shared;

/**
 *  发送命令到指定的频道
 *
 *  @param cmd     要发送的命令
 *  @param topic   频道
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)sendCommand:(MCIMCommandModel *)cmd toTopic:(NSString *)topic success:(ActionBlock)success failure:(FailureBlock)failure;

/**
 *  发送一条模拟消息，只是发给自己，用于消息流间的提示
 *
 *  @param conversation     对话
 */
- (void)sendFakeMessageWithText:(NSString *)text toConversation:(MCIMConversationModel *)conversation;

/**
 *  发送一条模拟消息
 *
 *  @param text         消息内容
 *  @param from         发送方
 *  @param conversation 到指定的对话
 *  @param msgType      消息类型，只能是 IMMessageTypeNotice 或 IMMessageTypeText
 */
- (void)sendFakeMessageWithText:(NSString *)text from:(NSString *)from conversation:(MCIMConversationModel *)conversation messageType:(IMMessageType)msgType;

/**
 *  发送一条通知消息到指定的频道
 *
 *  @param notice  通知内容
 *  @param topic   频道id
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @return 消息实体
 */
- (MCIMMessageModel *)sendNotice:(NSString *)notice toConversation:(MCIMConversationModel *)conversation success:(ActionBlock)success failure:(FailureBlock)failure;

/**
 *  发送文本消息到对应的会话
 *
 *  @param text         文本内容
 *  @param conversation 要发送的会话
 *  @param success      成功回调
 *  @param failure      失败回调
 *
 *  @return 返回新建的消息对象
 */
- (MCIMMessageModel *)sendText:(NSString *)text toConversation:(MCIMConversationModel *)conversation success:(ActionBlock)success failure:(FailureBlock)failure;

/**
 *  发送图片到指定的对话
 *
 *  @param image        图片
 *  @param conversation 相关的对话
 *  @param success      成功回调
 *  @param failure      失败回调
 *
 *  @return 消息对象
 */
- (MCIMMessageModel *)sendImage:(UIImage *)image toConversation:(MCIMConversationModel *)conversation success:(ActionBlock)success failure:(FailureBlock)failure;

/**
 *  发送文件到指定的会话
 *
 *  @param fileModel    文件对象
 *  @param fileName     文件名
 *  @param conversation 要发送的会话
 *  @param success      成功回调
 *  @param failure      失败回调
 *
 *  @return 消息对象
 */
- (MCIMMessageModel *)sendFileWithModel:(MCFileBaseModel *)fileModel fileName:(NSString *)fileName toConversation:(MCIMConversationModel *)conversation success:(ActionBlock)success failure:(FailureBlock)failure;

/**
 *  发送语音消息
 *
 *  @param voiceData    语音数据，amr格式的数据
 *  @param seconds      语音长度，单位秒
 *  @param voiceName    语音本地路径，wav格式的路径
 *  @param conversation 发送的对话
 *  @param success      成功回调
 *  @param failure      失败回调
 *
 *  @return 消息对象
 */
- (MCIMMessageModel *)sendVoiceWithData:(NSData *)voiceData seconds:(CGFloat)seconds name:(NSString *)voiceName toConversation:(MCIMConversationModel *)conversation success:(ActionBlock)success failure:(FailureBlock)failure;

/**
 *  转发一条消息到指定的会话
 *
 *  @param msg          要转发的消息
 *  @param conversation 目标会话
 *  @param success      成功回调
 *  @param failure      失败回调
 *
 *  @return 新的消息对象
 */
- (MCIMMessageModel *)forwardMessage:(MCIMMessageModel *)msg toConversation:(MCIMConversationModel *)conversation success:(ActionBlock)success failure:(FailureBlock)failure;


/**
 *  重发一条消息到指定的会话
 *
 *  @param msg          要重发的消息
 *  @param conversation 目标会话
 *  @param success      成功回调
 *  @param failure      失败回调
 *
 *  @return 新的消息对象
 */
- (MCIMMessageModel *)resendMessage:(MCIMMessageModel *)msg toConversation:(MCIMConversationModel *)conversation success:(ActionBlock)success failure:(FailureBlock)failure;


@end
