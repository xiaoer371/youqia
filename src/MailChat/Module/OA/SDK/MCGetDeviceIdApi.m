//
//  MCGetDeviceIdApi.m
//  NPushMail
//
//  Created by admin on 3/24/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCGetDeviceIdApi.h"
#import "MCAppSetting.h"

@implementation MCGetDeviceIdApi

- (NSString *)name
{
    return @"getdeviceid";
}

- (void)processWithParameters:(id)params success:(JSSuccessBlock)success failure:(JSFailureBlock)failure
{
    NSString *deviceId = AppSettings.clientId;
    if (success) {
        success(@[deviceId]);
    }
}

@end
