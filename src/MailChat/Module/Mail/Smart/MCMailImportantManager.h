//
//  MCMailImportantManager.h
//  NPushMail
//
//  Created by admin on 9/22/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCMailModel.h"


@interface MCMailImportantManager : NSObject

+ (instancetype)shared;


/**
 判断一封邮件是否是重要邮件
 
 @param mail 要判断的邮件
 
 @return 是否是重要邮件
 */
- (BOOL)checkIsImportantMail:(MCMailModel *)mail;

@end
