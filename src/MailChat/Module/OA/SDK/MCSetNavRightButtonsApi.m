//
//  MCSetNavRightButtonsApi.m
//  NPushMail
//
//  Created by wuwenyu on 2017/1/16.
//  Copyright © 2017年 sprite. All rights reserved.
//

#import "MCSetNavRightButtonsApi.h"

@implementation MCSetNavRightButtonsApi

- (NSString *)name {
    return @"setnavrightbuttons";
}

- (void)processWithParameters:(id)params success:(JSSuccessBlock)success failure:(JSFailureBlock)failure {
    NSString *title = [params objectForKey:@"title"];
    NSString *btnId = [params objectForKey:@"id"];
    DDLogInfo(@"右边按钮标题:%@, ID:%@", title, btnId);
}

@end
