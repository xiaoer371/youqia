//
//  MCMailBoxSyncPool.h
//  NPushMail
//
//  Created by admin on 09/11/2016.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCMailBoxSyncManager.h"

@interface MCMailBoxSyncPool : NSObject

@property (nonatomic,strong) NSMutableArray *managers;

+ (instancetype)shared;

- (MCMailBoxSyncManager *)syncManagerForFoler:(MCMailBox *)folder;

@end
