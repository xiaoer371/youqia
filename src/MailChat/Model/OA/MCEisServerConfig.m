//
//  MCEisServerConfig.m
//  NPushMail
//
//  Created by wuwenyu on 2017/1/11.
//  Copyright © 2017年 sprite. All rights reserved.
//

#import "MCEisServerConfig.h"
#import "NSString+JSON.h"

@implementation MCEisRouteModel

@end

@implementation MCEisRouteConfig

- (instancetype)initWithDictionary:(id)dict {
    if (self = [super init]) {
        NSDictionary *dic = (NSDictionary *)dict;
        self.errorCode = [[dic objectForKey:@"code"] intValue];
        self.message = [dic objectForKey:@"message"];
        self.serialNumber = [dic objectForKey:@"serialnumber"];
        self.list = [NSMutableArray new];
        if (self.message) {
            DDLogInfo(@"EIS路由信息获取结果:%@", self.message);
        }
        if (self.errorCode == 0) {
            if ([dic objectForKey:@"list"]) {
                NSArray *list = [dic objectForKey:@"list"];
                if (list.count > 0) {
                    for (NSDictionary *routeDic in list) {
                        MCEisRouteModel *model = [MCEisRouteModel new];
                        model.port = [[routeDic objectForKey:@"port"] integerValue];
                        model.serviceflag = [routeDic objectForKey:@"serviceflag"];
                        model.domain = [routeDic objectForKey:@"domain"];
                        model.ip = [routeDic objectForKey:@"ip"];
                        [self.list addObject:model];
                    }
                }
            }
        }
    }
    return self;
}

@end

@implementation MCEisTokenConfig

- (instancetype)initWithDictionary:(id)dict {
    if (self = [super init]) {
        NSDictionary *dic = (NSDictionary *)dict;
        self.resultCode = [[dic objectForKey:@"resultCode"] intValue];
        self.errorMsg = [dic objectForKey:@"errorMsg"];
        if (self.errorMsg) {
            DDLogInfo(@"%@", self.errorMsg);
        }
//        NSString *dataJsonString = [dic objectForKey:@"data"];
//        if (dataJsonString) {
//            NSData *jsonData = [dataJsonString dataUsingEncoding:NSUTF8StringEncoding];
//            NSError *err;
//            NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:jsonData
//                                                                options:NSJSONReadingMutableContainers
//                                                                  error:&err];
//            if(err) {
//                DDLogInfo(@"json解析失败：%@",err);
//                return nil;    
//            }else {
//                self.token = [dataDic objectForKey:@"token"];
//                self.expireTime = [[dataDic objectForKey:@"expire"] integerValue];
//
//            }
//            
//        }
    }
    return self;
}

@end

@implementation MCEisServerConfig

- (instancetype)initWithDictionary:(id)dict configType:(initEisServerConfigType)type {
    if (self = [super init]) {
        NSDictionary *dic = (NSDictionary *)dict;
        switch (type) {
            case EisRouteType:
                self.routeConfig = [[MCEisRouteConfig alloc] initWithDictionary:dic];
                break;
            case EisTokenType:
                self.tokenConfig = [[MCEisTokenConfig alloc] initWithDictionary:dic];
                break;
            default:
                break;
        }
    }
    return self;
}

@end
