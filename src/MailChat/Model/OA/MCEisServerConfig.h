//
//  MCEisServerConfig.h
//  NPushMail
//
//  Created by wuwenyu on 2017/1/11.
//  Copyright © 2017年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

//初始化OA配置的类型
typedef NS_ENUM(NSInteger, initEisServerConfigType) {
    EisRouteType = 0, //路由信息
    EisTokenType = 1,//获取token
};

#pragma mark - MCEisRouteModel

@interface MCEisRouteModel : NSObject

@property(nonatomic, assign) NSInteger port;
@property(nonatomic, strong) NSString *serviceflag;
@property(nonatomic, strong) NSString *ip;
@property(nonatomic, strong) NSString *domain;

@end

#pragma mark - MCEisRouteConfig

@interface MCEisRouteConfig : NSObject

/**
 错误码
 0  操作正常
 1  ER数据库异常
 2  报文格式非法
 3  服务异常
 4  其它异常
 5  鉴权失败
 */
@property(nonatomic, assign) int errorCode;

/**
 错误信息
 */
@property(nonatomic, strong) NSString *message;

/**
 返回的对应的域的路由信息，数组里成员为字典，内为MCEisRouteModel对象.
 */
@property(nonatomic, strong) NSMutableArray *list;

/**
 流水号
 */
@property(nonatomic, strong) NSString *serialNumber;

- (instancetype)initWithDictionary:(id)dict;

@end

#pragma mark - MCEisTokenConfig
@interface MCEisTokenConfig : NSObject

@property(nonatomic, assign) int resultCode;
@property(nonatomic, strong) NSString *errorMsg;
@property(nonatomic, strong) NSString *token;
/**
 token剩余过期时间
 */
@property(nonatomic, assign) NSInteger expireTime;
- (instancetype)initWithDictionary:(id)dict;

@end

#pragma mark - MCEisServerConfig
@interface MCEisServerConfig : NSObject

@property(nonatomic, strong) MCEisRouteConfig *routeConfig;
@property(nonatomic, strong) MCEisTokenConfig *tokenConfig;
- (instancetype)initWithDictionary:(id)dict configType:(initEisServerConfigType)type;

@end
