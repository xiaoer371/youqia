//
//  MCMailThreadFilter.m
//  NPushMail
//
//  Created by admin on 18/11/2016.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCMailThreadFilter.h"
#import "MCMailManager.h"
#import "MCMailSubject.h"
#import "MCMailBoxManager.h"

@implementation MCMailThreadFilter

- (BOOL)isImportantMail:(MCMailModel *)mail
{
    MCMailSubject *subject = [[MCMailSubject alloc] initWithSubject:mail.subject];
    if (!subject.isReply && !subject.isFoward) {
        return NO;
    }
    
    MCMailManager *mailMgr = [[MCMailManager alloc] init];
    MCMailModel *firstMail = [mailMgr getMailWithSubject:subject.realSubject box:mail.boxId];
    if (!firstMail) {
        return NO;
    }
    
    // 同主题的如果是重要的邮件，本身也是重要邮件
    if (firstMail.tags & MCMailTagImportant) {
        return YES;
    }
    
    // 我发送邮件的回复，也是重要邮件
    MCMailBoxManager *boxMgr = [[MCMailBoxManager alloc] init];
    MCMailBox *sentBox = [boxMgr getMailBoxWithAccount:mail.accountId type:MCMailFolderTypeSent];
    if (sentBox) {
        MCMailModel *sentMail = [mailMgr getMailWithSubject:subject.realSubject box:sentBox.uid];
        if (sentMail) {
            return YES;
        }
    }
    
    return NO;
}

@end
