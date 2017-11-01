//
//  MCNotificationCenter.m
//  NPushMail
//
//  Created by admin on 3/14/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCNotificationCenter.h"
NSString* MCNotificationDidLogoutOtherAccount = @"com.mailchat.notify.logoutAccout";
NSString* MCNotificationDidChangeAccount = @"com.mailchat.notify.changeaccount";
NSString* MCNotificationDidReceiveMessage = @"com.mailchat.notify.receivemessage";
NSString* MCNotificationDidKickedOut = @"com.mailchat.notfy.KickedOut";
NSString* MCNotificationDidReceiveApnsMailPush = @"com.mailchat.notify.apns.mailpush";
NSString* MCNotificationDidReceiveMqttMailPush = @"com.mailchat.notify.mqtt.mailpush";
NSString* MCNotificationDeleteMessage = @"com.mailchat.notify.msg.delete";
NSString* MCNotificationSentMailFailure = @"com.mailchat.notify.sentMail.failure";
NSString* MCNotificationSelectedPendingBox = @"com.mailchat.notify.selectPendingBox";
NSString* MCNotificationContactMailStateChange = @"com.mailchat.notify.contactMailStateChange";
@implementation MCNotificationCenter

+ (void)postNotification:(NSString *)name object:(id)object
{
    [self postNotification:name object:object userInfo:nil];
}

+ (void)postNotification:(NSString *)name object:(id)object userInfo:(NSDictionary*)info {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        DDLogVerbose(@"Post notification with name %@ and object = %@",name,object);
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:object userInfo:info];
    });
}

@end
