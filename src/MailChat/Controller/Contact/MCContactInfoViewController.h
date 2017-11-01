//
//  MCContactInfoViewController.h
//  NPushMail
//
//  Created by wuwenyu on 16/1/5.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseSubViewController.h"

@class MCContactModel;
typedef enum : NSUInteger {
    fromChat,           //从聊天界面进来
    fromReadMail,       //从读信界面进来
    fromContact,        //从联系人界面进来
    fromOA,             //从oa界面进来
} lookContactType;

@interface MCContactInfoViewController : MCBaseSubViewController

/**
 *  初始化
 *
 *  @param lookContactType 从哪个界面进入查看的
 *  @param model           联系人Model
 *  @param canEditable     联系人是否可编辑
 *  @param isEnterprise    是否是企业联系人
 *
 *  @return self实例
 */
- (id)initFromType:(lookContactType)lookContactType contactModel:(MCContactModel *)model canEditable:(BOOL)canEditable isEnterprise:(BOOL)isEnterprise;

@end
