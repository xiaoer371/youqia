//
//  MCEnterpriseContactCellItem.m
//  NPushMail
//
//  Created by wuwenyu on 16/1/13.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCEnterpriseContactCellItem.h"
#import "MCBranchInfo.h"
#import "MCContactModel.h"

@implementation MCEnterpriseContactCellItem

- (id)initWithItemType:(NSString *)type parentId:(NSString *)parentid branchInfo:(MCBranchInfo *)branchInfoObj employeeInfo:(MCContactModel *)employeeInfoObj level:(NSString *)level isOpen:(BOOL)isopen{
    if (self = [super init]) {
        _parentId = parentid;
        _itemLevel = level;
        _type = type;
        _isOpen = isopen;
        if ([type isEqualToString:@"0"]) {//部门的信息
            _branchInfo = branchInfoObj;
        }else{//员工信息
            _employeeInfo = employeeInfoObj;
        }
    }
    return self;
}

- (id)initWithEmployeeInfo:(MCContactModel *)employeeInfoObj {
    if (self = [super init]) {
        _employeeInfo = employeeInfoObj;
    }
    return self;
}

@end
