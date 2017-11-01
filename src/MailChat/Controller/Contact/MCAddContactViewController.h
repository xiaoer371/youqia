//
//  MCAddContactViewController.h
//  NPushMail
//
//  Created by wuwenyu on 16/8/15.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseSubViewController.h"

/**
   编辑的类型
 */
typedef enum : NSUInteger {
    editContactInfo, //编辑联系人信息
    addContact, //增加联系人
} MCContactEditType;

@class MCContactModel;

@interface MCAddContactViewController : MCBaseSubViewController

- (id)initWithContactEditType:(MCContactEditType)type contactModel:(MCContactModel *)model;

@end
