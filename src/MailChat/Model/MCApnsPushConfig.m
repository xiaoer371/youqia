//
//  MCApnsPushConfig.m
//  NPushMail
//
//  Created by wuwenyu on 16/12/7.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCApnsPushConfig.h"
#import "NSString+Extension.h"

@implementation MCApnsPushConfig

- (instancetype)initWithDictionary:(id)dict pushConfigType:(initPushConfigType)type {
    if (self = [super init]) {
        NSDictionary *dic = (NSDictionary *)dict;
        switch (type) {
            case pushDetailsType:
                self.detailsConfig = [[DetailsConfig alloc] initWithDictionary:dic];
                break;
            case pushUpdateType:{
                self.updateConfig = [[UpdateConfig alloc] initWithDictionary:dic];
                break;
            }
            default:
                break;
        }
    }
    return self;
}

@end

@implementation MCPushSettingModel

- (instancetype)initWithDictionary:(id)dict {
    if (self = [super init]) {
        self.appPush = [[dict objectForKey:@"app"] intValue];
        self.mailPush = [[dict objectForKey:@"mail"] intValue];
        self.msgPush = [[dict objectForKey:@"message"] intValue];
        self.detailsPush = [[dict objectForKey:@"push_detail"] intValue];
    }
    return self;
}

@end

@implementation DetailsConfig

- (instancetype)initWithDictionary:(id)dict {
    if (self = [super init]) {
        BOOL result = [[dict objectForKey:@"result"] boolValue];
        self.result = result;
        if (result) {
            NSDictionary *data = [dict objectForKey:@"data"];
            NSDictionary *ignoreInfo = [data objectForKey:@"ignore"];
            if (ignoreInfo) {
                self.ignoreInfo = ignoreInfo;
            }
            NSDictionary *settingInfo = [data objectForKey:@"setting"];
            self.globalSetting = [[MCPushSettingModel alloc] initWithDictionary:settingInfo];
            
            NSMutableArray *mailAccountSettings = [NSMutableArray new];
            for (NSString *settingKey in settingInfo.allKeys) {
                if ([settingKey isEmail]) {
                    MCPushSettingModel *settingModel = [[MCPushSettingModel alloc] initWithDictionary:[settingInfo objectForKey:settingKey]];
                    settingModel.email = settingKey;
                    //则是单邮箱配置
                    [mailAccountSettings addObject:settingModel];
                }
            }
            self.mailAccountPushSettings = [mailAccountSettings copy];
            
        }else {
            int errorCode = [[dict objectForKey:@"code"] intValue];
            NSString *errorMsg = [dict objectForKey:@"error"];
            if (errorCode) {
                self.errorCode = errorCode;
            }
            if (errorMsg) {
                self.errorMsg = errorMsg;
            }
        }
       
    }
    return self;
}

@end

@implementation UpdateConfig

- (instancetype)initWithDictionary:(id)dict {
    if (self = [super init]) {
        BOOL result = [[dict objectForKey:@"result"] boolValue];
        self.result = result;
        if (!result) {
            int errorCode = [[dict objectForKey:@"code"] intValue];
            NSString *errorMsg = [dict objectForKey:@"error"];
            if (errorCode) {
                self.errorCode = errorCode;
            }
            if (errorMsg) {
                self.errorMsg = errorMsg;
            }
        }
    }
    return self;
}

@end
