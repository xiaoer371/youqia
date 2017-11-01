//
//  MCTouchIdHelper.m
//  NPushMail
//
//  Created by wuwenyu on 16/5/13.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCTouchIdHelper.h"
#import <LocalAuthentication/LAContext.h>
#import "MCAppSetting.h"

@interface MCTouchIdHelper()

@property (nonatomic, strong) LAContext *context;

@end

@implementation MCTouchIdHelper

+ (instancetype)shared
{
    static id instance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [MCTouchIdHelper new];
    });
    return instance;
}

- (void)verificationTouchIdWithOpenGesturePwd:(BOOL)gestureFlag title:(NSString *)title reply:(verficationToucIdReply)verficationReply {
    _context = [LAContext new];
    NSError *error;
    //判断设备是否支持使用TouchId
    if([_context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error])
    {
        [_context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:title reply:^(BOOL success, NSError *error) {
            if (verficationReply) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    verficationReply(success, error);
                });
                
            }
        }];
    }
    else
    {
        DDLogWarn(@"该设备不支持指纹解锁");
        verficationReply(NO, error);
    }
}

@end
