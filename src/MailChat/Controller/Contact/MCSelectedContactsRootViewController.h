//
//  MCSelectedContactsRootViewController.h
//  NPushMail
//
//  Created by wuwenyu on 16/3/29.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseSubViewController.h"
#import "MCSelectedContactsBlock.h"
#import "MCContactRootViewController.h"

@interface MCSelectedContactsRootViewController :MCContactRootViewController
/**
 *  初始化
 *
 *  @param block  选择回调
 *  @param type   从哪个页面进入
 *  @param models 传入已选择联系人
 *
 *  @return
 */
- (id)initWithSelectedModelsBlock:(SelectedModelsBlock)block selectedMsgGroupModelBlock:(SelectedMsgGroupModelBlock)msgGroupBlock formCtrlType:(SelectedContactType)type alreadyExistsModels:(NSArray *)models;

@end
