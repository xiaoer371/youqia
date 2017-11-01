//
//  MCAccountDatabase.h
//  NPushMail
//
//  Created by admin on 3/11/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>

@interface MCAccountDatabase : NSObject

@property (nonatomic,strong,readonly) FMDatabaseQueue *dbQueue;

- (instancetype)initWithAccount:(MCAccount *)account;

@end
