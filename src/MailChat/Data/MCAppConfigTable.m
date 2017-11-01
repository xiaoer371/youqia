//
//  MCAppConfig.m
//  NPushMail
//
//  Created by admin on 12/25/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import "MCAppConfigTable.h"

@implementation MCAppConfigTable

- (NSArray *)allModels
{
    NSMutableArray *models = [[NSMutableArray alloc] init];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM AppConfig";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            MCAppConfigModel *model = [self modelWithResultSet:rs];
            [models addObject:model];
        }
    }];
    
    return models;
}

- (id)getModelById:(NSInteger)uid
{
    __block MCAppConfigModel *model;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM AppConfig WHERE id = ?", @(uid)];
        while ([rs next]) {
            model = [self modelWithResultSet:rs];
        }
    }];
    
    return model;
}

- (void)insertModel:(MCAppConfigModel *)model
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"INSERT INTO AppConfig (configKey,configValue) VALUES (?,?)";
        [db executeUpdate:sql,model.configKey,model.configValue];
        
    }];
}

- (void)updateModel:(MCAppConfigModel *)model
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"UPDATE AppConfig SET configValue = ? WHERE configKey = ?";
        [db executeUpdate:sql,model.configValue,model.configKey];
        
    }];
}

- (void)updateValue:(NSString *)value forKey:(NSString *)key
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"UPDATE AppConfig SET configValue = ? WHERE configKey = ?";
        [db executeUpdate:sql,value,key];
        
    }];
}

#pragma mark - Private

- (MCAppConfigModel *)modelWithResultSet:(FMResultSet *)rs
{
    MCAppConfigModel *model = [MCAppConfigModel new];
    
    model.configKey = [rs stringForColumn:@"configKey"];
    model.configValue = [rs stringForColumn:@"configValue"];
    
    return model;
}

@end
