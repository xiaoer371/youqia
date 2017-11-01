//
//  MCOAWorkSpaceManager.m
//  NPushMail
//
//  Created by wuwenyu on 2017/2/9.
//  Copyright © 2017年 sprite. All rights reserved.
//

#import "MCOAWorkSpaceManager.h"
#import "MCAccountConfig.h"
#import "MCAppDelegate.h"
#import "MCOAConfig.h"
#import "MCAppSetting.h"
#import "MCTabBarController.h"
#import "MCWorkspaceViewController.h"
#import "MCAccountManager.h"
#import "MCAccountConfigTable.h"
#import "MCAccountDatabase.h"

@implementation MCOAWorkSpaceManager

+ (void)oaWorkSpaceCheckWithAccountConfig:(MCAccountConfig *)accountConfig {
    [self accesstokenExpireinProcessComplite:^(BOOL expirein) {
        if (expirein) {
            //重新登录
            [self loginOaWithDomin:accountConfig.oaDomin accountConfig:accountConfig success:^(id response) {
                MCOAConfig *oaConfig = (MCOAConfig *)response;
                BOOL needUnBinding = [self isUnBindingWithAccountConfig:oaConfig];
                if (!needUnBinding) {
                    if (oaConfig.oaUserLoginTypeType.errorcode == 12901) {
                        //密码错误,影响到workspace的刷新要处理
                        accountConfig.isFirstSyncOAUser = YES;
                        accountConfig.oaPassword = nil;
                        [self oaWorkSpaceShowCheckWithAccountConfig:accountConfig];
                    }else if (oaConfig.oaUserLoginTypeType.errorcode == 0){
                        DDLogVerbose(@"重新登录获取accesstoken成功");
                        [self oaWorkSpaceShowCheckWithAccountConfig:accountConfig];
                    }else {
                        accountConfig.isFirstSyncOAUser = YES;
                        accountConfig.oaPassword = nil;
                        [self oaWorkSpaceShowCheckWithAccountConfig:accountConfig];
                    }
                    
                }else {
                    //解绑了
                    accountConfig.isFirstSyncOAUser = YES;
                    accountConfig.oaPassword = nil;
                    MCAppDelegate *del = (MCAppDelegate*)[UIApplication sharedApplication].delegate;
                    UINavigationController *workSapceNav = del.tabBarController.workSpaceNav;
                    MCWorkspaceViewController *v = (MCWorkspaceViewController *)[workSapceNav.viewControllers firstObject];
                    [v oaUnBindingAlert];
                }
                
                
            } failrue:^(NSError *error) {
                DDLogWarn(@"oa登录失败:%@", error);
                accountConfig.isFirstSyncOAUser = YES;
                [self oaWorkSpaceShowCheckWithAccountConfig:accountConfig];
            }];
            
        }else {
            [self oaWorkSpaceShowCheckWithAccountConfig:accountConfig];
        }
    }];
}

+ (void)oaWorkSpaceShowCheckWithAccountConfig:(MCAccountConfig *)accountConfig {
    if (accountConfig.isFirstSyncOAUser) {
        if (accountConfig.hasWorkspace && accountConfig.oaPassword) {
            //是oa用户
            accountConfig.isOAUser = YES;
            MCAppDelegate *del = (MCAppDelegate*)[UIApplication sharedApplication].delegate;
            [del setTabbarWithWorkspaceFlag:AppSettings.isShowWorkspace];
            [self refreshWorkSpaceData];
        }else {
            //验证是否oa用户
            MCAppDelegate *del = (MCAppDelegate*)[UIApplication sharedApplication].delegate;
            //保留之前的OA工作台显示状态
            [del setTabbarWithWorkspaceFlag:accountConfig.isOAUser&&AppSettings.isShowWorkspace];
            MCAccount *currentAct = [MCAccount new];
            currentAct.email = AppStatus.currentUser.email;
            currentAct.password = AppStatus.currentUser.password;
            [ServerAPI isOaUserWithEmail:currentAct.email success:^(id response) {
                if (![currentAct.email isEqualToString:AppStatus.currentUser.email]) {
                    return;
                }
                MCOAConfig *oaConfig = (MCOAConfig *)response;
                if (oaConfig.isOaUser) {
                    if (oaConfig.isOaUser.oaUserFlag) {
                        [SVProgressHUD dismiss];
                        //是OA用户，不需要再验证和绑定了
                        accountConfig.hasWorkspace = YES;
                        accountConfig.isOAUser = YES;
                        accountConfig.oaUserType = 0;//OA用户
                        accountConfig.oaUserName = currentAct.email;
                        NSRange range = [accountConfig.oaUserName rangeOfString:@"@"];
                        if (range.location !=NSNotFound) {
                            accountConfig.oaDomin = [accountConfig.oaUserName substringFromIndex:(range.location + 1)];
                        }else{
                            DDLogInfo(@"OA 格式异常===%@",accountConfig.oaUserName);
                        }
                        accountConfig.oaPassword = currentAct.password;
                        MCAppDelegate *del = (MCAppDelegate*)[UIApplication sharedApplication].delegate;
                        if ([currentAct.email isEqualToString:AppStatus.currentUser.email]) {
                            //验证成功之后就登录oa，获取accesstoken
                            [self loginOaWithDomin:accountConfig.oaDomin accountConfig:accountConfig success:^(id response) {
                                MCOAConfig *oaConfig1 = (MCOAConfig *)response;
                                if (![currentAct.email isEqualToString:AppStatus.currentUser.email]) {
                                    return;
                                }
                                if (oaConfig1.oaUserLoginTypeType.errorcode == 0) {
                                    accountConfig.isFirstSyncOAUser = NO;
                                    [del setTabbarWithWorkspaceFlag:AppSettings.isShowWorkspace];
                                    [self refreshWorkSpaceData];
                                }else {
                                    //登录失败
                                    DDLogWarn(@"oa登录失败，错误码:%d", oaConfig1.oaUserLoginTypeType.errorcode);
                                }
                            } failrue:^(NSError *error) {
                                DDLogWarn(@"oa登录失败:%@", error);
                            }];
                        }
                    }else {
                        //若账号本身不直接是OA用户，再判断是否绑定OA账号，若绑定了也判定为OA用户
                        [self checkIsBindingOAWithEmail:currentAct.email accountConfig:accountConfig];
                    }
                }else {
                    [SVProgressHUD dismiss];
                    MCAppDelegate *del = (MCAppDelegate*)[UIApplication sharedApplication].delegate;
                    if ([currentAct.email isEqualToString:AppStatus.currentUser.email]) {
                        //显示之前的OA工作台权限
                        [del setTabbarWithWorkspaceFlag:accountConfig.isOAUser&&AppSettings.isShowWorkspace];
                    }
                }
                
            } failrue:^(NSError *error) {
                if (![currentAct.email isEqualToString:AppStatus.currentUser.email]) {
                    return;
                }
                [self checkIsBindingOAWithEmail:currentAct.email accountConfig:accountConfig];
            }];
        }
        
    }else {
        if (accountConfig.isOAUser) {
            //是oa用户
            MCAppDelegate *del = (MCAppDelegate*)[UIApplication sharedApplication].delegate;
            [del setTabbarWithWorkspaceFlag:AppSettings.isShowWorkspace];
            [self refreshWorkSpaceData];
        }else {
            MCAppDelegate *del = (MCAppDelegate*)[UIApplication sharedApplication].delegate;
            [del setTabbarWithWorkspaceFlag:NO];
        }
    }
}

+(void)checkIsBindingOAWithEmail:(NSString *)currentUser accountConfig:(MCAccountConfig *)actConfig {
    MCAppDelegate *del = (MCAppDelegate*)[UIApplication sharedApplication].delegate;
    [ServerAPI checkIsBindingOAWithEmail:currentUser success:^(id response) {
        [SVProgressHUD dismiss];
        MCOAConfig *oaConfig = (MCOAConfig *)response;
        actConfig.oaUserType =  1;
        
        if (oaConfig.checkBindingOa) {
            actConfig.oaDomin = oaConfig.checkBindingOa.oaDomin;
            actConfig.oaUserName = oaConfig.checkBindingOa.oaUserName;
            if (oaConfig.checkBindingOa.bindingOaFlag) {
                //绑定过OA了
                actConfig.isOAUser = YES;
                actConfig.isFirstSyncOAUser = NO;
                actConfig.hasWorkspace = YES;
                actConfig.oaUserType = 1;
            }
        }
        if ([currentUser isEqualToString:AppStatus.currentUser.email]) {
            [del setTabbarWithWorkspaceFlag:actConfig.isOAUser];
        }
        
    } failrue:^(NSError *error) {
        [SVProgressHUD dismiss];
        if ([currentUser isEqualToString:AppStatus.currentUser.email]) {
            [del setTabbarWithWorkspaceFlag:actConfig.isOAUser];
        }
    }];
    
}

+ (void)loginOaWithDomin:(NSString *)domin accountConfig:(MCAccountConfig *)accountConfig success:(SuccessBlock)success failrue:(FailureBlock)failure {
    [ServerAPI loginOaWithDomin:domin success:^(id response) {
        MCOAConfig *oaConfig = (MCOAConfig *)response;
        if (oaConfig.oaUserLoginTypeType.errorcode == 0) {
            accountConfig.oaUserIs35Mail = oaConfig.oaUserLoginTypeType.is35mail;
            accountConfig.oaAccesstoken = oaConfig.oaUserLoginTypeType.accesstoken;
            accountConfig.oaAccesstokenExpireinTime = oaConfig.oaUserLoginTypeType.expireinTime;
            accountConfig.oaAccesstokenCreatetime = oaConfig.oaUserLoginTypeType.createtime;
        }
        if (success) {
            success(oaConfig);
        }
    } failrue:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

//判断accesstoken是否过期,过期需重新登录获取.
+ (void)accesstokenExpireinProcessComplite:(expireinTime)expireinTimeBlock {
    MCAccountConfig *accountConfig = AppStatus.accountData.accountConfig;
    BOOL expirein = NO;
    if (accountConfig.oaAccesstokenCreatetime) {
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss.S";
        NSDate *createtime = [fmt dateFromString:accountConfig.oaAccesstokenCreatetime];
        if (!createtime) {
            fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            createtime = [fmt dateFromString:accountConfig.oaAccesstokenCreatetime];
        }
        NSTimeInterval timeInterval = -[createtime timeIntervalSinceNow];
        NSInteger expireinTime = accountConfig.oaAccesstokenExpireinTime;
        //过期前10分钟重新请求accesstoken
        if (timeInterval > (expireinTime - 10*60)) {
            expirein = YES;
        }else {
            expirein = NO;
        }
    }
    if (expireinTimeBlock) {
        expireinTimeBlock(expirein);
    }
}

+ (BOOL)isExistOaUserInLocalSpaceWithOaUserName:(NSString *)oaUserName {
    NSArray *accounts = [[MCAccountManager shared] getAllAccounts];
    __block BOOL isExist = NO;
    for (MCAccount *account in accounts) {
        MCAccountDatabase *accountDb = [[MCAccountDatabase alloc] initWithAccount:account];
        MCAccountConfigTable *db = [[MCAccountConfigTable alloc] initWithDbQueue:accountDb.dbQueue];
        MCAccountConfigModel *model = [db getModelWithKey:@"OAUserName"];
        if (model) {
            if (model.configValue) {
                if ([model.configValue isEqualToString:oaUserName]) {
                    isExist = YES;
                }
            }
        }
    }
    return isExist;
}

+ (NSString *)getOaUserNameWithAccount:(MCAccount *)act {
    MCAccountDatabase *accountDb = [[MCAccountDatabase alloc] initWithAccount:act];
    MCAccountConfigTable *db = [[MCAccountConfigTable alloc] initWithDbQueue:accountDb.dbQueue];
    NSString *oaUserName = nil;
    MCAccountConfigModel *model = [db getModelWithKey:@"OAUserName"];
    if (model) {
        if (model.configValue) {
            oaUserName = model.configValue;
        }
    }
    return oaUserName;
}

+ (BOOL)isUnBindingWithAccountConfig:(MCOAConfig *)oaConfig {
    BOOL needUnBinding = NO;
    MCAccountConfig *accountConfig = AppStatus.accountData.accountConfig;
    if (oaConfig.oaUserLoginTypeType.errorcode != 0) {
        return needUnBinding;
    }
    if (!oaConfig.oaUserLoginTypeType.is35mail) {
        if (oaConfig.oaUserLoginTypeType.bindmail) {
            if (oaConfig.oaUserLoginTypeType.bindmail.length == 0) {
                needUnBinding = YES;
            }
        }else {
            needUnBinding = YES;
        }
    }else {
        //判断是否是个人邮箱用户，如果是个人邮箱用户，然后返回的bindmail也为空，也是解绑了。
        if (accountConfig.oaUserType == 1) {
            if (oaConfig.oaUserLoginTypeType.bindmail) {
                if (oaConfig.oaUserLoginTypeType.bindmail.length == 0) {
                    needUnBinding = YES;
                }
            }else {
                needUnBinding = YES;
            }
            
        }
    }
    return needUnBinding;
    
}

+ (void)resetOaWorkSpaceStatusWithAccount:(MCAccount *)act {
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
