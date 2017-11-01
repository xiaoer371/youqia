//
//  MCIMMessageModel.m
//  NPushMail
//
//  Created by swhl on 16/1/27.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMMessageModel.h"

@implementation MCIMMessageModel

- (IMServiceType)serviceType
{
    return IMServiceTypeMsgData;
}

- (NSString *)peerId
{
    if (self.conversationType == MailChatConversationTypeGroup ||
        self.isSender) {
        return self.to;
    }
    return self.from;
}

- (NSString *)shortDescription
{
    return self.content;
}

- (BOOL)isSender
{
    return [self.from isEqualToString:AppStatus.currentUser.email];
}


@end
