//
//  MCAccountTable.m
//  NPushMail
//
//  Created by admin on 12/25/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import "MCAccountTable.h"
#import "UIColor+Hex.h"
#import "MCRUKM.h"
#import "NSString+JSON.h"

@implementation MCAccountTable

- (NSArray *)allModels
{
    NSMutableArray *models = [[NSMutableArray alloc] init];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM Account";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            MCAccount *model = [self modelWithResultSet:rs];
            [models addObject:model];
        }
    }];
    
    return models;
}

- (id)getModelById:(NSInteger)uid
{
    __block MCAccount *model;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM Account WHERE accountId = ?", @(uid)];
        while ([rs next]) {
            model = [self modelWithResultSet:rs];
        }
    }];
    
    return model;
}

- (MCAccount *)getAccountByEmail:(NSString *)email
{
    __block MCAccount *model;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM Account WHERE email = ?", email];
        while ([rs next]) {
            model = [self modelWithResultSet:rs];
        }
    }];
    
    return model;
}

- (void)insertModel:(MCAccount *)model
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:@"INSERT INTO Account (email,password,type,isEIS,displayName,color,deleted,status,avatar,company,dept,title,signature,mailConfig, authType, authData) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",model.email,[MCRUKM makeIt:model.password], @(model.type),@(model.isEIS),model.displayName,@([model.color hexValue]),@(model.deleted),@(model.status), model.avatar,model.company,model.department,model.title,model.signature, [NSString jsonStringWithObject:[model.config toDictionary]], @(model.authType), model.authData];
        
        model.accountId = db.lastInsertRowId;
        
    }];
}

- (void)updateModel:(MCAccount *)model
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = @"UPDATE Account SET email = ?, password = ?, type = ?, isEIS = ?, displayName = ?,color = ?, avatar = ?, company = ?, dept = ?, title = ?, deleted = ?, signature = ?, mailConfig = ?, status = ?, authType = ?, authData = ? WHERE accountId = ?";
        [db executeUpdate:sql, model.email,[MCRUKM makeIt:model.password], @(model.type),@(model.isEIS), model.displayName,@([model.color hexValue]),model.avatar,model.company,model.department,model.title, @(model.deleted),model.signature, [NSString jsonStringWithObject:[model.config toDictionary]], @(model.status),@(model.authType),model.authData, @(model.accountId)];
        
    }];
}

- (void)deleteById:(NSInteger)uid {
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"DELETE FROM Account WHERE accountId = ?";
        [db executeUpdate:sql,@(uid)];
        DDLogDebug(@"从数据库删除账号---- %ld",uid);
    }];
}

#pragma mark - Private

- (MCAccount *)modelWithResultSet:(FMResultSet *)rs
{
    MCAccount *model = [MCAccount new];
    
    model.accountId = [rs intForColumn:@"accountId"];
    model.email = [rs stringForColumn:@"email"];
    model.password = [MCRUKM unmakeIt:[rs stringForColumn:@"password"]];
    model.type = [rs intForColumn:@"type"];
    model.isEIS = [rs boolForColumn:@"isEIS"];
    model.displayName = [rs stringForColumn:@"displayName"];
    model.color = [UIColor colorWithHexValue:[rs intForColumn:@"color"]];
    model.deleted = [rs boolForColumn:@"deleted"];
    model.signature = [rs stringForColumn:@"signature"];
    model.status = [rs intForColumn:@"status"];
    model.avatar = [rs stringForColumn:@"avatar"];
    model.company = [rs stringForColumn:@"company"];
    model.department = [rs stringForColumn:@"dept"];
    model.title = [rs stringForColumn:@"title"];
    model.authType = [rs intForColumn:@"authType"];
    model.authData = [rs dataForColumn:@"authData"];
    NSDictionary *configDict = [[rs stringForColumn:@"mailConfig"] toJson];
    model.config = [[MCMailConfig alloc] initWithDictionary:configDict];
    
    return model;
}

@end
