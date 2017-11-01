//
//  MCEnterpriseContactCellItem.h
//  NPushMail
//
//  Created by wuwenyu on 16/1/13.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCBranchInfo;
@class MCContactModel;

static const CGFloat  branchItemOriginX = 19;
static const CGFloat  offsetX = 7.5;

@interface MCEnterpriseContactCellItem : NSObject
/**
 *  父id
 */
@property (nonatomic, copy) NSString *parentId;
/**
 *  创建的是部门的或者员工的类型item
 */
@property (nonatomic, copy) NSString  *type;
/**
 *  部门信息
 */
@property (nonatomic, copy) MCBranchInfo *branchInfo;
/**
 *  员工信息
 */
@property (nonatomic, copy) MCContactModel *employeeInfo;
/**
 *  子部门集合
 */
@property (nonatomic, copy) NSMutableArray *childrenBranchItems;
/**
 *  子员工集合
 */
@property (nonatomic, copy) NSMutableArray *childrenEmplyoeeItems;
@property (nonatomic, copy) NSMutableArray *childrenContactModels;

/**
 *  item层级（页面展开和收缩使用）
 */
@property (nonatomic, copy) NSString *itemLevel;
/**
 *  该部门是否处于展开状态
 */
@property (nonatomic) BOOL isOpen;
/**
 *  部门原点X
 */
@property (nonatomic, assign) CGFloat branchItemOriginX;
/**
 *  员工原点X
 */
@property (nonatomic, assign) CGFloat emplyoeeItemOriginX;
/**
 *  部门下有多少员工
 */
@property (nonatomic) int size;
- (id)initWithItemType:(NSString *)type parentId:(NSString *)parentid branchInfo:(MCBranchInfo *)branchInfoObj employeeInfo:(MCContactModel *)employeeInfoObj level:(NSString *)level isOpen:(BOOL)isopen;
- (id)initWithEmployeeInfo:(MCContactModel *)employeeInfoObj;

@end
