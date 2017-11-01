//
//  MCDbVersion3.m
//  NPushMail
//
//  Created by zhang on 16/9/18.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCDbVersion3.h"
#import "MCDatabaseHelper.h"
@implementation MCDbVersion3

- (NSInteger)version {
    return 3;
}

- (BOOL)upgradeDatabase
{
    FMDatabaseQueue *queue = [MCDatabaseHelper shared].dbQueue;
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if (![db columnExists:@"authType" inTableWithName:@"Account"]) {
            NSString *sql = @"Alter table Account add column authType int not null default 0;"
            "Alter table Account add column authData BLOB";
            BOOL result = [db executeStatements:sql];
            DDLogInfo(@"MCDbVersion3 = %d",result);
        }
    }];
    
    return YES;
    
}

@end
