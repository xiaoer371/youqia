//
//  DatabaseHelper.h
//  NPushMail
//
//  Created by admin on 12/15/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>
#import "MCAccountDatabase.h"

@interface MCDatabaseHelper : NSObject

@property (nonatomic,strong,readonly) FMDatabaseQueue *dbQueue;

+ (instancetype)shared;

/**
 *  获取某个帐号的数据库队列
 *
 *  @param account 帐号信息
 *
 *  @return 帐号数据库队列
 */
- (MCAccountDatabase *)databaseWithAccount:(MCAccount *)account;

@end
