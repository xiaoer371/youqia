//
//  MCAddContactCellDataSource.m
//  NPushMail
//
//  Created by wuwenyu on 16/8/15.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAddContactCellDataSource.h"
#import "MCAddContactBaseInfoCell.h"
#import "MCGestureManagerCell.h"

@implementation MCAddContactCellDataSource {
    NSString *_baseInfoCellIdentifer;
    NSString *_settingCellIdentifier;
    TableViewCellConfigureBlock _configureCellBlock;
    commitEditingCellBlock _commitEditingCellBlock;
}

- (id)initWithBaseInfos:(NSMutableArray *)baseInfos phones:(NSMutableArray *)phones baseInfoCellIdentifier:(NSString *)aCellIdentifier settingCellIdentifier:(NSString *)bCellIdentifier configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock commitEditingCellBlock:(commitEditingCellBlock)commitEditingCellBlock {
    if (self = [super init]) {
        _baseInfos = baseInfos;
        _phones = phones;
        _baseInfoCellIdentifer = aCellIdentifier;
        _settingCellIdentifier = bCellIdentifier;
        _configureCellBlock = aConfigureCellBlock;
        _commitEditingCellBlock = commitEditingCellBlock;
    }
    return self;
}

- (id)modelAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return [_baseInfos objectAtIndex:indexPath.row];
            break;
        case 1:{
            if (_phones.count == indexPath.row) {
                return PMLocalizedStringWithKey(@"PM_Contact_addPhoneNumbers");
            }
            return [_phones objectAtIndex:indexPath.row];
            break;
        }
        case 2:
            return PMLocalizedStringWithKey(@"PM_Contact_setImportantFlag");
            break;
        case 3:
            return PMLocalizedStringWithKey(@"PM_Msg_DelContacts");
            break;
        default:
            break;
    }
    return nil;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return _baseInfos.count;
            break;
        case 1:
            return _phones.count + 1;
            break;
        case 2:
            return 1;
            break;
        case 3:
            return 1;
            break;
        default:
            break;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.enableDeleteFlag) {
        return 4;
    }
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.section != 2) {
        cell = (MCAddContactBaseInfoCell *)[tableView dequeueReusableCellWithIdentifier:_baseInfoCellIdentifer];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }else {
        cell = (MCGestureManagerCell *)[tableView dequeueReusableCellWithIdentifier:_settingCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    id model = [self modelAtIndexPath:indexPath];
    _configureCellBlock(model, cell, indexPath);
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_commitEditingCellBlock) {
        _commitEditingCellBlock(tableView, editingStyle, indexPath);
    }
}

@end
