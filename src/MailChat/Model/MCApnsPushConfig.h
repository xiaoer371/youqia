//
//  MCApnsPushConfig.h
//  NPushMail
//
//  Created by wuwenyu on 16/12/7.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
//初始化OA配置的类型
typedef NS_ENUM(NSInteger, initPushConfigType) {
    pushDetailsType = 0, //获取用户push配置
    pushUpdateType = 1,//push更新
};

#pragma mark - MCPushSettingModel

@interface MCPushSettingModel : NSObject

- (instancetype)initWithDictionary:(id)dict;

/**
 对应的邮箱
 */
@property(nonatomic, strong) NSString *email;
/**
 邮件推送开关，1为开启
 */
@property(nonatomic, assign) int mailPush;

/**
 消息推送开关，1位开启
 */
@property(nonatomic, assign) int msgPush;

/**
 是否推送详情
 */
@property(nonatomic, assign) int detailsPush;

/**
 应用推送
 */
@property(nonatomic, assign) int appPush;

@end

#pragma mark - DetailsConfig

@interface DetailsConfig : NSObject
/**
 结果
 */
@property(nonatomic, assign) BOOL result;

/**
 错误码
 */
@property(nonatomic, assign) int  errorCode;

/**
 错误信息
 */
@property(nonatomic, strong) NSString *errorMsg;

/**
 对话提醒过滤，邮箱-对话（群组ID或对方邮箱）"ignore":{"qiushzh@35.cn":["fb@mailchat.cn"] 有可能是多个邮箱,本地根据情况设置}
 */
@property(nonatomic, strong) NSDictionary *ignoreInfo;

/**
 推送全局配置
 */
@property(nonatomic, strong) MCPushSettingModel *globalSetting;
/**
 单个邮箱配置信息("qiushzh@35.cn":{"mail":"0","no_detail":"1","app":"0","message":"1"}有可能是多个邮箱,包存的为MCPushSettingModel对象在数组中)
 */
@property(nonatomic, strong) NSArray *mailAccountPushSettings;
- (instancetype)initWithDictionary:(id)dict;

@end

#pragma mark - UpdateConfig

@interface UpdateConfig : NSObject
/**
 结果
 */
@property(nonatomic, assign) BOOL result;

/**
 错误码
 */
@property(nonatomic, assign) int  errorCode;

/**
 错误信息
 */
@property(nonatomic, strong) NSString *errorMsg;
- (instancetype)initWithDictionary:(id)dict;

@end

#pragma mark - MCApnsPushConfig

@interface MCApnsPushConfig : NSObject

- (instancetype)initWithDictionary:(id)dict pushConfigType:(initPushConfigType)type;
@property(nonatomic ,strong) DetailsConfig *detailsConfig;
@property(nonatomic ,strong) UpdateConfig *updateConfig;

@end
