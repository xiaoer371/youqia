//
//  MCApnsPush.m
//  NPushMail
//
//  Created by wuwenyu on 16/1/21.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCApnsPush.h"
#import "RSAEncrypt.h"
#import "GTMBase64.h"
#import "MCAccount.h"
#import "MCAccountManager.h"
#import "MCServerAPI+APNS.h"
#import "MCAppSetting.h"
#import "MCAccountDatabase.h"

static NSString* const needAlertMsgApnsKey = @"needAlertMsgApns";//是否需要消息提醒
static NSString* const needAlertMailApnsKey = @"needAlertMailApns";//是否需要邮件提醒
static NSString* const needAlertOAApnsKey = @"needAlertOAApns";//是否需要OA消息提醒
static NSString* const needAlertShowDetailApnsKey = @"needAlertShowDetailApns";//是否显示通知详情

@interface MCApnsPush ()

@property (nonatomic,copy) NSString *token;
@property (nonatomic,copy) NSString *clientId;

@end

@implementation MCApnsPush

- (instancetype)init
{
    if (self = [super init]) {
        _token = [AppSettings.apnsToken copy];
        _clientId = [AppSettings.clientId copy];
    }
    return self;
}

- (instancetype)initWithToken:(NSString *)token clientId:(NSString *)clientId
{
    if (self = [super init]) {
        _token = [token copy];
        _clientId = [clientId copy];
    }
    return self;
}


/**
 新接口
 */

- (void)getPushDetailsWithSuccess:(SuccessBlock)success failure:(FailureBlock)failure {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    if (![identifier isEqualToString:@"com.c35.ptc.pushmail"]) {
        return;
    }
    
    if (!self.token) {
        DDLogError(@"错误:token为空，未开启推送");
        if (failure) {
            failure(nil);
        }
        return;
    }
    
    if (!AppStatus.currentUser) {
        DDLogWarn(@"当前尚未有账号登录,不设置推送");
        return;
    }
    
    NSMutableDictionary *params = [ServerAPI authParameters];
    params[@"to"] = self.token;
    DDLogInfo(@"APNS PARAMETERS = %@",params);
    [ServerAPI getPushDetailsWithDic:params success:^(id response) {
        if (response) {
            DDLogInfo(@"获取推送设置详情成功");
            if (success) {
                success(response);
            }
        }
    } failrue:^(NSError *error) {
        DDLogInfo(@"获取推送设置详情失败%@", error);
        if (failure) {
            failure(error);
        }
    }];

}

- (void)updatePushSettingWithPushSettingModel:(MCPushSettingModel *)pushSettingModel  success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    if (![identifier isEqualToString:@"com.c35.ptc.pushmail"]) {
        return;
    }
    
    if (!self.token) {
        DDLogError(@"错误:token为空，未开启推送");
        if (failure) {
            failure(nil);
        }
        return;
    }
    
    if (!AppStatus.currentUser) {
        DDLogWarn(@"当前尚未有账号登录,不设置推送");
        return;
    }
    NSMutableDictionary *params = [ServerAPI authParameters];
    params[@"to"] = self.token;
    params[@"badge"] = [NSString stringWithFormat:@"%d", 0];
    if (pushSettingModel.email) {
        params[@"e"] = [pushSettingModel.email lowercaseStringWithSpaceRemoved];
    }
    params[@"mail"] = [NSString stringWithFormat:@"%d", pushSettingModel.mailPush];
    params[@"message"] = [NSString stringWithFormat:@"%d", pushSettingModel.msgPush];
    params[@"app"] = [NSString stringWithFormat:@"%d", pushSettingModel.appPush];
    params[@"nd"] = [NSString stringWithFormat:@"%d", pushSettingModel.detailsPush];
    
    [ServerAPI updatePushSettingWithDic:params success:^(id response) {
        if (response) {
            DDLogInfo(@"");
            if (success) {
                success(response);
            }
        }
    } failrue:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

-(void)setPushOnOrOffWithTopic:(NSString *)topic
                            on:(BOOL)onOrOff
                   resultBlock:(ResultBlock)result
{
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    if (![identifier isEqualToString:@"com.c35.ptc.pushmail"]) {
        return;
    }
    if (!self.token) {
        if (result) {
            result(NO);
        }
        return;
    }
    
    NSMutableDictionary *params = [ServerAPI authParameters];
    params[@"to"] = self.token;
    params[@"e"] = [AppStatus.currentUser.email lowercaseStringWithSpaceRemoved];
    params[@"op"] = [NSNumber numberWithBool:onOrOff];
    params[@"key"] = [topic lowercaseStringWithSpaceRemoved];
    
    [ServerAPI setTopicPushOnOrOffWithParameters:params success:^(id response) {
        //
        if (response) {
            int resultCode = [[response objectForKey:@"result"] intValue];
            if (resultCode == 1) {
                result(YES);
            }else {
                DDLogError(@"关闭MQTT_apns失败%@",[response objectForKey:@"err"]);
                result(NO);
            }
        }
    } failrue:^(NSError *error) {
        //
        result(NO);
    }];
}

//获取推送设置
- (MCPushSettingModel *)getPushSettingModelWithEmail:(NSString *)email {
    MCPushSettingModel *model = [MCPushSettingModel new];
    if (email) {
        NSArray *accounts = [[MCAccountManager shared] getAllAccounts];
        for (MCAccount *account in accounts) {
            if ([email isEqualToString:account.email]) {
                MCAccountDatabase *accountDb = [[MCAccountDatabase alloc] initWithAccount:account];
                [accountDb.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                    BOOL msgPushFlag = YES;
                    BOOL mailPushFlag = YES;
                    BOOL oaPushFlag = YES;
                    BOOL detailsFlag = YES;
                    FMResultSet *rs1 = [db executeQuery:@"SELECT * FROM AccountConfig WHERE configKey = ?", @"msgPushFlagKey"];
                    FMResultSet *rs2 = [db executeQuery:@"SELECT * FROM AccountConfig WHERE configKey = ?", @"mailPushFlagKey"];
                    FMResultSet *rs3 = [db executeQuery:@"SELECT * FROM AccountConfig WHERE configKey = ?", @"OAPushFlagKey"];
                    FMResultSet *rs4 = [db executeQuery:@"SELECT * FROM AccountConfig WHERE configKey = ?", @"pushDetailFlagKey"];
                    while ([rs1 next]) {
                        msgPushFlag = [[rs1 stringForColumn:@"configValue"] intValue];
                    }
                    while ([rs2 next]) {
                        mailPushFlag = [[rs2 stringForColumn:@"configValue"] intValue];
                    }
                    while ([rs3 next]) {
                        oaPushFlag = [[rs3 stringForColumn:@"configValue"] intValue];
                    }
                    while ([rs4 next]) {
                        detailsFlag = [[rs4 stringForColumn:@"configValue"] intValue];
                    }
                    model.msgPush = msgPushFlag;
                    model.mailPush = mailPushFlag;
                    model.appPush = oaPushFlag;
                    model.detailsPush = detailsFlag;
                }];
            }
        }
    }else {
        model.msgPush = AppSettings.msgPushFlag;
        model.mailPush = AppSettings.mailPushFlag;
        model.appPush = AppSettings.oaPushFlag;
        model.detailsPush = AppSettings.pushDetailFlag;
    }
    
    return model;
}

//设置推送设置
- (void)setPushSettingConfigWithSettingModel:(MCPushSettingModel *)model {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT , 0), ^{
        NSArray *accounts = [[MCAccountManager shared] getAllAccounts];
        for (MCAccount *account in accounts) {
            if ([model.email isEqualToString:account.email]) {
                MCAccountDatabase *accountDb = [[MCAccountDatabase alloc] initWithAccount:account];
                [accountDb.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                    FMResultSet *rs1 = [db executeQuery:@"SELECT * FROM AccountConfig WHERE configKey = ?", @"msgPushFlagKey"];
                    FMResultSet *rs2 = [db executeQuery:@"SELECT * FROM AccountConfig WHERE configKey = ?", @"mailPushFlagKey"];
                    FMResultSet *rs3 = [db executeQuery:@"SELECT * FROM AccountConfig WHERE configKey = ?", @"OAPushFlagKey"];
                    FMResultSet *rs4 = [db executeQuery:@"SELECT * FROM AccountConfig WHERE configKey = ?", @"pushDetailFlagKey"];
                    BOOL msgUpdate = [rs1 next];
                    BOOL mailUpdate = [rs2 next];
                    BOOL appUpdate = [rs3 next];
                    BOOL detailsUpdate = [rs4 next];
                    
//                    while ([rs1 next]) {
//                    }
//                    
//                    while ([rs2 next]) {
//                        
//                    }
//                    while ([rs3 next]) {
//                        
//                    }
//                    while ([rs4 next]) {
//                        
//                    }
                    
                    NSString *updateSql = @"UPDATE AccountConfig SET configValue = ? WHERE configKey = ?";
                    NSString *insertSql = @"INSERT INTO AccountConfig (configKey, configValue) VALUES (?,?)";

                    if (msgUpdate) {
                        [db executeUpdate:updateSql, @(model.msgPush), @"msgPushFlagKey"];
                    }else {
                        [db executeUpdate:insertSql, @"msgPushFlagKey", @(model.msgPush)];
                    }
                    
                    if (mailUpdate) {
                        [db executeUpdate:updateSql, @(model.mailPush), @"mailPushFlagKey"];
                    }else {
                        [db executeUpdate:insertSql, @"mailPushFlagKey", @(model.mailPush)];
                    }
                    
                    if (appUpdate) {
                        [db executeUpdate:updateSql, @(model.appPush), @"OAPushFlagKey"];
                    }else {
                        [db executeUpdate:insertSql, @"OAPushFlagKey", @(model.appPush)];
                    }
                    
                    if (detailsUpdate) {
                        [db executeUpdate:updateSql, @(model.detailsPush), @"pushDetailFlagKey"];
                    }else {
                        [db executeUpdate:insertSql, @"pushDetailFlagKey", @(model.detailsPush)];
                    }
                    
                }];
            }
        }
    });
}

+ (BOOL)isOaUserWithEmail:(NSString *)email {
    __block BOOL isOaUser = NO;
    NSArray *accounts = [[MCAccountManager shared] getAllAccounts];
    for (MCAccount *account in accounts) {
        if ([email isEqualToString:account.email]) {
            MCAccountDatabase *accountDb = [[MCAccountDatabase alloc] initWithAccount:account];
            [accountDb.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                FMResultSet *rs = [db executeQuery:@"SELECT * FROM AccountConfig WHERE configKey = ?", @"isOAUser"];
                while ([rs next]) {
                    isOaUser =  [[rs stringForColumn:@"configValue"] boolValue];
                }
            }];
        }
    }
    return isOaUser;
}

@end
