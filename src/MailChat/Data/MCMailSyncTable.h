//
//  MailSyncTable.h
//  NPushMail
//
//  Created by admin on 12/14/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import "MCTableBase.h"
#import "MCMailSyncModel.h"

@interface MCMailSyncTable : MCTableBase

- (NSArray *)getModelsWithAccountId:(NSInteger)accountId;

/**
 *  更新尝试次数
 *
 *  @param model 需要更新的对象
 */
- (void)updateTryTimes:(MCMailSyncModel *)model;

@end
