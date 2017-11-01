//
//  MCDbVersion7.m
//  NPushMail
//

#import "MCDbVersion7.h"
#import "MCDatabaseHelper.h"
@implementation MCDbVersion7

- (NSInteger)version {
    return 7;
}

- (BOOL)upgradeDatabase
{

    FMDatabaseQueue *queue = [MCDatabaseHelper shared].dbQueue;
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = @"CREATE INDEX `idx_mail_content_messageuid` ON `MailContent` ( `boxId`, `messageUid` DESC )";
        [db executeStatements:sql];
    }];

    return YES;
    
}

@end
