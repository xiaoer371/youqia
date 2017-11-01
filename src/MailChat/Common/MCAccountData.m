//
//  MCAccountData.m
//  NPushMail
//
//  Created by admin on 5/10/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCAccountData.h"
#import "MCAccountDatabase.h"
#import "MCAccountConfig.h"
#import "MCContactManager.h"
#import "MCIMClient.h"
#import "MCIMService.h"
#import "MCIMConversationManager.h"
#import "MCIMGroupManager.h"
#import "MCAppSetting.h"
#import "MCIMMessageSender.h"
#import "MCDatabaseHelper.h"

@implementation MCAccountData
{
    MCAccountDatabase *_accountDb;
    MCAccountConfig *_accountConfig;
    MCContactManager *_contactManager;
    MCIMClient *_imClient;
    MCIMService *_imService;
    MCIMMessageSender *_imMessageSender;
    MCIMConversationManager *_imConversationManager;
    MCIMGroupManager *_imGroupManager;
}

- (instancetype)initWithAccount:(MCAccount *)account
{
    if (self = [super init]) {
        _account = account;
    }
    
    return self;
}

- (MCAccountDatabase *)accountDb
{
    if (!_accountDb) {
        _accountDb = [[MCDatabaseHelper shared] databaseWithAccount:_account];
    }
    
    return _accountDb;
}

- (MCAccountConfig *)accountConfig
{
    if (!_accountConfig) {
        _accountConfig = [[MCAccountConfig alloc] initWithAccount:_account];
    }
    
    return _accountConfig;
}

- (MCContactManager *)contactManager
{
    if (!_contactManager) {
        _contactManager = [[MCContactManager alloc] init];
    }
    
    return _contactManager;
}

- (MCIMClient *)imClient
{
    if (!_imClient) {
        NSString *clientId = [NSString stringWithFormat:@"ios_%@_%@",AppSettings.clientId, self.account.email];
        clientId = [clientId lowercaseString];
        _imClient = [[MCIMClient alloc] initWithClientId:clientId];
    }
    
    return _imClient;
}

- (MCIMService *)imService
{
    if (!_imService) {
        _imService = [[MCIMService alloc] initWithAccount:_account];
    }
    
    return _imService;
}

- (MCIMMessageSender *)imMessageSender
{
    if (!_imMessageSender) {
        _imMessageSender = [MCIMMessageSender new];
    }
    
    return _imMessageSender;
}

- (MCIMConversationManager *)imConversationManager
{
    if (!_imConversationManager) {
        _imConversationManager = [MCIMConversationManager new];
    }
    
    return _imConversationManager;
}

- (MCIMGroupManager *)imGroupManager
{
    if (!_imGroupManager) {
        _imGroupManager = [MCIMGroupManager new];
    }
    
    return _imGroupManager;
}

@end
