//
//  MCFeatureReleaseConfig.m
//  NPushMail
//
//  Created by wuwenyu on 16/10/25.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCFeatureReleaseConfig.h"

@implementation MCFeatureReleaseConfig

- (instancetype)initWithDictionary:(id)dict {
    self = [super init];
    if (self) {
        if (dict) {
            NSDictionary *properties = [dict objectForKey:@"properties"];
            self.importantMailEnableFlag = [[properties objectForKey:@"smart-inbox"] boolValue];
            self.needRollBack = [[dict objectForKey:@"rollback"] boolValue];
        }
    }
    return self;
}

@end
