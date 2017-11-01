//
//  MCServerAPI+testAccoount.m
//  NPushMail
//
//  Created by wuwenyu on 16/9/21.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCServerAPI+testAccoount.h"

@implementation MCServerAPI (testAccoount)

- (void)addMailToUser:(NSString *)user pwd:(NSString *)pwd email:(NSString *)email withPassword:(NSString *)password shouldValidate:(BOOL)shouldValidate success:(SuccessBlock)success failure:(FailureBlock)failure
{
    DDLogVerbose(@"[addMailToUser]");
    if (!user) {
        DDLogError(@"Cannot generate auth parameters, should login firstly");
        return;
    }
    
    NSTimeInterval timeStamp = [[NSDate new] timeIntervalSince1970];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:user forKey:@"d"];
    [params setObject:pwd forKey:@"p"];
    [params setObject:@(timeStamp) forKey:@"ts"];
    
    
    params[@"ae"] = [email lowercaseStringWithSpaceRemoved];
    params[@"ap"] = password;
    params[@"ev"] = shouldValidate ? @1 : @0;
    
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

@end
