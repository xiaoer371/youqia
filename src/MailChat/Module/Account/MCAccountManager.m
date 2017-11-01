//
//  MCAccountManager.m
//  NPushMail
//
//  Created by admin on 12/29/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import "MCAccountManager.h"
#import "MCAccountTable.h"
#import "MCMailConfig.h"
#import "NSString+Extension.h"
#import "MCServerAPI.h"
#import "MCServerAPI+Account.h"
#import "MCMailManager.h"
#import "MCMailConfigManager.h"
#import "MCServerAPI+Event.h"


@interface MCAccountManager ()

@property (nonatomic,strong) MCAccountTable *accountDb;
@property (nonatomic,strong) NSMutableArray *accounts;

@end


@implementation MCAccountManager

- (instancetype)init
{
    if (self = [super init]) {
        _accountDb = [MCAccountTable new];
        _accounts = [[_accountDb allModels] mutableCopy];
    }
    
    return self;
}

+ (instancetype)shared
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MCAccountManager alloc] init];
    });
    
    return instance;
}

- (BOOL)isNewUser
{
    return self.accounts.count == 0;
}

#pragma mark - Server

- (void)updateAccountsSuccess:(SuccessBlock)success failure:(FailureBlock)failure
{
    [ServerAPI getAllEmailAccountsSuccess:^(id response) {
        [self syncAccounts:response];
        if (success) {
            success(response);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getAccountStatus:(MCAccount *)account success:(ActionBlock)success failure:(FailureBlock)failure
{
    [ServerAPI getAuthenticationStatusWithEmail:account.email success:^(id response) {
        BOOL authenticated = [response boolValue];
        account.status = authenticated ? MCAccountStatusValidated : MCAccountStatusInitialized;
        [self.accountDb updateModel:account];
        if (success) {
            success();
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)changeAccount:(MCAccount *)account avatar:(UIImage *)avatarImage success:(ActionBlock)success failure:(FailureBlock)failure
{
    [ServerAPI updateAccount:account.email avatar:avatarImage success:^(id response) {
        account.avatar = response;
        [self updateAccount:account];
        if (success) {
            success();
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)updateAccount:(MCAccount *)account withNickName:(NSString *)nickName company:(NSString *)company dept:(NSString *)dept title:(NSString *)title success:(ActionBlock)success failure:(FailureBlock)failure
{
    [ServerAPI updateAccount:account.email withNickName:nickName company:company department:dept title:title success:^{
        account.displayName = nickName;
        account.company = company;
        account.department = dept;
        account.title = title;
        [self updateAccount:account];
        if (success) {
            success();
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)updateAccountFromServer:(MCAccount *)account success:(SuccessBlock)success failure:(FailureBlock)failure
{
    [ServerAPI getUserInfoWithEmail:account.email success:^(MCAccount *serverAccount) {
        account.displayName = serverAccount.displayName;
        account.avatar = serverAccount.avatar;
        account.status = serverAccount.status;
        [self updateAccount:account];
        if (success) {
            success(account);
        }
        
    } failrue:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark - Local

- (NSArray *)getAllAccounts
{
    NSMutableArray *enableAccounts = [[NSMutableArray alloc] initWithCapacity:self.accounts.count];
    for (MCAccount *account in self.accounts) {
        if (!account.deleted) {
            [enableAccounts addObject:account];
        }
    }
    return enableAccounts;
}

- (NSArray *)getAllAccountsRemoveCurrrent
{
    NSMutableArray *enableAccounts = [[NSMutableArray alloc] initWithCapacity:self.accounts.count];
    for (MCAccount *account in self.accounts) {
        if (!account.deleted && ![account.email isEqualToString:AppStatus.currentUser.email]) {
            [enableAccounts addObject:account];
        }
    }
    return enableAccounts;
}



- (MCAccount *)accountWithId:(NSInteger)accountId
{
    for (MCAccount *account in self.accounts) {
        if (account.accountId == accountId) {
            return account;
        }
    }
    
    return nil;
}

- (MCAccount *)accountWithEmail:(NSString *)email
{
    for (MCAccount *account in self.accounts) {
        if ([account.email isEqualToString:email]) {
            return account;
        }
    }
    
    return nil;
}

- (void)insertAccount:(MCAccount *)account
{
    if (![self.accounts containsObject:account]) {
        [self.accounts addObject:account];
    }
    [_accountDb insertModel:account];
}

- (void)updateAccount:(MCAccount *)account
{
    [_accountDb updateModel:account];
}

- (void)deleteAccount:(MCAccount*)account {
    account.deleted = YES;
    [self.accountDb updateModel:account];
}

#pragma mark - Private

- (void)syncAccounts:(NSArray *)accounts
{
    NSArray *localAccounts = self.accounts;
    for (MCAccount *account in accounts) {
        NSInteger index = [localAccounts indexOfObject:account];
        if (index != NSNotFound) {
            MCAccount *localAccount = localAccounts[index];
            localAccount.password = account.password;
            localAccount.displayName = account.displayName;
            localAccount.status = account.status;
            localAccount.avatar = account.avatar;
            account.accountId = localAccount.accountId;
            account.deleted = account.deleted;
            [_accountDb updateModel:localAccount];
        }
        else{
            [[MCMailConfigManager shared] findMailConfigWithEmail:account.email forceUpdate:NO success:^(id response) {
                account.config = response;
                [_accountDb insertModel:account];
            } failure:^(NSError *error) {
                DDLogError(@"syncAccounts ERROR = %@",error);
            }];
        }
    }
    
}
- (void)checkEvent:(MCAccount *)account success:(SuccessBlock)success failure:(FailureBlock)failure
{
    [ServerAPI checkEventWithEmail:account.email success:^(id response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}


@end
