//
//  MCNotificationCenter.h
//  NPushMail
//
//  Created by admin on 3/14/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString* MCNotificationDidLogoutOtherAccount;
extern NSString* MCNotificationDidChangeAccount;
extern NSString* MCNotificationDidReceiveMessage;
extern NSString* MCNotificationDidKickedOut;
extern NSString* MCNotificationDidReceiveApnsMailPush;
extern NSString* MCNotificationDidReceiveMqttMailPush;
extern NSString* MCNotificationDeleteMessage;
extern NSString* MCNotificationSentMailFailure;
extern NSString* MCNotificationSelectedPendingBox;
extern NSString* MCNotificationContactMailStateChange;

@interface MCNotificationCenter : NSObject

+ (void)postNotification:(NSString *)name object:(id)object;

+ (void)postNotification:(NSString *)name object:(id)object userInfo:(NSDictionary*)info;

@end
