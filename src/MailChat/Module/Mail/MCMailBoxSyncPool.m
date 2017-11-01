//
//  MCMailBoxSyncPool.m
//  NPushMail
//
//  Created by admin on 09/11/2016.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCMailBoxSyncPool.h"

@interface MCMailBoxSyncPool ()


@end

@implementation MCMailBoxSyncPool

- (instancetype)init
{
    if (self = [super init]) {
        _managers = [NSMutableArray new];
    }
    
    return self;
}

+ (instancetype)shared
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [MCMailBoxSyncPool new];
    });
    
    return instance;
}

- (MCMailBoxSyncManager *)syncManagerForFoler:(MCMailBox *)folder
{
    MCMailBoxSyncManager *mgr = [self findManagerWithFolder:folder];
    if (mgr) {
        return mgr;
    }
    
    @synchronized (self) {
        mgr = [self findManagerWithFolder:folder];
        if (mgr) {
            return mgr;
        }
        mgr = [[MCMailBoxSyncManager alloc] initWithMailBox:folder];
        [self.managers addObject:mgr];
        return mgr;
    }
}

- (MCMailBoxSyncManager *)findManagerWithFolder:(MCMailBox *)folder
{
    for (MCMailBoxSyncManager *mgr in self.managers) {
        if ([mgr.folder isEqual:folder]) {
            return mgr;
        }
    }
    
    return nil;
}

@end
