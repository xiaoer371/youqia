//
//  MCMail35Info.m
//  NPushMail
//
//  Created by admin on 1/6/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCMail35Info.h"

@implementation MCMail35Info

- (instancetype)initWithDictionary:(id)dict
{
    if (self = [super init]) {
        _result = [[dict objectForKey:@"result"] boolValue];
        if (_result) {
            _version = dict[@"version"];
            _isEIS = [_version isEqualToString:@"3.0"];
        }
    }
    
    return self;
}

@end
