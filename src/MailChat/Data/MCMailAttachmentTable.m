//
//  MailAttachmentTable.m
//  NPushMail
//
//  Created by admin on 12/17/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import "MCMailAttachmentTable.h"

@implementation MCMailAttachmentTable

- (NSArray *)allModels
{
    NSMutableArray *models = [[NSMutableArray alloc] init];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM MailAttachment";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            MCMailAttachment *model = [[self class] modelWithResultSet:rs];
            [models addObject:model];
        }
    }];
    
    return models;
}


- (id)getModelById:(NSInteger)uid
{
    __block MCMailAttachment *model;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM MailAttachment WHERE id = ?", @(uid)];
        while ([rs next]) {
            model = [[self class] modelWithResultSet:rs];
        }
    }];
    
    return model;
}


- (void)insertModel:(MCMailAttachment *)model
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {

        [[self class] insertAttachmet:model db:db];
    }];
}


- (void)updateModel:(MCMailAttachment *)model
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"UPDATE MailAttachment SET mailId = ?, mailUid = ?, partId = ?, name = ?, cid = ?, size = ?, mimeType = ?, partEncoding = ?, localPath = ?, partFolder = ?, fileExtension = ?, isDownload = ? WHERE id = ?";
        
       BOOL updata =  [db executeUpdate:sql, @(model.mailId),@(model.mailUid),model.partId,model.name,model.cid,@(model.size),model.mimeType,@(model.partEncode),model.localPath,model.partFolder,model.fileExtension,@(model.isDownload),@(model.uid)];
        DDLogDebug(@"updataAttachmentInfo--%d",updata);
    }];
}

- (NSArray *)getAttachementsForMail:(NSInteger)mailId
{
    NSMutableArray *models = [[NSMutableArray alloc] init];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM MailAttachment WHERE mailId = ? AND cid is NULL ";
        FMResultSet *rs = [db executeQuery:sql, @(mailId)];
        while ([rs next]) {
            MCMailAttachment *model = [[self class] modelWithResultSet:rs];
            [models insertObject:model atIndex:0];
        }
    }];
    
    return models;
}

- (NSArray *)getInlineAttachmentForMail:(NSInteger)mailId {
    
    NSMutableArray *models = [[NSMutableArray alloc] init];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM MailAttachment WHERE mailId = ? AND cid is NOT NULL ";
        FMResultSet *rs = [db executeQuery:sql, @(mailId)];
        while ([rs next]) {
            MCMailAttachment *model = [[self class] modelWithResultSet:rs];
            [models addObject:model];
        }
    }];
    
    return models;
}

- (void)deleteAttachmentLocalFileWithUid:(NSInteger)uid {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
       NSString *sql = @"UPDATE MailAttachment SET isDownload = ?, localPath = NULL  WHERE id = ?";
        [db executeUpdate:sql,@(NO),@(uid)];
    }];
}
#pragma mark - Private

+ (id)modelWithResultSet:(FMResultSet *)rs
{
    MCMailAttachment *model = [MCMailAttachment new];
    
    model.uid = [rs intForColumn:@"id"];
    model.mailId = [rs intForColumn:@"mailId"];
    model.mailUid = [rs intForColumn:@"mailUid"];
    model.partId = [rs stringForColumn:@"partId"];
    model.name = [rs stringForColumn:@"name"];
    model.cid = [rs stringForColumn:@"CID"];
    model.size = [rs intForColumn:@"size"];
    model.mimeType = [rs stringForColumn:@"mimeType"];
    model.partEncode = [rs intForColumn:@"partEncoding"];
    model.localPath = [rs stringForColumn:@"localPath"];
    model.partFolder = [rs stringForColumn:@"partFolder"];
    model.fileExtension = [rs stringForColumn:@"fileExtension"];
    model.isDownload = [rs boolForColumn:@"isDownload"];
    model.receiveDate = [rs intForColumn:@"receiveDate"];
    model.from = [[MCMailAddress alloc]initWithJsonString:[rs stringForColumn:@"fromAddress"]];
    return model;
}

+ (void)insertAttachmet:(MCMailAttachment*)model db:(FMDatabase*)db {
    
    NSString *sql = @"INSERT INTO MailAttachment ( mailId, mailUid, partId, name, cid, size, mimeType, partEncoding, localPath, partFolder, fileExtension, isDownload ,receiveDate ,fromAddress ) VALUES ( ?,?,?,?,?,?,?,?,?,?,?,?,?,? )";
    [db executeUpdate:sql, @(model.mailId),@(model.mailUid),model.partId,model.name,model.cid,@(model.size),model.mimeType,@(model.partEncode),model.localPath,model.partFolder,model.fileExtension,@(model.isDownload),@(model.receiveDate),[model.from toJsonString]];
    
    model.uid = db.lastInsertRowId;
}

+ (NSArray*)getAttachmentWithMailId:(NSInteger)mailId db:(FMDatabase*)db inlineAttach:(BOOL)isInline{
    
    NSMutableArray *models = [NSMutableArray new];
    NSString *sql;
    
    if (!isInline) {
        sql = @"SELECT * FROM MailAttachment WHERE mailId = ? AND cid is NULL ";
    } else {
        sql = @"SELECT * FROM MailAttachment WHERE mailId = ? AND cid is NOT NULL ";
    }
 
    FMResultSet *rs = [db executeQuery:sql, @(mailId)];
    while ([rs next]) {
        MCMailAttachment *model = [self modelWithResultSet:rs];
        [models addObject:model];
    }
    return models;
}

+ (void)deleteAttachmentsWithMailId:(NSInteger)mailId db:(FMDatabase*)db{
    
    [db executeUpdate:@"DELETE FROM MailAttachment WHERE mailId = ?",@(mailId)];
}

@end
