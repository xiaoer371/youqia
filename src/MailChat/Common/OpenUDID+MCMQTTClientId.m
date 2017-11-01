//
//  OpenUDID+MCMQTTClientId.m
//  NPushMail
//
//  Created by swhl on 16/7/21.
//  Copyright © 2016年 sprite. All rights reserved.
//
#define serverName @"124.202.153.103"
#define appAccount @"NPushMail"

#import "OpenUDID+MCMQTTClientId.h"
#import "SSKeychain.h"

@implementation OpenUDID (MCMQTTClientId)

+ (NSString *)getSysUDID
{
    NSString *uuid =[self value];
    NSError *error =nil;
    NSString *password =[SSKeychain passwordForService:serverName account:appAccount error:&error];
    if ([error code]==errSecItemNotFound)
    {
        NSString *openuuid =[self value];
        [SSKeychain setPassword:openuuid forService:serverName account:appAccount error:&error];
        uuid =openuuid;
    }
    else
    {
        uuid =password;
    }
    return uuid;
}

+ (NSString *)uuidThatDifferentEvery
{
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}

@end
