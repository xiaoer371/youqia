//
//  MCShowBackButtonApi.m
//  NPushMail
//
//  Created by wuwenyu on 2017/1/16.
//  Copyright © 2017年 sprite. All rights reserved.
//

#import "MCShowBackButtonApi.h"

@implementation MCShowBackButtonApi

- (NSString *)name {
    return @"showBackButton";
}

- (void)processWithParameters:(id)params success:(JSSuccessBlock)success failure:(JSFailureBlock)failure {
    //0 : hide, 1 : show
    int status = [[params objectForKey:@"status"] intValue];
    switch (status) {
        case 0:
            //隐藏返回按钮
            break;
        case 1:
            //显示返回按钮
            break;
        default:
            break;
    }
}

@end
