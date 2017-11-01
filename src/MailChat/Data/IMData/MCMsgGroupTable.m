//
//  MCMsgGroupTable.m
//  NPushMail
//
//  Created by swhl on 16/1/26.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCMsgGroupTable.h"

@implementation MCMsgGroupTable


- (NSArray *)allModels
{
    NSMutableArray *models = [NSMutableArray new];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM IMGroup";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            MCIMGroupModel *model = [self modelWithResultSet:rs];
            if (model.groupId) {
                [models addObject:model];
            }
        }
    }];
    
    return models;
}

- (id)getModelById:(NSInteger)uid
{
    __block MCIMGroupModel *model;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM IMGroup WHERE id = ?";
        FMResultSet *rs = [db executeQuery:sql,@(uid)];
        while ([rs next]) {
            model = [self modelWithResultSet:rs];
        }
    }];
    
    return model;
}

- (MCIMGroupModel *)groupWithGroupId:(NSString *)groupId
{
    __block MCIMGroupModel *model;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM IMGroup WHERE groupId = ?";
        FMResultSet *rs = [db executeQuery:sql,groupId];
        while ([rs next]) {
            model = [self modelWithResultSet:rs];
        }
    }];
    
    return model;
}

- (NSArray  <MCIMGroupModel*> * )getSavedGroupModels
{
    __block NSMutableArray *models = [NSMutableArray new];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM IMGroup WHERE isSaved = 1";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            MCIMGroupModel *model = [self modelWithResultSet:rs];
            if (model.groupId) {
                [models addObject:model];
            }
        }
    }];
    return models;
}

- (void)insertModel:(MCIMGroupModel *)model
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"INSERT INTO IMGroup (groupId,name,isSaved,avatar,state) VALUES (?,?,?,?,?)";
        [db executeUpdate:sql,model.groupId,model.groupName,@(model.isSaved),model.avatarUrl,@(model.state)];
        model.uid = db.lastInsertRowId;
    }];
}

- (void)updateModel:(MCIMGroupModel *)model
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"UPDATE IMGroup SET groupId = ?, name = ?, isSaved = ?, avatar = ?, state = ? WHERE id = ?";
        [db executeUpdate:sql,model.groupId,model.groupName,@(model.isSaved),model.avatarUrl,@(model.state),@(model.uid)];
    }];
}

- (void)deleteById:(NSInteger)uid
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"DELETE FROM IMGroup WHERE id = ?";
        [db executeUpdate:sql,@(uid)];
    }];
}


- (MCIMGroupModel *)modelWithResultSet:(FMResultSet *)rs
{
    MCIMGroupModel *model = [MCIMGroupModel new];
    model.uid = [rs intForColumn:@"id"];
    model.groupId = [rs stringForColumn:@"groupId"];
    model.groupName = [rs stringForColumn:@"name"];
    model.isSaved = [rs boolForColumn:@"isSaved"];
    model.avatar = [rs stringForColumn:@"avatar"];
    model.state = [rs intForColumn:@"state"];
    
    return model;
}

@end
