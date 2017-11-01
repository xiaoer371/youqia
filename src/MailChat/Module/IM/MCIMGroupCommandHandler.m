//
//  MCIMGroupCommandHandler.m
//  NPushMail
//
//  Created by admin on 4/7/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCIMGroupCommandHandler.h"
#import "MCIMCommandModel.h"
#import "MCIMGroupManager.h"
#import "MCIMConversationManager.h"
#import "MCContactManager.h"
#import "MCIMMessageSender.h"

@implementation MCIMGroupCommandHandler

- (void)processData:(MCIMDataModel *)msg
{
    if (!msg || msg.serviceType != IMServiceTypeGroupCmd) {
        return;
    }
    
    MCIMCommandModel *cmd = (MCIMCommandModel *)msg;
    switch (cmd.cmd) {
        case MCIMCmdJoinGroup:{
            [self processJoinCommand:cmd];
            break;
        }
        case MCIMCmdDeleteGroup:{
            [self processDeleteCommand:cmd];
            break;
        }
        case MCIMCmdLeaveGroup:{
            [self processLeaveCommand:cmd];
            break;
        }
        case MCIMCmdOtherUserBeKickedOff:{
            [self processOtherUserBeKickedOffCommand:cmd];
            break;
        }
        case MCIMCmdBeKickefOff:{
            [self processBeKickedOffCommand:cmd];
            break;
        }
        case MCIMCmdModifyGroupName:{
            [self processModifyGroupNameCommand:cmd];
            break;
        }
            
        default:
            break;
    }
    
}

#pragma mark - Private

- (void)processJoinCommand:(MCIMCommandModel *)cmd
{
    MCIMInvitationModel *invite = [MCIMInvitationModel new];
    invite.by = cmd.from;
    invite.groupId = cmd.groupId;
    invite.timeStamp = cmd.timeStamp;
    [[MCIMGroupManager shared] joinGroupWithInvitation:invite success:^(MCIMGroupModel *group) {
        DDLogVerbose(@"Join group %@ success",group.groupId);
    } failure:^(NSError *error) {
        DDLogError(@"Process Join Group cmd error = %@",error);
    }];
}

- (void)processDeleteCommand:(MCIMCommandModel *)cmd
{
    [[MCIMGroupManager shared] groupDeleted:cmd.groupId success:^(id response) {
        DDLogVerbose(@"Group deleted, groupId = %@",cmd.groupId);
    } failure:^(NSError *error) {
        DDLogError(@"Group deleted error = %@",error);
    }];
}

- (void)processLeaveCommand:(MCIMCommandModel *)cmd
{
    // 多端同步的命令，离开群租等于删除群租
    if ([cmd.from isEqualToString:AppStatus.currentUser.email]) {
        [[MCIMGroupManager shared] groupDeleted:cmd.groupId success:^(id response) {
            DDLogVerbose(@"User %@ leave group %@",cmd.from,cmd.groupId);
        } failure:^(NSError *error) {
            DDLogError(@"User leave group error");
        }];
    }
    else {
        [[MCIMGroupManager shared] user:cmd.from leaveGroup:cmd.groupId success:^{
            DDLogVerbose(@"User %@ leave group %@",cmd.from,cmd.groupId);
        } failure:^(NSError *error) {
            DDLogError(@"User leave group error");
        }];
    }
    
}

- (void)processOtherUserBeKickedOffCommand:(MCIMCommandModel *)cmd
{
    [[MCIMGroupManager shared] user:cmd.kickedOffUserId leaveGroup:cmd.groupId success:^{
        DDLogVerbose(@"User %@ be kicked off group %@",cmd.from,cmd.groupId);
    } failure:^(NSError *error) {
        DDLogError(@"User be kicked off group error = %@",error);
    }];
}

- (void)processBeKickedOffCommand:(MCIMCommandModel *)cmd
{
    [[MCIMGroupManager shared] beKickedOffGroup:cmd.groupId success:^(id response) {
        DDLogVerbose(@"Being kicked off group %@",cmd.groupId);
    } failure:^(NSError *error) {
        DDLogError(@"Being kicked off group error = %@",error);
    }];
}

- (void)processModifyGroupNameCommand:(MCIMCommandModel *)cmd
{
    MCIMGroupModel *group = [[MCIMGroupManager shared] getGroupWithGroupId:cmd.groupId];
    if (group) {
        group.groupName = cmd.groupName;
        [[MCIMGroupManager shared] updateGroup:group];
    }
}

@end
