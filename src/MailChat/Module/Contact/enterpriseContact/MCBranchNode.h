//
//  MCBranchNode.h
//  NPushMail
//
//  Created by wuwenyu on 16/1/13.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCBranchInfo;

@interface MCBranchNode : NSObject
/**
 *  部门id
 */
@property (nonatomic, copy) NSString        *branchId;
/**
 *  父亲id
 */
@property (nonatomic, copy) NSString        *parentId;
/**
 *  孩子部门节点
 */
@property (nonatomic, copy) NSMutableArray  *childrenBranch;
/**
 *  孩子员工节点
 */
@property (nonatomic, copy) NSMutableArray  *childrenEmplyoee;
/**
 *  部门信息
 */
@property (nonatomic, copy) MCBranchInfo *branchInfo;
/**
 *  节点层级
 */
@property (nonatomic, copy) NSString   *nodeLevel;
/**
 *  排序id
 */
@property (nonatomic, copy) NSString   *sortId;
/**
 *  递归标记
 */
@property (nonatomic)       BOOL       recursiveFlag;
- (id)initBranchNodeWith:(MCBranchInfo *)  branchInfoObj;

@end
