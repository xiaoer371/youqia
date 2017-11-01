//
//  MCMsgContentTable.m
//  NPushMail
//
//  Created by swhl on 16/1/26.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCMsgContentTable.h"

@implementation MCMsgContentTable

- (NSArray *)allModels
{
    NSMutableArray *models = [[NSMutableArray alloc] init];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM IMMessage";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            MCIMMessageModel *model = [self.class modelWithResultSet:rs];
            [models addObject:model];
        }
    }];
    
    return models;
}

- (void)insertModel:(MCIMMessageModel *)model
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"INSERT INTO IMMessage (messageId,conversationId,conversationType,type,fromUserId,toId,content,time,state,isRead,isSender,sendMsgId ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)";
        [db executeUpdate:sql,model.messageId,@(model.conversationId),@(model.conversationType), @(model.type),model.from,model.to,model.content,model.time,@(model.state),@(model.isRead),@(model.isSender),@(model.sendMsgId)];
        model.uid = db.lastInsertRowId;
    }];
}

- (void)deleteMessage:(MCIMMessageModel *)model
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"DELETE FROM IMMessage WHERE messageId = ?";
        [db executeUpdate:sql,model.messageId];
    }];
}


- (void)updateModel:(MCIMMessageModel *)model
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"UPDATE IMMessage SET messageId = ?, conversationId = ?,conversationType = ?, type = ?, fromUserId = ?,toId = ?,content = ?,time = ?, state = ?, isRead = ?, isSender = ?, sendMsgId = ? WHERE id = ?";
        [db executeUpdate:sql,model.messageId,@(model.conversationId),@(model.conversationType), @(model.type),model.from,model.to,model.content,model.time,@(model.state),@(model.isRead),@(model.isSender),@(model.sendMsgId),@(model.uid)];
    }];
}

- (void)updateMessageState:(MCIMMessageModel *)model
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"UPDATE IMMessage SET sendMsgId = ?, state = ? WHERE id = ?";
        [db executeUpdate:sql,@(model.sendMsgId), @(model.state),@(model.uid)];
    }];

}

- (id)getModelById:(NSInteger)uid
{
    __block MCIMMessageModel *model;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM IMMessage WHERE id = ?";
        FMResultSet *rs = [db executeQuery:sql,@(uid)];
        while ([rs next]) {
            model = [self.class modelWithResultSet:rs];
        }
    }];
    
    return model;
}

- (MCIMMessageModel *)getMessageWithMessageId:(NSString *)messageId
{
    __block MCIMMessageModel *model;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM IMMessage WHERE messageId = ?";
        FMResultSet *rs = [db executeQuery:sql,messageId];
        while ([rs next]) {
            model = [self.class modelWithResultSet:rs];
        }
    }];
    
    return model;
}

- (NSArray *)getMessagesWithConversationId:(NSInteger)conversationId fromId:(NSInteger)fromId number:(NSInteger)number
{
    NSMutableArray *models = [[NSMutableArray alloc] init];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"SELECT * FROM IMMessage WHERE conversationId = ? AND id < ? ORDER BY id desc limit ?";
        FMResultSet *rs = [db executeQuery:sql,@(conversationId),@(fromId),@(number)];
        while ([rs next]) {
            MCIMMessageModel *model = [self.class modelWithResultSet:rs];
            [models insertObject:model atIndex:0];
        }
    }];
    
    return models;
}


- (int) getChatCountsWithChatter:(NSInteger)conversationId withDb:(FMDatabase*)db withCount:(int)count {
    
    __block int numbers = count;
    NSString *tableStr=[NSString stringWithFormat:@"select count(*) from IMMessage where conversationId =?"];
    FMResultSet *rs = [db executeQuery:tableStr,@(conversationId)];
    while ([rs next]) {
        numbers = [rs intForColumnIndex:0];
    }
    [rs close];
    return numbers;
}

- (void)deleteMessagesWithConversationId:(NSInteger)conversationId
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"DELETE FROM IMMessage WHERE conversationId = ?";
        [db executeUpdate:sql,@(conversationId)];
    }];
}

- (NSArray *)getVoiceNameWithConversationId:(NSInteger)conversationId
{
    NSMutableArray *models = [[NSMutableArray alloc] init];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"SELECT * FROM IMMessage WHERE conversationId = ? AND  type = '3'";
        FMResultSet *rs = [db executeQuery:sql,@(conversationId)];
        while ([rs next]) {
            MCIMMessageModel *model = [self.class modelWithResultSet:rs];
            [models insertObject:model atIndex:0];
        }
    }];
    
    return models;
}
- (void)updateFileMessageWithFileId:(NSString*)fileId
{
    
    __block MCIMMessageModel *model;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        //模糊查找到要修改的fileModel 
        NSString *sql =[NSString stringWithFormat:@"SELECT * FROM IMMessage WHERE content like '%@%@%@'",@"%",fileId,@"%"];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            model = [self.class modelWithResultSet:rs];
        }
    }];
    MCIMFileModel *fileModel =(MCIMFileModel*)model;
    fileModel.downloadState =IMFileDownloadNone;
    [self updateModel:fileModel];
}


- (BOOL)messageExists:(NSString *)messageId
{
    __block BOOL exists = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT 1 FROM IMMessage WHERE messageId = ?";
        FMResultSet *rs = [db executeQuery:sql,messageId];
        while ([rs next]) {
            exists = YES;
        }
    }];
    
    return exists;
}

- (void)updateState:(IMMessageState)state withMsgId:(NSInteger)msgId
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"UPDATE IMMessage SET state = ? WHERE sendMsgId = ?";
        [db executeUpdate:sql,@(state),@(msgId)];
    }];
}


#pragma mark - Private

+ (MCIMMessageModel *)modelWithResultSet:(FMResultSet *)rs
{
    IMMessageType type = [rs intForColumn:@"type"];
    MCIMMessageModel *model = [MCMsgContentTable createModelWithType:type];
    
    model.type = type;
    model.uid = [rs intForColumn:@"id"];
    model.messageId = [rs stringForColumn:@"messageId"];
    model.conversationId = [rs intForColumn:@"conversationId"];
    model.conversationType = [rs intForColumn:@"conversationType"];
    model.content = [rs stringForColumn:@"content"];
    model.from = [rs stringForColumn:@"fromUserId"];
    model.to = [rs stringForColumn:@"toId"];
    model.time = [rs dateForColumn:@"time"];
    model.state = [rs intForColumn:@"state"]==0?IMMessageStateFailure:[rs intForColumn:@"state"];
    model.isRead = [rs boolForColumn:@"isRead"];
    model.isSender = [rs boolForColumn:@"isSender"];
    model.sendMsgId = [rs intForColumn:@"sendMsgId"];
    return model;
}

+ (MCIMMessageModel *)createModelWithType:(IMMessageType)type
{
    MCIMMessageModel *model = nil;
    switch (type) {
        case IMMessageTypeImage:
            model = [MCIMImageModel new];
            break;
        case IMMessageTypeVoice:
            model = [MCIMVoiceModel new];
            break;
        case IMMessageTypeFile:
            model = [MCIMFileModel new];
            break;
        case IMMessageTypeNotice:
        case IMMessageTypeText:
            model = [MCIMMessageModel new];
            break;
        case IMMessageTypeOA:
            model = [MCIMOAMessageModel new];
        default:
            break;
    }
    
    return model;
}

@end
