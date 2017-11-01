//
//  MCMsgConversationTable.m
//  NPushMail
//
//  Created by swhl on 16/1/26.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCMsgConversationTable.h"
#import "MCIMConversationModel.h"

@implementation MCMsgConversationTable

- (NSArray *)allModels
{
    NSMutableArray *models = [[NSMutableArray alloc] init];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM IMConversation ORDER BY onTopTime DESC,lastMsgTime DESC";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            MCIMConversationModel *model = [self modelWithResultSet:rs];
            [models addObject:model];
        }
    }];
    
    return models;
}

- (void)insertModel:(MCIMConversationModel *)model
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"INSERT INTO IMConversation (peerId,content,draft,lastMsgTime,type,unreadCount,onTopTime,state,isShield ) VALUES (?,?,?,?,?,?,?,?,?)";
        [db executeUpdate:sql,model.peerId,model.content,model.draft,model.lastMsgTime,@(model.type),@(model.unreadCount),@(model.onTopTime),@(model.state),@(model.isShield)];
        model.uid = db.lastInsertRowId;
    }];
}

- (void)updateModel:(MCIMConversationModel *)model
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"UPDATE IMConversation SET type = ?, peerId = ?,  content = ?,draft = ?,lastMsgTime = ?,unreadCount = ?, onTopTime = ?, state = ?, isShield = ? WHERE id = ?";
        [db executeUpdate:sql,@(model.type),model.peerId,model.content,model.draft,model.lastMsgTime,@(model.unreadCount),@(model.onTopTime),@(model.state),@(model.isShield), @(model.uid)];
    }];
}

- (id)getModelById:(NSInteger)uid
{
    __block MCIMConversationModel *model;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM IMConversation WHERE id = ?";
        FMResultSet *rs = [db executeQuery:sql,@(uid)];
        while ([rs next]) {
            model = [self modelWithResultSet:rs];
        }
    }];
    
    return model;
}

- (MCIMConversationModel *)getModelByPeerId:(NSString *)peerId
{
    __block MCIMConversationModel *model;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM IMConversation WHERE peerId = ?";
        FMResultSet *rs = [db executeQuery:sql,peerId];
        while ([rs next]) {
            model = [self modelWithResultSet:rs];
        }
    }];
    
    return model;
}

- (void)deleteById:(NSInteger)uid
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"DELETE FROM IMConversation WHERE id = ?";
        [db executeUpdate:sql,@(uid)];
    }];
}


#pragma mark - Private

- (MCIMConversationModel *)modelWithResultSet:(FMResultSet *)rs
{
    MCIMConversationModel *model = [MCIMConversationModel new];
    model.uid = [rs intForColumn:@"id"];
    model.type = [rs intForColumn:@"type"];
    model.peerId = [rs stringForColumn:@"peerId"];
    model.content = [rs stringForColumn:@"content"];
    model.draft = [rs stringForColumn:@"draft"];
    model.lastMsgTime = [rs dateForColumn:@"lastMsgTime"];
    model.unreadCount = [rs intForColumn:@"unreadCount"];
    model.onTopTime = [rs doubleForColumn:@"onTopTime"];
    model.state = [rs intForColumn:@"state"];
    model.isShield = [rs boolForColumn:@"isShield"];
    
    return model;
}

@end
