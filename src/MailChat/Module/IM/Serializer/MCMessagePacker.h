//
//  MCMessagePacker.h
//  NPushMail
//
//  Created by swhl on 16/1/21.
//  Copyright © 2016年 sprite. All rights reserved.
//


/**
 *  消息包装类
 */

#import <Foundation/Foundation.h>
#import "MCIMCommandModel.h"
#import "MCIMMessageModel.h"
#import "MCIMImageModel.h"
#import "MCIMFileModel.h"
#import "MCIMVoiceModel.h"

@interface MCMessagePacker : NSObject

#pragma mark - 系统消息

+ (NSDictionary *)dictionaryWithCommand:(MCIMCommandModel *)cmd;
+ (NSDictionary *)dictionaryWithMessage:(MCIMMessageModel *)msg;

#pragma mark - 单聊 群聊消息

@end
