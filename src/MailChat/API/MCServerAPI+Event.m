//
//  MCServerAPI+Event.m
//  NPushMail
//
//  Created by swhl on 16/12/15.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCServerAPI+Event.h"

@implementation MCServerAPI (Event)

- (void)checkEventWithEmail:(NSString *)e
                   success:(SuccessBlock)success
                   failure:(FailureBlock)failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[self authParameters]];
    params[@"e"] = e;
    [self.manager POST:@"app/event_check" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        DDLogDebug(@"%@",responseObject);
        BOOL result = [[responseObject objectForKey:@"result"] boolValue];
        if (result) {
            success(responseObject);
        }else{
            failure(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"%@",error);
        if (failure) {
            failure(error);
        }
    }];
}

@end
