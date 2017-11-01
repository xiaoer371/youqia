//
//  MCServerAPI+Launch.m
//  NPushMail
//
//  Created by swhl on 16/12/23.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCServerAPI+Launch.h"

@implementation MCServerAPI (Launch)

/*
 * 检查是否有 app开机启动资源
 * {result：1  res：{类型、是否更新、是否显示、资源下载路径}}
 *
 */
- (void)checkLaunchVersion:(NSString *)version
                   success:(SuccessBlock)success
                   failure:(FailureBlock)failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[self authParameters]];
    params[@"ver"] = version;
    params[@"os"] = @"ios";
    NSString *urlStr = [NSString stringWithFormat:@"https://new.mailchat.cn/app/startup"];
    ///TODO : 参数 路径
    [self.manager GET:urlStr parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        DDLogDebug(@"%@",responseObject);
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogError(@"%@",error);
        if (failure) {
            failure(error);
        }
    }];
}




@end
