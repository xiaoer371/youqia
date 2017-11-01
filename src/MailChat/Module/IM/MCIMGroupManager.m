//
//  MCIMGroupManager.m
//  NPushMail
//
//  Created by admin on 2/25/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCIMGroupManager.h"
#import "MCMsgGroupTable.h"
#import "MCServerAPI+Groups.h"
#import "MCMsgGroupMemberTable.h"
#import "MCIMClient.h"
#import "MCIMMessageSender.h"
#import "MCUDID.h"
#import "MCIMConversationManager.h"
#import "MCNotificationCenter.h"
#import "MCContactManager.h"

static NSInteger const kGropuNameMaxLength = 36;

@interface MCIMGroupManager ()

@property (nonatomic,strong) MCMsgGroupTable *db;
@property (nonatomic,strong) MCMsgGroupMemberTable *memberDb;

// 缓存，切换账户的时候必须清空掉
@property (nonatomic,strong) NSMutableDictionary *groups;

@property (nonatomic,strong) NSTimer *syncTimer;
@property (nonatomic,strong) NSMutableDictionary *failedInvitations;

@end

@implementation MCIMGroupManager

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _db = [MCMsgGroupTable new];
        _memberDb = [MCMsgGroupMemberTable new];
        _failedInvitations = [NSMutableDictionary new];
        [self commonInit];
    }
    return self;
}

+ (instancetype)shared
{
    return AppStatus.accountData.imGroupManager;
}

#pragma mark - Public

- (MCIMGroupModel *)getGroupWithGroupId:(NSString *)groupId
{
    return self.groups[groupId];
}

/**
 *  获取用户邀请信息
 *
 *  @param success 成功回调，返回MCIMInvitationModel列表
 *  @param failure 失败回调，返回错误信息
 */
- (void)getInvitationsSuccess:(SuccessBlock)success failure:(FailureBlock)failure
{
    [ServerAPI getInvitationsWithEmail:AppStatus.currentUser.email success:^(id response) {
        if (success) {
            success(response);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)updateUserGroupsSuccess:(SuccessBlock)success failure:(FailureBlock)failure
{
    [ServerAPI getGroupsWithEmail:AppStatus.currentUser.email success:^(id response) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *serverGroups = (NSArray *)response;
            for (MCIMGroupModel *group in serverGroups) {
                [self insertOrUpdateGroup:group];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    success(serverGroups);
                }
            });
        });
    } failrue:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}
- (void)updateUserCurrentGroupWithGroupId:(NSString *)groupId  Success:(SuccessBlock)success failure:(FailureBlock)failure
{
    [ServerAPI getGroupInfoWithGroupId:groupId  success:^(id response) {
        NSArray *serverGroups = (NSArray *)response;
        for (MCIMGroupModel *group in serverGroups) {
            [self insertOrUpdateGroup:group];
        }
        if (success) {
            success(serverGroups);
        }
    } failrue:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark - 主动群操作

- (void)createGroupWithGroupName:(NSString *)groupName members:(NSArray *)members success:(SuccessBlock)success failure:(FailureBlock)failure
{
    NSMutableArray *memberIds = [[NSMutableArray alloc] initWithCapacity:members.count];
    for (MCContactModel *member in members) {
        [memberIds addObject:member.account];
    }
    
    NSString *gName = groupName;
    // 生成默认的群名
    if ([groupName length] == 0) {
        NSMutableString *mutableGroupName = [NSMutableString new];
        NSInteger count = members.count < 3 ? members.count : 3;
        for (NSInteger i = 0; i < count; i++) {
            MCContactModel *member = members[i];
            if (mutableGroupName.length > 0) {
                [mutableGroupName appendString:@"、"];
            }
            [mutableGroupName appendString:member.displayName];
        }
        if (mutableGroupName.length > kGropuNameMaxLength) {
            gName = [mutableGroupName substringToIndex:kGropuNameMaxLength];
        }
        else{
            gName = [mutableGroupName copy];
        }
    }
    
    NSString *groupId = [[MCUDID newUUID] lowercaseString];
    [ServerAPI createGroupWithEmail:AppStatus.currentUser.email groupId:[groupId lowercaseString] members:memberIds groupName:gName success:^(MCIMGroupModel *group) {
        
        MCIMCommandModel *cmd = [MCIMCommandModel new];
        cmd.from = AppStatus.currentUser.email;
        cmd.cmd = MCIMCmdJoinGroup;
        cmd.groupId = group.groupId;
        cmd.groupName = group.groupName;
        cmd.messageId = [[MCUDID newUUID] lowercaseString];
        //创建群的时候也给自己发一条消息（多设备同步）
        NSString *selfTopic = [NSString stringWithFormat:@"%@/s",AppStatus.currentUser.email];
        [[MCIMMessageSender shared] sendCommand:cmd toTopic:selfTopic success:nil failure:nil];
        
        //往群成员/s频道发送建群命令，这一步如果失败了，也没关系，因为接口创建成功后就有invitation信息
        for (MCContactModel *member in members) {
            if ([member.account isEqualToString:AppStatus.currentUser.email]) {
                continue;
            }
            NSString *topic = [NSString stringWithFormat:@"%@/s",member.account];
            cmd.messageId = [[MCUDID newUUID] lowercaseString];
            [[MCIMMessageSender shared] sendCommand:cmd toTopic:topic success:^{
                DDLogVerbose(@"Send join group command to %@ success",topic);
            } failure:^(NSError *error) {
                DDLogError(@"Send join group command to %@ error = %@",topic,error);
            }];
        }
        
        //订阅群频道
        [[MCIMClient shared] subscribeTopics:@[group.groupId] success:^{
            // 添加群成员
            NSMutableArray *groupMembers = [NSMutableArray new];
            for (MCContactModel *contact in members) {
                MCIMGroupMember *gm = [MCIMGroupMember new];
                gm.userId = contact.account;
                [groupMembers addObject:gm];
            }
            MCIMGroupMember *gm = [MCIMGroupMember new];
            gm.userId = AppStatus.currentUser.email;
            gm.isOwner = YES;
            [groupMembers addObject:gm];
            group.members = [groupMembers copy];
            [self insertOrUpdateGroup:group];
            
            //给自己发送一条建群消息
            NSString *msg = [self buildCreateGroupInfo:members];
            MCIMConversationModel *conversation = [[MCIMConversationManager shared] conversationForGroup:group];
            [[MCIMMessageSender shared] sendFakeMessageWithText:msg toConversation:conversation];
            
            if (success) {
                success(group);
            }
        } failure:^(NSError *error) {
            DDLogError(@"[createGroupWithGroupId] subscribe topic error = %@",error);
            if (failure) {
                failure(error);
            }
        }];
    } failure:^(NSError *error) {
        DDLogError(@"[createGroupWithEmail] error = %@",error);
        if (failure) {
            failure(error);
        }
    }];
}

- (void)inviteContacts:(NSArray *)contacts toGroup:(MCIMGroupModel *)group success:(ActionBlock)success failure:(FailureBlock)failure
{
    NSMutableArray *memberIds = [[NSMutableArray alloc] initWithCapacity:contacts.count];
    for (MCContactModel *contact in contacts) {
        [memberIds addObject:contact.account];
    }
    
    [ServerAPI user:AppStatus.currentUser.email addMembers:memberIds toGroup:group.groupId success:^{
        
        //往群成员/s频道发送邀请命令，这一步如果失败了，也没关系，因为接口创建成功后就有invitation信息
        for (MCContactModel *member in contacts) {
            NSString *topic = [NSString stringWithFormat:@"%@/s",member.account];
            MCIMCommandModel *cmd = [MCIMCommandModel new];
            cmd.from = AppStatus.currentUser.email;
            cmd.cmd = MCIMCmdJoinGroup;
            cmd.groupId = group.groupId;
            cmd.groupName = group.groupName;
            cmd.messageId = [[MCUDID newUUID] lowercaseString];
            [[MCIMMessageSender shared] sendCommand:cmd toTopic:topic success:^{
                DDLogVerbose(@"Send join group command to %@ success",topic);
            } failure:^(NSError *error) {
                DDLogError(@"Send join group command to %@ error = %@",topic,error);
            }];
        }
        
        // 发送一条邀请通知
        NSString *notice = [self buildAddMembersNotice:contacts];
        MCIMConversationModel *conversation = [[MCIMConversationManager shared] conversationForGroup:group];
        [[MCIMMessageSender shared] sendNotice:notice toConversation:conversation success:^{
            DDLogVerbose(@"Send add member notice success");
            // 添加到本地数据库
            [self addContacts:contacts toGroup:group];
            if (success) {
                success();
            }
        } failure:^(NSError *error) {
            DDLogError(@"Send add member notice error = %@",error);
            if (failure) {
                failure(error);
            }
        }];
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)removeMembers:(NSArray<MCContactModel*> *)contacts fromGroup:(MCIMGroupModel *)group success:(ActionBlock)success failure:(FailureBlock)failure
{
    NSMutableArray *contactIdList = [[NSMutableArray alloc] initWithCapacity:contacts.count];
    // 靠qos保证消息发送出去
    for (MCContactModel *contact in contacts) {
        [contactIdList addObject:contact.account];
    }
    // 保证接口调用成功
    [ServerAPI user:AppStatus.currentUser.email removeMembers:contactIdList fromGroup:group.groupId success:^{
        
        MCIMCommandModel *cmd = [MCIMCommandModel new];
        cmd.from = AppStatus.currentUser.email;
        cmd.cmd = MCIMCmdBeKickefOff;
        cmd.groupId = group.groupId;
        cmd.groupName = group.groupName;
        cmd.messageId = [[MCUDID newUUID] lowercaseString];
        // 靠qos保证消息发送出去
        for (MCContactModel *contact in contacts) {
            NSString *topic = [NSString stringWithFormat:@"%@/s",contact.account];
            [[MCIMMessageSender shared] sendCommand:cmd toTopic:topic success:nil failure:nil];
        }
        
        for (NSString *userId in contactIdList) {
            [self.memberDb deleteByGroupId:group.uid userId:userId];
        }
        // 发送一条移除通知
        NSString *notice = [self buildRemoveMembersNotice:contacts];
        MCIMConversationModel *conversation = [[MCIMConversationManager shared] conversationForGroup:group];
        [[MCIMMessageSender shared] sendNotice:notice toConversation:conversation success:nil failure:nil];
        
        if (success) {
            success();
        }
    } failure:^(NSError *error) {
        DDLogError(@"remove member from group api error = %@",error);
        if (failure) {
            failure(error);
        }
    }];
}

- (void)leaveGroup:(MCIMGroupModel *)group success:(SuccessBlock)success failure:(FailureBlock)failure
{
    [self.failedInvitations removeObjectForKey:group.groupId];
    
    [ServerAPI leaveGroupWithEmail:AppStatus.currentUser.email groupId:group.groupId success:^{
        // 取消订阅群频道，如果API调用成功了，反订阅虽然不一定能成功，靠qos来保证会发出去
        [[MCIMClient shared] unsubscribeToTopics:@[group.groupId] success:nil failure:nil];
        // 往其它群成员发送离开命令
        MCIMCommandModel *leaveCmd = [MCIMCommandModel new];
        leaveCmd.from = AppStatus.currentUser.email;
        leaveCmd.cmd = MCIMCmdLeaveGroup;
        leaveCmd.groupId = group.groupId;
        leaveCmd.groupName = group.groupName;
        leaveCmd.messageId = [[MCUDID newUUID] lowercaseString];
        NSArray *members = [self.memberDb getGroupMembersWithGroupId:group.uid];
        for (MCIMGroupMember *member in members) {
            NSString *topic = [NSString stringWithFormat:@"%@/s",member.userId];
            [[MCIMMessageSender shared] sendCommand:leaveCmd toTopic:topic success:nil failure:nil];
        }
        
        // 发送一条离开通知
        NSString *notice = [NSString stringWithFormat:PMLocalizedStringWithKey(@"PM_IMChat_LeaveGroup"),[self groupNoticeContact]];
        MCIMConversationModel *conversation = [[MCIMConversationManager shared] conversationForGroup:group];
        [[MCIMMessageSender shared] sendNotice:notice toConversation:conversation success:nil failure:nil];
        
        // 删除了本地的群
        [self deleteGroup:group];
        if (success) {
            success(@"succes");
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)dismissGroup:(MCIMGroupModel *)group success:(SuccessBlock)success failure:(FailureBlock)failure
{
    [self.failedInvitations removeObjectForKey:group.groupId];
    
    [ServerAPI deleteGroupWithEmail:AppStatus.currentUser.email groupId:group.groupId success:^{
        // 往其它群成员发送离开命令
        MCIMCommandModel *deleteCmd = [MCIMCommandModel new];
        deleteCmd.from = AppStatus.currentUser.email;
        deleteCmd.cmd = MCIMCmdDeleteGroup;
        deleteCmd.groupId = group.groupId;
        deleteCmd.groupName = group.groupName;
        deleteCmd.messageId = [[MCUDID newUUID] lowercaseString];
        NSArray *members = [self.memberDb getGroupMembersWithGroupId:group.uid];
        for (MCIMGroupMember *member in members) {
            NSString *topic = [NSString stringWithFormat:@"%@/s",member.userId];
            [[MCIMMessageSender shared] sendCommand:deleteCmd toTopic:topic success:nil failure:nil];
        }
        
        // 取消订阅群频道，如果API调用成功了，反订阅虽然不一定能成功，靠qos来保证会发出去
        [[MCIMClient shared] unsubscribeToTopics:@[group.groupId] success:nil failure:nil];
        // 删除了本地的群
        [self deleteGroup:group];
        
        if (success) {
            success(@"succes");
        }
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)changeGroup:(MCIMGroupModel *)group withNewName:(NSString *)newName success:(ActionBlock)success failure:(FailureBlock)failure
{
    [ServerAPI renameGroup:group.groupId withNewName:newName success:^{
        group.groupName = newName;
        [self updateGroup:group];
        //往群成员发改群名命令
        MCIMCommandModel *changeNameCmd = [MCIMCommandModel new];
        changeNameCmd.from = AppStatus.currentUser.email;
        changeNameCmd.cmd = MCIMCmdModifyGroupName;
        changeNameCmd.groupId = group.groupId;
        changeNameCmd.groupName = newName;
        changeNameCmd.messageId = [[MCUDID newUUID] lowercaseString];
        NSArray *members = [self.memberDb getGroupMembersWithGroupId:group.uid];
        for (MCIMGroupMember *member in members) {
            NSString *topic = [NSString stringWithFormat:@"%@/s",member.userId];
            [[MCIMMessageSender shared] sendCommand:changeNameCmd toTopic:topic success:nil failure:nil];
        }
        
        // 发送一条改名通知
        NSString *notice = [NSString stringWithFormat:PMLocalizedStringWithKey(@"PM_IMChat_ChangeGroupName"),[self groupNoticeContact], newName];
        MCIMConversationModel *conversation = [[MCIMConversationManager shared] conversationForGroup:group];
        [[MCIMMessageSender shared] sendNotice:notice toConversation:conversation success:nil failure:nil];
        
        if (success) {
            success();
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark - 被动群操作

- (void)joinGroupWithInvitation:(MCIMInvitationModel *)invite success:(SuccessBlock)success failure:(FailureBlock)failure
{
    [ServerAPI joinGroupWithEmail:AppStatus.currentUser.email groupId:invite.groupId success:^(MCIMGroupModel *group) {
        [self insertOrUpdateGroup:group];
        
        if (![AppStatus.currentUser.email isEqualToString:invite.by]) {
            [self sendJoinMessageWithInvitation:invite group:group];
        }
        
        [[MCIMClient shared] subscribeTopics:@[invite.groupId] success:^{
            if (success) {
                success(group);
            }
        } failure:failure];
    } failure:^(NSError *error){
        // 如果调用接口失败，就启用定时器，定时加入群组
        [self.failedInvitations setObject:invite forKey:invite.groupId];
        
        [self startSyncTimer];
        
        if (failure) {
            failure(error);
        }
        
    }];
}

- (void)joinGroupWithInvitations:(NSArray *)invitations success:(SuccessBlock)success failure:(FailureBlock)failure
{
    NSMutableArray *groupIds = [[NSMutableArray alloc] initWithCapacity:invitations.count];
    for (MCIMInvitationModel *invitation in invitations) {
        [groupIds addObject:invitation.groupId];
    }
    
    
    [ServerAPI josinGroupsWithEmail:AppStatus.currentUser.email groupIds:groupIds success:^(NSArray *groups) {
        
        [groupIds removeAllObjects];
        NSMutableArray *goodGroups = [NSMutableArray new];
        // 防止群组已经删除，但是邀请没被删除的情况
        for (MCIMGroupModel *group in groups) {
            if (group.groupId.length > 0) {
                [groupIds addObject:group.groupId];
                [goodGroups addObject:group];
            }
        }
        
        [[MCIMClient shared] subscribeTopics:groupIds success:^{
            for (MCIMGroupModel *group in goodGroups) {
                [self insertOrUpdateGroup:group];
                MCIMInvitationModel *invite = [[self class] findInvitationWithGroupId:group.groupId inInvations:invitations];
                [self sendJoinMessageWithInvitation:invite group:group];
            }
            
            if (success) {
                success(groups);
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    } failure:^(NSError *error) {
        
        for (MCIMInvitationModel *invitation in invitations) {
            [self.failedInvitations setObject:invitation forKey:invitation.groupId];
        }
        if (failure) {
            failure(error);
        }
    }];
}

- (void)groupDeleted:(NSString *)groupId success:(SuccessBlock)success failure:(FailureBlock)failure
{
    [self.failedInvitations removeObjectForKey:groupId];
    
    MCIMGroupModel *group = [self getGroupWithGroupId:groupId];
    if (group) {
        [MCNotificationCenter postNotification:MCNotificationDidKickedOut object:@[group,AppStatus.currentUser.email]];
    }
    [self deleteGroup:group];
    [[MCIMClient shared] unsubscribeToTopics:@[groupId] success:^{
        if (success) {
            success(group);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)user:(NSString *)userId leaveGroup:(NSString *)groupId success:(ActionBlock)success failure:(FailureBlock)failure
{
    [self.failedInvitations removeObjectForKey:groupId];
    
    MCIMGroupModel *group = [self getGroupWithGroupId:groupId];
    if (group) {
        [MCNotificationCenter postNotification:MCNotificationDidKickedOut object:@[group,userId]];
    }
    [self.memberDb deleteByGroupId:group.uid userId:userId];
    if (success) {
        success();
    }
}

- (void)beKickedOffGroup:(NSString *)groupId success:(SuccessBlock)success failure:(FailureBlock)failure
{
    [self.failedInvitations removeObjectForKey:groupId];
    
    MCIMGroupModel *group = [self getGroupWithGroupId:groupId];
    if (group) {
        [MCNotificationCenter postNotification:MCNotificationDidKickedOut object:@[group,AppStatus.currentUser.email]];
    }
    [self deleteGroup:group];
    [[MCIMClient shared] unsubscribeToTopics:@[groupId] success:^{
        if (success) {
            success(group);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)checkUnloginMessage:(NSString *)email success:(SuccessBlock)success failure:(FailureBlock)failure
{
    [ServerAPI checkUnloginMessage:email success:^(id response) {
        if (success) {
            success(response);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}
#pragma mark - 数据存储

- (NSArray *)groupMembersWithGroupuid:(NSInteger)groupuid
{
    return [self.memberDb getGroupMembersWithGroupId:groupuid];
}

- (void)deleteGroup:(MCIMGroupModel *)group
{
    if(!group || !group.uid) return;
    @synchronized (self.groups) {
        [[MCIMConversationManager shared] deleteConversationPermantelyWithPeerId:group.groupId];
        [self.groups removeObjectForKey:group.groupId];
        [self.db deleteById:group.uid];
        [self.memberDb deleteByGroupId:group.uid];
    }
}

- (void)updateGroup:(MCIMGroupModel *)group
{
    [self.db updateModel:group];
}

- (NSArray <MCIMGroupModel*> *)getSavedGroupModels
{
    return [self.db getSavedGroupModels];
}

#pragma mark - Private

- (void)commonInit
{
    self.groups = [NSMutableDictionary new];
    NSArray *allGroups = [self.db allModels];
    for (MCIMGroupModel *group in allGroups) {
        [self.groups setObject:group forKey:group.groupId];
    }
}


- (void)insertOrUpdateGroup:(MCIMGroupModel *)group
{
    @synchronized (self.groups) {
        MCIMGroupModel *localGroup = self.groups[group.groupId];
        if (localGroup) {
            localGroup.groupName = group.groupName;
            localGroup.avatar = group.avatar;
            [self.db updateModel:localGroup];
            [self.memberDb updateGroupMembers:group.members withGroupId:localGroup.uid];
        }
        else{
            [self.db insertModel:group];
            [self.memberDb updateGroupMembers:group.members withGroupId:group.uid];
            [self.groups setObject:group forKey:group.groupId];
        }
    }
}

- (void)addContacts:(NSArray *)contacts toGroup:(MCIMGroupModel *)group
{
    NSMutableArray *groupMembers = group.members ? [group.members mutableCopy] : [NSMutableArray new];
    
    for (MCContactModel *contact in contacts) {
        MCIMGroupMember *member = [MCIMGroupMember new];
        member.groupId = group.uid;
        member.userId = contact.account;
        [self.memberDb insertModel:member];
        [groupMembers addObject:member];
    }
    group.members = [groupMembers copy];
}

- (NSString *)buildCreateGroupInfo:(NSArray *)members
{
    NSString *membersStr = [self memberStringWithMembers:members];
    NSString *fromatStr = PMLocalizedStringWithKey(@"PM_IMChat_CreateGroup");
    return [NSString stringWithFormat:fromatStr,[self groupNoticeContact],membersStr];
}

- (NSString *)buildAddMembersNotice:(NSArray *)members
{
    NSString *membersStr = [self memberStringWithMembers:members];
    NSString *fromatStr = PMLocalizedStringWithKey(@"PM_IMChat_AddMembers");
    return [NSString stringWithFormat:fromatStr,[self groupNoticeContact],membersStr];
}

- (NSString *)buildRemoveMembersNotice:(NSArray *)members
{
    NSString *membersStr = [self memberStringWithMembers:members];
    NSString *fromatStr = PMLocalizedStringWithKey(@"PM_IMChat_RemoveMembers");
    return [NSString stringWithFormat:fromatStr,[self groupNoticeContact],membersStr];
}

- (NSString *)memberStringWithMembers:(NSArray *)members
{
    NSMutableString *membersStr = [NSMutableString new];
    for (MCContactModel *user in members) {
        if (membersStr.length > 0) {
            [membersStr appendString:@"、"];
        }
        [membersStr appendString:user.displayName];
    }
    
    return membersStr;
}

- (NSString *)groupNoticeContact
{
    return AppStatus.currentUser.displayName.length>1? AppStatus.currentUser.displayName:AppStatus.currentUser.email;
}

- (void)startSyncTimer
{
    [self stopSyncTimer];
    
    MCWeakProxy *weakProxy = [[MCWeakProxy alloc] initWithTarget:self];
    self.syncTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:weakProxy selector:@selector(onSyncTimer:) userInfo:nil repeats:NO];
}

- (void)stopSyncTimer
{
    [self.syncTimer invalidate];
    self.syncTimer = nil;
}


- (void)sendJoinMessageWithInvitation:(MCIMInvitationModel *)invite group:(MCIMGroupModel *)group
{
    MCIMConversationModel *conversation = [[MCIMConversationManager shared] conversationForGroup:group];
    MCContactModel *invitor = [[MCContactManager sharedInstance] getOrCreateContactWithEmail:invite.by name:nil];
    NSString *notice = [NSString stringWithFormat:PMLocalizedStringWithKey(@"PM_IMChat_JoinGroup"),invitor.displayName];
    [[MCIMMessageSender shared] sendFakeMessageWithText:notice toConversation:conversation];
}

+ (MCIMInvitationModel *)findInvitationWithGroupId:(NSString *)groupId inInvations:(NSArray *)invitations
{
    for (MCIMInvitationModel *model in invitations) {
        if ([model.groupId isEqualToString:groupId]) {
            return model;
        }
    }
    
    return nil;
}


- (void)onSyncTimer:(NSTimer *)timer
{
    DDLogVerbose(@"on sync join group timer");
    if (self.failedInvitations.count == 0) {
        [self stopSyncTimer];
        return;
    }
    
    if (AppStatus.networkStatus == NotReachable) {
        [self startSyncTimer];
        return;
    }
    
    [self joinGroupWithInvitations:self.failedInvitations.allValues success:^(id response) {
        [self.failedInvitations removeAllObjects];
        [self stopSyncTimer];
    } failure:^(NSError *error) {
        [self startSyncTimer];
    }];
}

@end
