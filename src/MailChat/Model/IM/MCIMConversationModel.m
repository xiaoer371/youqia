//
//  MCIMConversationModel.m
//  NPushMail
//
//  Created by admin on 2/22/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCIMConversationModel.h"

@implementation MCIMConversationModel

- (void)setLastMessage:(MCIMMessageModel *)lastMessage
{
    _lastMessage = lastMessage;
    self.peerId = lastMessage.peerId;
    self.lastMsgTime = lastMessage.time;
    self.content = [lastMessage shortDescription];
}

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    }
    
    if (![other isKindOfClass:self.class]) {
        return NO;
    }
    
    return [self.peerId isEqualToString:[other peerId]];
}

- (NSUInteger)hash
{
    return [self.peerId hash];
}

@end
