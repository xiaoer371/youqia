//
//  MCDbVersion2.m
//  NPushMail
//
//  Created by admin on 8/15/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCDbVersion2.h"
#import "MCDatabaseHelper.h"

@implementation MCDbVersion2

- (NSInteger)version
{
    return 2;
}

- (BOOL)upgradeDatabase
{
    FMDatabaseQueue *queue = [MCDatabaseHelper shared].dbQueue;
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = @"UPDATE MailBox SET parentId = 0, level = 0 WHERE path LIKE 'INBOX.%';"
                        "UPDATE MailBox SET type = 4 WHERE path = 'INBOX.Draft';"
                        "UPDATE MailBox SET type = 2 WHERE path = 'INBOX.Sent';"
                        "UPDATE MailBox SET type = 6 WHERE path = 'INBOX.Spam';"
                        "UPDATE MailBox SET type = 5 WHERE path = 'INBOX.Trash';";
        BOOL result = [db executeStatements:sql];
        DDLogInfo(@"MCDbVersion2 = %d",result);
        
    }];
    
    return YES;
}

@end
