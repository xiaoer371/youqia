//
//  MCIMOAMessageModel.m
//  NPushMail
//
//  Created by admin on 4/15/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCIMOAMessageModel.h"
#import "NSString+JSON.h"

@implementation MCIMOAMessageModel

- (MailChatConversationType)conversationType
{
    return MailChatConversationTypeApp;
}

- (IMMessageType)type
{
    return IMMessageTypeOA;
}

- (NSString *)shortDescription
{
    return self.title;
}

- (NSString *)content
{
    NSDictionary *json = @{@"app" : self.app,
                           @"toUser" : self.toUser,
                           @"title" : self.title,
                           @"oaType" : @(self.oaType),
                           @"eventId" : self.eventId,
                           @"url" : self.url,
                           @"extend" : self.extend ?: @""
                           };
    return [NSString jsonStringWithObject:json];
}

- (void)setContent:(NSString *)content
{
    [super setContent:content];
    
    if (content) {
        NSDictionary *json = [content toJson];
        self.app = json[@"app"];
        self.toUser = json[@"toUser"];
        self.title = json[@"title"];
        self.oaType = [json[@"oaType"] integerValue];
        self.eventId = json[@"eventId"];
        self.url = json[@"url"];
        self.extend = json[@"extend"];
    }
}

@end
