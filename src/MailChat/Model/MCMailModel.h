//
//  MailModel.h
//  NPushMail
//
//  Created by swhl on 14-9-15.
//  Copyright (c) 2014年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCMailConstants.h"
#import "MCMailAddress.h"
#import "MCContactModel.h"

//邮件分类
typedef NS_ENUM(NSInteger, MCMailClassifyType) {
    MCMailClassifyTypeALL = 0,
    MCMailClassifyTypeUnread,
    MCMailClassifyTypeCollection
};

//邮件批量操作
typedef NS_ENUM(NSInteger, MCMailProcessType) {
    MCMailProcessRead = 0,
    MCMailProcessUnread,
    MCMailProcessStarred,
    MCMailProcessUnstarred,
    MCMailProcessMove,
    MCMailProcessDelete,
    MCMailProcessVip,
    MCMailProcessUnVip,
    MCMailProcessBacklog,
    MCMailProcessUnBackLog
};


typedef NS_OPTIONS(NSInteger, MCMailTags){
    MCMailTagNone = 0,
    MCMailTagImportant = 1 << 0,
    MCMailTagBacklog = 1 << 1,
    MCMailTagAll = MCMailTagNone | MCMailTagImportant | MCMailTagBacklog
};


/**
 邮件状态

 - MCMailStatusDefault: 默认未处理
 */
typedef NS_ENUM(NSInteger, MCMailStatus){
    MCMailStatusDefault = 0,      // 默认未处理
    MCMailStatusProcessed = 1     // 已处理
};

typedef void(^MCMailProcessBlock) (NSArray *mails,id obj,MCMailProcessType processType);

static NSString *const MCMailNeedToSynchKey = @"MCSYNC";

@interface MCMailModel : NSObject

/**
 *  本地ID，自增长
 */
@property (nonatomic,assign) NSInteger uid;

@property (nonatomic,assign) NSInteger accountId;

/**
 *  邮件所在的文件夹id
 */
@property (nonatomic,assign) NSInteger boxId;

//文件夹
@property (nonatomic,copy) NSString *folder;

//邮件uid  唯一
@property (nonatomic,assign) NSInteger messageUid;

//messageID
@property (nonatomic,copy) NSString *messageId;

@property (nonatomic,copy) NSString *conversationId;

//自定义标示
@property (nonatomic,copy) NSString *customMarkId;


//邮件主题
@property (nonatomic,copy) NSString *subject;

//邮件内容  html格式
@property (nonatomic,copy) NSString *messageContentHtml;

//邮件内容 纯文本格式
@property (nonatomic,copy) NSString *messageContentString;

//收藏标记
@property (nonatomic,assign) BOOL isStar;

//已读标记
@property (nonatomic,assign) BOOL isRead;
//已回复标记
@property (nonatomic,assign) BOOL isAnswer;
//转发
@property (nonatomic,assign) BOOL isForward;
//附件标记
@property (nonatomic,assign) BOOL hasAttachment;

//邮件大小
@property (nonatomic,assign)  NSInteger messageSize;

//邮件接收的时间
@property (nonatomic,strong) NSDate *receivedDate;

/** References field. It's an array of message-ids.*/
@property (nonatomic, copy) NSArray *references;

/** In-Reply-To field. It's an array of message-ids.*/
@property (nonatomic, copy) NSArray *inReplyTo;

/** Date field: sent date of the message.*/
@property (nonatomic, strong) NSDate * date;

@property (nonatomic, strong) MCMailAddress *from;

/**
 *  收件人地址，是一个 MCMailAddress 数组
 */
@property (nonatomic, strong) NSArray *to;

@property (nonatomic, strong) NSArray *cc;

@property (nonatomic, strong) NSArray *bcc;

@property (nonatomic, strong) NSArray *replyTo;

@property (nonatomic, assign) MCMailTags tags;

@property (nonatomic, assign) MCMailFlags mailFlags;

/**
 邮件优先级，1 表示高，3 表示中，5表示低，默认0表示没有设置优先级
 */
@property (nonatomic,assign) NSInteger xPriority;

/**
 * 附件内容，是一个MCMailAttachment 数组
 */
@property (nonatomic, strong) NSArray *attachments;
/**
 * 附件内容，是一个MCMailAttachment 数组 inlineAttachment;
 */
@property (nonatomic, strong) NSArray *inlineAttachments;

@property (nonatomic,assign) BOOL isDeleted;

@property (nonatomic,assign) BOOL isSelected;

@property (nonatomic,assign) BOOL isPush;

@property (nonatomic,strong) MCContactModel *fromUser;

@property (nonatomic,assign) MCMailStatus status;

- (BOOL)isEqualToDraftModel:(id)object;

@end
