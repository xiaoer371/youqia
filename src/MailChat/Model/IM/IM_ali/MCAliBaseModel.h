//
//  MCAliBaseModel.h
//  NPushMail
//
//  Created by swhl on 16/12/9.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    MCAliMsgIMTypeMsg         = 0,                // 聊天消息
    MCAliMsgIMTypeGroupCmd    = 1,                // 群命令（加人，减人等操作）
    MCAliMsgIMTypeSystem      = 2,                // 系统消息
} MCAliMsgIMType;

@interface MCAliBaseModel : NSObject

/**
 消息类型 。最外层，消息分类的type
 */
@property (nonatomic, assign) MCAliMsgIMType  imType;

@end
