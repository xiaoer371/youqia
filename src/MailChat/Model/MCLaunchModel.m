//
//  MCLaunchModel.m
//  NPushMail
//
//  Created by swhl on 17/2/14.
//  Copyright © 2017年 sprite. All rights reserved.
//

#import "MCLaunchModel.h"

@implementation MCLaunchModel

- (instancetype)initWithDictionary:(id)dict {
    self = [super init];
    if (self) {
        if (dict) {
            self.version = [dict objectForKey:@"version"]?:@"0";
            self.resources = [dict objectForKey:@"resources"];
            self.enter = [dict objectForKey:@"enter"];
            self.title = [dict objectForKey:@"title"];
            self.enable = [[dict objectForKey:@"enable"] boolValue];
            self.skip = [[dict objectForKey:@"skip"] boolValue];
            self.end = [[dict objectForKey:@"end"] floatValue];
            self.start = [[dict objectForKey:@"start"] floatValue];
            if ([[dict objectForKey:@"delay"] isKindOfClass:[NSString class]]) {
                self.delay = [[dict objectForKey:@"delay"] floatValue];
            }else self.delay = 5.0f;
            self.model = [[dict objectForKey:@"model"] integerValue];
            self.isDownLoad = [[dict objectForKey:@"isDownLoad"] boolValue];
        }
    }
    return self;
}

- (NSDictionary *)toJson
{
    return @{@"version" : @([self.version integerValue]),
             @"resources" : self.resources,
             @"enter" : self.enter,
             @"title" : self.title,
             @"enable" : @(self.enable),
             @"skip" : @(self.skip),
             @"end" : @(self.end),
             @"start" : @(self.start),
             @"delay" : @(self.delay),
             @"model" : @(self.model),
             @"isDownLoad":@(self.isDownLoad)
             };
}

@end
