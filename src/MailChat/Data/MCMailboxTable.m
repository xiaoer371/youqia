//
//  MailboxTable.m
//  NPushMail
//
//  Created by admin on 12/10/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import "MCMailboxTable.h"

//TODO: Save uidNext and message count
@implementation MCMailboxTable

- (NSArray *)allModels
{
    NSMutableArray *models = [[NSMutableArray alloc] init];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM MailBox";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            MCMailBox *model = [self modelWithResultSet:rs];
            [models addObject:model];
        }
    }];
    
    return models;
}

- (NSArray *)getModelsForUser:(NSInteger)accountId
{
    NSMutableArray *models = [[NSMutableArray alloc] init];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM MailBox WHERE accountId = ?";
        FMResultSet *rs = [db executeQuery:sql, @(accountId)];
        while ([rs next]) {
            MCMailBox *model = [self modelWithResultSet:rs];
            [models addObject:model];
        }
    }];
    return models;
}


- (id)getModelById:(NSInteger)uid
{
    __block MCMailBox *model;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM MailBox WHERE id = ?", @(uid)];
        while ([rs next]) {
            model = [self modelWithResultSet:rs];
        }
    }];
    
    return model;
}

- (MCMailBox *)getMailBoxWithAccount:(NSInteger)accountId path:(NSString *)boxPath
{
    __block MCMailBox *model;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM MailBox WHERE accountId = ? and path = ?", @(accountId), boxPath];
        while ([rs next]) {
            model = [self modelWithResultSet:rs];
        }
    }];
    
    return model;
}

- (MCMailBox *)getMailBoxWithAccount:(NSInteger)accountId type:(MCMailFolderType)type
{
    __block MCMailBox *model;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM MailBox WHERE accountId = ? and type = ?", @(accountId), @(type)];
        while ([rs next]) {
            model = [self modelWithResultSet:rs];
        }
    }];
    
    return model;
}


- (MCMailBox *)getMailBoxWithAccount:(NSInteger)accountId name:(NSString *)name level:(NSInteger)level
{
    __block MCMailBox *model;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM MailBox WHERE accountId = ? and name = ? and level = ?", @(accountId), name,@(level)];
        while ([rs next]) {
            model = [self modelWithResultSet:rs];
        }
    }];
    
    return model;
}

- (void)insertModel:(MCMailBox *)model
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:@"INSERT INTO MailBox (accountId, name, path, type, flags, folderOrder,uidValidity, uidFractured,totalCount,unreadCount,parentId, level, syncUtc) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)", @(model.accountId),model.name,model.path,@(model.type),@(model.flags),@(model.folderOrder),@(model.uidValidity),@(model.uidFractured),@(model.totalCount), @(model.unreadCount),@(model.parentId),@(model.level),@(model.syncUtc)];
        
        model.uid = db.lastInsertRowId;
        
    }];
}

- (void)updateModel:(MCMailBox *)model
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:@"UPDATE MailBox SET accountId = ?, name = ?, path = ?, type = ?, flags = ?, folderOrder = ?, uidValidity = ?, uidFractured = ?,totalCount = ?, unreadCount = ?, parentId = ?,level = ?, syncUtc = ? WHERE id = ?",@(model.accountId),model.name,model.path,@(model.type),@(model.flags),@(model.folderOrder),@(model.uidValidity),@(model.uidFractured),@(model.totalCount), @(model.unreadCount),@(model.parentId),@(model.level),@(model.syncUtc), @(model.uid)];
        
    }];
}

- (void)deleteById:(NSInteger)uid
{
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *mailSql = @"DELETE FROM MailContent WHERE boxId = ?";
        [db executeUpdate:mailSql,@(uid)];
        NSString *sql = @"DELETE FROM MailBox Where id = ?";
        [db executeUpdate:sql,@(uid)];
    }];
}

#pragma mark - Private

- (id)modelWithResultSet:(FMResultSet *)rs
{
    MCMailBox *model = [MCMailBox new];
    
    model.uid = [rs intForColumn:@"id"];
    model.accountId = [rs intForColumn:@"accountId"];
    model.name = [rs stringForColumn:@"name"];
    model.path = [rs stringForColumn:@"path"];
    model.type = [rs intForColumn:@"type"];
    model.flags = [rs intForColumn:@"flags"];
    model.folderOrder = [rs intForColumn:@"folderOrder"];
    model.uidValidity = [rs intForColumn:@"uidValidity"];
    model.uidFractured = [rs intForColumn:@"uidFractured"];
//    model.unreadCount = [rs intForColumn:@"unreadCount"];
    model.unreadCount = NSNotFound;
    model.parentId = [rs intForColumn:@"parentId"];
    model.totalCount = [rs intForColumn:@"totalCount"];
    model.level = [rs intForColumn:@"level"];
    model.syncUtc = [rs doubleForColumn:@"syncUtc"];
    
    return model;
    
}


@end
