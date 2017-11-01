//
//  MCOAWorkSpaceManager.h
//  NPushMail
//
//  Created by wuwenyu on 2017/2/9.
//  Copyright © 2017年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCServerAPI+OA.h"
#import "MCWorkSpaceConstants.h"
#import "MCBaseWorkSpaceManager.h"

@class MCOAConfig;

@interface MCOAWorkSpaceManager : MCBaseWorkSpaceManager

+ (void)loginOaWithDomin:(NSString *)domin accountConfig:(MCAccountConfig *)accountConfig success:(SuccessBlock)success failrue:(FailureBlock)failure;
//判断本地是否存在oa账号了，若存在，则不允许重复登录
+ (BOOL)isExistOaUserInLocalSpaceWithOaUserName:(NSString *)oaUserName;
//获取OA账号
+ (NSString *)getOaUserNameWithAccount:(MCAccount *)act;
//判断是否是已经解绑
+ (BOOL)isUnBindingWithAccountConfig:(MCOAConfig *)oaConfig;
+ (void)oaWorkSpaceCheckWithAccountConfig:(MCAccountConfig *)accountConfig;
+ (void)oaWorkSpaceShowCheckWithAccountConfig:(MCAccountConfig *)accountConfig;
+ (void)accesstokenExpireinProcessComplite:(expireinTime)expireinTimeBlock;
+ (void)resetOaWorkSpaceStatusWithAccount:(MCAccount *)act;

@end
