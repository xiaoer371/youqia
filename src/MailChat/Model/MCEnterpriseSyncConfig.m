//
//  MCEnterpriseSyncConfig.m
//  NPushMail
//
//  Created by wuwenyu on 16/3/23.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCEnterpriseSyncConfig.h"
#import "MCAccountConfig.h"
#import "MCAvatarHelper.h"

static const NSString *companyKey = @"enterpriseCompany";


@implementation MCEnterpriseSyncBranchItem

- (id)initWithDictionary:(id)dict {
    self = [super init];
    if (self) {
        NSArray *data = (NSArray *)dict;
        NSMutableArray *branchs = [NSMutableArray new];
        for (NSDictionary* branchDic in data) {
            MCBranchInfo* branchObj = [[MCBranchInfo alloc] init];
            branchObj.branchId = [branchDic objectForKey:@"i"];
            branchObj.name = [branchDic objectForKey:@"n"];
            branchObj.parentId = [branchDic objectForKey:@"p"];
            if ([[branchDic objectForKey:@"s"] isEqual:[NSNull null]]) {
                branchObj.sortId = 1;
            }else {
                branchObj.sortId = [[branchDic objectForKey:@"s"] intValue];
            }
            branchObj.emplyoeesCnt = [[branchDic objectForKey:@"cnt"] intValue];
            branchObj.subBranchCnt = [[branchDic objectForKey:@"sub"] intValue];
            [branchs addObject:branchObj];
        }
        _models = [branchs copy];
    }
    return self;
}

@end

@implementation MCEnterpriseSyncEmplyoeeItem

- (id)initWithDictionary:(id)dict {
    self = [super init];
    if (self) {
        NSArray *data = (NSArray *)dict;
        NSMutableArray *emplyoees = [NSMutableArray new];
        NSString *companyName = AppStatus.accountData.accountConfig.company;
        for (NSDictionary* emplyoeeDic in data) {
            MCContactModel *emplyoeeObj = [[MCContactModel alloc] init];
            emplyoeeObj.account = [emplyoeeDic objectForKey:@"e"];
            emplyoeeObj.headDefaultColorStr = [MCAvatarHelper randomColorHexString];
            emplyoeeObj.company = companyName;
            emplyoeeObj.isCompanyUser = YES;
            if ([emplyoeeDic objectForKey:@"n"]) {
                emplyoeeObj.enterpriseUserName = [emplyoeeDic objectForKey:@"n"];
            }
            if ([emplyoeeDic objectForKey:@"k"]) {
                emplyoeeObj.youqiaNickName = [emplyoeeDic objectForKey:@"k"];
            }
            
            emplyoeeObj.headChecksum = [emplyoeeDic objectForKey:@"a"];
            emplyoeeObj.youqiaFlag = [[emplyoeeDic objectForKey:@"s"] boolValue];
            emplyoeeObj.enterpriseMobile_phone = @"";
            emplyoeeObj.enterpriseWork_phone = @"";
            emplyoeeObj.enterpriseHome_phone = @"";
            emplyoeeObj.enterpriseSortId = [[emplyoeeDic objectForKey:@"ss"] integerValue];
            emplyoeeObj.enterpriseTopId = [[emplyoeeDic objectForKey:@"tt"] integerValue];
            emplyoeeObj.headDefaultColorStr = [MCAvatarHelper randomColorHexString];
            if (![[emplyoeeDic objectForKey:@"mp"] isEqual:[NSNull null]]) {
                NSMutableArray *ary = [emplyoeeDic objectForKey:@"mp"];
                if (ary.count > 0) {
                    emplyoeeObj.enterpriseMobile_phone = [ary componentsJoinedByString:@","];
                }
            }
            if (![[emplyoeeDic objectForKey:@"wp"] isEqual:[NSNull null]]) {
                NSMutableArray *ary = [emplyoeeDic objectForKey:@"wp"];
                if (ary.count > 0) {
                    emplyoeeObj.enterpriseWork_phone = [ary componentsJoinedByString:@","];
                }
            }
            if (![[emplyoeeDic objectForKey:@"hp"] isEqual:[NSNull null]]) {
                NSMutableArray *ary = [emplyoeeDic objectForKey:@"hp"];
                if (ary.count > 0) {
                    emplyoeeObj.enterpriseHome_phone = [ary componentsJoinedByString:@","];
                }
            }
            [emplyoees addObject:emplyoeeObj];
        }
        _models = [emplyoees copy];
    }
    return self;
}

@end

@implementation MCEnterpriseSyncBranchEmplyoeeItem

- (id)initWithDictionary:(id)dict {
    if (self = [super init]) {
        NSArray *data = (NSArray *)dict;
        NSMutableArray *branchEmplyoees = [NSMutableArray new];
        for (NSDictionary* branchEmplyossDic in data) {
            MCBranchEmplyoeeInfo *branchEmplyoeeObj = [[MCBranchEmplyoeeInfo alloc] init];
            branchEmplyoeeObj.branch_id = [branchEmplyossDic objectForKey:@"b"];
            branchEmplyoeeObj.email = [branchEmplyossDic objectForKey:@"u"];
            branchEmplyoeeObj.isLeader = [[branchEmplyossDic objectForKey:@"l"] boolValue];
            [branchEmplyoees addObject:branchEmplyoeeObj];
        }
        _models = [branchEmplyoees copy];
    }
    return self;
}

@end

@implementation MCEnterpriseSyncConfig

- (id)initWithDictionary:(id)dict {
    if (self = [super init]) {
        _companyName = [dict[@"name"] copy];
        _syncTimestamp = [dict[@"ts"] doubleValue];
        
        id deptObj = dict[@"deps"];
        if (deptObj) {
            _hasNewValue = YES;
            _branchInfo = [[MCEnterpriseSyncBranchItem alloc] initWithDictionary:[dict objectForKey:@"deps"]];
            _emplyoeeInfo = [[MCEnterpriseSyncEmplyoeeItem alloc] initWithDictionary:[dict objectForKey:@"users"]];
            _branchEmplyoeeInfo = [[MCEnterpriseSyncBranchEmplyoeeItem alloc] initWithDictionary:[dict objectForKey:@"rels"]];
        }
    }
    return self;
}

@end
