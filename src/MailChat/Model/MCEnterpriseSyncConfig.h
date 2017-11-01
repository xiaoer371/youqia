//
//  MCEnterpriseSyncConfig.h
//  NPushMail
//
//  Created by wuwenyu on 16/3/23.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCContactModel.h"
#import "MCBranchInfo.h"
#import "MCBranchEmplyoeeInfo.h"

@interface MCEnterpriseSyncBranchItem : NSObject

@property (nonatomic, strong) NSArray *models;
- (instancetype)initWithDictionary:(id)dict;

@end

@interface MCEnterpriseSyncEmplyoeeItem : NSObject

@property (nonatomic, strong) NSArray *models;
- (instancetype)initWithDictionary:(id)dict;

@end

@interface MCEnterpriseSyncBranchEmplyoeeItem : NSObject

@property (nonatomic, strong) NSArray *models;
- (instancetype)initWithDictionary:(id)dict;

@end

@interface MCEnterpriseSyncConfig : NSObject

@property (nonatomic,assign) BOOL hasNewValue;

@property (nonatomic,copy) NSString *companyName;
@property (nonatomic,assign) NSTimeInterval syncTimestamp;

@property (nonatomic, strong) MCEnterpriseSyncBranchItem *branchInfo;
@property (nonatomic, strong) MCEnterpriseSyncBranchEmplyoeeItem *branchEmplyoeeInfo;
@property (nonatomic, strong) MCEnterpriseSyncEmplyoeeItem *emplyoeeInfo;


- (instancetype)initWithDictionary:(id)dict;

@end
