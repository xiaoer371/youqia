//
//  MCTableBase.m
//  NPushMail
//
//  Created by admin on 12/22/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import "MCTableBase.h"
#import "MCDatabaseHelper.h"

@implementation MCTableBase

- (instancetype)init
{
    if (self = [super init]) {
        _dbQueue = [[MCDatabaseHelper shared] dbQueue];
    }
    
    return self;
}

- (instancetype)initWithDbQueue:(FMDatabaseQueue *)queue
{
    if (self = [super init]) {
        _dbQueue = queue;
    }
    return self;
}

#pragma mark - Protocols

- (NSArray *)allModels
{
    DDLogError(@"allModels not implemented");
    return nil;
}

- (id)getModelById:(NSInteger)uid
{
    DDLogError(@"getModelById not implemented");
    return nil;
}

- (void)insertModel:(id)model
{
    DDLogError(@"insertModel not implemented");
}

- (void)updateModel:(id)model
{
    DDLogError(@"updateModel not implemented");
}

- (void)deleteById:(NSInteger)uid
{
    DDLogError(@"deleteById not implemented");
}

@end
