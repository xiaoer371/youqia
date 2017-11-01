//
//  MCMailImportantManager.m
//  NPushMail
//
//  Created by admin on 9/22/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCMailImportantManager.h"
#import "MCMailImportantProtocol.h"
#import "MCMailPriorityFilter.h"
#import "MCMailContactFilter.h"
#import "MCUmengManager.h"
#import "MCMailThreadFilter.h"

@interface MCMailImportantManager ()

@property (nonatomic,strong) NSArray *filters;

@end

@implementation MCMailImportantManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        MCMailPriorityFilter *filter1 = [MCMailPriorityFilter new];
        MCMailContactFilter *filter2 = [MCMailContactFilter new];
        MCMailThreadFilter *filter3 = [MCMailThreadFilter new];
        _filters = @[filter1,filter2,filter3];
    }
    return self;
}

+ (instancetype)shared
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [MCMailImportantManager new];
    });
    
    return instance;
}

- (BOOL)checkIsImportantMail:(MCMailModel *)mail
{
    if (mail.tags & MCMailTagImportant) {
        return YES;
    }
    
    for (id<MCMailImportantProtocol> filter in self.filters) {
        if ([filter isImportantMail:mail]) {
            DDLogDebug(@"[%ld] important mail",(long)mail.uid);
            [MCUmengManager importantEvent:mc_mail_important_count];
            if (!mail.isRead) {
                [MCUmengManager importantEvent:mc_mail_important_unread_count];
            }
            return YES;
        }
    }
    
    return NO;
}

@end
