//
//  MCUserInfo.m
//  NPushMail
//
//  Created by admin on 3/25/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCUserInfo.h"

@implementation MCUserInfo

- (instancetype)initWithJson:(id)json
{
    if (self = [super init]) {
        _serverId = [json[@"serverId"] copy];
        _userId = [json[@"userId"] copy];
        _userName = [json[@"userName"] copy];
        _password = [json[@"password"] copy];
        _registerDate = [json[@"registerDate"] doubleValue];
        _createDate = [json[@"createDate"] doubleValue];
    }
    
    return self;
}

- (NSDictionary *)toJson
{
    return @{@"serverId" : self.serverId,
             @"userId" : self.userId,
             @"userName" : self.userName,
             @"password" : self.password,
             @"registerDate" : @(self.registerDate),
             @"createDate" : @(self.createDate)
             };
}

@end
