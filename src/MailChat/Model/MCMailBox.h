//
//  MailBox.h
//  NPushMail
//
//  Created by swhl on 14-10-8.
//  Copyright (c) 2014年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

//邮件夹
typedef NS_ENUM(NSInteger, MCMailFolderType) {
    MCMailFolderTypeSmartBox = -1,//重要邮件夹
    MCMailFolderTypeInbox = 0,    //收件箱
    MCMailFolderTypePending,      //待发送
    MCMailFolderTypeSent,         //已发送
    MCMailFolderTypeStarred,      //收藏夹
    MCMailFolderTypeDrafts,       //草稿箱
    MCMailFolderTypeTrash,        //已删除
    MCMailFolderTypeSpam,         //垃圾邮件
    MCMailFolderTypeOther
};


@interface MCMailBox : NSObject

@property (nonatomic,assign) NSInteger uid;

@property (nonatomic,assign) NSInteger accountId;

/**
 *  当前显示文件夹名称
 */
@property (nonatomic,copy) NSString *name;

/**
 *  文件夹imap名称 如  INBOX.Archive
 */
@property (nonatomic,copy) NSString *path;

/**
 *  It's the delimiter for each component of the path. Commonly . or /
 */
@property (nonatomic,assign) char delimiter;
/**
 * 文件夹图标
 */
@property (nonatomic,strong)UIImage *boxIconIamge;
/**
 * 文件夹类型
 */
@property (nonatomic,assign) MCMailFolderType type;

//文件夹标记
@property (nonatomic, assign) NSInteger flags;

/**
 *  The folder's IMAP UIDNEXT value. Used to determine the uid for the next received message.
 */
@property (nonatomic, assign) NSInteger uidNext;

@property (nonatomic,assign) NSInteger uidValidity;

@property (nonatomic,assign) NSInteger uidFractured;

//文件夹位序
@property (nonatomic,assign) NSInteger folderOrder;

/**
 *  总的数量
 */
@property (nonatomic,assign) NSInteger totalCount;
//未读数量
@property (nonatomic,assign) NSInteger unreadCount;
//展示数量
@property (nonatomic,assign) NSInteger showCount;

@property (nonatomic,assign) NSInteger highestModSeqValue;

/**
 *  能否选中
 */
@property (nonatomic,assign) BOOL selectable;

@property (nonatomic,assign) NSInteger parentId;

/**
 *  层级关系，最上层是0
 */
@property (nonatomic,assign) NSInteger level;

/**
 *  最后同步时间
 */
@property (nonatomic,assign) NSTimeInterval syncUtc;
//是否拥有IMAPfolderFlag
@property (nonatomic,assign) BOOL haveIMAPfolderFlag;
@end
