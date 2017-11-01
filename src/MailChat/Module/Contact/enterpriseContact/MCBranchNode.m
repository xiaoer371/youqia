//
//  MCBranchNode.m
//  NPushMail
//
//  Created by wuwenyu on 16/1/13.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBranchNode.h"
#import "MCBranchInfo.h"

@implementation MCBranchNode

- (id)initBranchNodeWith:(MCBranchInfo *)branchInfoObj {
    if (self = [super init]) {
        _branchInfo = branchInfoObj;
        _childrenBranch = [NSMutableArray arrayWithCapacity:0];
        _childrenEmplyoee = [NSMutableArray arrayWithCapacity:0];
        if (branchInfoObj) {
            _branchId = branchInfoObj.branchId;
            _parentId = branchInfoObj.parentId;
            _sortId = [NSString stringWithFormat:@"%d",branchInfoObj.sortId];
        }else{
            _branchId = @"";
            _parentId = @"";
        }
    }
    return self;
}

@end
