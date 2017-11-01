//
//  MCJSApi.m
//  NPushMail
//
//  Created by admin on 3/24/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCJSApi.h"

@implementation MCJSApi

- (void)processWithParameters:(id)params success:(JSSuccessBlock)success failure:(JSFailureBlock)failure
{
    if (failure) {
        failure(@"Should implement method in subclass");
    }
}

@end
