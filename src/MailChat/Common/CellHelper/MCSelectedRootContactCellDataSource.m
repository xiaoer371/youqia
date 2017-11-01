//
//  MCSelectedRootContactCellDataSource.m
//  NPushMail
//
//  Created by wuwenyu on 16/4/27.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCSelectedRootContactCellDataSource.h"
#import "MCEnterpriseBranchCell.h"
#import "MCBranchInfo.h"
#import "MCContactModel.h"
#import "MCContactCell.h"
#import "MCGroup.h"
#import "UITableView+Common.h"

@implementation MCSelectedRootContactCellDataSource {
    NSString *_branchCellIdentifier;
    NSString *_contactCellIdentifier;
    ContactCellConfigureBlock _configureCellBlock;
    MCGroup *_selectedAllGroup;
}

- (id)initWithModels:(NSArray *)models customGroups:(NSArray *)groups branchs:(NSArray *)branchs branchCellIdentifier:(NSString *)aCellIdentifier contactCellIdentifier:(NSString *)cCellIdentifier configureCellBlock:(ContactCellConfigureBlock)aConfigureCellBlock {
    if (self = [super init]) {
        _models = models;
        _branchs = branchs;
        _groups = groups;
        _branchCellIdentifier = aCellIdentifier;
        _contactCellIdentifier = cCellIdentifier;
        _configureCellBlock = [aConfigureCellBlock copy];
        _selectedAllGroup = [MCGroup new];
    }
    return self;
}

- (id)modelAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [_groups objectAtIndex:indexPath.row];
    }
    //企业联系人
    if (_branchs && _branchs.count >0) {
        if (indexPath.section == 1) {
            //分组
            return [_branchs objectAtIndex:indexPath.row];
        }
        return [_models objectAtIndex:indexPath.row];
    }else {
        return [_models objectAtIndex:indexPath.row];
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:{
            return _groups.count;
            break;
        }
        case 1:{
            if (_branchs && _branchs.count > 0) {
                return _branchs.count;
            }else {
                return _models.count;
            }
            break;
        }
        case 2:
            return _models.count;
            break;
        default:
            break;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_branchs && _branchs.count >0) {
        return 3;
    }else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_branchs && _branchs.count > 0) {
        if (indexPath.section != 2) {
            MCEnterpriseBranchCell *cell = [self enterprisBranchCellWithTableView:tableView cellForRowAtIndexPath:indexPath];
            return cell;
        }else {
            MCContactCell *cell = [self contactCellWithTableView:tableView cellForRowAtIndexPath:indexPath];
            return cell;
        }
        
    }else {
        if (indexPath.section != 0) {
            MCContactCell *cell = [self contactCellWithTableView:tableView cellForRowAtIndexPath:indexPath];
            return cell;
        }else {
            MCEnterpriseBranchCell *cell = [self enterprisBranchCellWithTableView:tableView cellForRowAtIndexPath:indexPath];
            return cell;
        }
    }
    
}

- (id)enterprisBranchCellWithTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id obj = nil;
    MCEnterpriseBranchCell* cell = (MCEnterpriseBranchCell*)[tableView dequeueReusableCellWithIdentifier:_branchCellIdentifier];
    if (!cell) {
        cell = [MCEnterpriseBranchCell instanceFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    if (indexPath.section == 0) {
        obj = [_groups objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else {
        obj = [_branchs objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    _configureCellBlock(obj, cell, indexPath);
    return cell;
}

- (id)contactCellWithTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCContactModel * model = nil;
    model = _models[indexPath.row];
    MCContactCell *cell = [tableView dequeueReusableCellWithIdentifier:_contactCellIdentifier];
    _configureCellBlock(model, cell, indexPath);
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!AppStatus.currentUser.isEIS) {
        if (indexPath.section != 0) {
            return YES;
        }
        return NO;
    }
    return NO;
}


@end
