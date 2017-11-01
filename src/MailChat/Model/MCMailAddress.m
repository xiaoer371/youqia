//
//  MCMailAddress.m
//  NPushMail
//
//  Created by admin on 2/14/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCMailAddress.h"
#import "NSString+JSON.h"

@implementation MCMailAddress

- (instancetype)initWithJsonString:(NSString *)jsonStr
{
    id obj = [jsonStr toJson];
    return [self initWithJsonObject:obj];
}

- (instancetype)initWithJsonObject:(NSDictionary *)obj
{
    if (self = [super init]) {
        _name = [[obj objectForKey:@"name"] copy];
        _email = [[obj objectForKey:@"email"] copy];
    }
    return self;
}

- (NSDictionary *)toDictionary
{
    id name = self.name ? self.name : @"";
    id mail = self.email ? self.email : @"";
    
    return @{@"name" : name,
             @"email" : mail
             };
}

- (NSString *)toJsonString
{
    NSDictionary *json = [self toDictionary];
    return [NSString jsonStringWithObject:json];
}

- (BOOL)isEqual:(id)object {
    
    MCMailAddress *mailAddress = (MCMailAddress*)object;
    
    if (self == mailAddress) {
        return  YES;
    }
    if ([self.email isEqualToString:mailAddress.email]) {
        return  YES;
    }
    return NO;
}

@end
