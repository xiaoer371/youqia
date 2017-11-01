//
//  MCAliMsgBaseModel.h
//  NPushMail
//
//  Created by swhl on 16/12/9.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAliBaseModel.h"

typedef enum : NSUInteger {
        MCAliMsgTypeUnknown     = 0,       // 未知格式
        MCAliMsgTypeText        = 1,       // 文本
        MCAliMsgTypeImage       = 2,       // 图片
        MCAliMsgTypeSound       = 3,       // 语音
        MCAliMsgTypeFile        = 4,       // 文件
        MCAliMsgTypeVideo       = 5,       // 视频
        MCAliMsgTypeLocation    = 6,       // 位置
        MCAliMsgTypeFace        = 7,       // 表情
        MCAliMsgTypeCard        = 8,       // 名片
        MCAliMsgTypeMail        = 9,       // 在消息里面引用的邮件
        MCAliMsgTypeTips        = 10,      // 消息中间的提示
        MCAliMsgTypeRedPacket   = 11,      // 红包
} MCAliMsgType;

typedef enum : NSUInteger {
    MCAliMsgStateTypeSending = 0,
    MCAliMsgStateTypeSuccess = 1,
    MCAliMsgStateTypeFailure = 2,
} MCAliMsgStateType;

@interface MCAliMsgBaseModel : MCAliBaseModel

/**
 消息类型
 */
@property (nonatomic, assign) MCAliMsgType  type;

/**
  来自谁的消息
 */
@property (nonatomic, strong) NSString  *from;

/**
 发送给谁的消息
 */
@property (nonatomic, strong) NSString  *to;

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
@property (nonatomic ,assign) MCAliMsgStateType state;

/**
 *   是否是自己发送的消息
 */
@property (nonatomic) BOOL isSender;

/**
 *  单元格的高度
 */
@property (nonatomic,assign) CGFloat cellHeight;


@end
