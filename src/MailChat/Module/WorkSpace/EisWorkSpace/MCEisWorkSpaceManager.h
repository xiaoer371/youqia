//
//  MCEisWorkSpaceManager.h
//  NPushMail
//
//  Created by wuwenyu on 2017/2/9.
//  Copyright © 2017年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCWorkSpaceConstants.h"
#import "MCBaseWorkSpaceManager.h"

@interface MCEisWorkSpaceManager : MCBaseWorkSpaceManager

+ (void)accesstokenExpireinProcessComplite:(expireinTime)expireinTimeBlock;
+ (NSString *)getEisHomeUrl;
+ (void)reLoginEisWithAccountConfig:(MCAccountConfig *)accountConfig act:(MCAccount *)currentAct success:(SuccessBlock)success failrue:(FailureBlock)failure;
+ (void)eisWorkSpaceCheckWithAccountConfig:(MCAccountConfig *)accountConfig act:(MCAccount *)currentAct;

@end
