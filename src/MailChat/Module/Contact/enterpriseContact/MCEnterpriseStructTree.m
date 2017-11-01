//
//  MCEnterpriseStructTree.m
//  NPushMail
//
//  Created by wuwenyu on 16/1/13.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCEnterpriseStructTree.h"
#import "MCBranchInfo.h"
#import "MCBranchEmplyoeeInfo.h"
#import "MCBranchNode.h"
#import "MCEnterpriseContactCellItem.h"
#import "MCContactManager.h"

@implementation MCEnterpriseStructTree

- (id)initWithBranchInfo:(NSMutableArray *)branchInfoObjArray {
    if (self = [super init]) {
        _rootNode = [[MCBranchNode alloc] initBranchNodeWith:nil];
        _nodesDic = [NSMutableDictionary dictionaryWithCapacity:0];
        _rootNodeItemArray = [NSMutableArray arrayWithCapacity:0];
        _allNodeItemArray = [NSMutableArray arrayWithCapacity:0];
        for (MCBranchInfo *branchInfoObj in branchInfoObjArray) {
            //根据部门信息得到部门节点信息
            MCBranchNode *node = [[MCBranchNode alloc] initBranchNodeWith:branchInfoObj];
            [_nodesDic  setObject:node forKey:node.branchId];
        }
        [self buildTree];
        [self setAllBranchNodeLevel];
        [self setRootNodeItem];
        [self setAllNodeItem];
    }
    return self;
}

-(void) buildTree {
    for (MCBranchNode *node in _nodesDic.allValues) {
        if (node.parentId && [node.parentId isEqualToString:@"0"]) {//当前属于根节点(也就是第一级节点)
            [_rootNode.childrenBranch addObject:node.branchId];
        }else{//不属于根节点则加到它的父亲节点的子节点上面
            MCBranchNode *tempNode = [_nodesDic objectForKey:node.parentId];//得到该节点的父节点
            [tempNode.childrenBranch addObject:node.branchId];
        }
    }
}

- (void)setAllBranchNodeLevel {
    for (MCBranchNode *obj in _nodesDic.allValues) {
        obj.recursiveFlag = NO;
    }
    [self setAllBranchNodeLevelFromRoot:_rootNode];
}

- (void)setRootNodeItem {
    NSMutableArray *rootNodeTmpArray = [NSMutableArray arrayWithCapacity:0];
    rootNodeTmpArray = [[self getSortChildrenByNode:_rootNode] mutableCopy];
    
    for (int i = 0;i < rootNodeTmpArray.count;i++) {
        MCBranchNode *obj = [rootNodeTmpArray objectAtIndex:i];
        MCEnterpriseContactCellItem* cellItem = [[MCEnterpriseContactCellItem alloc] initWithItemType:@"0" parentId:obj.parentId branchInfo:obj.branchInfo employeeInfo:nil level:obj.nodeLevel isOpen:NO];
        cellItem.branchItemOriginX = branchItemOriginX;
        cellItem.size = [self getBranchAllEmployeeCountWithBranchNode:obj];
        [_rootNodeItemArray addObject:cellItem];
    }
}

- (void)setAllNodeItem {
    _sortNodesArray = [NSMutableArray arrayWithCapacity:0];//排序好的部门
    [self getAllSortNodeWithNode:_rootNode resultArray:_sortNodesArray];
    
    for  (int i = 0; i < _sortNodesArray.count; i ++) {
        MCBranchNode* obj = [_sortNodesArray objectAtIndex:i];
        MCEnterpriseContactCellItem *branchItemObj = [[MCEnterpriseContactCellItem alloc] initWithItemType:@"0" parentId:obj.parentId branchInfo:obj.branchInfo employeeInfo:nil level:obj.nodeLevel isOpen:NO];//创建部门item
        if (branchItemObj) {
            [_allNodeItemArray addObject:branchItemObj];
        }
    }
}

- (void)setAllBranchNodeLevelFromRoot:(MCBranchNode *)node{
    if (node.recursiveFlag) {
        return;
    }
    node.recursiveFlag = YES;
    //遍历当前节点的字节点，并设置层级关系
    for (NSString *branchId in node.childrenBranch) {
        MCBranchNode *obj = [_nodesDic objectForKey:branchId];
        int levelValue = [node.nodeLevel intValue] + 1;
        obj.nodeLevel = [NSString stringWithFormat:@"%d",levelValue];
        [self setAllBranchNodeLevelFromRoot:obj];
    }
}

//根据sortid排序每个节点的孩子节点
- (NSArray *)getSortChildrenByNode:(MCBranchNode *)node{
    NSComparator cmptr= ^(MCBranchNode *obj1,MCBranchNode *obj2){
        if ([obj1.sortId integerValue] > [obj2.sortId integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([obj1.sortId integerValue] < [obj2.sortId integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return [obj1.branchInfo.name compare:obj2.branchInfo.name];
    };
    NSMutableArray* nodeArray = [NSMutableArray arrayWithCapacity:0];
    for (NSString* nodeBranchId in node.childrenBranch) {//将当前节点的孩子节点排序
        MCBranchNode *obj = [_nodesDic objectForKey:nodeBranchId];
        [nodeArray addObject:obj];
    }
    if (nodeArray.count != 0) {
        NSArray *array = [nodeArray sortedArrayUsingComparator:cmptr];
        return array;
    }
    return nil;
}

//得到当前部门节点下面所有得员工数量
- (int)getBranchAllEmployeeCountWithBranchNode:(MCBranchNode *)branchNode {
    int size = 0;
    //如果当前节点没有子部门节点,则直接找当前节点对应得员工的数量加上即可
    if (branchNode.childrenBranch && branchNode.childrenBranch.count == 0) {
        size = [[MCContactManager sharedInstance] getBranchEmplyoeesCountWithBranchId:branchNode.branchId];
        return size;
    }
    size += [[MCContactManager sharedInstance] getBranchEmplyoeesCountWithBranchId:branchNode.branchId];
    //加上孩子部门节点的员工数量
    for (NSString* childrenBranchId in branchNode.childrenBranch) {
        MCBranchNode *childrenBranchNode = [_nodesDic objectForKey:childrenBranchId];
        size += [self getBranchAllEmployeeCountWithBranchNode:childrenBranchNode];
        
    }
    return size;
}

//根据sortid排序得到的所有节点信息
- (void )getAllSortNodeWithNode:(MCBranchNode* )node resultArray:(NSMutableArray* )resultArray {
    //传入根节点，递归得到排序好的所有节点信息
    if (node != _rootNode) {
        [resultArray addObject:node];
    }
    NSMutableArray* alreadySortChildrenNode = [[self getSortChildrenByNode:node] mutableCopy];
    //无孩子节点
    if (!alreadySortChildrenNode) {
        return;
    }
    for (int i = 0;i < alreadySortChildrenNode.count;i++) {
        MCBranchNode *obj = [alreadySortChildrenNode objectAtIndex:i];
        [self getAllSortNodeWithNode:obj resultArray:resultArray];//递归得到当前节点的子结点并加入到结果集中
    }
}

-(NSMutableArray *)getChildrenEmplyoeeItemsWithBranchId:(NSString *)branchId {
    @autoreleasepool {
        MCBranchNode *obj = [_nodesDic objectForKey:branchId];
        NSMutableArray *branchEmplyoeeInfos = [[[MCContactManager sharedInstance] getEnterpriseBranchEmployeeInfosByBranchId:branchId] mutableCopy];
        NSMutableArray *emplyoeeItemsAry = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *employeeInfoArray = [NSMutableArray arrayWithCapacity:0];
       
        //获取到该部门下的所有成员
        for (MCBranchEmplyoeeInfo* obj1 in branchEmplyoeeInfos) {
            MCContactModel *emplyoeeInfoObj = [[MCContactManager sharedInstance] getContactWithEmail:obj1.email];
            emplyoeeInfoObj.isLeader = obj1.isLeader;
            if (emplyoeeInfoObj) {
                [employeeInfoArray addObject:emplyoeeInfoObj];
            }
        }
        
        //这里需要重新排序,先按sortid从小到大排序，如果sortid一样，那么按topid从小到大排序
        NSComparator cmptr= ^(MCContactModel *obj1,MCContactModel *obj2){
            if (obj1.enterpriseSortId > obj2.enterpriseSortId) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            if (obj1.enterpriseSortId  < obj2.enterpriseSortId) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            if (obj1.enterpriseTopId > obj2.enterpriseTopId) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            if (obj1.enterpriseTopId  < obj2.enterpriseTopId) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return [obj1.displayName compare:obj2.displayName];
        };
        
        NSArray *emplyoeeSortArray = [employeeInfoArray sortedArrayUsingComparator:cmptr];
        
        for (int i = 0; i < emplyoeeSortArray.count; i++) {
            MCContactModel *employeeObj = [emplyoeeSortArray objectAtIndex:i];
            MCEnterpriseContactCellItem *employeeItem = [[MCEnterpriseContactCellItem alloc] initWithItemType:@"1" parentId:nil branchInfo:nil employeeInfo:employeeObj level:[NSString stringWithFormat:@"%d",[obj.nodeLevel intValue]+1] isOpen:NO];
            employeeItem.emplyoeeItemOriginX = branchItemOriginX + ([employeeItem.itemLevel intValue] - 1)*offsetX + offsetX - 14;
            if (employeeItem) {
                [emplyoeeItemsAry addObject:employeeItem];
            }

        }
        return emplyoeeItemsAry;
    }
}

-(NSMutableArray *)getChildrenContactModelsWithBranchId:(NSString *)branchId {
    @autoreleasepool {
        NSMutableArray *branchEmplyoeeInfos = [[[MCContactManager sharedInstance] getEnterpriseBranchEmployeeInfosByBranchId:branchId] mutableCopy];
        NSMutableArray *employeeInfoArray = [NSMutableArray arrayWithCapacity:0];
        
        //获取到该部门下的所有成员
        for (MCBranchEmplyoeeInfo* obj1 in branchEmplyoeeInfos) {
            MCContactModel *emplyoeeInfoObj = [[MCContactManager sharedInstance] getContactWithEmail:obj1.email];
            emplyoeeInfoObj.isLeader = obj1.isLeader;
            if (emplyoeeInfoObj) {
                [employeeInfoArray addObject:emplyoeeInfoObj];
            }
        }
        return employeeInfoArray;
    }
}

-(NSMutableArray *)getChildrenBranchItemsWithBranchId:(NSString *)branchId {
    @autoreleasepool {
        MCBranchNode *obj = [_nodesDic objectForKey:branchId];
        NSMutableArray *childrenBranchNodes = [[self getSortChildrenByNode:obj] mutableCopy];
        NSMutableArray *childrenBranchItemsAry = [NSMutableArray new];
        for (int i = 0; i < childrenBranchNodes.count; i++) {
            MCBranchNode *childrenNode = [childrenBranchNodes objectAtIndex:i];
            MCBranchInfo *branchInfoObj = [[MCContactManager sharedInstance] getEnterpriseBranchInfoWithBranchId:childrenNode.branchId];
            MCEnterpriseContactCellItem* branchItem = [[MCEnterpriseContactCellItem alloc] initWithItemType:@"0" parentId:obj.branchId branchInfo:branchInfoObj employeeInfo:nil level:[NSString stringWithFormat:@"%d",[obj.nodeLevel intValue]+1] isOpen:NO];
            branchItem.branchItemOriginX = branchItemOriginX + ([branchItem.itemLevel intValue] - 1)*offsetX;
            branchItem.size = branchInfoObj.emplyoeesCnt;//[self getBranchAllEmployeeCountWithBranchNode:childrenNode];
            [childrenBranchItemsAry addObject:branchItem];
        }
        return childrenBranchItemsAry;
    }
}

-(NSMutableArray *)getParentBranchItemsWithBranchId:(NSString *)branchId {
    @autoreleasepool {
        MCBranchNode *obj = [_nodesDic objectForKey:branchId];
        NSMutableArray *parentBranchNodes = [[self getSortParentByNode:obj] mutableCopy];
        NSMutableArray *parentBranchItemsAry = [NSMutableArray new];
        for (int i = 0; i < parentBranchNodes.count; i++) {
            MCBranchNode *childrenNode = [parentBranchNodes objectAtIndex:i];
            MCBranchInfo *branchInfoObj = [[MCContactManager sharedInstance] getEnterpriseBranchInfoWithBranchId:childrenNode.branchId];
            MCEnterpriseContactCellItem* branchItem = [[MCEnterpriseContactCellItem alloc] initWithItemType:@"0" parentId:obj.branchId branchInfo:branchInfoObj employeeInfo:nil level:[NSString stringWithFormat:@"%d",[obj.nodeLevel intValue]+1] isOpen:NO];
            branchItem.branchItemOriginX = branchItemOriginX + ([branchItem.itemLevel intValue] - 1)*offsetX;
            branchItem.size = branchInfoObj.emplyoeesCnt;
            [parentBranchItemsAry addObject:branchItem];
        }
        return parentBranchItemsAry;
    }
}

//得到排序好的每个父节点
- (NSArray *)getSortParentByNode:(MCBranchNode *)node{
    MCBranchNode *tempNode = node;
    NSMutableArray* nodeArray = [NSMutableArray arrayWithCapacity:0];
    while (tempNode) {
        /**
         *  得到该节点的父节点
         */
        if (tempNode.parentId && [tempNode.parentId isEqualToString:@"0"]) {
            //为根节点, 无上级节点，直接返回
            break;
        }
        MCBranchNode *parentNode = [_nodesDic objectForKey:tempNode.parentId];
        [nodeArray addObject:parentNode];
        tempNode = parentNode;
    }
    [nodeArray addObject:node];
    return nodeArray;
}

@end
