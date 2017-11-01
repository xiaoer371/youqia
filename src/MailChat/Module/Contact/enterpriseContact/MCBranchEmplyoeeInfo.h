//
//  MCBranchEmplyoeeInfo.h
//  NPushMail
//
//  Created by wuwenyu on 16/1/13.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCBranchEmplyoeeInfo : NSObject
/**
 *  部门编号
 */
@property (nonatomic, strong) NSString *branch_id;
/**
 *  邮箱
 */
@property (nonatomic, strong) NSString *email;
/**
 *  是否是领导
 */
@property (nonatomic, assign) BOOL isLeader;
/**
 *  最后更新时间
 */
@property (nonatomic, assign) int64_t lastUpdateTime;

@end
