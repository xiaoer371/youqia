//
//  MCEnterpriseOrganizationDataSource.h
//  NPushMail
//
//  Created by wuwenyu on 16/3/2.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ContactCellConfigureBlock)(id model, id cell, NSIndexPath *index);

@interface MCEnterpriseOrganizationDataSource : NSObject<UITableViewDataSource>

- (id)initWithEisFlag:(BOOL)eisFlag showItems:(NSArray *)amodels branchCellIdentifier:(NSString *)aCellIdentifier emplyoeeCellIdentifier:(NSString *)bCellIdentifier contactCellIdentifier:(NSString *)cCellIdentifier configureCellBlock:(ContactCellConfigureBlock)aConfigureCellBlock;
@property (nonatomic, strong) NSArray *showItems;
@property (nonatomic, assign) BOOL eisFlag;

@end
