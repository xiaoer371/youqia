//
//  MCFileTable.m
//  NPushMail
//
//  Created by wuwenyu on 15/12/25.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import "MCFileTable.h"
#import "MCFileBaseModel.h"
#import "MCDatabaseHelper.h"

@implementation MCFileTable

- (id)getModelById:(NSInteger)uid
{
    __block MCFileBaseModel *model = nil;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM FileBase WHERE id = ?";
        FMResultSet *rs = [db executeQuery:sql,@(uid)];
        while ([rs next]) {
            model = [self modelWithResultSet:rs];
        }
    }];
    
    return model;
}

- (id)getModelByfileId:(NSString *)fileId
{
    __block MCFileBaseModel *model = nil;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM FileBase WHERE fileId = ?";
        FMResultSet *rs = [db executeQuery:sql,fileId];
        while ([rs next]) {
            model = [self modelWithResultSet:rs];
        }
    }];
    return model;
}



- (NSMutableArray *)getAllFiles {
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:0];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM FileBase ORDER BY downLoadDate DESC";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            MCFileBaseModel *model = [self modelWithResultSet:rs];
            [models addObject:model];
        }
    }];
    return models;
}

- (NSMutableArray *)getFilesWithLocation:(NSString *)location{
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:0];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM FileBase WHERE location = ?";
        FMResultSet *rs = [db executeQuery:sql, location];
        if ([location isEqualToString:@"collectFile"]) {
            sql = @"SELECT * FROM FileBase WHERE isCollect = ?";
            rs = [db executeQuery:sql, @1];
        }
        while ([rs next]) {
            MCFileBaseModel *model = [self modelWithResultSet:rs];
            [models addObject:model];
        }
    }];
    return models;
}

- (void)insertModel:(id)model {
    if ([model isMemberOfClass:[MCFileBaseModel class]]) {
        MCFileBaseModel *fileModel = (MCFileBaseModel *)model;
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            NSString *sql = [NSString stringWithFormat:@"INSERT OR IGNORE INTO FileBase (type, fileId, fromUser, format, sourceName, displayName, size, receiveDate, downLoadDate, isCollect, isFolder, location, parentId, source, remark) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"];
            [db executeUpdate:sql, @(fileModel.type), fileModel.fileId, fileModel.fromUser, fileModel.format, fileModel.sourceName, fileModel.displayName, @(fileModel.size), @(fileModel.receiveDate), @(fileModel.downLoadDate), @(fileModel.isCollect), @(fileModel.isFolder), fileModel.location, @(fileModel.parentId), @(fileModel.source), fileModel.remark];
            fileModel.uid = db.lastInsertRowId;
        }];
    }
}

- (BOOL)deleteFileWithFileName:(NSString *)fileName {
    __block BOOL result = NO;
    [self.dbQueue inDatabase:^(FMDatabase * db) {
        [db setShouldCacheStatements:YES];
        NSString *string =[NSString stringWithFormat:@"DELETE FROM FileBase WHERE displayName = ?"];
        result = [db executeUpdate:string, fileName];
    }];
    return result;
}

- (void)setCollectWithFileName:(NSString *)fileName isCollect:(BOOL)isCollect {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"UPDATE FileBase SET isCollect = ? WHERE displayName = ?";
        [db executeUpdate:sql, @(isCollect), fileName];
    }];
}

- (void)setLocationWithFileName:(NSString *)fileName location:(NSString *)location {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"UPDATE FileBase SET location = ? WHERE displayName = ?";
        [db executeUpdate:sql, location, fileName];
    }];
}

- (MCFileBaseModel *)modelWithResultSet:(FMResultSet *)rs {
    MCFileBaseModel *model = [[MCFileBaseModel alloc] init];
    model.uid = [rs intForColumn:@"id"];
    model.fileId = [rs stringForColumn:@"fileId"];
    model.type = [rs intForColumn:@"type"];
    model.format = [rs stringForColumn:@"format"];
    model.sourceName = [rs stringForColumn:@"sourceName"];
    model.displayName = [rs stringForColumn:@"displayName"];
    model.size = [rs intForColumn:@"size"];
    model.receiveDate = [rs intForColumn:@"receiveDate"];
    model.downLoadDate = [rs intForColumn:@"downLoadDate"];
    model.isCollect = [rs boolForColumn:@"isCollect"];
    model.isFolder = [rs boolForColumn:@"isFolder"];
    model.location = [rs stringForColumn:@"location"];
    model.parentId = [rs intForColumn:@"parentId"];
    model.source = [rs intForColumn:@"source"];
    model.remark = [rs stringForColumn:@"remark"];
    return model;
}

@end
