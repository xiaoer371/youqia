//
//  MCMailTagManager.m
//  NPushMail
//
//  Created by admin on 9/6/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCMailTagManager.h"
#import "MCContactManager.h"
#import "MCMailBoxSyncPool.h"
#import "MCMailBoxManager.h"
#import "MCMailImportantManager.h"

// 一进来要分析的已发送邮件数量
static NSInteger const kMailChatSentBoxAnalysisCount = 100;

@implementation MCMailTagManager

- (MCMailTags)mailTagForMail:(MCMailModel *)mail
{
    BOOL isImportant = [[MCMailImportantManager shared] checkIsImportantMail:mail];
    MCMailTags tag  = MCMailTagNone;
    if (isImportant) {
        tag |= MCMailTagImportant;
    }
    
    return tag;
}

- (void)analysisSentBox:(MCMailBox *)sentBox success:(ActionBlock)success failure:(FailureBlock)failure
{
    // 分析的已发送不用 MCMailBoxSyncPool，通常情况下不需要保留已发送的数据
    MCMailBoxSyncManager *syncManager = [[MCMailBoxSyncManager alloc] initWithMailBox:sentBox];
    [syncManager getLatestMailsWithWindowSize:kMailChatSentBoxAnalysisCount success:^(id response) {
        NSArray *sentMailList = (NSArray *)response;
        for (MCMailModel *mail in sentMailList) {
            [self analysisSentMail:mail];
        }
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                success();
            });
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            failure(error);
        });
    }];
}

#pragma mark - Private

- (void)analysisSentMail:(MCMailModel *)mail
{
    MCContactManager *contactMgr = [MCContactManager sharedInstance];
    for (MCMailAddress *to in mail.to) {
        MCContactModel *contact = [contactMgr getOrCreateContactWithEmail:to.email name:to.name];
        if (contact) {
            [contactMgr addWeight:kMailChatContactWeightNewMail toContact:contact];
        }
    }
    
    for (MCMailAddress *addr in mail.cc) {
        MCContactModel *contact = [contactMgr getOrCreateContactWithEmail:addr.email name:addr.name];
        if (contact) {
            [contactMgr addWeight:kMailChatContactWeightCc toContact:contact];
        }
    }
    
    for (MCMailAddress *addr in mail.bcc) {
        MCContactModel *contact = [contactMgr getOrCreateContactWithEmail:addr.email name:addr.name];
        if (contact) {
            [contactMgr addWeight:kMailChatContactWeightBcc toContact:contact];
        }
    }
}

@end
