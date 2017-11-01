//
//  MCIMChatContactCellModel.m
//  NPushMail
//
//  Created by swhl on 16/3/1.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMChatContactCellModel.h"

#import "MCContactManager.h"

@implementation MCIMChatContactCellModel

+(MCIMChatContactCellModel*)contactModelWithConversationModel:(MCIMConversationModel *)conversation
{
    MCIMChatContactCellModel *model = [[MCIMChatContactCellModel alloc] init];
    model.account = conversation.peerId;
    model.name = conversation.peer.peerName;
    model.headerUrl = conversation.peer.avatarUrl;
    model.headerDefaule = [conversation.peer avatarPlaceHolder];
    model.type = MCModelStateMember;
    return model;
}

+(NSArray*)contactModelWithMembers:(NSArray *)members
{
    NSMutableArray *array =[[NSMutableArray alloc] initWithCapacity:members.count];
    for (MCIMGroupMember *member  in members) {
        MCIMChatContactCellModel *model = [[MCIMChatContactCellModel alloc] init];
        MCContactModel *contactModel =[[MCContactManager sharedInstance] getOrCreateContactWithEmail:member.userId name:member.userId];
        model.account = contactModel.account;
        model.name = contactModel.displayName;
        model.headerUrl = contactModel.headImageUrl;
        model.headerDefaule = contactModel.avatarPlaceHolder;
        
        if ([member isOwner]) {
            model.type = MCModelStateOwner;
        }else{
            model.type = MCModelStateMember;
        }
        
        if ( member.joinState == IMGroupMemberJoinStateWaiting  ) {
              model.type = MCModelStateNotJion;
        }
        [array addObject:model];
    }
    
    return array;
}

+(NSArray *)contactModelWithContactModels:(NSArray *)contacts
{
    NSMutableArray *array =[[NSMutableArray alloc] initWithCapacity:contacts.count];
    for ( MCContactModel *contactModel in contacts) {
        MCIMChatContactCellModel *model = [[MCIMChatContactCellModel alloc] init];
        model.account = contactModel.account;
        model.name = contactModel.displayName;
        model.headerUrl = contactModel.headImageUrl;
        model.headerDefaule = contactModel.avatarPlaceHolder;
        model.type = MCModelStateNotJion;
        [array addObject:model];
    }
    return array;
}

@end
