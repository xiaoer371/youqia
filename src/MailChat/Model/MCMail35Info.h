//
//  MCMail35Info.h
//  NPushMail
//
//  Created by admin on 1/6/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  35 邮件的信息
 */
@interface MCMail35Info : NSObject

/**
 *  0 表示错误，1表示成功
 */
@property (nonatomic,assign) BOOL result;

/**
 *  是否是EIS 用户
 */
@property (nonatomic,assign) BOOL isEIS;

/**
 *  邮箱的版本
 */
@property (nonatomic,strong) NSString *version;

- (instancetype)initWithDictionary:(id)dict;

@end
