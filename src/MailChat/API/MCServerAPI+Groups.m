//
//  MCServerAPI+Groups.m
//  NPushMail
//
//  Created by admin on 3/22/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCServerAPI+Groups.h"

@implementation MCServerAPI (Groups)

- (void)createGroupWithEmail:(NSString *)email groupId:(NSString *)groupId members:(NSArray *)members groupName:(NSString *)groupName success:(SuccessBlock)success failure:(FailureBlock)failure
{
    NSMutableDictionary *params = [self authParameters];
    params[@"e"] = [email lowercaseStringWithSpaceRemoved];
    params[@"id"] = groupId;
    params[@"name"] = groupName;
    NSString *membersStr = [self stringParameterWithArray:members];
    params[@"members"] = membersStr;

    [self.manager POST:@"chat/create_group" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        DDLogVerbose(@"createGroupWithEmail response = %@",responseObject);
        BOOL result = [[responseObject objectForKey:@"result"] boolValue];
        if (result) {
            if (success) {
                NSArray *dataObj = responseObject[@"data"];
                MCIMGroupModel *group = [self groupWithObj:dataObj];
                success(group);
            }
        }else{
            if (failure) {
                NSError *error = [self errorWithResponse:responseObject];
                failure(error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"[createGroupWithEmail] ERROR = %@",error);
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getInvitationsWithEmail:(NSString *)email success:(SuccessBlock)success failure:(FailureBlock)failure
{
    NSMutableDictionary *params = [self authParameters];
    params[@"e"] = [email lowercaseStringWithSpaceRemoved];

    [self.manager POST:@"user/invitations" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        DDLogVerbose(@"getInvitationsWithEmail response = %@",responseObject);
        BOOL result = [[responseObject objectForKey:@"result"] boolValue];
        if (result) {
            if (success) {
                NSArray *invitations = [self invitationsWithResponseObj:responseObject];
                success(invitations);
            }
        }
        else{
            if (failure) {
                NSError *error = [self errorWithResponse:responseObject];
                failure(error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"[getInvitationsWithEmail] ERROR = %@",error);
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getGroupsWithEmail:(NSString *)email success:(SuccessBlock)success failrue:(FailureBlock)failure
{
    NSMutableDictionary *params = [self authParameters];
    params[@"e"] = [email lowercaseStringWithSpaceRemoved];
    
    [self.manager POST:@"chat/groups" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        DDLogVerbose(@"getGroupsWithEmail response = %@",responseObject);
        BOOL result = [[responseObject objectForKey:@"result"] boolValue];
        if (result) {
            if (success) {
                NSArray *objList = responseObject[@"data"];
                NSMutableArray *groups = [[NSMutableArray alloc] initWithCapacity:objList.count];
                for (id obj in objList) {
                    MCIMGroupModel *group = [self groupWithObj:obj];
                    [groups addObject:group];
                }
                success(groups);
            }
        }
        else{
            if (failure) {
                NSError *error = [self errorWithResponse:responseObject];
                failure(error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"[getGroupsWithEmail] ERROR = %@",error);
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getGroupInfoWithGroupId:(NSString *)groupId success:(SuccessBlock)success failrue:(FailureBlock)failure
{
    NSMutableDictionary *params = [self authParameters];
    params[@"e"] = [AppStatus.currentUser.email lowercaseStringWithSpaceRemoved];
    params[@"id"] = [groupId lowercaseStringWithSpaceRemoved];

    [self.manager POST:@"chat/group" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        DDLogVerbose(@"getGroupInfoWithGroupId response = %@",responseObject);
        BOOL result = [[responseObject objectForKey:@"result"] boolValue];
        if (result) {
            if (success) {
                NSMutableArray *groups = [[NSMutableArray alloc] initWithCapacity:1];
                MCIMGroupModel *group = [self groupWithObj:responseObject[@"data"]];
                [groups addObject:group];
                success(groups);
            }
        }
        else{
            if (failure) {
                NSError *error = [self errorWithResponse:responseObject];
                failure(error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"[getGroupInfoWithGroupId] ERROR = %@",error);
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getGroupWithGroupId:(NSString *)groupId email:(NSString *)email success:(SuccessBlock)success failrue:(FailureBlock)failure
{
    NSMutableDictionary *params = [self authParameters];
    params[@"e"] = [email lowercaseStringWithSpaceRemoved];
    params[@"id"] = [groupId lowercaseStringWithSpaceRemoved];
    
    [self.manager POST:@"chat/group" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        DDLogVerbose(@"[getGroupWithGroupId] response = %@",responseObject);
        BOOL result = [[responseObject objectForKey:@"result"] boolValue];
        if (result) {
            id dataObj = responseObject[@"data"];
            MCIMGroupModel *group = [self groupWithObj:dataObj];
            if (success) {
                success(group);
            }
        }
        else{
            if (failure) {
                NSError *error = [self errorWithResponse:responseObject];
                failure(error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"[getGroupWithGroupId] ERROR = %@",error);
        if (failure) {
            failure(error);
        }
    }];
}

- (void)joinGroupWithEmail:(NSString *)email groupId:(NSString *)groupId success:(SuccessBlock)success failure:(FailureBlock)failure
{
    NSMutableDictionary *params = [self authParameters];
    params[@"e"] = [email lowercaseStringWithSpaceRemoved];
    params[@"id"] = [groupId lowercaseStringWithSpaceRemoved];
    
    [self.manager POST:@"chat/join_group" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        DDLogVerbose(@"joinGroupWithEmail response = %@",responseObject);
        BOOL result = [[responseObject objectForKey:@"result"] boolValue];
        if (result) {
            if (success) {
                id dataObj = responseObject[@"data"];
                MCIMGroupModel *group = [self groupWithObj:dataObj];
                success(group);
            }
        }
        else{
            if (failure) {
                NSError *error = [self errorWithResponse:responseObject];
                failure(error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"[joinGroupWithEmail] ERROR = %@",error);
        if (failure) {
            failure(error);
        }
    }];
}

- (void)josinGroupsWithEmail:(NSString *)email groupIds:(NSArray *)groupIds success:(SuccessBlock)success failure:(FailureBlock)failure
{
    NSMutableDictionary *params = [self authParameters];
    params[@"e"] = [email lowercaseStringWithSpaceRemoved];
    NSString *idsString = [self stringParameterWithArray:groupIds];
    params[@"ids"] = idsString;
    
    [self.manager POST:@"chat/join_groups" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        DDLogVerbose(@"josinGroupsWithEmail response = %@",responseObject);
        BOOL result = [[responseObject objectForKey:@"result"] boolValue];
        if (result) {
            if (success) {
                NSDictionary *dataObj = responseObject[@"data"];
                NSMutableArray *groups = [[NSMutableArray alloc] initWithCapacity:dataObj.count];
                [dataObj enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    MCIMGroupModel *group = [self groupWithObj:obj[@"data"]];
                    [groups addObject:group];
                }];
                
                success(groups);
            }
        }
        else{
            if (failure) {
                NSError *error = [self errorWithResponse:responseObject];
                failure(error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"[josinGroupsWithEmail] ERROR = %@",error);
        if (failure) {
            failure(error);
        }
    }];
}

- (void)user:(NSString *)email addMembers:(NSArray *)members toGroup:(NSString *)groupId success:(ActionBlock)success failure:(FailureBlock)failure
{
    NSMutableDictionary *params = [self authParameters];
    params[@"e"] = [email lowercaseStringWithSpaceRemoved];
    params[@"id"] = [groupId lowercaseStringWithSpaceRemoved];
    NSString *membersStr = [self stringParameterWithArray:members];
    params[@"members"] = membersStr;
    
    [self.manager POST:@"chat/add_member" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        DDLogVerbose(@"addMembers response = %@",responseObject);
        BOOL result = [[responseObject objectForKey:@"result"] boolValue];
        if (result) {
            if (success) {
                success();
            }
        }
        else{
            if (failure) {
                NSError *error = [self errorWithResponse:responseObject];
                failure(error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"[addMembers] ERROR = %@",error);
        if (failure) {
            failure(error);
        }
    }];
}

- (void)user:(NSString *)email removeMembers:(NSArray *)members fromGroup:(NSString *)groupId success:(ActionBlock)success failure:(FailureBlock)failure
{
    NSMutableDictionary *params = [self authParameters];
    params[@"e"] = [email lowercaseStringWithSpaceRemoved];
    params[@"id"] = [groupId lowercaseStringWithSpaceRemoved];
    NSString *membersStr = [self stringParameterWithArray:members];
    params[@"members"] = membersStr;
    
    [self.manager POST:@"chat/remove_member" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        DDLogVerbose(@"[removeMembers] response = %@",responseObject);
        BOOL result = [[responseObject objectForKey:@"result"] boolValue];
        if (result) {
            if (success) {
                success();
            }
        }
        else{
            if (failure) {
                NSError *error = [self errorWithResponse:responseObject];
                failure(error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"[removeMembers] ERROR = %@",error);
        if (failure) {
            failure(error);
        }
    }];
}

- (void)leaveGroupWithEmail:(NSString *)email groupId:(NSString *)groupId success:(ActionBlock)success failure:(FailureBlock)failure
{
    NSMutableDictionary *params = [self authParameters];
    params[@"e"] = [email lowercaseStringWithSpaceRemoved];
    params[@"id"] = [groupId lowercaseStringWithSpaceRemoved];
   
    [self.manager POST:@"chat/leave_group" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        DDLogVerbose(@"[leaveGroupWithEmail] response = %@",responseObject);
        BOOL result = [[responseObject objectForKey:@"result"] boolValue];
        if (result) {
            if (success) {
                success();
            }
        }
        else{
            if (failure) {
                NSError *error = [self errorWithResponse:responseObject];
                failure(error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"[leaveGroupWithEmail] ERROR = %@",error);
        if (failure) {
            failure(error);
        }
    }];
}

- (void)deleteGroupWithEmail:(NSString *)email groupId:(NSString *)groupId success:(ActionBlock)success failure:(FailureBlock)failure
{
    NSMutableDictionary *params = [self authParameters];
    params[@"e"] = [email lowercaseStringWithSpaceRemoved];
    params[@"id"] = [groupId lowercaseStringWithSpaceRemoved];
    
    [self.manager POST:@"chat/delete_group" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        DDLogVerbose(@"[deleteGroupWithEmail] response = %@",responseObject);
        BOOL result = [[responseObject objectForKey:@"result"] boolValue];
        if (result) {
            if (success) {
                success();
            }
        }
        else{
            if (failure) {
                NSError *error = [self errorWithResponse:responseObject];
                failure(error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"[deleteGroupWithEmail] ERROR = %@",error);
        if (failure) {
            failure(error);
        }
    }];

}

- (void)renameGroup:(NSString *)groupId withNewName:(NSString *)newName success:(ActionBlock)success failure:(FailureBlock)failure
{
    NSMutableDictionary *params = [self authParameters];
    params[@"id"] = [groupId lowercaseStringWithSpaceRemoved];
    params[@"name"] = newName;
    params[@"e"] = [AppStatus.currentUser.email lowercaseStringWithSpaceRemoved];

    [self.manager POST:@"chat/rename_group" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        DDLogVerbose(@"[renameGroup] response = %@",responseObject);
        BOOL result = [[responseObject objectForKey:@"result"] boolValue];
        if (result) {
            if (success) {
                success();
            }
        }
        else{
            if (failure) {
                NSError *error = [self errorWithResponse:responseObject];
                failure(error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"[renameGroup] ERROR = %@",error);
        if (failure) {
            failure(error);
        }
    }];
}

- (void)checkUnloginMessage:(NSString *)email success:(SuccessBlock)success failure:(FailureBlock)failure
{
    NSMutableDictionary *params = [self authParameters];
    params[@"e"] = [AppStatus.currentUser.email lowercaseStringWithSpaceRemoved];
    params[@"to"] = [email lowercaseStringWithSpaceRemoved];
    params[@"op"] = @(1);
     [self.manager POST:@"chat/userim" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
         DDLogVerbose(@"[chat/userim] response = %@",responseObject);
         BOOL result = [[responseObject objectForKey:@"result"] boolValue];
            if (result) {
                if (success) {
                    success(@(result));
                }
            }
            else{
                if (failure) {
                    NSError *error = [self errorWithResponse:responseObject];
                    failure(error);
            }
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"[chat/userim] ERROR = %@",error);
            if (failure) {
                failure(error);
            }
     }];
}


#pragma mark - Private

- (NSArray *)invitationsWithResponseObj:(id)responseObj
{
    NSArray *invitationObjArray = [responseObj objectForKey:@"invitations"];
    NSMutableArray *invitations = [NSMutableArray new];
    for (id invitationObj in invitationObjArray) {
        MCIMInvitationModel *model = [MCIMInvitationModel new];
        model.groupId = invitationObj[@"gid"];
        model.by = invitationObj[@"by"];
        model.timeStamp = [invitationObj[@"ts"] doubleValue];
        [invitations addObject:model];
    }
    
    return [invitations copy];
}

- (MCIMGroupModel *)groupWithObj:(id)groupObj
{
    MCIMGroupModel *group = [MCIMGroupModel new];
    group.groupId = groupObj[@"gid"];
    group.groupName = groupObj[@"name"];
    group.avatar = groupObj[@"avatar"];
    
    NSMutableArray *members = [[NSMutableArray alloc] init];
    NSArray *membersObj = groupObj[@"members"];
    for (id memberObj in membersObj) {
        MCIMGroupMember *gmember = [self groupMemberWithObj:memberObj];
        gmember.joinState = IMGroupMemberJoinStateJoined;
        [members addObject:gmember];
    }
    NSArray *invitesObj = groupObj[@"invite"];
    for (id memberObj in invitesObj) {
        MCIMGroupMember *gmember = [self groupMemberWithObj:memberObj];
        gmember.joinState = IMGroupMemberJoinStateWaiting;
        [members addObject:gmember];
    }
    
    group.members = members;
    
    return group;
    
}

- (MCIMGroupMember *)groupMemberWithObj:(id)obj
{
    MCIMGroupMember *gmember = [MCIMGroupMember new];
    gmember.userId = obj[@"email"];
    gmember.isOwner = [obj[@"is_admin"] boolValue];
    gmember.nickName = obj[@"name"];
    
    return gmember;
}

- (NSString *)stringParameterWithArray:(NSArray *)array
{
    NSMutableString *idsString = [NSMutableString new];
    for (NSString *str in array) {
        if (idsString.length > 0) {
            [idsString appendString:@","];
        }
        [idsString appendString:str];
    }
    
    return [idsString copy];
}

@end
