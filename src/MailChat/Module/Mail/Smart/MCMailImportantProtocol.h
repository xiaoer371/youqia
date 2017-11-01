//
//  MCMailImportantProtocol.h
//  NPushMail
//
//  Created by admin on 9/22/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCMailModel.h"

@protocol MCMailImportantProtocol <NSObject>


/**
 判断一封邮件是否是重要邮件
 
 @param mail 要判断的邮件
 
 @return 是否是重要邮件
 */
- (BOOL)isImportantMail:(MCMailModel *)mail;

@end
