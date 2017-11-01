//
//  MCCallbackUtils.h
//  NPushMail
//
//  Created by admin on 4/5/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCCallbackUtils : NSObject

+ (void)reportSuccessOnMainThread:(SuccessBlock)successBlock withResponse:(id)response;
+ (void)reportErrorOnMainThread:(FailureBlock)failureBlock withError:(NSError *)error;

@end
