//
//  MCServerAPI+Version.h
//  NPushMail
//
//  Created by zhang on 16/6/7.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCServerAPI.h"

@interface MCServerAPI (Version)

- (void)getAppVersionSuccess:(SuccessBlock)success failuer:(FailureBlock)failure;

/**
 新的检查更新接口
 
 @param params c=渠道名称&v=客户端版本
 optional
 _LOCALE_=语言
 中文zh_CN【默认】
 繁体 zh_TW
 英文 en
 @param success success description
 @param failure failure description
 */
- (void)getAppNewVersionWithParams:(NSDictionary *)params success:(SuccessBlock)success failuer:(FailureBlock)failure;


- (void)checkFeatureReleaseWithParams:(NSDictionary *)params success:(SuccessBlock)success failure:(FailureBlock)failure;

@end
