//
//  MCSetNavTitleApi.m
//  NPushMail
//
//  Created by wuwenyu on 2017/1/16.
//  Copyright © 2017年 sprite. All rights reserved.
//

#import "MCSetNavTitleApi.h"

@implementation MCSetNavTitleApi

- (NSString *)name {
    return @"setnavtitle";
}

- (void)processWithParameters:(id)params success:(JSSuccessBlock)success failure:(JSFailureBlock)failure {
    NSString *title = [params objectForKey:@"title"];
    DDLogInfo(@"设置导航栏标题为:%@", title);
}

@end
