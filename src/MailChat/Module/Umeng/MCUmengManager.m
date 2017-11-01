//
//  MCUmengManager.m
//  NPushMail
//
//  Created by zhang on 15/12/29.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import "MCUmengManager.h"
#import <UMMobClick/MobClick.h>

@implementation MCUmengManager

+ (void)addEventWithKey:(NSString*)key{
    
    [MobClick event:key];
}

+ (void)addEventWithKey:(NSString*)key  label:(NSString *)string
{
    [MobClick event:key label:string];
}

+ (void)importantEvent:(NSString *)event
{
    [MobClick event:mc_mail_important attributes:@{@"action" : event}];
}

+ (void)folderChangeEvent:(NSString*)event {
    [MobClick event:mc_mail_folder attributes:@{@"action":event}];
}

+ (void)pushEvent:(NSString*)event {
    [MobClick event:mc_push attributes:@{@"action":event}];
}

+ (void)praiseEvent:(NSString*)event {
    [MobClick event:mc_praise attributes:@{@"action":event}];
}

+ (void)backlogEvent:(NSString *)event {
    [MobClick event:mc_mail_backlog attributes:@{@"action":event}];
}

+ (void)addEventWithKey:(NSString *)key attributes:(NSDictionary *)attributes
{
    [MobClick event:key attributes:attributes];
}


@end
