//
//  MCFileBaseModule.h
//  NPushMail
//
//  Created by wuwenyu on 15/12/29.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCFileCore;
@interface MCFileBaseModule : NSObject

// 初始化
- (id)init;
- (id)initWithFileCore:(MCFileCore *)core;
- (MCFileCore *)getFileCore;

@end
