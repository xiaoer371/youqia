//
//  MCMessageParser.h
//  NPushMail
//
//  Created by swhl on 16/1/21.
//  Copyright © 2016年 sprite. All rights reserved.
//

/**
 *  消息解析类
 */

#import <Foundation/Foundation.h>
#import "MCIMMessageModel.h"
#import "MCIMCommandModel.h"
#import "MCIMAppModel.h"
#import "MCIMImageModel.h"
#import "MCIMVoiceModel.h"
#import "MCIMFileModel.h"
#import "MCIMNewMailModel.h"
#import "MCIMOAMessageModel.h"

@interface MCMessageParser : NSObject

+ (MCIMDataModel *)createMesssageWithTopic:(NSString *)topic data:(NSData *)data;

+ (NSTimeInterval)parseTimeWithData:(NSData *)data;

+ (MCIMCommandModel *)newCommandWithData:(NSData *)data;

+ (MCIMMessageModel *)newMessageWithData:(NSData *)data;

@end
