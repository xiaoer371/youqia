//
//  MailAttachmentTable.h
//  NPushMail
//
//  Created by admin on 12/17/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import "MCTableBase.h"
#import "MCMailAttachment.h"

@interface MCMailAttachmentTable : MCTableBase
/**
 *  保存附件信息
 *
 *  @param model MCMailAttachment
 *  @param db    FMDatabase
 */
+ (void)insertAttachmet:(MCMailAttachment*)model db:(FMDatabase*)db;
/**
 *  根据mailid 获取附件信息
 *
 *  @param mailuId   邮件uid
 *  @param db       FMDatabase
 *  @param isInline 是否是内嵌附件
 *  @return        attachments
 */
+ (NSArray*)getAttachmentWithMailId:(NSInteger)mailId db:(FMDatabase*)db inlineAttach:(BOOL)isInline;
/**
 *  根据mailuid 删除附件
 *
 *  @param mailId 邮件uid
 *  @param db     FMDatabase
 */
+ (void)deleteAttachmentsWithMailId:(NSInteger)mailId db:(FMDatabase*)db;

- (NSArray *)getAttachementsForMail:(NSInteger)mailId;

- (NSArray *)getInlineAttachmentForMail:(NSInteger)mailId;
/**
 *  更新附件信息
 *  isDownload   localPath
 *  @param model MCMailAttachment
 */
- (void)updateModel:(MCMailAttachment *)model;
/**
 *  删除本地file 更新附件数据库
 *
 *  @param uid attachmentUid
 */
- (void)deleteAttachmentLocalFileWithUid:(NSInteger)uid;
@end
