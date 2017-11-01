//
//  MCMsgGroupMemberTable.m
//  NPushMail
//
//  Created by admin on 3/17/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCMsgGroupMemberTable.h"

@implementation MCMsgGroupMemberTable

- (NSArray *)allModels
{
    NSMutableArray *models = [NSMutableArray new];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM IMGroupMember";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            MCIMGroupMember *model = [self modelWithResultSet:rs];
            [models addObject:model];
        }
    }];
    
    return models;
}

- (void)insertModel:(MCIMGroupMember *)model
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"INSERT INTO IMGroupMember (groupId,userId,nickName,isOwner,joinState) VALUES (?,?,?,?,?)";
        [db executeUpdate:sql,@(model.groupId),model.userId,model.nickName,@(model.isOwner),@(model.joinState)];
        model.uid = db.lastInsertRowId;
    }];
}

- (void)updateModel:(MCIMGroupMember *)model
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"UPDATE IMGroupMember SET groupId = ?, userId = ?, nickName = ?, isOwner = ?, joinState = ? WHERE id = ?";
        [db executeUpdate:sql,@(model.groupId),model.userId,model.nickName,@(model.isOwner),@(model.joinState),@(model.uid)];
    }];
}

- (void)deleteById:(NSInteger)uid
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"DELETE FROM IMGroupMember WHERE id = ?";
        [db executeUpdate:sql,@(uid)];
    }];
}

- (void)deleteByGroupId:(NSInteger)groupId
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"DELETE FROM IMGroupMember WHERE groupId = ?";
        [db executeUpdate:sql,@(groupId)];
    }];
}

- (void)deleteByGroupId:(NSInteger)groupId userId:(NSString *)userId
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"DELETE FROM IMGroupMember WHERE groupId = ? AND userId = ?";
        [db executeUpdate:sql,@(groupId),userId];
    }];
}

- (void)updateGroupMembers:(NSArray *)members withGroupId:(NSInteger)groupId
{
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = @"DELETE FROM IMGroupMember WHERE groupId = ?";
        [db executeUpdate:sql,@(groupId)];
        NSString *insertSql = @"INSERT INTO IMGroupMember (groupId,userId,nickName,isOwner,joinState) VALUES (?,?,?,?,?)";
        for (MCIMGroupMember *model in members) {
            model.groupId = groupId;
            [db executeUpdate:insertSql,@(model.groupId),model.userId,model.nickName,@(model.isOwner),@(model.joinState)];
            model.uid = db.lastInsertRowId;
        }
    }];
}

- (NSArray *)getGroupMembersWithGroupId:(NSInteger)groupId
{
    NSMutableArray *models = [NSMutableArray new];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM IMGroupMember WHERE groupId = ?";
        FMResultSet *rs = [db executeQuery:sql,@(groupId)];
        while ([rs next]) {
            MCIMGroupMember *model = [self modelWithResultSet:rs];
            [models addObject:model];
        }
    }];
    
    return models;
}

- (MCIMGroupMember *)modelWithResultSet:(FMResultSet *)rs
{
    MCIMGroupMember *model = [MCIMGroupMember new];
    model.uid = [rs intForColumn:@"id"];
    model.groupId = [rs intForColumn:@"groupId"];
    model.userId = [rs stringForColumn:@"userId"];
    model.nickName = [rs stringForColumn:@"nickName"];
    model.isOwner = [rs boolForColumn:@"isOwner"];
    model.joinState = [rs intForColumn:@"joinState"];
    return model;
}

@end
