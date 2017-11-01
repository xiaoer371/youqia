//
//  MCOABindingEmailLoginViewController.h
//  NPushMail
//
//  Created by wuwenyu on 16/11/23.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCLoginViewController.h"
#import "MCOAConfig.h"

@interface MCOABindingEmailLoginViewController :MCLoginViewController

- (id)initWithOaConfig:(MCOAConfig *)oaConfig email:(NSString *)email password:(NSString *)password oaUserName:(NSString *)oaUserName oaPassword:(NSString *)oaPassword;

@end
