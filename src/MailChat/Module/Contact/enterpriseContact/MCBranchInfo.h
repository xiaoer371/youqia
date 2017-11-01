//
//  MCBranchInfo.h
//  NPushMail
//
//  Created by wuwenyu on 16/1/13.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCBranchInfo : NSObject
/**
 *  部门编号
 */
@property (nonatomic, strong) NSString *branchId;
/**
 *  部门名称
 */
@property (nonatomic, strong) NSString *name;
/**
 *  上级部门ID（顶级为0）
 */
@property (nonatomic, strong) NSString *parentId;
/**
 *  排序ID
 */
@property (nonatomic, assign) int32_t  sortId;
/**
 *  员工数量
 */
@property (nonatomic, assign) int32_t  emplyoeesCnt;
/**
 *  子部门的数量
 */
@property (nonatomic, assign) int32_t  subBranchCnt;
/**
 *  最后更新时间
 */
@property (nonatomic, assign) int64_t  lastUpdateTime;
/**
 *  是否已删除
 */
@property (nonatomic, assign) BOOL deleteFlag;

@end
