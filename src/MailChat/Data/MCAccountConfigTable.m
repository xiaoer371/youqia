//
//  MCAccountConfigTable.m
//  NPushMail
//
//  Created by admin on 12/25/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import "MCAccountConfigTable.h"

@implementation MCAccountConfigTable

- (NSArray *)allModels
{
    NSMutableArray *models = [[NSMutableArray alloc] init];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM AccountConfig";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            MCAccountConfigModel *model = [self modelWithResultSet:rs];
            [models addObject:model];
        }
    }];
    
    return models;
}

- (id)getModelById:(NSInteger)uid
{
    __block MCAccountConfigModel *model;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM AccountConfig WHERE id = ?", @(uid)];
        if ([rs next]) {
            model = [self modelWithResultSet:rs];
        }
    }];
    
    return model;
}

- (id)getModelWithKey:(NSString *)key {
    __block MCAccountConfigModel *model;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM AccountConfig WHERE configKey = ?", key];
        while ([rs next]) {
            model = [self modelWithResultSet:rs];

        }
    }];
    
    return model;
}

- (void)insertModel:(MCAccountConfigModel *)model
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"INSERT OR REPLACE INTO AccountConfig (configKey, configValue) VALUES (?,?)";
        [db executeUpdate:sql, model.configKey, model.configValue];
        
    }];
}

- (void)updateModel:(MCAccountConfigModel *)model
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"UPDATE AccountConfig SET configKey = ?, configValue = ? WHERE id = ?";
        [db executeUpdate:sql, model.configKey, model.configValue, @(model.uid)];
        
    }];
}

- (void)updateValue:(NSString *)value forKey:(NSString *)key {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"UPDATE AccountConfig SET configValue = ? WHERE configKey = ?";
        [db executeUpdate:sql, value, key];
        
    }];
}

- (void)delValueWithKey:(NSString *)key {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"DELETE FROM AccountConfig WHERE configKey = ?";
        [db executeUpdate:sql, key];
        
    }];
}

#pragma mark - Private

- (MCAccountConfigModel *)modelWithResultSet:(FMResultSet *)rs
{
    MCAccountConfigModel *model = [MCAccountConfigModel new];
    
    model.uid = [rs intForColumn:@"id"];
    model.configKey = [rs stringForColumn:@"configKey"];
    model.configValue = [rs stringForColumn:@"configValue"];
    
    return model;
}

@end
