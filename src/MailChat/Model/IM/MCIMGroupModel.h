//
//  MCIMGroupModel.h
//  NPushMail
//
//  Created by swhl on 16/1/27.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCIMPeerModelProtocol.h"

typedef enum : NSUInteger {
    IMGroupStateNormal,
    IMGroupStateDismissed,
} IMGroupState;

typedef enum : NSUInteger {
    IMGroupMemberJoinStateWaiting,
    IMGroupMemberJoinStateJoined,
    IMGroupMemberJoinStateLeaved,
} IMGroupMemberJoinState;

@class MCIMMemeber;

@interface MCIMGroupModel : NSObject <MCIMPeerModelProtocol>

@property (nonatomic,assign) NSInteger uid;
@property (nonatomic,strong) NSString *groupId;
@property (nonatomic,strong) NSString *groupName;
@property (nonatomic,copy) NSString *avatar;
@property (nonatomic,readonly) NSString *avatarUrl;
@property (nonatomic,assign) NSTimeInterval joinTime;

/**
 *  是否保存到联系人群组
 */
@property (nonatomic,assign) BOOL isSaved;

/**
 *  群组状态，是否解散。TODO: 定义确切的状态
 */
@property (nonatomic,assign) IMGroupState state;

@property (nonatomic,strong) NSArray *members;

@end


@interface MCIMGroupMember : NSObject

@property (nonatomic,assign) NSInteger uid;

@property (nonatomic,assign) NSInteger groupId;

@property (nonatomic,strong) NSString *userId;

/**
 *  在群组中的别名，可以为空
 */
@property (nonatomic,strong) NSString *nickName;

@property (nonatomic,assign) BOOL isOwner;

@property (nonatomic,assign) IMGroupMemberJoinState joinState;

@end