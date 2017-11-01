//
//  MCContactInfoConfig.m
//  NPushMail
//
//  Created by wuwenyu on 16/3/23.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCContactInfoConfig.h"
#import "MCContactModel.h"
#import "MCAvatarHelper.h"

@implementation MCContactInfoConfig

- (instancetype)initWithDictionary:(id)dict {
    if (self = [super init]) {
        NSDictionary *data = (NSDictionary *)dict;
        NSArray *contacts = [data objectForKey:@"data"];
        NSTimeInterval lastUpdateTime = [[data objectForKey:@"ts"] doubleValue];
        _infos = [self infosWithContacts:contacts lastUpdateTime:lastUpdateTime];
    }
    return self;
}

- (NSArray *)infosWithContacts:(NSArray *)contacts lastUpdateTime:(NSTimeInterval)lastUpdateTime {
    if ([contacts isEqual:[NSNull null]]) {
        return nil;
    }
    if (!contacts || contacts.count == 0) {
        return nil;
    }
    NSMutableArray *ary = [NSMutableArray new];
    for (NSDictionary *obj in contacts) {
        NSString *email = [obj valueForKey:@"email"];
        NSString *name = [obj valueForKey:@"name"];//昵称
        NSString *position = [obj valueForKey:@"title"];//职务
        NSString *departMent = [obj valueForKey:@"dep"];//部门
        NSString *company = [obj valueForKey:@"com"];//公司
        NSString *checksum = [obj valueForKey:@"checksum"];//图片的url后缀,加_s表示小图
        MCContactModel *model = [MCContactModel contactWithEmail:email emailNickName:email];
        model.youqiaNickName = name;
        model.company = company;
        model.position = position;
        model.enterpriseDepartMent = departMent;
        model.lastUpdateTime = lastUpdateTime;
        if (checksum) {
            model.headChecksum = checksum;
        }
        [ary addObject:model];
    }
    return [ary copy];
}

@end
