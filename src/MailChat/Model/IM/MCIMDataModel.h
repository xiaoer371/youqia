//
//  MCIMDataModel.h
//  NPushMail
//
//  Created by admin on 4/7/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 消息格式类型
 */
typedef enum : NSUInteger {
    IMServiceTypeMsgData = 0,       // 正常的消息数据
    IMServiceTypeGroupCmd = 1,      // 加群减群命令等
    IMServiceTypeMailPush = 2,      // 邮件推送
} IMServiceType;

/**
 *  所有推送数据的基类
 */
@interface MCIMDataModel : NSObject

@property (nonatomic,assign) IMServiceType serviceType;

/**
 *  服务器的时间戳
 */
@property (nonatomic,assign) NSTimeInterval timeStamp;

@end
