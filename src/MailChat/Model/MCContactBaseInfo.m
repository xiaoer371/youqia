//
//  MCContactBaseInfo.m
//  NPushMail
//
//  Created by wuwenyu on 16/2/17.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCContactBaseInfo.h"

@implementation MCContactBaseInfo

- (id)initWithTitle:(NSString *)title value:(NSString *)value {
    self = [super init];
    if (self) {
        self.title = title;
        self.value = value;
    }
    return self;
}

@end
