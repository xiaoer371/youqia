//
//  MCWorkSpaceManager.m
//  NPushMail
//
//  Created by wuwenyu on 2017/2/9.
//  Copyright © 2017年 sprite. All rights reserved.
//

#import "MCWorkSpaceManager.h"
#import "MCAccountManager.h"
#import "MCAccountDatabase.h"
#import "MCAccountConfigTable.h"

@implementation MCWorkSpaceManager

#pragma mark - 检查工作台（总入口）
+ (void)workSpaceUserCheck {
    MCAccountConfig *accountConfig = AppStatus.accountData.accountConfig;
    MCAccount *currentAct = AppStatus.currentUser;
    BOOL isEis = currentAct.isEIS;
    if (isEis) {
        [MCEisWorkSpaceManager eisWorkSpaceCheckWithAccountConfig:accountConfig act:currentAct];
    }else {
        [MCOAWorkSpaceManager oaWorkSpaceCheckWithAccountConfig:accountConfig];
    }
}

+ (void)resetWorkSpaceStatusWithAccount:(MCAccount *)act {
    NSArray *accounts = [[MCAccountManager shared] getAllAccounts];
    for (MCAccount *account in accounts) {
        if ([act.email isEqualToString:account.email]) {
            MCAccountDatabase *accountDb = [[MCAccountDatabase alloc] initWithAccount:act];
            MCAccountConfigTable *db = [[MCAccountConfigTable alloc] initWithDbQueue:accountDb.dbQueue];
            [db delValueWithKey:@"isFirstSyncOAUser"];
            [db delValueWithKey:@"isOAUser"];
            [db delValueWithKey:@"oaUserIs35Mail"];
            [db delValueWithKey:@"isWorkspaceUser"];
            [db delValueWithKey:@"OADomain"];
            [db delValueWithKey:@"OAUserName"];
            [db delValueWithKey:@"OAPassword"];
            [db delValueWithKey:@"OAUserType"];
            [db delValueWithKey:@"OAAccesstokenCreatetime"];
            [db delValueWithKey:@"OAAccesstokenExpireinTime"];
            [db delValueWithKey:@"OAAccesstoken"];
        }
    }
}

@end
