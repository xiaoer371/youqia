//
//  MCFileBaseModule.m
//  NPushMail
//
//  Created by wuwenyu on 15/12/29.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import "MCFileBaseModule.h"
#import "MCFileCore.h"

@implementation MCFileBaseModule {
    __weak MCFileCore *mWeakCore;
}

- (id)init {
    return [self initWithFileCore:nil];
}

- (id)initWithFileCore:(MCFileCore *)core {
    self = [super init];
    if (self) {
        mWeakCore = core;
    }
    return self;
}

- (MCFileCore *)getFileCore {
    return mWeakCore;
}

@end
