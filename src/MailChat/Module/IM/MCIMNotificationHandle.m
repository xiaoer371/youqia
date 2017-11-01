//
//  MCIMNotificationHandle.m
//  NPushMail
//
//  Created by admin on 7/13/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCIMNotificationHandle.h"
#import "MCIMNewMailModel.h"
#import "MCMailManager.h"
#import "MCNotificationCenter.h"

@implementation MCIMNotificationHandle

- (void)processData:(MCIMDataModel *)msg
{
    if (!msg || msg.serviceType != IMServiceTypeMailPush) {
        return;
    }
    
    MCIMNewMailModel *msgModel = (MCIMNewMailModel *)msg;
    MCMailModel *mail = [MCMailManager mailForNotification:msgModel.mailInfo];
    if (mail) {
        [MCNotificationCenter postNotification:MCNotificationDidReceiveMqttMailPush object:mail];
    }
}

@end
