//
//  MCServerAPI+EIS.m
//  NPushMail
//
//  Created by admin on 3/23/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCServerAPI+EIS.h"
#import "NSData+zlib.h"
#import "MCAppSetting.h"
#import "NSString+JSON.h"

static NSString* const kMCEisAPIErrorDomain = @"com.mailchat.error.mail-api";

@implementation MCServerAPI (EIS)

- (void)syncContacts:(NSArray *)contacts success:(SuccessBlock)success failure:(FailureBlock)failure
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] initWithCapacity:contacts.count];
    for (MCContactModel *contact in contacts) {
        [dataArray addObject:@{@"e" : contact.account,
                               @"ts" : @(contact.lastUpdateTime)}];
    }
    
    NSMutableDictionary *params = [self authParameters];
    params[@"e"] = [AppStatus.currentUser.email lowercaseStringWithSpaceRemoved];
    NSString *contactJsonString = [NSString jsonStringWithObject:@{ @"data" : dataArray }];
    params[@"data"] = contactJsonString;
    
    DDLogVerbose(@"Update contact parameters = %@",params);
    
    NSString *path = @"user/contacts";
    [self.manager POST:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if (responseObject) {
            if ([[responseObject objectForKey:@"result"] intValue] == 1) {
                if (success) {
                    MCContactInfoConfig *model = [[MCContactInfoConfig alloc] initWithDictionary:responseObject];
                    success(model);
                }else {
                    if (failure) {
                        DDLogWarn(@"%@",[responseObject objectForKey:@"error"]);
                        NSError *error = [NSError errorWithDomain:kMCEisAPIErrorDomain code:0 userInfo:@{@"error" : [responseObject objectForKey:@"error"]}];
                        failure(error);
                    }
                }
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogError(@"[synContactsInfoWithContacs] = %@",error);
        if (failure) {
            failure(error);
        }
    }];
    
}


- (void)getEnterpriseContactsWithEmail:(NSString *)email lastSyncTimestamp:(NSTimeInterval)lastTimestamp success:(SuccessBlock)success failrue:(FailureBlock)failure
{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:AppSettings.apiBaseUrl]];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"application/octet-stream", @"text/html",nil];
    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    policy.allowInvalidCertificates = YES;
    [policy setValidatesDomainName:NO];
    manager.securityPolicy = policy;
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30;
    NSString *path = @"user/eis";
    //u=用户名&p=密码&d=设备&ts=时间戳&e=邮箱
    NSMutableDictionary *params = [self authParameters];
    params[@"e"] = email;
    params[@"cache_ts"] = @(lastTimestamp);
    
    DDLogDebug(@"GET user/eis");
    
    [manager GET:path parameters:params success:^(NSURLSessionDataTask *task, id  responseObject) {
        
        NSDictionary *responseDic = nil;
        if ([task.response.MIMEType isEqualToString:@"application/json"]) {
            responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        }
        else {
            NSData* zlibData = [responseObject bbs_dataByInflatingWithError:nil];
            responseDic = [NSJSONSerialization JSONObjectWithData:zlibData options:0 error:nil];
        }
        
        if (!responseDic) {
            NSError *error = [NSError errorWithDomain:kMCEisAPIErrorDomain code:0 userInfo:@{@"error" : @"[getEnterpriseContactsWithEmail] parse response data error"}];
            failure(error);
            return;
        }
        
        BOOL disabled = [[responseDic objectForKey:@"disabled"] boolValue];
        if (disabled) {
            NSError *error = [NSError errorWithDomain:kMCEisAPIErrorDomain code:MCAPIErrorCodeEnterpriseContactDisabled userInfo:@{@"error" : @"管理员已关闭企业通讯录"}];
            failure(error);
            return;
        }
        
        int result = [[responseDic objectForKey:@"result"] intValue];
        if (result == 1) {
            if (success) {
                MCEnterpriseSyncConfig *model = [[MCEnterpriseSyncConfig alloc] initWithDictionary:responseDic];
                success(model);
            }
        }else{
            DDLogError(@"Response result error = %@",responseDic);
            if (failure) {
                NSError *error = [self errorWithResponse:responseDic];
                failure(error);
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogError(@"[getEnterpriseContactsWithEmail] = %@",error);
        failure(error);
    }];
}

@end
