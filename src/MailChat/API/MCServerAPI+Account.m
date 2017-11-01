//
//  MCServerAPI+Account.m
//  NPushMail
//
//  Created by admin on 3/23/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCServerAPI+Account.h"
#import "NSString+Extension.h"

@implementation MCServerAPI (Account)

#pragma mark - User

- (void)authenticateUser:(NSString *)userName
                   password:(NSString *)password
                   clientId:(NSString *)clientId
                 deviceName:(NSString *)deviceName
                  apnsToken:(NSString *)apnsToken
                  clientVer:(NSString *)clientVer
                    success:(SuccessBlock)success
                    failure:(FailureBlock)failure
{
    
    NSTimeInterval timeStamp = [[NSDate new] timeIntervalSince1970];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"d"] = userName;
    params[@"p"] = password;
    params[@"ts"] = @(timeStamp);
    params[@"type"] = @"ios";
    params[@"name"] = deviceName;
    params[@"cid"] = clientId;
    params[@"to"] = apnsToken == nil ? @"" : apnsToken;
    params[@"push"] = @"apns";
    params[@"ver"] = clientVer;
    [self.manager POST:@"user/auth" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        DDLogDebug(@"%@",responseObject);
        if (success) {
            MCUserInfo *user = [self userWithResponse:responseObject];
            user.password = password;
            success(user);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"%@",error);
        if (failure) {
            failure(error);
        }
    }];
    
}

- (void)updateAPNSToken:(NSString *)token withClientId:(NSString *)clientId success:(ActionBlock)success failure:(FailureBlock)failure
{
    NSMutableDictionary *params = [self authParameters];
    params[@"cid"] = [clientId lowercaseString];
    params[@"to"] = token;
    NSString* clientVer = nil;
    NSString* versionStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (Debug_Flag == 1) {
        //debug版本
        clientVer = [NSString stringWithFormat:@"R:%@:D",versionStr];
    }else {
        //release版本
        clientVer = [NSString stringWithFormat:@"R:%@",versionStr];
    }
    params[@"ver"] = clientVer;
    [self.manager POST:@"user/update_client" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        DDLogDebug(@"%@",responseObject);
        if (success) {
            success();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"%@",error);
        if (failure) {
            failure(error);
        }
    }];
}


- (void)getAllEmailAccountsSuccess:(SuccessBlock)success failure:(FailureBlock)failure
{
    NSMutableDictionary *params = [self authParameters];
    [self.manager POST:@"user/emails" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        DDLogVerbose(@"%@",responseObject);
        BOOL result = [responseObject[@"result"] boolValue];
        if (result) {
            NSArray *accounts = [self accountArrayWithResponseObj:responseObject];
            if (success) {
                success(accounts);
            }
        }
        else{
            if (failure) {
                NSInteger code = [responseObject[@"code"] integerValue];
                NSError *error = [NSError errorWithDomain:kMCMailAPIErrorDomain code:code userInfo:nil];
                failure(error);
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getUserInfoUser:(NSString *)user deviceId:(NSString *)deviceId success:(SuccessBlock)success failure:(FailureBlock)failure {
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"user_id"] = user;
    params[@"device_id"] = deviceId;
    [self.manager POST:@"admin/all" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getAuthenticationStatusWithEmail:(NSString *)email success:(SuccessBlock)success failure:(FailureBlock)failure
{
    DDLogVerbose(@"[getAuthenticationStatusWithEmail]");
    NSMutableDictionary *params = [self authParameters];
    params[@"e"] = [email lowercaseStringWithSpaceRemoved];
    [self.manager POST:@"user/get_mail_status" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        DDLogVerbose(@"getAuthenticationStatusWithEmail response = %@",responseObject);
        BOOL result = [[responseObject objectForKey:@"result"] boolValue];
        if (result) {
            id status = responseObject[@"status"];
            if (success) {
                success(status);
            }
        }
        else{
            if (failure) {
                NSError *error = [self errorWithResponse:responseObject];
                failure(error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"[getAuthenticationStatusWithEmail] ERROR = %@",error);
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark - Mail

- (void)getMailConfigWithEmail:(NSString *)email
                   forceUpdate:(BOOL)forceUpdate
                       success:(SuccessBlock)success
                       failure:(FailureBlock)failure
{
    NSParameterAssert(email);
    
    NSDictionary *params = @{@"email" : email,
                             @"force" : @(forceUpdate)
                             };
    [self.manager GET:@"mail/mailsetting" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogVerbose(@"getMailConfigWithEmail response = %@",responseObject);
        NSInteger result = [[responseObject objectForKey:@"result"] integerValue];
        // Result = 1 不代表就有数据，
        if (result == 1) {
            if (responseObject[@"imap"] && responseObject[@"smtp"]) {
                if (success) {
                    MCMailConfig *config = [[MCMailConfig alloc] initWithDictionary:responseObject];
                    success(config);
                }
            }
            else{
                // 找不到配置数据
                NSError *error = [NSError errorWithDomain:kMCMailAPIErrorDomain code:1 userInfo:@{@"error" : @"Mail setting not found"}];
                if (failure) {
                    failure(error);
                }
            }
        }
        else{
            if (failure) {
                NSError *error = [self errorWithResponse:responseObject];
                failure(error);
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogError(@"getMailConfigWithEmail ERROR = %@",error);
        if (failure) {
            failure(error);
        }
    }];
}

- (void)updateMailConfig:(MCMailConfig *)config withEmail:(NSString *)email success:(SuccessBlock)success failure:(FailureBlock)failure
{
    NSMutableDictionary *params = [self authParameters];
    params[@"e"] = email;
    params[@"imap"] = [NSString stringWithFormat:@"%@|%d|%d",config.imap.hostName,(int)config.imap.port,(int)config.imap.ssl];
    params[@"smtp"] = [NSString stringWithFormat:@"%@|%d|%d",config.smtp.hostName,(int)config.smtp.port,(int)config.smtp.ssl];
    
    //编码
    //path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self.manager POST:@"mail/update_setting" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogVerbose(@"updateMailConfig response = %@",responseObject);
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogError(@"updateMailConfig ERROR = %@",error);
        if (failure) {
            failure(error);
        }
    }];
}

- (void)checkIs35Mail:(NSString *)email success:(SuccessBlock)success failrue:(FailureBlock)failure
{
    NSString *path = @"mail/check35";
    NSDictionary *params = @{@"email" : email};
    [self.manager GET:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogVerbose(@"checkIs35Mail response = %@",responseObject);
        NSInteger result = [[responseObject objectForKey:@"result"] integerValue];
        if (result) {
            MCMail35Info *info = [[MCMail35Info alloc] initWithDictionary:responseObject];
            if (success) {
                success(info);
            }
        }
        else{
            NSError *error = [self errorWithResponse:responseObject];
            if (failure) {
                failure(error);
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogError(@"[checkIs35Mail] ERROR = %@",error);
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getUserInfoWithEmail:(NSString *)email success:(SuccessBlock)success failrue:(FailureBlock)failure {
    NSString *path = @"user/email";
    NSMutableDictionary *params = [self authParameters];
    params[@"e"] = email;
    [self.manager GET:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogVerbose(@"[getUserInfoWithEmail] response = %@",responseObject);
        NSInteger result = [[responseObject objectForKey:@"result"] integerValue];
        if (result) {
            MCAccount *account = [self accountWithObj:responseObject];
            if (success) {
                success(account);
            }
        }
        else {
            if (failure) {
                NSError *error = [self errorWithResponse:responseObject];
                failure(error);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogError(@"[getUserInfoWithEmail] error = %@",error);
        failure(error);
    }];
    
}

- (void)addMailToUser:(NSString *)email withPassword:(NSString *)password authCode:(NSString *)authCode shouldValidate:(BOOL)shouldValidate success:(SuccessBlock)success failure:(FailureBlock)failure
{
    DDLogVerbose(@"[addMailToUser]");
    NSMutableDictionary *params = [self authParameters];
    params[@"ae"] = [email lowercaseStringWithSpaceRemoved];
    params[@"ap"] = password ?: @"";
    params[@"ev"] = shouldValidate ? @1 : @0;
    if (authCode.length > 0) {
        params[@"auth_code"] = authCode;
    }
    
    [self.manager POST:@"user/add_mail" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        DDLogVerbose(@"[addMailToUser] response = %@",responseObject);
        BOOL result = [[responseObject objectForKey:@"result"] boolValue];
        if (result) {
            if (success) {
                success(responseObject[@"status"]);
            }
        }
        else{
            if (failure) {
                NSError *error = [self errorWithResponse:responseObject];
                failure(error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"[addMailToUser] ERROR = %@",error);
        if (failure) {
            failure(error);
        }
    }];
}

- (void)deleteMail:(NSString *)email success:(ActionBlock)success failure:(FailureBlock)failure
{
    DDLogVerbose(@"[deleteMail]");
    NSMutableDictionary *params = [self authParameters];
    params[@"de"] = [email lowercaseStringWithSpaceRemoved];
    
    [self.manager POST:@"user/del_mail" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        DDLogVerbose(@"[deleteMail] response = %@",responseObject);
        BOOL result = [[responseObject objectForKey:@"result"] boolValue];
        if (result) {
            if (success) {
                success();
            }
        }
        else{
            if (failure) {
                NSError *error = [self errorWithResponse:responseObject];
                failure(error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"[deleteMail] ERROR = %@",error);
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark - Profile

- (void)updateAccount:(NSString *)email withNickName:(NSString *)nickName company:(NSString *)company department:(NSString *)department title:(NSString *)title success:(ActionBlock)success failure:(FailureBlock)failure
{
    DDLogVerbose(@"[updateAccount]");
    NSMutableDictionary *params = [self authParameters];
    params[@"e"] = [email lowercaseStringWithSpaceRemoved];
    params[@"na"] = nickName ?: @"";
    params[@"co"] = company ?: @"";
    params[@"de"] = department ?: @"";
    params[@"ti"] = title ?:@"";
    
    [self.manager POST:@"user/set_profile" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        DDLogVerbose(@"[updateAccount] response = %@",responseObject);
        BOOL result = [[responseObject objectForKey:@"result"] boolValue];
        if (result) {
            if (success) {
                success();
            }
        }
        else{
            if (failure) {
                NSError *error = [self errorWithResponse:responseObject];
                failure(error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"[updateAccount] ERROR = %@",error);
        if (failure) {
            failure(error);
        }
    }];
}

- (void)updateAccount:(NSString *)email avatar:(UIImage *)avatarImage success:(SuccessBlock)success failure:(FailureBlock)failure
{
    NSMutableDictionary *params = [self authParameters];
    params[@"e"] = email;
    
    [self.manager POST:@"/user/set_avatar" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSData *imageData = UIImageJPEGRepresentation(avatarImage, 0.75);
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg",[email mailName]];
        [formData appendPartWithFileData:imageData name:@"av" fileName:fileName mimeType:@"image/jpeg"];
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        DDLogVerbose(@"set avatar response = %@",responseObject);
        BOOL result = [responseObject[@"result"] boolValue];
        if (result) {
            if (success) {
                NSString *checksum = responseObject[@"checksum"];
                success(checksum);
            }
        }
        else{
            NSError *error = [self errorWithResponse:responseObject];
            if (failure) {
                failure(error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"set avatar error = %@",error);
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark - Private

- (MCUserInfo *)userWithResponse:(id)responseObj
{
    MCUserInfo *user = [MCUserInfo new];
    
    id json = responseObj[@"user"];
    user.serverId = json[@"_id"];
    //user.password = json[@"passwd"];  //这个是md5后的密码，对客户端来说没用
    user.userId = json[@"device_id"];
    user.userName = json[@"user_name"];
    user.registerDate = [self floatValueWithJsonValue:json[@"reg_date"]];
    user.createDate = [self floatValueWithJsonValue:json[@"create_date"]];
    
    return user;
}

- (CGFloat)floatValueWithJsonValue:(id)jsonValue
{
    if (!jsonValue || jsonValue == [NSNull null]) {
        return 0;
    }
    
    return [jsonValue floatValue];
}

- (NSArray *)accountArrayWithResponseObj:(id)responseObj
{
    NSArray *emails = responseObj[@"emails"];
    NSMutableArray *accounts = [[NSMutableArray alloc] initWithCapacity:emails.count];
    for (id obj in emails) {
        MCAccount *account = [self accountWithObj:obj];
        [accounts addObject:account];
    }
    return accounts;
}

- (MCAccount *)accountWithObj:(id)obj
{
    MCAccount *account = [MCAccount new];
    account.email = obj[@"email"];
    account.password = obj[@"passwd"];
    account.displayName = obj[@"name"];
    account.status = [obj[@"status"] integerValue] == 1 ? MCAccountStatusValidated : MCAccountStatusInitialized;
    account.avatar = obj[@"checksum"];
    
    return account;
}

@end
