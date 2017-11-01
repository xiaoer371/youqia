//
//  MailContentTable.m
//  NPushMail
//
//  Created by admin on 12/14/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import "MCMailContentTable.h"
#import "NSString+JSON.h"
#import "MCMailAttachmentTable.h"

@interface MCMailContentTable ()

@property (nonatomic,strong)MCMailAttachmentTable *dbAttachment;

@end

@implementation MCMailContentTable

- (id)init {
    
    if (self = [super init]) {
        _dbAttachment = [MCMailAttachmentTable new];
    }
    return self;
}

- (id)getModelById:(NSInteger)uid
{
    __block MCMailModel *model = nil;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"SELECT * FROM MailContent WHERE id = ?";
        FMResultSet *rs = [db executeQuery:sql,@(uid)];
        while ([rs next]) {
            model = [MCMailContentTable modelWithResutSet:rs];
        }
    }];
    
    return model;
}

- (NSArray *)allModels
{
    NSMutableArray *list = [NSMutableArray new];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"SELECT * FROM MailContent";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            MCMailModel *model = [MCMailContentTable modelWithResutSet:rs];
            [list addObject:model];
        }
        
    }];
    
    return list;
}

- (void)insertModel:(MCMailModel *)model
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        [[self class] insertModel:model withDb:db];
        
    }];
}

- (void)insertMails:(NSArray *)mails
{
    if (mails.count == 0) {
        return;
    }
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (MCMailModel *mail in mails) {
            [MCMailContentTable insertModel:mail withDb:db];
            for (MCMailAttachment *attachment in mail.attachments) {
                attachment.mailId = mail.uid;
                [MCMailAttachmentTable insertAttachmet:attachment db:db];
            }
            for (MCMailAttachment *attachment in mail.inlineAttachments) {
                attachment.mailId = mail.uid;
                [MCMailAttachmentTable insertAttachmet:attachment db:db];
            }
        }
    }];
}

+ (NSString *)jsonStringWithAddressArray:(NSArray *)addresses
{
    if (!addresses || addresses.count == 0) {
        return nil;
    }
    
    NSMutableArray *jsonArray = [[NSMutableArray alloc] initWithCapacity:addresses.count];
    for (MCMailAddress *addr in addresses) {
        [jsonArray addObject:[addr toDictionary]];
    }
    
    return [NSString jsonStringWithObject:jsonArray];
}


- (void)updateMailStatus:(NSArray *)mails
{
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        for (MCMailModel *mail in mails) {
            [db executeUpdate:@"UPDATE MailContent SET isRead = ?,isStar = ?,isDeleted = ?, status = ?, tags = ?,flags = ? WHERE id = ?",
             @(mail.isRead),@(mail.isStar),@(mail.isDeleted),@(mail.status),@(mail.tags),@(mail.mailFlags), @(mail.uid)];
        }
        
    }];
}

- (void)updateMailContent:(MCMailModel *)model
{
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if (model.isDeleted) {
            model.isDeleted = NO;
            NSString*sql = @"UPDATE MailContent SET  messageId = ?,size = ?,fromMail = ?,tos = ?,ccs = ?,bccs = ?,replyTo= ?,receivedDate= ?,subject= ?,summary= ?,content= ?,referenceIds= ?,inReplyTo= ?,conversationId= ?,customMarkId= ?,hasAttachment= ?,isStar= ?,isRead= ?,isDeleted= ?,status = ?, xPriority = ?, tags = ? ,flags = ? WHERE id = ?";
            
            [db executeUpdate:sql,model.messageId,
             @(model.messageSize),
             [model.from toJsonString],
             [[self class] jsonStringWithAddressArray:model.to],
             [[self class] jsonStringWithAddressArray:model.cc],
             [[self class] jsonStringWithAddressArray:model.bcc],
             [[self class] jsonStringWithAddressArray:model.replyTo],
             @([model.receivedDate timeIntervalSince1970]),
             model.subject,
             model.messageContentString,
             model.messageContentHtml,
             [NSString jsonStringWithObject:model.references],
             [NSString jsonStringWithObject:model.inReplyTo],
             model.conversationId,
             model.customMarkId,
             @(model.hasAttachment),
             @(model.isStar),
             @(model.isRead),
             @(model.isDeleted),
             @(model.status),
             @(model.xPriority),
             @(model.tags),
             @(model.mailFlags),
             @(model.uid)];
            for (MCMailAttachment *attachment in model.attachments) {
                attachment.mailId = model.uid;
                [MCMailAttachmentTable insertAttachmet:attachment db:db];
            }
            for (MCMailAttachment *attachment in model.inlineAttachments) {
                attachment.mailId = model.uid;
                [MCMailAttachmentTable insertAttachmet:attachment db:db];
            }
            
        } else {
            [db executeUpdate:@"UPDATE MailContent SET summary = ?,content  = ?,hasAttachment = ? WHERE id = ?",
             model.messageContentString,model.messageContentHtml,@(model.hasAttachment),@(model.uid)];
        }
     
    }];
}

- (void)deleteMails:(NSArray *)mails
{
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (MCMailModel *mail in mails) {
            [db executeUpdate:@"DELETE FROM MailContent WHERE id = ?",@(mail.uid)];
            [MCMailAttachmentTable deleteAttachmentsWithMailId:mail.uid db:db];
        }
    }];
}

- (void)moveMails:(NSArray*)mails toFolder:(MCMailBox*)mailbox {
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (MCMailModel *mail in mails) {
            NSString *sql = [NSString stringWithFormat:@"UPDATE MailContent SET boxId = ?,isDeleted = ? WHERE boxId = ? AND messageUid = ?"];
            [db executeUpdate:sql,@(mailbox.uid),@(YES),@(mail.boxId),@(mail.messageUid)];
        }
    }];
}

- (void)deleteById:(NSInteger)uid
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"DELETE FROM MailContent WHERE id = ?";
        [db executeUpdate:sql,@(uid)];
    }];
}

- (NSArray *)getMailsWithFolder:(NSInteger)folderId beginUid:(NSInteger)beginUid endUid:(NSInteger)endUid
{
    NSMutableArray *list = [NSMutableArray new];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"SELECT * FROM MailContent WHERE  boxId = ? AND messageUid >= ? AND messageUid <= ? ORDER BY messageUid desc";
        FMResultSet *rs = [db executeQuery:sql,@(folderId),@(beginUid),@(endUid)];
        while ([rs next]) {
            MCMailModel *model = [MCMailContentTable modelWithResutSet:rs];
            [list addObject:model];
        }
        
    }];
    
    return list;
}

- (NSArray *)getMailsWithFolder:(NSInteger)folderId belowUid:(NSInteger)belowUid limit:(NSInteger)limit
{
    DDLogVerbose(@"getMailsWithFolder folderId = %ld,belowUid = %ld,limit = %ld",folderId,belowUid,limit);
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:limit];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        //根据时间倒序排列
        NSString *sql = @"SELECT * FROM MailContent WHERE boxId = ? AND messageUid < ? ORDER BY messageUid desc limit ?";
        DDLogInfo(@"begin execute sql");
        FMResultSet *rs = [db executeQuery:sql,@(folderId),@(belowUid),@(limit)];
        DDLogInfo(@"end execute sql");
        DDLogInfo(@"begin rs next");
        while ([rs next]) {
            MCMailModel *model = [[self class] modelWithResutSet:rs];
            [list addObject:model];
        }
        DDLogInfo(@"end rs next");
    }];
    
    return list;
}

- (NSArray *)getAllImportantMailsWithFolder:(MCMailBox*)folder {
   
    NSMutableArray *list = [NSMutableArray new];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        //根据时间倒序排列
        NSString *sql = @"SELECT * FROM MailContent WHERE boxId = ? AND tags & ? ORDER BY messageUid desc";
        FMResultSet *rs = [db executeQuery:sql,@(folder.uid),@(1)];
        while ([rs next]) {
            MCMailModel *model = [[self class] modelWithResutSet:rs];
            [list addObject:model];
        }
    }];
    
    return list;
}

- (NSArray *)getAllBackLogMailsWithFolder :(MCMailBox*)folder {
   
    NSMutableArray *list = [NSMutableArray new];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        //根据时间倒序排列
        NSString *sql = @"SELECT * FROM MailContent WHERE accountId = ? AND  tags & ? ORDER BY messageUid desc";
        FMResultSet *rs = [db executeQuery:sql,@(folder.accountId),@(2)];
        while ([rs next]) {
            MCMailModel *model = [[self class] modelWithResutSet:rs];
            [list addObject:model];
        }
    }];
    return list;
}

- (NSArray *)getMailsWithFolder:(NSInteger)folderId fromIndex:(NSInteger)fromIndex limit:(NSInteger)limit
{
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:limit];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        //根据时间倒序排列
        NSString *sql = @"SELECT * FROM MailContent WHERE boxId = ? ORDER BY receivedDate desc limit ?,?";
        FMResultSet *rs = [db executeQuery:sql,@(folderId),@(fromIndex),@(limit)];
        while ([rs next]) {
            MCMailModel *model = [[self class] modelWithResutSet:rs];
//            model.attachments  = [MCMailAttachmentTable getAttachmentWithMailId:model.uid db:db inlineAttach:NO];
//            model.inlineAttachments = [MCMailAttachmentTable getAttachmentWithMailId:model.uid db:db inlineAttach:YES];
            [list addObject:model];
        }
    }];
    
    return list;
}

- (NSArray*)getStarMailsWithAccountId:(NSInteger)accountId {
    
    NSMutableArray *list = [NSMutableArray new];
    NSString *sql  = @"SELECT * FROM MailContent WHERE isStar = 1 AND accountId = ?  ORDER BY receivedDate desc";
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql,@(accountId)];
        while ([rs next]) {
            MCMailModel *model = [[self class] modelWithResutSet:rs];
//            model.attachments  = [MCMailAttachmentTable getAttachmentWithMailId:model.uid db:db inlineAttach:NO];
//            model.inlineAttachments = [MCMailAttachmentTable getAttachmentWithMailId:model.uid db:db inlineAttach:YES];
            [list addObject:model];
        }
    }];
    return list;
}

- (NSArray*)getPendingMailsWithBoxId:(NSInteger)boxId {
    
    NSMutableArray *list = [NSMutableArray new];
    NSString *sql  = @"SELECT * FROM MailContent WHERE boxId = ?  ORDER BY receivedDate desc";
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql,@(boxId)];
        while ([rs next]) {
            MCMailModel *model = [[self class] modelWithResutSet:rs];
            model.attachments  = [MCMailAttachmentTable getAttachmentWithMailId:model.uid db:db inlineAttach:NO];
            model.inlineAttachments = [MCMailAttachmentTable getAttachmentWithMailId:model.uid db:db inlineAttach:YES];
            [list addObject:model];
        }
    }];
    return list;
}

- (NSInteger)unreadMailCountWithFolder:(MCMailBox*)folder limit:(NSInteger)limit {
    
     __block NSInteger unreadMailCount = 0;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString*sql =  @"SELECT a.isRead ,COUNT(a.isRead) FROM (SELECT isRead FROM MailContent WHERE boxId =  ?  ORDER BY receivedDate DESC LIMIT  ?) AS a WHERE a.isRead = ?";
        FMResultSet*rs = [db executeQuery:sql,@(folder.uid),@(limit),@(NO)];
        while ([rs next]) {
            unreadMailCount = [rs intForColumn:@"COUNT(a.isRead)"];
        }
    }];
    return unreadMailCount;
}

- (MCMailModel*)getMailWithFolder:(NSInteger)folderId mailUid:(NSInteger)mailUid {
    __block  MCMailModel *mail;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM MailContent WHERE boxId = ? AND messageUid = ?";
        FMResultSet *rs = [db executeQuery:sql,@(folderId),@(mailUid)];
        if ([rs next]) {
            mail = [[self class] modelWithResutSet:rs];
        }
        [rs close];
    }];
    return mail;
}

- (void)deleteMailsInFolder:(NSInteger)folderId belowUid:(NSInteger)lastUid
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"DELETE FROM MailContent WHERE boxId = ? AND messageUid < ?";
        [db executeUpdate:sql,@(folderId),@(lastUid)];
    }];
}

- (void)deleteMailsInFolder:(NSInteger)folderId aboveUid:(NSInteger)firstUid
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"DELETE FROM MailContent WHERE boxId = ? AND messageUid > ?";
        [db executeUpdate:sql,@(folderId),@(firstUid)];
    }];
}

- (void)deleteMailsInFolder:(NSInteger)folderId
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"DELETE FROM MailContent WHERE boxId = ?";
        [db executeUpdate:sql,@(folderId)];
    }];
}

- (MCMailModel *)getMailWithMessageId:(NSString *)messageId
{
    __block  MCMailModel *mail;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM MailContent WHERE messageId = ?";
        FMResultSet *rs = [db executeQuery:sql,messageId];
        while ([rs next]) {
            mail = [[self class] modelWithResutSet:rs];
        }
        [rs close];
    }];
    return mail;
}

- (MCMailModel *)getMailWithSubject:(NSString *)subject box:(NSInteger)boxId
{
    __block  MCMailModel *mail;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM MailContent WHERE boxId = ? AND subject = ? LIMIT 1";
        FMResultSet *rs = [db executeQuery:sql,@(boxId), subject];
        while ([rs next]) {
            mail = [[self class] modelWithResutSet:rs];
        }
        [rs close];
    }];
    return mail;
}

- (NSArray*)getContactMailsWithEmail:(NSString*)email {
    
    __block NSMutableArray *mails = [NSMutableArray new];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM MailContent WHERE fromMail LIKE '%@%@%@'OR tos LIKE '%@%@%@' ORDER BY receivedDate",@"%",email,@"%",@"%",email,@"%"];
       FMResultSet *rs =  [db executeQuery:sql];
        while ([rs next]) {
            MCMailModel *mail = [self.class modelWithResutSet:rs];
            [mails addObject:mail];
        }
    }];
    return mails;
}


- (NSArray*)getContactMailsWithEmail:(NSString *)email outFolderUids:(NSArray*)uids fromIndex:(NSInteger)index {
    
    NSString *contactEmail = email;
    NSString *userEmail = AppStatus.currentUser.email;
    if (!contactEmail || !userEmail) {
        return @[];
    }
    __block NSMutableArray *mails = [NSMutableArray new];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
       NSString *sql = [NSString stringWithFormat:@"SELECT * FROM MailContent WHERE (fromMail LIKE '%@\"%@%@'OR (fromMail LIKE '%@\"%@%@' AND tos LIKE '%@\"%@%@')) AND accountId = %ld  AND boxId NOT IN (%@) ORDER BY receivedDate desc limit %ld,20 ",@"%",contactEmail,@"%",@"%",userEmail,@"%",@"%",contactEmail,@"%",(long)AppStatus.currentUser.accountId,[uids componentsJoinedByString:@","],(long)index];
        FMResultSet *rs =  [db executeQuery:sql];
        while ([rs next]) {
            MCMailModel *mail = [self.class modelWithResutSet:rs];
            [mails addObject:mail];
        }
    }];
    return mails;
}

#pragma mark - Private

+ (MCMailModel *)modelWithResutSet:(FMResultSet *)rs
{
    MCMailModel *model = [MCMailModel new];
    
    model.uid = [rs intForColumn:@"id"];
    model.accountId = [rs intForColumn:@"accountId"];
    model.boxId = [rs intForColumn:@"boxId"];
    model.folder = [rs stringForColumn:@"folder"];
    model.messageUid = [rs intForColumn:@"messageUid"];
    model.messageId = [rs stringForColumn:@"messageId"];
//    model.isRead = [rs boolForColumn:@"isRead"];
    model.messageSize = [rs longForColumn:@"size"];
    model.from = [[MCMailAddress alloc] initWithJsonString:[rs stringForColumn:@"fromMail"]];
    model.to = [[self class] addressArrayWithString:[rs stringForColumn:@"tos"]];
    model.cc = [[self class] addressArrayWithString:[rs stringForColumn:@"ccs"]];
    model.bcc = [[self class] addressArrayWithString:[rs stringForColumn:@"bccs"]];
    model.replyTo = [[self class] addressArrayWithString:[rs stringForColumn:@"replyTo"]];
    model.receivedDate = [rs dateForColumn:@"receivedDate"];
    model.subject = [rs stringForColumn:@"subject"];
    model.messageContentString = [rs stringForColumn:@"summary"];
    model.messageContentHtml = [rs stringForColumn:@"content"];
    model.hasAttachment = [rs boolForColumn:@"hasAttachment"];
//    model.isStar = [rs boolForColumn:@"isStar"];
    model.isDeleted = [rs boolForColumn:@"isDeleted"];
    model.conversationId = [rs stringForColumn:@"conversationId"];
    model.customMarkId = [rs stringForColumn:@"customMarkId"];
    model.references = [[rs stringForColumn:@"referenceIds"] componentsSeparatedByString:@","];
    model.inReplyTo = [[rs stringForColumn:@"inReplyTo"] componentsSeparatedByString:@","];
    model.status = [rs intForColumn:@"status"];
    model.xPriority = [rs intForColumn:@"xPriority"];
    model.tags = [rs intForColumn:@"tags"];
    model.mailFlags = [rs intForColumn:@"flags"];
    return model;
}

+ (NSArray *)addressArrayWithString:(NSString *)string
{
    NSArray *array = [string toJson];
    if (array.count == 0) {
        return nil;
    }
    
    NSMutableArray *addressList = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (id obj in array) {
        MCMailAddress *addr = [[MCMailAddress alloc] initWithJsonObject:obj];
        [addressList addObject:addr];
    }
    
    return addressList;
}

+ (BOOL)insertModel:(MCMailModel *)model withDb:(FMDatabase *)db
{
    
    if (model.customMarkId) {
        
        NSString *sql = @"SELECT*FROM MailContent WHERE boxId = ? AND customMarkId = ? AND isDeleted = ?";
        FMResultSet *rs = [db executeQuery:sql,@(model.boxId),model.customMarkId,@(YES)];
        if ([rs next]) {
            sql = @"DELETE FROM MailContent WHERE boxId = ? AND customMarkId = ?";
            BOOL deleted = [db executeUpdate:sql,@(model.boxId),model.customMarkId];
            DDLogDebug(@"----%d---Success",deleted);
            [MCMailAttachmentTable deleteAttachmentsWithMailId:[rs intForColumn:@"id"] db:db];
        }
        [rs close];
    }
    
    NSString*sqlStr = @"SELECT *FROM MailContent WHERE receivedDate = ? AND isDeleted = ?";
    FMResultSet *rs = [db executeQuery:sqlStr,@([model.receivedDate timeIntervalSince1970]),@(YES)];
    if ([rs next]) {
        sqlStr = @"DELETE FROM MailContent WHERE receivedDate = ? AND isDeleted = ?";
        BOOL isDelete = [db executeUpdate:sqlStr,@([model.receivedDate timeIntervalSince1970]),@(YES)];
        DDLogDebug(@"--mailDelete--%d---Success",isDelete);
        [MCMailAttachmentTable deleteAttachmentsWithMailId:[rs intForColumn:@"id"] db:db];
    }
    [rs close];
    
    NSString *sql = @"INSERT INTO MailContent (accountId,boxId,folder, messageUid, messageId,size,fromMail,tos,ccs,bccs,replyTo,receivedDate,subject,summary,content,referenceIds,inReplyTo,conversationId,customMarkId,hasAttachment,isStar,isRead,isDeleted,status,xPriority,tags,flags) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    BOOL result = [db executeUpdate:sql,
     @(model.accountId),
     @(model.boxId),
     model.folder,
     @(model.messageUid),
     model.messageId,
     @(model.messageSize),
     [model.from toJsonString],
     [[self class] jsonStringWithAddressArray:model.to],
     [[self class] jsonStringWithAddressArray:model.cc],
     [[self class] jsonStringWithAddressArray:model.bcc],
     [[self class] jsonStringWithAddressArray:model.replyTo],
     @([model.receivedDate timeIntervalSince1970]),
     model.subject,
     model.messageContentString,
     model.messageContentHtml,
     [NSString jsonStringWithObject:model.references],
     [NSString jsonStringWithObject:model.inReplyTo],
     model.conversationId,
     model.customMarkId,
     @(model.hasAttachment),
     @(model.isStar),
     @(model.isRead),
     @(model.isDeleted),
     @(model.status),
     @(model.xPriority),
     @(model.tags),
     @(model.mailFlags)];
    
    model.uid = db.lastInsertRowId;
    
    return result;
}

@end
