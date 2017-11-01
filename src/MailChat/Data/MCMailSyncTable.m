//
//  MailSyncTable.m
//  NPushMail
//
//  Created by admin on 12/14/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import "MCMailSyncTable.h"

@implementation MCMailSyncTable

- (NSArray *)allModels
{
    NSMutableArray *models = [[NSMutableArray alloc] init];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM MailSync";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            MCMailSyncModel *model = [self modelWithResultSet:rs];
            [models addObject:model];
        }
    }];
    
    return models;
}

- (NSArray *)getModelsWithAccountId:(NSInteger)accountId
{
    NSMutableArray *models = [[NSMutableArray alloc] init];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM MailSync WHERE accountId = ?";
        FMResultSet *rs = [db executeQuery:sql,@(accountId)];
        while ([rs next]) {
            MCMailSyncModel *model = [self modelWithResultSet:rs];
            [models addObject:model];
        }
    }];
    
    return models;
}

- (id)getModelById:(NSInteger)uid
{
    __block MCMailSyncModel *model;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM MailSync WHERE id = ?", @(uid)];
        while ([rs next]) {
            model = [self modelWithResultSet:rs];
        }
    }];
    
    return model;
}

- (void)insertModel:(MCMailSyncModel *)model
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"INSERT INTO MailSync (accountId, mailId, type, fromBoxId, toBoxId, tryTimes ) VALUES ( ?,?,?,?,?,? )";
        [db executeUpdate:sql,@(model.accountId), @(model.mailId),@(model.syncType),@(model.fromBoxId),@(model.toBoxId),@(model.tryTimes)];
        model.uid = db.lastInsertRowId;
    }];
}

- (void)updateModel:(MCMailSyncModel *)model
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"UPDATE MailSync SET accountId = ?, mailId = ?, type = ?, fromBoxId = ?, toBoxId = ?, tryTimes = ? WHERE id = ?";
        [db executeUpdate:sql,@(model.accountId), @(model.mailId),@(model.syncType),@(model.fromBoxId),@(model.toBoxId),@(model.tryTimes), @(model.uid)];
    }];
}

- (void)updateTryTimes:(MCMailSyncModel *)model
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"UPDATE MailSync SET tryTimes = ? WHERE id = ?";
        [db executeUpdate:sql,@(model.tryTimes), @(model.uid)];
    }];
}

- (void)deleteById:(NSInteger)uid
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"DELETE FROM MailSync WHERE id = ?";
        [db executeUpdate:sql,@(uid)];
    }];
}

#pragma mark - Private

- (id)modelWithResultSet:(FMResultSet *)rs
{
    MCMailSyncModel *model = [MCMailSyncModel new];
    
    model.uid = [rs intForColumn:@"id"];
    model.accountId = [rs intForColumn:@"accountId"];
    model.mailId = [rs intForColumn:@"mailId"];
    model.syncType = [rs intForColumn:@"type"];
    model.fromBoxId = [rs intForColumn:@"fromBoxId"];
    model.toBoxId = [rs intForColumn:@"toBoxId"];
    model.tryTimes = [rs intForColumn:@"tryTimes"];
    
    return model;
}

@end
