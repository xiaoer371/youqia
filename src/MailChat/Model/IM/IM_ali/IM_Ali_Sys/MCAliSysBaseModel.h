//
//  MCAliSysBaseModel.h
//  NPushMail
//
//  Created by swhl on 16/12/9.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAliBaseModel.h"

typedef enum : NSUInteger {
    MCAliSysTypeHello  =0 ,  //小助手消息
    MCAliSysTypeMailValidation, //邮件认证消息
} MCAliSysType;

@interface MCAliSysBaseModel : MCAliBaseModel

@property (nonatomic, assign) MCAliSysType  type;


/**
 email 邮箱
 */
@property (nonatomic, strong) NSString    *email;

@end
