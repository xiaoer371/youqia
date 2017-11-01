//
//  MCDbVersion4.m
//  NPushMail
//
//  Created by admin on 10/9/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCDbVersion4.h"
#import "MCDatabaseHelper.h"
#import "MCAccountManager.h"
#import "MCAccountDatabase.h"

@implementation MCDbVersion4

- (NSInteger)version {
    return 4;
}

- (BOOL)upgradeDatabase
{
    FMDatabaseQueue *queue = [MCDatabaseHelper shared].dbQueue;
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = @"ALTER TABLE MailContent ADD COLUMN status INTEGER NOT NULL default 0;"
        "ALTER TABLE MailContent ADD COLUMN tags INTEGER NOT NULL default 0;"
        "ALTER TABLE MailContent ADD COLUMN xPriority INTEGER NOT NULL DEFAULT 0;";
        [db executeStatements:sql];
    }];
    
    [self upgradeContacts];
    
    return YES;
}

- (void)upgradeContacts
{
    NSArray *accounts = [[MCAccountManager shared] getAllAccounts];
    for (MCAccount *account in accounts) {
        MCAccountDatabase *accountDb = [[MCAccountDatabase alloc] initWithAccount:account];
        [accountDb.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            NSString * sql = @"delete  from Contact where id in (select MAX(id) from Contact group by email having count(email) > 1 );"
                            "CREATE UNIQUE INDEX IF NOT EXISTS email_index ON Contact(email);";
            BOOL result = [db executeStatements:sql];
            DDLogInfo(@"MCDbVersion4 = %d",result);
        }];
    }
}


@end
