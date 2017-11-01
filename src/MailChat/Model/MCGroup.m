//
//  MCGroup.m
//  NPushMail
//
//  Created by wuwenyu on 16/1/15.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCGroup.h"

@implementation MCGroup

- (id)initWithName:(NSString *)name withGroupId:(NSString *)groupId withSortId:(int32_t)sortId withMembers:(NSMutableArray *)members withSwitchFlag:(BOOL)flag {
    self = [super init];
    if (self) {
        self.name = name;
        self.groupId = groupId;
        self.sortId = sortId;
        self.members = members;
        self.switchFlag = flag;
    }
    return self;
}

@end
