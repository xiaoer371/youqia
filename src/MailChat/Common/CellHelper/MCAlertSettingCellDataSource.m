//
//  MCAlertSettingCellDataSource.m
//  NPushMail
//
//  Created by wuwenyu on 16/4/22.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAlertSettingCellDataSource.h"
#import "MCGestureManagerCell.h"
#import "UITableView+Common.h"
#import "MCNotificationAccountCell.h"


@implementation MCAlertSettingCellDataSource {
    NSString *_cellIdentifier;
    NSArray  *_titles;
    ContactCellConfigureBlock _configureCellBlock;
}


- (id)initWithContactModels:(NSArray *)bmodels contactCellIdentifier:(NSString *)cellIdentifier configureCellBlock:(ContactCellConfigureBlock)aConfigureCellBlock {
    self = [super init];
    if (self) {
        _titles = bmodels;
        _cellIdentifier = cellIdentifier;
        _configureCellBlock = [aConfigureCellBlock copy];
    }
    return self;
    
}

- (id)modelAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self noPermissionNotice])
        return nil;
    
    if (indexPath.section == 0) {
        return _titles[indexPath.section][indexPath.row];
    }else if (indexPath.section == 1){
        return _titles[indexPath.section][indexPath.row];
    }else {
        return PMLocalizedStringWithKey(@"PM_Mail_Push_Show_Detail");
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if ([self noPermissionNotice]||(self.type == MCNoticeAccountSetDetail)){
        return 1;
    }else return 3;
 
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([self noPermissionNotice]) {
        return 0;
    }else{
        switch (section) {
            case 0:
            case 1:{
                if(_titles.count>1 ||self.type == MCNoticeAccountSetDetail){
                    NSArray *arr = _titles[section];
                    return arr.count;
                }
                return 1;
            }
                break;
            default:
                break;
        }
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.section==0 ||indexPath.section==2) {
        cell = (MCGestureManagerCell *)[tableView dequeueReusableCellWithIdentifier:_cellIdentifier];
        [tableView addUpAndDownLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
        id model = [self modelAtIndexPath:indexPath];
        _configureCellBlock(model, cell, indexPath);
        return cell;
    }else{
        cell = (MCNotificationAccountCell *)[tableView dequeueReusableCellWithIdentifier:@"SetAccountNotice"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        MCNotificationAccountCell *notifeCell  = (MCNotificationAccountCell*) cell;
        id model = [self modelAtIndexPath:indexPath];
        [notifeCell setMCAccount:model];
        return cell;
    }
}

- (BOOL)noPermissionNotice
{
    if([[[UIApplication sharedApplication] currentUserNotificationSettings] types] == UIUserNotificationTypeNone){
        return YES;
    }return NO;
}

@end
