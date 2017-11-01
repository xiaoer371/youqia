//
//  MCSelectedSubContactsViewController.h
//  NPushMail
//
//  Created by wuwenyu on 16/3/29.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseSubViewController.h"
#import "MCSelectedContactsBlock.h"

@class MCEnterpriseStructTree;
@interface MCSelectedSubContactsViewController : MCBaseSubViewController
/**
 *  初始化方法
 *
 *  @param group      当前分组或部门
 *  @param subBranchs 子部门
 *  @param type       从哪个页面进入的
 *
 *  @return
 */
- (id)initWithGroup:(id)group subBranchs:(NSArray *)subBranchs selectedBlock:(selectedModelsWithRefreshBlock)block formCtrlType:(SelectedContactType)type selectedModels:(NSArray *)selectedModels alreadyExistsModels:(NSArray *)models;
@property (nonatomic, strong) MCEnterpriseStructTree *tree;

@end
