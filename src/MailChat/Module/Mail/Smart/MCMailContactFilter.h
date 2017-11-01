//
//  MCMailContactFilter.h
//  NPushMail
//
//  Created by admin on 9/22/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCMailImportantProtocol.h"


/**
 根据发件人判断是否是重要邮件
 */
@interface MCMailContactFilter : NSObject<MCMailImportantProtocol>

- (BOOL)isImportantMail:(MCMailModel *)mail;

@end
