//
//  MCEnterpriseStructTree.h
//  NPushMail
//
//  Created by wuwenyu on 16/1/13.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCBranchNode;

@interface MCEnterpriseStructTree : NSObject
/**
 *  根节点,用于递归得出每个节点的level
 */
@property(nonatomic, copy) MCBranchNode *rootNode;
/**
 *  所有节点值
 */
@property(nonatomic, copy) NSMutableDictionary *nodesDic;
/**
 *  根节点的item
 */
@property(nonatomic, copy) NSMutableArray *rootNodeItemArray;
/**
 *  所有节点的item
 */
@property(nonatomic, copy) NSMutableArray *allNodeItemArray;
/**
 *  排序好的部门
 */
@property(nonatomic, copy) NSMutableArray *sortNodesArray;
-(id)initWithBranchInfo:(NSMutableArray *) branchInfoObjArray;
/**
 *  根据部门ID获取部门成员信息
 *
 *  @param branchId
 *
 *  @return
 */
-(NSMutableArray *)getChildrenEmplyoeeItemsWithBranchId:(NSString *)branchId;
/**
 *  根据部门ID获取子部门信息
 *
 *  @param branchId
 *
 *  @return
 */
-(NSMutableArray *)getChildrenBranchItemsWithBranchId:(NSString *)branchId;
-(NSMutableArray *)getChildrenContactModelsWithBranchId:(NSString *)branchId;
/**
 *  得到部门的所有父节点
 *
 *  @param branchId
 *
 *  @return 
 */
-(NSMutableArray *)getParentBranchItemsWithBranchId:(NSString *)branchId;

@end
