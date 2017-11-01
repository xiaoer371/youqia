//
//  MCJsFileConfig.m
//  NPushMail
//
//  Created by wuwenyu on 16/10/10.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCJsFileConfig.h"

@implementation MCJsFileConfig

- (instancetype)initWithDictionary:(id)dict {
    self = [super init];
    if (self) {
        if (dict) {
            self.jsUrl = [dict objectForKey:@"js"];
            self.jsVersion = [[dict objectForKey:@"hotfix-ver"] integerValue];
            self.md5 = [dict objectForKey:@"md5"];
            self.needRollBack = [[dict objectForKey:@"rollback"] boolValue];
            self.needUpdate = YES;
        }
    }
    return self;
}

@end
