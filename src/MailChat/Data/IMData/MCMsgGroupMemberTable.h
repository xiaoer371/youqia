//
//  MCMsgGroupMemberTable.h
//  NPushMail
//
//  Created by admin on 3/17/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCAccountTableBase.h"
#import "MCIMGroupModel.h"

@interface MCMsgGroupMemberTable : MCAccountTableBase

- (void)deleteByGroupId:(NSInteger)groupId;

- (void)deleteByGroupId:(NSInteger)groupId userId:(NSString *)userId;

- (void)updateGroupMembers:(NSArray *)members withGroupId:(NSInteger)groupId;

- (NSArray *)getGroupMembersWithGroupId:(NSInteger)groupId;

@end
