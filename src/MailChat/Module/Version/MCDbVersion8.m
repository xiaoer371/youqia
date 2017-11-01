//
//  MCDbVersion8.m
//  NPushMail
//
//  Created by zhang on 2016/12/29.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCDbVersion8.h"
#import "MCAccountManager.h"
#import "MCAccountDatabase.h"

@implementation MCDbVersion8 

- (NSInteger)version {
    return 8;
}

- (BOOL)upgradeDatabase
{
    NSArray *accounts = [[MCAccountManager shared] getAllAccounts];
    for (MCAccount *account in accounts) {
        MCAccountDatabase *accountDb = [[MCAccountDatabase alloc] initWithAccount:account];
        [accountDb.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            NSString *sql1 = @"DELETE FROM AccountConfig WHERE configKey = 'isFirstSyncOAUser'";
            NSString *sql2 = @"DELETE FROM AccountConfig WHERE configKey = 'isOAUser'";
            NSString *sql3 = @"DELETE FROM AccountConfig WHERE configKey = 'isWorkspaceUser'";
            [db executeStatements:sql1];
            [db executeStatements:sql2];
            [db executeStatements:sql3];
            DDLogInfo(@"MCDbVersion7 = %d account = %@",YES, account.email);
        }];
    }
    return YES;
}

@end
