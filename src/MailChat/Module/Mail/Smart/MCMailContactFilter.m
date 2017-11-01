//
//  MCMailContactFilter.m
//  NPushMail
//
//  Created by admin on 9/22/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCMailContactFilter.h"
#import "MCContactManager.h"

@implementation MCMailContactFilter

- (BOOL)isImportantMail:(MCMailModel *)mail
{
    if (!mail.from.email) {
        return NO;
    }
    
    MCContactManager *contactMgr = [MCContactManager sharedInstance];
    
    if (!mail.fromUser) {
        mail.fromUser = [contactMgr getOrCreateContactWithEmail:mail.from.email name:mail.from.name];
    }
    
    if (mail.fromUser.importantFlag) {
        return YES;
    }

    // 不使用权重值进行判断
    if (mail.fromUser.weights >= kMailChatContactImportantWeight) {
        return YES;
    }
    
    // 是否是直接领导，直接领导发过来的邮件也是重要邮件
    if (contactMgr.leader && [mail.fromUser isEqual:contactMgr.leader]) {
        return YES;
    }
    
    // 单独主送给我的，并且发件人的权重大于 10的
    if (mail.to.count == 1) {
        MCMailAddress *addr = mail.to[0];
        NSString *myEmail = AppStatus.currentUser.email;
        if (![mail.from.email isEqualToString:myEmail] && [addr.email isEqualToString:myEmail] &&
            mail.fromUser.weights >= 10) {
            return YES;
        }
    }
    
    return NO;
}

@end
