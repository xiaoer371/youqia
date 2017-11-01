//
//  MCDbVersion5.m
//  NPushMail
//
//  Created by wuwenyu on 16/11/16.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCDbVersion5.h"

#import "MCDatabaseHelper.h"
#import "MCAccountManager.h"
#import "MCAccountDatabase.h"

@implementation MCDbVersion5

- (NSInteger)version {
    return 5;
}

- (BOOL)upgradeDatabase
{
    NSArray *accounts = [[MCAccountManager shared] getAllAccounts];
    for (MCAccount *account in accounts) {
        MCAccountDatabase *accountDb = [[MCAccountDatabase alloc] initWithAccount:account];
        [accountDb.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            NSString *sql = @"ALTER TABLE Contact ADD COLUMN enterprise_sortId int32 NOT NULL default 1;"
            "ALTER TABLE Contact ADD COLUMN enterprise_topId int32 NOT NULL default 1;"
            "DELETE FROM AccountConfig WHERE id NOT IN ( SELECT MAX(id) from AccountConfig group by configKey);"
            "CREATE UNIQUE INDEX IF NOT EXISTS configKey_index ON AccountConfig(configKey);";
            
            BOOL result = [db executeStatements:sql];
            DDLogInfo(@"MCDbVersion5 = %d",result);
        }];
    }
    return YES;
}

@end

