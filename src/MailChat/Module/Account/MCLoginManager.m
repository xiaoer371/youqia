//
//  MCLoginManager.m
//  NPushMail
//
//  Created by admin on 1/15/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCLoginManager.h"
#import "MCAccountManager.h"
#import "MCMailConfig.h"
#import "NSString+Extension.h"
#import "MCServerAPI+Account.h"
#import "MCServerAPI+Stats.h"
#import "MCMailManager.h"
#import "MCMailConfigManager.h"
#import "MCAppSetting.h"
#import "MCUDID.h"
#import "MCNotificationCenter.h"
#import "MCCallbackUtils.h"
#import "MCAvatarHelper.h"
#import "MCIMservice.h"
#import "PCCircleViewConst.h"
#import "MCWorkSpaceManager.h"

NSString *const kMCLoginManagerChangeAccountKey = @"kMCLoginManagerChangeAccountKey";
NSString *const kMCAccountDefautSignature = @"发自邮洽";
NSString* const kMCAliyunMailServer = @"35.mailchat.cn";

@implementation MCLoginManager

#pragma mark - Public

- (BOOL)loginLastUser
{
    if (AppSettings.lastAccountId > 0){
        MCAccountManager *accountMgr = [MCAccountManager shared];
        MCAccount *account = [accountMgr accountWithId:AppSettings.lastAccountId];
        if (!account) {
            NSArray *allAccounts = [accountMgr getAllAccounts];
            account = allAccounts.firstObject;
        }
        
        if (account && [account.email isEmail]) {
            [self loginWithAccount:account];
            return YES;
        }
    }
    
    return NO;
}

+ (NSString *)getClientVer
{
    NSString *clientVer;
    NSString* versionStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (Debug_Flag == 1) {
        //debug版本
        clientVer = [NSString stringWithFormat:@"R:%@:D",versionStr];
    }else {
        //release版本
        clientVer = [NSString stringWithFormat:@"R:%@",versionStr];
    }
    return clientVer;
}

- (void)authenticateNewUserSuccess:(SuccessBlock)success failure:(FailureBlock)failure
{
    NSString *userId = [NSString stringWithFormat:@"iosu_%@",[MCUDID newUUID]];
    NSString *password = [MCUDID newUUID];
    NSString* clientVer = [[self class] getClientVer];
    NSString *deviceName = [[UIDevice currentDevice] name];
    [ServerAPI authenticateUser:userId password:password clientId:AppSettings.clientId deviceName:deviceName apnsToken:nil clientVer:clientVer success:^(MCUserInfo *user) {
        AppSettings.user = user;
        if (success) {
            success(user);
        }
        
    } failure:^(NSError *error){
        if (failure) {
            failure(error);
        }
    }];
}

- (void)authenticateUserSuccess:(SuccessBlock)success failure:(FailureBlock)failure
{
    if (!AppSettings.user) {
        [self authenticateNewUserSuccess:success failure:failure];
    }
    else{
        MCUserInfo *user = AppSettings.user;
        NSString* clientVer = [[self class] getClientVer];
        NSString *deviceName = [[UIDevice currentDevice] name];
        DDLogVerbose(@"[authenticateUser]");
        [ServerAPI authenticateUser:user.userId password:user.password clientId:AppSettings.clientId deviceName:deviceName apnsToken:AppSettings.apnsToken clientVer:clientVer success:success failure:failure];
    }
}


- (void)loginWithUserName:(NSString *)userName
                 password:(NSString *)password
                  success:(SuccessBlock)success
                  failure:(FailureBlock)failure
{
    [self loginWithUserName:userName password:password forceUpdate:NO success:success failure:failure];
}

- (void)loginWithUserName:(NSString *)userName
                 password:(NSString *)password
             customConfig:(MCMailConfig *)config
                  success:(SuccessBlock)success
                  failure:(FailureBlock)failure
{
    [self loginWithUserName:userName password:password mailConfig:config success:^(id response) {
        // 缓存配置
        [[MCMailConfigManager shared] saveMailConfig:config forMail:userName success:nil failure:nil];
        [MCCallbackUtils reportSuccessOnMainThread:success withResponse:response];
        
    } failure:^(NSError *error) {
        [MCCallbackUtils reportErrorOnMainThread:failure withError:error];
    }];
}

- (void)loginWithAccount:(MCAccount *)account
{
    MCAccount *oldAccount = AppStatus.currentUser;
    BOOL accountChanged = oldAccount != nil && oldAccount != account;
    
    NSAssert([[NSThread currentThread] isMainThread], @"Should be called in mail thread");
    // MQTT Service 的创建必须在主线程
    AppStatus.currentUser = account;
    AppSettings.lastAccountId = account.accountId;
    AppStatus.accountData = [[MCAccountData alloc] initWithAccount:account];
    DDLogDebug(@"Create account data");
    // 创建用户后就可以开始接收消息
    [AppStatus.accountData.imService run];
    
    BOOL isNewUser = [[MCAccountManager shared] isNewUser];
    // 匿名用户不发通知
    if (![account.email containsString:@"_$@"] && !isNewUser) {
        [MCNotificationCenter postNotification:MCNotificationDidChangeAccount object:account];
    }
}

- (void)logoutAccount:(MCAccount*)account Success:(SuccessBlock)success failure:(FailureBlock)failure
{
    [ServerAPI deleteMail:account.email success:^{
        NSMutableArray *allAccounts = [[[MCAccountManager shared] getAllAccounts] mutableCopy];
        //重置oa状态
        [MCWorkSpaceManager resetWorkSpaceStatusWithAccount:account];
        [[MCAccountManager shared] deleteAccount:account];
        [allAccounts removeObject:account];
        // 如果是当前用户，注销当前用户
        
        BOOL outCurrentUser = NO;
        if ([account.email isEqualToString:AppStatus.currentUser.email]) {
            outCurrentUser = YES;
            [self stopCurrentUser];
        }
        
        // 没有其它帐号了，关掉安全认证
        if (allAccounts.count == 0) {
            [AppSettings setGesturePasswordFlag:NO];
            [PCCircleViewConst saveGesture:nil Key:gestureOneSaveKey];
            [PCCircleViewConst saveGesture:nil Key:gestureFinalSaveKey];
            [AppSettings setTouchIdFlag:NO];
            AppSettings.lastAccountId = 0;
        }
        
        if (success) {
            success(@(outCurrentUser));
        }
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)loginAnonymousUserIfNeeded
{
    // 已经有登录用户，不需要再登录匿名用户了
    if (AppStatus.currentUser) {
        return;
    }
    
    MCAccount *account = [[MCAccount alloc] init];
    // 以 $@结尾的表示是匿名用户
    account.email = [NSString stringWithFormat:@"%@_$@",AppSettings.clientId];
    account.displayName = PMLocalizedStringWithKey(@"Anonymous");
    
    [self loginWithAccount:account];
}

- (BOOL)validateUserWithEmail:(NSString *)email password:(NSString *)password
{
    MCAccountManager *accountMgr = [MCAccountManager new];
    MCAccount *account = [accountMgr accountWithEmail:email];
    if (!account) {
        return NO;
    }
    
    return [account.password isEqualToString:password];
}

- (void)loginWithValidatedAccount:(MCAccount *)account success:(SuccessBlock)success failure:(FailureBlock)failure
{
    [self addEmailToUser:account.email
            withPassword:account.password
            orServerCode:account.serverCode
                 success:^{
                     // 不能用 weakSelf，这边没有循环引用
                     MCAccount *updatedAccount = [self createOrUpdateAccount:account];
                     [self loginWithAccount:updatedAccount];
                     [ServerAPI reportLoginStatus:YES withEmail:updatedAccount.email error:nil success:nil failure:nil];
                     if (success) {
                         success(updatedAccount);
                     }
                     
                 } failure:^(NSError *error) {
                     [ServerAPI reportLoginStatus:NO withEmail:account.email error:error success:nil failure:nil];
                     if (failure) {
                         failure(error);
                     }
                 }];
}

- (void)updateAccountInfo:(MCAccount *)newAccount success:(SuccessBlock)success failure:(FailureBlock)failure
{
    [self addEmailToUser:newAccount.email withPassword:newAccount.password orServerCode:newAccount.serverCode success:^{
        MCAccount *updatedAccount = [self createOrUpdateAccount:newAccount];
        if (success) {
            success(updatedAccount);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark - Private


- (void)loginWithUserName:(NSString *)userName
                 password:(NSString *)password
              forceUpdate:(BOOL)forceUpdate
                  success:(SuccessBlock)success
                  failure:(FailureBlock)failure
{
    if (!userName) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:kMailChatLoginErrorDomain code:MailChatLoginErrorCodeUnknown userInfo:@{@"error" : @"userName is nil"}];
            failure(error);
        }
        return;
    }
    
    //获取配置
    [[MCMailConfigManager shared] findMailConfigWithEmail:userName forceUpdate:forceUpdate success:^(MCMailConfig *config) {
        
        //找到配置，直接登录
        [self loginWithUserName:userName password:password mailConfig:config success:success failure:^(NSError *error) {
            // 配置不正确，强制更新配置再尝试一次
            if (!forceUpdate && error.code == 1 && [error.domain isEqualToString:@"MCOErrorDomain"]) {
                [self loginWithUserName:userName password:password forceUpdate:YES success:success failure:failure];
            }
            else {
                [MCCallbackUtils reportErrorOnMainThread:failure withError:error];
            }
        }];
        
    } failure:^(NSError *error) {
        //没有找到正确的配置，使用默认配置试试看
        MCMailConfig *defaultConfig = [MCMailConfigManager defaultConfigForMail:userName ssl:YES];
        [self loginWithUserName:userName password:password customConfig:defaultConfig success:success failure:failure];
    }];
}





- (void)stopCurrentUser
{
    if (AppStatus.accountData) {
        [AppStatus.accountData.imService stop];
        AppStatus.accountData = nil;
        AppStatus.currentUser = nil;
    }
}

- (void)loginWithUserName:(NSString *)userName password:(NSString *)password mailConfig:(MCMailConfig *)config success:(SuccessBlock)success failure:(FailureBlock)failure
{
    
    [MCMailManager loginWithUserName:userName password:password config:config success:^{

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __block NSError *lastError = nil;
            __block MCMail35Info *tfMailInfo = nil;
            __block BOOL authenticated = NO;
            dispatch_group_t group = dispatch_group_create();
            dispatch_group_enter(group);
            // 邮件服务器登录成功后，要把邮箱添加到当前用户中，才算所有的流程都走完
            [self checkUserSuccess:^(MCUserInfo *user) {
                // 登录成功后，把邮箱帐号添加到当前的账号系统中
                [ServerAPI addMailToUser:userName withPassword:password authCode:nil shouldValidate:NO success:^(id response) {
                    authenticated = [response boolValue];
                    dispatch_group_leave(group);
                } failure:^(NSError *error) {
                    // 已经绑定的不是错误，不需要重新绑定
                    if (error.code != MCAPIErrorCodeEmailAlreadyBinded) {
                        lastError = error;
                    }
                    dispatch_group_leave(group);
                }];
                
            } failure:^(NSError *error) {
                lastError = error;
                dispatch_group_leave(group);
            }];
            
            // 判断是否是35邮箱
            if (config.is35Mail || config.mailType == MCMailTypeUnknown || config.mailType == MCMailTypeOthers) {
                dispatch_group_enter(group);
                [ServerAPI checkIs35Mail:userName success:^(MCMail35Info *mailInfo) {
                    tfMailInfo = mailInfo;
                    config.mailType = mailInfo.isEIS ? MCMailType35_30 : MCMailType35_20;
                    dispatch_group_leave(group);
                } failrue:^(NSError *error) {
                    // 即使判断35邮箱错误，也不认为是登录错误，所以不设置错误信息
                    dispatch_group_leave(group);
                }];
            }
            
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
            
            if (lastError) {
                if (failure) {
                    failure(lastError);
                }
                [ServerAPI reportLoginStatus:NO withEmail:userName error:lastError success:nil failure:nil];
            }
            else{
                
                // 创建新账号
                MCAccount *account = [self createOrUpdateAccountWithUserName:userName password:password config:config tfMailInfo:tfMailInfo authenticated:authenticated];
                // 一定要在主线程切换账号，否则mqtt服务会有问题
                // 添加帐号的时候，要直接切换过去
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self loginWithAccount:account];
                    if (success) {
                        success(account);
                    }
                });
                
                [ServerAPI reportLoginStatus:YES withEmail:userName error:nil success:nil failure:nil];
            }
            
        });
        
    } failure:^(NSError *error) {
        [ServerAPI reportLoginStatus:NO withEmail:userName error:error success:nil failure:nil];
        [self switchToAliyunServerIfNeededWithError:error userName:userName password:password mailConfig:config success:success failure:failure];
    }];
    
}

- (void)checkUserSuccess:(SuccessBlock)success failure:(FailureBlock)failure
{
    if (AppSettings.user) {
        success(AppSettings.user);
        return;
    }
    
    [self authenticateNewUserSuccess:^(MCUserInfo *user) {
        if (success) {
            success(user);
        }
    } failure:failure];
    
}

- (void)addEmailToUser:(NSString *)email withPassword:(NSString *)password orServerCode:(NSString *)serverCode success:(ActionBlock)success failure:(FailureBlock)failure
{
    // 邮件服务器登录成功后，要把邮箱添加到当前用户中，才算所有的流程都走完
    [self checkUserSuccess:^(MCUserInfo *user) {
        // 登录成功后，把邮箱帐号添加到当前的账号系统中
        [ServerAPI addMailToUser:email withPassword:password authCode:serverCode shouldValidate:NO success:^(id response) {
            if (success) {
                success();
            }
        } failure:^(NSError *error) {
            // 已经绑定的不是错误，不需要重新绑定
            if (error.code == MCAPIErrorCodeEmailAlreadyBinded) {
                if (success) {
                    success();
                }
            }
            else {
                if (failure) {
                    failure(error);
                }
            }
        }];
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (MCAccount *)createOrUpdateAccountWithUserName:(NSString *)userName password:(NSString *)password config:(MCMailConfig *)config tfMailInfo:(MCMail35Info *)tfMailInfo  authenticated:(BOOL)authenticated
{
    
    MCAccount *account = [[MCAccountManager shared] accountWithEmail:userName];
    if (!account) {
        account = [[MCAccount alloc] init];
        account.email = userName;
        account.displayName = [account.email mailName];
        NSString *colorString = [MCAvatarHelper randomColorHexString];
        account.color = [UIColor colorWithHexString:colorString];
        account.password = password;
        account.isEIS = tfMailInfo.isEIS;
        account.status = authenticated ? MCAccountStatusValidated : MCAccountStatusInitialized;
        account.config = config;
        if (account.isEIS) {
            account.type = [tfMailInfo.version  isEqual: @"3.0"] ? MCMailType35_30 : MCMailType35_20;
        }
        [[MCAccountManager shared] insertAccount:account];
    }
    else{
        account.password = password;
        account.isEIS = tfMailInfo.isEIS;
        account.deleted = NO;
        account.status = authenticated ? MCAccountStatusValidated : MCAccountStatusInitialized;
        if (account.isEIS) {
            account.type = [tfMailInfo.version  isEqual: @"3.0"] ? MCMailType35_30 : MCMailType35_20;
        }
        account.config = config;
        [[MCAccountManager shared] updateAccount:account];
    }
    account.signature = kMCAccountDefautSignature;
    
    
    return account;
}

- (MCAccount *)createOrUpdateAccount:(MCAccount *)newAccount
{
    MCAccount *localAccount = [[MCAccountManager shared] accountWithEmail:newAccount.email];
    if (localAccount) {
        localAccount.authType = newAccount.authType;
        localAccount.authData = newAccount.authData;
        localAccount.password = newAccount.password;
        localAccount.config = newAccount.config;
        localAccount.displayName = newAccount.displayName;
        localAccount.deleted = NO;
        localAccount.status = MCAccountStatusValidated;
        [[MCAccountManager shared] updateAccount:localAccount];
    }
    else {
        [[MCAccountManager shared] insertAccount:newAccount];
        newAccount.status = MCAccountStatusValidated;
        localAccount = newAccount;
    }
    
    return localAccount;
}

// 登录失败的时候，判断是否是35邮箱，如果是就切换到阿里云的多线机房
- (void)switchToAliyunServerIfNeededWithError:(NSError *)error userName:(NSString *)userName password:(NSString *)password mailConfig:(MCMailConfig *)config success:(SuccessBlock)success failure:(FailureBlock)failure
{
    // A stable connection to the server could not be established
    if ([error.domain isEqualToString:@"MCOErrorDomain"] && error.code == 1
        && AppStatus.networkStatus != NotReachable
        && ![config.imap.hostName isEqualToString:kMCAliyunMailServer]) {
        [ServerAPI checkIs35Mail:userName success:^(MCMail35Info *info) {
            if (info.result == 1) {
                config.imap.hostName = kMCAliyunMailServer;
                config.smtp.hostName = kMCAliyunMailServer;
                [self loginWithUserName:userName password:password mailConfig:config success:success failure:failure];
            }
            else {
                if (failure) {
                    failure(error);
                }
            }
        } failrue:^(NSError *err) {
            if (failure) {
                failure(error);
            }
        }];
    }
    else {
        if (failure) {
            failure(error);
        }
    }
}


@end
