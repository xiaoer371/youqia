//
//  MCOABindingMailConfig.m
//  NPushMail
//
//  Created by wuwenyu on 16/11/23.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCOABindingMailConfig.h"

@implementation MCOABindingMailConfig

- (instancetype)initWithDictionary:(id)dict {
    if (self = [super init]) {
        NSDictionary *dic = (NSDictionary *)dict;
        int result = [[dic objectForKey:@"result"] intValue];
        if (result == 1) {
            //成功
            if ([dic objectForKey:@"email"]) {
                self.email = [dic objectForKey:@"email"];
            }else {
                DDLogVerbose(@"没有email字段或email为空,一般为OA绑定了其他邮箱");
            }
        }else {
            if ([dic objectForKey:@"code"]) {
                self.errorCode = [[dic objectForKey:@"code"] intValue];
            }
            if ([dic objectForKey:@"error"]) {
                self.errorMsg = [dic objectForKey:@"error"];
            }
        }
    }
    return self;

}

@end
