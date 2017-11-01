//
//  MCAccountTableBase.m
//  NPushMail
//
//  Created by admin on 3/11/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCAccountTableBase.h"
#import "MCAccountDatabase.h"

@implementation MCAccountTableBase

- (instancetype)init
{
    FMDatabaseQueue *queue = AppStatus.accountData.accountDb.dbQueue;
    self = [super initWithDbQueue:queue];
    return self;
}

@end
