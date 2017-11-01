//
//  MCServerAPI+Launch.h
//  NPushMail
//
//  Created by swhl on 16/12/23.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCServerAPI.h"

@interface MCServerAPI (Launch)


/*
 * 检查是否有 app开机启动资源
 * {result：1  res：{类型、是否更新、是否显示、资源下载路径}}
 *
 */
- (void)checkLaunchVersion:(NSString *)version
                    success:(SuccessBlock)success
                    failure:(FailureBlock)failure;


@end
