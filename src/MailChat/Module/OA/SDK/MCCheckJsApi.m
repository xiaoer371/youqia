//
//  MCCheckJsApi.m
//  NPushMail
//
//  Created by admin on 3/24/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCCheckJsApi.h"

@interface MCCheckJsApi ()

@property (nonatomic,weak) NSDictionary *supportMethods;

@end

@implementation MCCheckJsApi

- (instancetype)initWithHanlders:(NSDictionary *)handlers
{
    if (self = [super init]) {
        _supportMethods = handlers;
    }
    
    return self;
}

- (NSString *)name
{
    return @"checkjsapi";
}

- (void)processWithParameters:(id)params success:(JSSuccessBlock)success failure:(JSFailureBlock)failure
{
    NSArray *apiNames = [params objectForKey:@"jsApiList"];
    if (!apiNames) {
        if (failure) {
            failure(@"Invalid parameters");
        }
        return;
    }
    
    NSMutableDictionary *apiResult = [NSMutableDictionary new];
    for (NSString *name in apiNames) {
        NSString *lowerName = [name lowercaseString];
        if ([[self.supportMethods allKeys] containsObject:lowerName]) {
            [apiResult setObject:@(YES) forKey:name];
        }
        else{
            [apiResult setObject:@(NO) forKey:name];
        }
    }
    
    if (success) {
        success(@[apiResult]);
    }
    
}

@end
