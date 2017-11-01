//
//  MCServerAPI+Groups.h
//  NPushMail
//
//  Created by admin on 3/22/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCServerAPI.h"
#import "MCIMInvitationModel.h"
#import "MCIMGroupModel.h"

@interface MCServerAPI (Groups)

- (void)getInvitationsWithEmail:(NSString *)email success:(SuccessBlock)success failure:(FailureBlock)failure;

- (void)getGroupsWithEmail:(NSString *)email success:(SuccessBlock)success failrue:(FailureBlock)failure;

- (void)getGroupInfoWithGroupId:(NSString *)groupId success:(SuccessBlock)success failrue:(FailureBlock)failure;

- (void)getGroupWithGroupId:(NSString *)groupId email:(NSString *)email success:(SuccessBlock)success failrue:(FailureBlock)failure;


- (void)joinGroupWithEmail:(NSString *)email groupId:(NSString *)groupId success:(SuccessBlock)success failure:(FailureBlock)failure;

- (void)josinGroupsWithEmail:(NSString *)email groupIds:(NSArray *)groupIds success:(SuccessBlock)success failure:(FailureBlock)failure;

- (void)createGroupWithEmail:(NSString *)email groupId:(NSString *)groupId members:(NSArray *)members groupName:(NSString *)groupName success:(SuccessBlock)success failure:(FailureBlock)failure;

- (void)user:(NSString *)email addMembers:(NSArray *)members toGroup:(NSString *)groupId success:(ActionBlock)success failure:(FailureBlock)failure;
- (void)user:(NSString *)email removeMembers:(NSArray *)members fromGroup:(NSString *)groupId success:(ActionBlock)success failure:(FailureBlock)failure;

- (void)leaveGroupWithEmail:(NSString *)email groupId:(NSString *)groupId success:(ActionBlock)success failure:(FailureBlock)failure;

- (void)deleteGroupWithEmail:(NSString *)email groupId:(NSString *)groupId success:(ActionBlock)success failure:(FailureBlock)failure;

- (void)renameGroup:(NSString *)groupId withNewName:(NSString *)newName success:(ActionBlock)success failure:(FailureBlock)failure;

- (void)checkUnloginMessage:(NSString *)email success:(SuccessBlock)success failure:(FailureBlock)failure;

@end
