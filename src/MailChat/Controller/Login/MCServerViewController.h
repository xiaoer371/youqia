//
//  MCSerVerViewController.h
//  NPushMail
//
//  Created by zhang on 16/1/21.
//  Copyright © 2016年 sprite. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "MCAccount.h"

@interface MCSerVerSettingCell : UITableViewCell
@end

typedef void(^validationBlock)(MCAccount *accout);

#import "MCBaseSubViewController.h"

@interface MCServerViewController : MCBaseSubViewController
- (id)initWithAccount:(MCAccount*)mcAccount;
//- (id)initWithEmail:(NSString*)email passWord:(NSString*)passWord;
- (id)initWithEmail:(NSString *)email passWord:(NSString *)passWord validationComplete:(validationBlock)validationComplete;
@end
