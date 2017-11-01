//
//  MCServerAPI+OA.m
//  NPushMail
//
//  Created by wuwenyu on 16/5/30.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCServerAPI+OA.h"
#import "RSAEncrypt.h"
#import "MCAccountConfig.h"
#import "GTMBase64.h"
#import "MCOAConfig.h"
#import "NSString+MKNetworkKitAdditions.h"
#import "MCOABindingMailConfig.h"
#import "MCEisServerConfig.h"
#import "NSString+JSON.h"

/**
 * oa相关URL
 * 规则：OA_BASE_URL_START+域名+OA_BASE_URL_END +p=加密信息；
 * *///
#define OA_BASE_URL_START @"http://"
#define OA_BASE_NEW_URL_END @"/outerPostAction.do?actionType=4005&msgType=NEW"//新建事务
#define OA_BASE_NEW_TRANS_URL_END @"/outerPostAction.do?actionType=4005&msgType=NEW_TRANS"//待办事务列表
#define OA_BASE_MYPASS_URL_END @"/outerPostAction.do?actionType=4005&msgType=MYPASS"//我办过的事务列表
#define OA_BASE_MYCREATE_URL_END @"/outerPostAction.do?actionType=4005&msgType=MYCREATE"//我发起的事务列表
#define OA_BASE_WORKOUTSIDE_URL_END @"/outerPostAction.do?actionType=4005&msgType=WQREG"//外勤签到
//#define OA_BASE_URL @"http://oa.35.cn/outerPostAction.do?actionType=4000&msgType=&toPage=webapp" //到主页的（需替换域名）
#define OA_BASE_URL @"http://oa.35.cn/outerPostAction.do?actionType=4005&msgType=" //到主页的（需替换域名）
/**
 流水号，自定义，服务端会返回相同的流水号回来
 */
#define EIS_SERIALNUMBER   @"201701111323"

/**
 EIS 授权码
 */
#define EIS_AUTHCODE @"B4DAE50FE9024196B95B166722CA4215"

@implementation MCServerAPI (OA)

- (NSString *)getOaResultUrlWithPayloadUrl:(NSString*)payloadUrl isMQTT:(BOOL)isMqtt withEndUrlType:(OAUrlType)oaUrlType {
    NSString *oaPublicParms = [self oaPublicParameters];
    NSString* baseUrl = payloadUrl;
    MCAccountConfig *accountConfig = AppStatus.accountData.accountConfig;
    if (isMqtt) {
        NSString* currentEmail = AppStatus.currentUser.email;
        NSString* domin = [currentEmail mailDomain];
        if (accountConfig.oaDomin) {
            domin = accountConfig.oaDomin;
        }
        domin = [self getOaDomin:domin];
        NSString* startAndDominStr = [OA_BASE_URL_START stringByAppendingFormat:@"%@",domin];
        switch (oaUrlType) {
            case OATrans:
                startAndDominStr = [startAndDominStr stringByAppendingFormat:@"%@", OA_BASE_NEW_TRANS_URL_END];
                break;
            case OAMypass:
                startAndDominStr = [startAndDominStr stringByAppendingFormat:@"%@", OA_BASE_MYPASS_URL_END];
                break;
            case OAMycreate:
                startAndDominStr = [startAndDominStr stringByAppendingFormat:@"%@", OA_BASE_MYCREATE_URL_END];
                break;
            case OANew:
                startAndDominStr = [startAndDominStr stringByAppendingFormat:@"%@", OA_BASE_NEW_URL_END];
            default:
                break;
        }
        baseUrl = startAndDominStr;
    }
    NSString* resultUrl = [baseUrl stringByAppendingFormat:@"&%@", oaPublicParms];
    return resultUrl;
}

- (NSString *)getOaHomePageResultUrl {
    NSString *useName = AppStatus.accountData.accountConfig.oaUserName;
    NSRange range = [useName rangeOfString:@"@"];
    NSString *domin = [self getOaDomin:[useName substringFromIndex:(range.location + 1)]];
    NSString* baseUrl = [OA_BASE_URL stringByReplacingOccurrencesOfString:@"oa.35.cn" withString:domin];
    NSString *oaPublicParms = [self oaPublicParameters];
    NSString* resultUrl = [baseUrl stringByAppendingFormat:@"&%@", oaPublicParms];
    return resultUrl;
}

//oa主页或者跳转各页面公共的参数
- (NSString *)oaPublicParameters {
    MCAccountConfig *actConfig = AppStatus.accountData.accountConfig;
    MCAccount* currentAccount = AppStatus.currentUser;
    NSString *useName = actConfig.oaUserName;
    NSString* appendStr = [@"oausername=" stringByAppendingFormat:@"%@", useName];
    if (!actConfig.oaAccesstoken) {
        DDLogError(@"错误:访问oa的accesstoken不存在");
    }
    appendStr = [appendStr stringByAppendingFormat:@"&accesstoken=%@", actConfig.oaAccesstoken];
    appendStr = [appendStr stringByAppendingFormat:@"&mail=%@", currentAccount.email];
    return appendStr;
}

- (NSString *)authenticateStrWithRSACerType:(RSACerType) type {
    MCAccount* currentAccount = AppStatus.currentUser;
    NSString* strTimestamp = [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]];
    NSString *useName = AppStatus.accountData.accountConfig.oaUserName;
    NSString *pwd = AppStatus.accountData.accountConfig.oaPassword;
    NSString* appendStr = [@"u=" stringByAppendingFormat:@"%@", [useName encodedString]];
    appendStr = [appendStr stringByAppendingFormat:@"&p=%@", [pwd encodedString]];
    appendStr = [appendStr stringByAppendingFormat:@"&t=%@", [strTimestamp encodedString]];
    appendStr = [appendStr stringByAppendingFormat:@"&m=%@", [currentAccount.email encodedString]];
    NSData* encryptData = [RSAEncrypt rsaEncryptString:appendStr withType:type];
    NSString* rsaUrl = [GTMBase64 stringByEncodingData:encryptData];
    return rsaUrl;
}

- (AFHTTPSessionManager *)afManager {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"application/octet-stream", @"text/html", @"text/plain", nil];
    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    policy.allowInvalidCertificates = YES;
    [policy setValidatesDomainName:NO];
    manager.securityPolicy = policy;
    manager.requestSerializer.timeoutInterval = 15;
    return manager;
}

-(void)isOaUserWithEmail:(NSString *)email success:(SuccessBlock)success failrue:(FailureBlock)failure {
    NSRange range = [email rangeOfString:@"@"];
    NSString *domin = [email substringFromIndex:(range.location + 1)];
    domin = [self getOaDomin:domin];
    NSString *url = [NSString stringWithFormat:@"http://%@/outerPostAction.do?actionType=4001&mail=%@", domin, email];
    
    AFHTTPSessionManager *manager = [self afManager];
    [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id  responseObject) {
        if (responseObject) {
            if (success) {
                MCOAConfig *oaConfig = [[MCOAConfig alloc] initWithDictionary:responseObject oaConfigType:IsOaUserType];
                if (oaConfig.oaUserLoginTypeType.accesstoken) {
                    AppStatus.accountData.accountConfig.oaAccesstoken = oaConfig.oaUserLoginTypeType.accesstoken;
                }
                success(oaConfig);
            }
        }else {
            failure(nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

- (void)checkIsBindingOAWithEmail:(NSString *)email success:(SuccessBlock)success failrue:(FailureBlock)failure {
    AFHTTPSessionManager *manager = [self afManager];
    NSString* url = [NSString stringWithFormat:@"http://vip01.oa.35.com/openportal/queryemailuser.35?email=%@", email];
    [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id  responseObject) {
        if (responseObject) {
            if ([[responseObject objectForKey:@"result"] intValue] == 0) {
                if (success) {
                    MCOAConfig *oaConfig = [[MCOAConfig alloc] initWithDictionary:responseObject oaConfigType:CheckIsBindingOaType];
                    success(oaConfig);
                }
            }else {
                failure(nil);
            }
           
        }else {
            failure(nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

- (void)getOAUserLoginTypeWithDomin:(NSString *)domin success:(SuccessBlock)success failrue:(FailureBlock)failure {
    domin = [self getOaDomin:domin];
    AFHTTPSessionManager *manager = [self afManager];
    NSString *rsaUrl = [self authenticateStrWithRSACerType:RSACerOA];
    NSString* url = [NSString stringWithFormat:@"http://%@/outerPostAction.do?actionType=4003&p=%@", domin, rsaUrl];
    
    [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id  responseObject) {
        if (responseObject) {
            if (success) {
                MCOAConfig *oaConfig = [[MCOAConfig alloc] initWithDictionary:responseObject oaConfigType:OAUserLoginTypeType];
                success(oaConfig);
            }
        }else {
            failure(nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

- (void)loginOaWithDomin:(NSString *)domin success:(SuccessBlock)success failrue:(FailureBlock)failure {
    domin = [self getOaDomin:domin];
    AFHTTPSessionManager *manager = [self afManager];
    NSString *rsaUrl = [self authenticateStrWithRSACerType:RSACerOA];
    NSString* url = [NSString stringWithFormat:@"http://%@/outerPostAction.do?actionType=4004&p=%@", domin, rsaUrl];
    
    [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id  responseObject) {
        if (responseObject) {
            if (success) {
                MCOAConfig *oaConfig = [[MCOAConfig alloc] initWithDictionary:responseObject oaConfigType:OAUserLoginTypeType];
                success(oaConfig);
            }
        }else {
            failure(nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];

}

- (void)loginOaWithUserName:(NSString *)userName password:(NSString *)pwd domin:(NSString *)domin success:(SuccessBlock)success failrue:(FailureBlock)failure {
    domin = [self getOaDomin:domin];
    AFHTTPSessionManager *manager = [self afManager];
    NSString* strTimestamp = [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]];
    NSString* appendStr = [@"u=" stringByAppendingFormat:@"%@", [userName encodedString]];
    appendStr = [appendStr stringByAppendingFormat:@"&p=%@", [pwd encodedString]];
    appendStr = [appendStr stringByAppendingFormat:@"&t=%@", [strTimestamp encodedString]];
    NSData* encryptData = [RSAEncrypt rsaEncryptString:appendStr withType:RSACerOA];
    NSString* rsaUrl = [GTMBase64 stringByEncodingData:encryptData];
    
    NSString* url = [NSString stringWithFormat:@"http://%@/outerPostAction.do?actionType=4004&p=%@", domin, rsaUrl];
    
    [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id  responseObject) {
        if (responseObject) {
            if (success) {
                MCOAConfig *oaConfig = [[MCOAConfig alloc] initWithDictionary:responseObject oaConfigType:OAUserLoginTypeType];
                success(oaConfig);
            }
        }else {
            failure(nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];

}

- (void)getOaBindingMailWithMail:(NSString *)mail oaUserName:(NSString *)userName oaPassword:(NSString *)pwd success:(SuccessBlock)success failrue:(FailureBlock)failure {
    NSMutableDictionary *params = [self authParameters];
    params[@"user"] = [userName lowercaseStringWithSpaceRemoved];
    params[@"pass"] = [pwd trim];
    if (mail) {
        [mail lowercaseStringWithSpaceRemoved];
    }
    params[@"mail"] = mail;
    
    [self.manager POST:@"user/oa_mail" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if (responseObject) {
            if (success) {
                MCOABindingMailConfig *oaBindingMailConfig = [[MCOABindingMailConfig alloc] initWithDictionary:responseObject];
                success(oaBindingMailConfig);
            }
        }else {
            failure(nil);
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];

}

- (NSString *)getOaDomin:(NSString *)domin {
    NSString *realDomin = [NSString stringWithFormat:@"oa.%@",domin];
    MCAccountConfig *accountConfig = AppStatus.accountData.accountConfig;
    if (accountConfig.oAProxyServer) {
        if ([accountConfig.oAProxyServer length] > 0) {
            realDomin = accountConfig.oAProxyServer;
        }
    }
    return realDomin;
}


/**
 获取EIS实际IP地址
 */
- (void)getEisRouteAddressWithSuccess:(SuccessBlock)success failrue:(FailureBlock)failure {
    AFHTTPSessionManager *manager = [self afManager];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strTimestamp = [formatter stringFromDate:[NSDate date]];
    NSString *signStr = [NSString stringWithFormat:@"%@%@%@", @"ER", strTimestamp, @"DS4rd3drsa^(~^7d"];
    NSString *sign = [signStr md5];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"ER" forHTTPHeaderField:@"clientid"];
    [manager.requestSerializer setValue:strTimestamp forHTTPHeaderField:@"timestamp"];
    [manager.requestSerializer setValue:sign forHTTPHeaderField:@"sign"];
    [manager.requestSerializer setValue:EIS_SERIALNUMBER forHTTPHeaderField:@"serialnumber"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"businesscode"] = @"ROUTE";
    params[@"opttype"] = @"2";
    params[@"serialnumber"] = EIS_SERIALNUMBER;
    NSString *domin = [AppStatus.currentUser.email mailDomain];
    if ([domin isEqualToString:@"35.cn"]) {
        domin = @"china-channel.com";
    }
    NSDictionary *dominDic = [NSDictionary dictionaryWithObject:domin forKey:@"domain"];
    params[@"list"] = @[dominDic];
    
    [manager POST:@"http://eis.35.com/ER/route" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if (responseObject) {
            if (success) {
                MCEisRouteConfig *eisConfig = [[MCEisRouteConfig alloc] initWithDictionary:responseObject];
                success(eisConfig);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getEisTokenWithAccount:(MCAccount *)act ip:(NSString *)ip success:(SuccessBlock)success failrue:(FailureBlock)failure {
    AFHTTPSessionManager *manager = [self afManager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSString *path = [NSString stringWithFormat:@"https://%@/domain/workbench/getToken", ip];
//    NSString *path = @"http://mail.sofia7.com/domain/workbench/getToken";
//    params[@"email"] = @"zhangjx1@testworkstation.com";
//    params[@"password"] = @"Aa654123";
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"email"] = act.email;
    params[@"password"] = act.password;
    params[@"authCode"] = EIS_AUTHCODE;
    [manager POST:path parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if (responseObject) {
            if (success) {
                MCEisTokenConfig *tokenConfig = [[MCEisTokenConfig alloc] initWithDictionary:responseObject];
                success(tokenConfig);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (NSString *)getEisHomeUrl {
    MCAccountConfig *accountConfig = AppStatus.accountData.accountConfig;
    NSString *resultUrl = [NSString stringWithFormat:@"http://%@/domain/workbench/home?", accountConfig.eisRouteIpAddress];
    resultUrl = [resultUrl stringByAppendingFormat:@"&token=%@", accountConfig.eisAccessToken];
    resultUrl = [resultUrl stringByAppendingFormat:@"&email=%@", AppStatus.currentUser.email];
    resultUrl = [resultUrl stringByAppendingFormat:@"&authCode=%@", EIS_AUTHCODE];
    return resultUrl;
}

@end
