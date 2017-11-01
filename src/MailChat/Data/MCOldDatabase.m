//
//  MCOldDatabase.m
//  NPushMail
//
//  Created by admin on 7/5/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCOldDatabase.h"
#import <FMDB.h>

@interface MCOldDatabase ()

@property (nonatomic,strong) FMDatabaseQueue *databaseQueue;
@property (nonatomic,strong) FMDatabaseQueue *messageQueue;

@end

@implementation MCOldDatabase

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *databasePath = [AppStatus.documentDir stringByAppendingPathComponent:@"database.sqlite"];
        _databaseQueue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
        NSString *messagePath = [AppStatus.documentDir stringByAppendingPathComponent:@"message.sqlite"];
        _messageQueue = [FMDatabaseQueue databaseQueueWithPath:messagePath];
    }
    return self;
}

@end
