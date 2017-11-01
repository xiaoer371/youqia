//
//  MCAliIMParser.h
//  NPushMail
//
//  Created by swhl on 16/12/9.
//  Copyright © 2016年 sprite. All rights reserved.
//

/**
 *   阿里云 消息解析类
 */
#import <Foundation/Foundation.h>
#import "MCAliBaseModel.h"

@interface MCAliIMParser : NSObject

+ (MCAliBaseModel *)parserAliMsgData:(NSData *)data;

@end
