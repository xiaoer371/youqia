//
//  MCIMCommandModel.h
//  NPushMail
//
//  Created by admin on 3/4/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCIMDataModel.h"

typedef enum : NSUInteger {
    MCIMCmdJoinGroup = 1,
    MCIMCmdDeleteGroup,
    MCIMCmdLeaveGroup,
    MCIMCmdModifyGroupName,
    MCIMCmdBeKickefOff,
    MCIMCmdOtherUserBeKickedOff
} MCIMCommand;

@interface MCIMCommandModel : MCIMDataModel

@property (nonatomic,assign) MCIMCommand cmd;

@property (nonatomic,copy) NSString *from;

@property (nonatomic,copy) NSString *messageId;

@property (nonatomic,copy) NSString *groupId;

/**
 *  新群组名称，当cmd 为 ModifyGroupName 的时候有效
 */
@property (nonatomic,copy) NSString *groupName;

/**
 *  被剔除群成员的email，当 cmd 为 MCIMCmdOtherUserBeKickedOff 有效
 */
@property (nonatomic,copy) NSString *kickedOffUserId;

@end
