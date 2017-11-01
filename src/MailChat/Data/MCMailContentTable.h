//
//  MailContentTable.h
//  NPushMail
//
//  Created by admin on 12/14/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import "MCTableBase.h"
#import "MCMailModel.h"
#import "MCMailBox.h"
@interface MCMailContentTable : MCTableBase


- (NSArray *)getMailsWithFolder:(NSInteger)folderId
                       beginUid:(NSInteger)beginUid
                         endUid:(NSInteger)endUid;


/**
 *  获取按uid降序排列的邮件
 *
 *  @param folder   所在的文件夹
 *  @param belowUid 起始uid，不包括此uid
 *  @param limit    加载邮件数量
 *
 *  @return 按uid降序排列的数组
 */
- (NSArray *)getMailsWithFolder:(NSInteger)folder belowUid:(NSInteger)belowUid limit:(NSInteger)limit;

- (NSArray *)getAllImportantMailsWithFolder:(MCMailBox*)folder;

- (NSArray *)getAllBackLogMailsWithFolder :(MCMailBox*)folder;

- (NSArray*)getStarMailsWithAccountId:(NSInteger)accountId;

- (NSArray*)getPendingMailsWithBoxId:(NSInteger)boxId;


- (MCMailModel*)getMailWithFolder:(NSInteger)folderId mailUid:(NSInteger)mailUid;

- (void)insertMails:(NSArray *)mails;
//邮件删除
- (void)deleteMails:(NSArray *)mails;
//邮件移动
- (void)moveMails:(NSArray*)mails toFolder:(MCMailBox*)mailbox;
/**
 *  只更新邮件的状态（isRead,isStar,isDeleted,status)
 *
 *  @param mails 需要更新的邮件
 */
- (void)updateMailStatus:(NSArray *)mails;
/**
 *  更新邮件内容
 */
- (void)updateMailContent:(MCMailModel *)mail;


/**
 *  未读数量的获取
 *
 *  @param folder MCMailBox
 *  @param limit  数量
 *
 *  @return 未读数量 NSInteger
 */
- (NSInteger)unreadMailCountWithFolder:(MCMailBox*)folder limit:(NSInteger)limit;
/**
 *  删除指定文件夹下面的邮件
 *
 *  @param folderId 要删除的文件夹
 *  @param lastUid  最后一封邮件的uid，小于这个uid的邮件都会被删除掉
 */
- (void)deleteMailsInFolder:(NSInteger)folderId belowUid:(NSInteger)lastUid;
/**
 *  删除指定文件夹下面的邮件
 *
 *  @param folderId 要删除的文件夹
 *  @param firstUid  第一封邮件的uid，大于这个uid的邮件都会被删除掉
 */
- (void)deleteMailsInFolder:(NSInteger)folderId aboveUid:(NSInteger)firstUid;

- (void)deleteMailsInFolder:(NSInteger)folderId;

- (MCMailModel *)getMailWithMessageId:(NSString *)messageId;

- (MCMailModel *)getMailWithSubject:(NSString *)subject box:(NSInteger)boxId;

- (NSArray*)getContactMailsWithEmail:(NSString*)email;

- (NSArray*)getContactMailsWithEmail:(NSString *)email outFolderUids:(NSArray*)uids fromIndex:(NSInteger)index;
@end
