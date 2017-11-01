//
//  MCRecentContactsViewController.h
//  NPushMail
//
//  Created by wuwenyu on 16/4/6.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseSubViewController.h"
#import "MCContactDidSelectedContactBlock.h"

typedef enum : NSUInteger {
    ContactRecentsSourceType,           //最近联系人
    ContactPersonalSourceType,       //个人通讯录
    ContactEnterpriseSameDomin,      //第三方同域的企业联系人
} ContactSourceType;

@interface MCRecentContactsViewController : MCBaseSubViewController
- (id)initWithContactSourceType:(ContactSourceType)type didSelectedBlock:(ContactDidSelectedBlock)block;
- (void)loadDataSource;
@end
