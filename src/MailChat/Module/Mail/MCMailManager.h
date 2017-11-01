//
//  MailManager.h
//  NPushMail
//
//  Created by admin on 12/14/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCMailAttachment.h"
#import "MCMailConfig.h"
#import "MCMailModel.h"
#import "MCMailBox.h"
#import "MCMailNotificationModel.h"

/**
 获取最新邮件的状态
 */
typedef enum : NSUInteger {
    LoadMailResultNoNewMails,     // 没有新邮件
    LoadMailResultLatestMails,    // 最新的邮件，替换当前已显示的邮件
} LoadMailResult;

typedef void(^LoadMailSuccessBlock)(MCMailBox *box, LoadMailResult result, NSArray *mails);


@interface MCMailSyncResult : NSObject

/**
 *  是否有新的邮件
 */
@property (nonatomic,assign) BOOL hasNewData;
/**
 *  是否要清除本地缓存，比如说uidValidity改变了，或是messageCount ＝ 0
 */
@property (nonatomic,assign) BOOL shouldClearCache;
/**
 *  服务器的数据是否到底了
 */
@property (nonatomic,assign) BOOL isEnd;
/**
 *  MCMailModel 列表
 */
@property (nonatomic,strong) NSArray *data;

@end


/**
 *  邮件管理，用于管理本地邮件和服务器的邮件
 */
@interface MCMailManager : NSObject

#pragma mark - Lifecycle

- (instancetype)initWithAccount:(MCAccount *)account;

#pragma mark - Login

/**
 *  根据用户名，密码和配置进行登录。用于用户登录时的验证
 *
 *  @param userName 电子邮件地址
 *  @param password 密码
 *  @param config   邮件登录配置
 *  @param success  成功回调
 *  @param failure  失败回调
 */
+ (void)loginWithUserName:(NSString *)userName
                 password:(NSString *)password
                   config:(MCMailConfig *)config
                  success:(ActionBlock)success
                  failure:(FailureBlock)failure;

/**
 *  登录当前帐号
 *
 *  @param success 登录成功，成功回调
 *  @param failure 登录失败，失败回调
 */
- (void)loginSuccess:(ActionBlock)success
             failure:(FailureBlock)failure;

#pragma mark - Folder

/**
 *  获取当前用户的所有收件箱
 *
 *  @param success 成功回调，返回 MCMailBox Array
 *  @param failure 失败回调，返回错误信息
 */
- (void)getAllFoldersSuccess:(SuccessBlock)success
                    failure:(FailureBlock)failure;


- (NSArray*)getLocalFoldersWithUserId:(NSInteger)userId;

#pragma mark - Mail

/**
 *  获取本地邮件指定uid区间的邮件，包括beginUid 和 endUid
 *
 *  @param folder   要获取的文件夹
 *  @param beginUid 开始UID
 *  @param endUid   结束uid
 *
 *  @return 邮件列表
 */

- (NSArray *)getLocalMailsInFolder:(MCMailBox *)folder
                          beginUid:(NSInteger)beginUid
                            endUid:(NSInteger)endUid;

/**
 *  获取本地按uid降序排列的邮件
 *
 *  @param folder  邮件所在文件夹
 *  @param belowId 开始UID，不包含此UID
 *  @param limit   数量
 *
 *  @return 按UID降序排列的邮件
 */
- (NSArray *)getLocalMailsInFolder:(MCMailBox *)folder
                          belowUid:(NSInteger)belowId
                             limit:(NSInteger)limit;
/**
 获取重要邮件
 */
- (NSArray *)getLocalImportantMailsWithFolder:(MCMailBox*)folder;

/**
 获取待办邮件
 */
- (NSArray *)getLocalBacklogMailsWithFolder:(MCMailBox*)folder;
/**
 获取待发送邮件
 */
- (NSArray *)getPendingMailsWithFolderId:(NSInteger)folderId;

/**
 获取收藏邮件

 @return 收藏邮件列表
 */
- (NSArray *)getStarMails;

//更新VIPState
- (void)updateTagsMails:(NSArray*)mails;

/**
 *  获取未读邮件数量
 *
 *  @param folder 需要获取的邮件夹
 *  @param limit  获取前面多少封邮件的未读数量
 *  @return 未读数量
 */
- (NSInteger)getUnreadMailCountWihtFolder:(MCMailBox*)folder
                                    limit:(NSInteger)limit;

/**
 *  根据 messageId 获取本地邮件
 */
- (MCMailModel *)getLocalMailWithMessageId:(NSString *)messageId;

- (MCMailModel *)getMailWithSubject:(NSString *)subject box:(NSInteger)boxId;


/**
 根据账号获取本地往来邮件

 @param email 账号

 @param fromIndex 从第几封开始
 
 @return mails
 */
- (NSArray*)getContactMailsWithEmail:(NSString*)email fromIndex:(NSInteger)index;

#pragma mark - IMAP

/**
 *  把本地邮件的相关状态同步到服务器
 *
 *  @param completion 同步完成回调，如果NSError为nil表示成功，否则表示失败
 */
- (void)syncMailsCompletion:(FailureBlock)completion;

/**
 *  加载文件夹的最新邮件ID
 *
 *  @param folder     要加载的文件夹
 *  @param windowSize 邮件列表窗口大小，按uid从大到小排列
 *  @param forceUpdate 不管如何，都获取最新的邮件id
 *  @param success    成功回调，返回 MCMailSyncResult
 *  @param failure    失败回调，返回错误信息
 */
- (void)fetchLatestMailsWithFolder:(MCMailBox *)folder
                        windowSize:(NSInteger)windowSize
                       forceUpdate:(BOOL)forceUpdate
                           success:(SuccessBlock)success
                           failure:(FailureBlock)failure;

/**
 *  获取邮件的头部
 *
 *  @param folder  邮件所在文件夹
 *  @param mails   要获取的邮件
 *  @param success 成功回调，返回邮件列表
 *  @param failure 失败回调，返回错误信息
 */
- (void)loadNewMailBriefWithFolder:(MCMailBox *)folder
                             mails:(NSArray *)mails
                           success:(SuccessBlock)success
                           failure:(FailureBlock)failure;

/**
 *  更新邮件的flags
 *
 *  @param mailsToUpdate 需要更新的邮件
 *  @param folder        邮件所在的文件夹
 *  @param success       成功回调，返回更新后的邮件
 *  @param failure       失败回调，返回错误信息
 */
- (void)updateMailStatus:(NSArray *)mailsToUpdate
              withFolder:(MCMailBox *)folder
                 success:(SuccessBlock)success
                 failure:(FailureBlock)failure;

/**
 *  加载邮件内容
 *
 *  @param mail    需要加载内容的邮件MCMailModel
 *  @param success 返回内容
 *  @param failure error
 */
- (void)loadMailContent:(MCMailModel *)mail
               inFolder:(MCMailBox *)folder
                 urgent:(BOOL)urgent
                success:(SuccessBlock)success
                failure:(FailureBlock)failure;


/**
 *  移动邮件到指定的文件夹
 *
 *  @param mails      需要移动的邮件
 *  @param fromFolder 原来的文件夹
 *  @param toFolder   目标文件夹
 *  @param success    成功回调
 *  @param failure    失败回调
 */
- (void)moveMails:(NSArray *)mails
       fromFolder:(MCMailBox *)fromFolder
         toFolder:(MCMailBox *)toFolder
          success:(ActionBlock)success
          failure:(FailureBlock)failure;

/**
 *  标记已读未读
 *
 *  @param isRead  标记已读还是未读
 *  @param mails   需要标记的邮件
 *  @param success 成功回调
 *  @param failure error
 */
- (void)setReadFlag:(BOOL)isRead
           forMails:(NSArray *)mails
            success:(SuccessBlock)success
            failure:(FailureBlock)failure ;

- (void)setStarBoxReadFlag:(BOOL)isRead
                  forMails:(NSArray*)mails
                    sucess:(SuccessBlock)success
                   failure:(FailureBlock)failure;
/**
 *  标记收藏与否
 *
 *  @param isStar  标记收藏还是取消收藏
 *  @param mails   需要标记的邮件（MCMailModel）
 *  @param success 成功回调
 *  @param failure error
 */
- (void)setStarFlag:(BOOL)isStar
           forMails:(NSArray *)mails
            success:(ActionBlock)success
            failure:(FailureBlock)failure;


/**
 标记已回复

 @param isAnswer 是否已经回复
 @param mail     需要标记的邮件
 @param success  成功回调
 @param failure  erro
 */
- (void)setAnswerFlag:(BOOL)isAnswer
              forMail:(MCMailModel*)mail
              success:(ActionBlock)success
              failure:(FailureBlock)failure;

#pragma mark - Search

/**
 *  开始进入搜索状态
 *
 *  @param locMails 当前页邮件
 */
- (void)beginSearchWithLocMails:(NSArray*)locMails;
/**
 *  删除搜索邮件
 *
 *  @param mails 被删除邮件
 */
- (void)deleteSearchMails:(NSArray*)mails;
/**
 *  本地搜索（目前仅对当前展示的邮件搜索）
 *
 *  @param searchText 搜索内容
 *  @param searchKind 搜索类型
 *
 *  @return mails 搜索结果
 */
- (NSArray*)searchLocMailsSearchText:(NSString*)searchText
                          searchKind:(NSInteger)searchKind;
/**
 *  向服务器搜索邮件
 *
 *  @param folder  搜索文件夹
 *  @param success 返回搜索结果
 *  @param failure error
 */
- (void)searchFromServerWithFolder:(MCMailBox*)folder
                           success:(SuccessBlock)success
                           failure:(FailureBlock)failure;



- (void)loadMoreSearchWithfolder:(MCMailBox*)folder
                        success:(SuccessBlock)success
                        failure:(FailureBlock)failure;

#pragma mark - Attachment

/**
 *  attachment
 *
 *  @param attachment MCMailAttachment
 *  @param progress   进度
 *  @param success    MCMailAttachment
 *  @param failure    失败
 *
 *  @return 是否需要下载
 */
- (BOOL)getAttachmentDataInfo:(MCMailAttachment*)attachment progress:(ProgressBlock)progress success:(SuccessBlock)success failure:(FailureBlock)failure;

/**
 *  加载内嵌附件
 *
 *  @param inlineAttachment MCMailAttachment
 *  @param success          jsString For webView
 *  @param failure          error
 */
- (void)loadInlineAttachment:(NSArray*)inlineAttachments success:(SuccessBlock)success failure:(FailureBlock)failure;

/**
 *  inlineAttachment
 */
- (NSArray*)getInlineAttachmetsWithMailId:(NSInteger)mailId;

/**
 *  attachments
 *
 *  @return MCMailAttachment Array
 */
- (NSArray*)getAttachmentsWithMailId:(NSInteger)mailId;

/**
 *  更新附件信息
 *
 *  @param attachment MCMailAttachment
 */
- (void)updataAttachmentInfo:(MCMailAttachment*)attachment mail:(MCMailModel*)mail;

/**
 *  删除本地附件
 *
 *  @param uid attachment Uid
 */
- (void)deleteAttachmentLocalFileUpdateInfoWithUid:(NSInteger)uid;

#pragma mark - send mail
/**
 *  链接写信服务器
 *
 *  @param success success
 *  @param failure error
 */
- (void)smtpConnectSuccess:(SuccessBlock)success failure:(FailureBlock)failure;


/**
 *  发送邮件
 *
 *  @param mail      MCMailModel
 *  @param success   成功 nil
 *  @param failure   失败 error
 *  @param proggress 进度
 */
- (void)sendEmailWithMail:(MCMailModel*)mail success:(SuccessBlock)success failure:(FailureBlock)failure progress:(ProgressBlock)proggress;

/**
 *  保存草稿
 *
 *  @param mail    MCMailModel
 *  @param draft   草稿箱 imap path
 *  @param success 成功 nil
 *  @param failure 失败 error
 */
- (void)saveDraftWithMail:(MCMailModel *)mail  success:(SuccessBlock)success failure:(FailureBlock)failure;

/*
   保存待发送
 */
- (BOOL)savePendingMail:(MCMailModel*)mail;

/**
 *  生成附件（mail）
 *
 *  @return MCMailAttachment
 */

- (MCMailAttachment*)addMailAsAttachmentWithMail:(MCMailModel*)mail;




#pragma mark - Operations

/**
 *  取消当前imap请求
 */
- (void)cancelOpration;

#pragma mark - Class methods

/**
 *  根据通知内容构建一个邮件对象，如果有错误，返回nil
 *
 *  @param notifyModel 通知内容
 *
 *  @return 添加成功后的邮件对象
 */
+ (MCMailModel *)mailForNotification:(MCMailNotificationModel *)notifyModel;

+ (void)addMail:(MCMailModel *)mail;

@end
