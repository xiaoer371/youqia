//
//  MCEnterpriseOrganizationDataSource.m
//  NPushMail
//
//  Created by wuwenyu on 16/3/2.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCEnterpriseOrganizationDataSource.h"
#import "MCEnterpriseBranchCell.h"
#import "MCEnterpriseEmplyoeeCell.h"
#import "MCContactCell.h"
#import "MCContactModel.h"
#import "MCEnterpriseContactCellItem.h"

@implementation MCEnterpriseOrganizationDataSource {
    NSString *_branchCellIdentifier;
    NSString *_contactCellIdentifier;
    NSString *_emplyoeeCellIdentifier;
    ContactCellConfigureBlock _configureCellBlock;
}

- (id)initWithEisFlag:(BOOL)eisFlag showItems:(NSArray *)amodels branchCellIdentifier:(NSString *)aCellIdentifier emplyoeeCellIdentifier:(NSString *)bCellIdentifier contactCellIdentifier:(NSString *)cCellIdentifier configureCellBlock:(ContactCellConfigureBlock)aConfigureCellBlock {
    self = [super init];
    if (self) {
        _eisFlag = eisFlag;
        _showItems = amodels;
        _branchCellIdentifier = aCellIdentifier;
        _emplyoeeCellIdentifier = bCellIdentifier;
        _contactCellIdentifier = cCellIdentifier;
        _configureCellBlock = aConfigureCellBlock;
    }
    return self;
}

- (id)modelAtIndexPath:(NSIndexPath *)indexPath {
    return [_showItems objectAtIndex:indexPath.row];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _showItems.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_eisFlag) {
        //2.0域显示
        MCContactModel * model = nil;
        model = _showItems[indexPath.row];
        MCContactCell *cell = [tableView dequeueReusableCellWithIdentifier:_contactCellIdentifier];
        _configureCellBlock(model, cell, indexPath);
        return cell;
    }
    
    MCEnterpriseContactCellItem *obj = [_showItems objectAtIndex:indexPath.row];
    //部门cell的绘制
    if (obj.branchInfo) {
        MCEnterpriseBranchCell *cell = (MCEnterpriseBranchCell *)[tableView dequeueReusableCellWithIdentifier:_branchCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        _configureCellBlock(obj, cell, indexPath);
        return cell;
        
    }else {
        //联系人cell绘制
        MCEnterpriseEmplyoeeCell *cell = (MCEnterpriseEmplyoeeCell*)[tableView dequeueReusableCellWithIdentifier:_emplyoeeCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        _configureCellBlock(obj, cell, indexPath);
        return cell;
    }
}

@end
