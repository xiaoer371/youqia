//
//  MCOnFunctionApi.m
//  NPushMail
//
//  Created by gaoyq on 10/02/2017.
//  Copyright © 2017 sprite. All rights reserved.
//

#import "MCOnFunctionApi.h"

@interface MCOnFunctionApi ()

@property (nonatomic,strong) NSMutableDictionary *successCallbacks;
@property (nonatomic,strong) NSMutableDictionary *failureCallbacks;


@end

@implementation MCOnFunctionApi

- (instancetype)init
{
    self = [super init];
    if (self) {
        _successCallbacks = [NSMutableDictionary new];
        _failureCallbacks = [NSMutableDictionary new];
    }
    return self;
}

- (NSString *)name {
    return @"on";
}

- (void)processWithParameters:(id)params success:(JSSuccessBlock)success failure:(JSFailureBlock)failure {
    
    NSString *event = params[@"event"];
    if (success) {
        self.successCallbacks[event] = [success copy];
    }
    else {
        [self.successCallbacks removeObjectForKey:event];
    }
    
    if (failure) {
        self.failureCallbacks[event] = [failure copy];
    }
    else {
        [self.failureCallbacks removeObjectForKey:event];
    }
    
}

- (void)fireEvent:(NSString *)event withParameters:(id)parameters
{
    JSSuccessBlock success = (JSSuccessBlock)self.successCallbacks[event];
    if (success) {
        success(@[parameters]);
    }
}

@end
