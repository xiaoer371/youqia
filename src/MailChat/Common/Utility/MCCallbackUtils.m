//
//  MCCallbackUtils.m
//  NPushMail
//
//  Created by admin on 4/5/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCCallbackUtils.h"

@implementation MCCallbackUtils

+ (void)reportSuccessOnMainThread:(SuccessBlock)successBlock withResponse:(id)response
{
    if (!successBlock) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        successBlock(response);
    });
}

+ (void)reportErrorOnMainThread:(FailureBlock)failureBlock withError:(NSError *)error
{
    if (!failureBlock) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        failureBlock(error);
    });
    
}

@end
