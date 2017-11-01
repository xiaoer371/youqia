//
//  MCContactBaseInfo.h
//  NPushMail
//
//  Created by wuwenyu on 16/2/17.
//  Copyright © 2016年 sprite. All rights reserved.
//  存放基础信息，如公司，部门等等。

#import <Foundation/Foundation.h>

@interface MCContactBaseInfo : NSObject
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *value;
- (id)initWithTitle:(NSString *)title value:(NSString *)value;

@end
