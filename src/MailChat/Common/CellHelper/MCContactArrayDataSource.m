//
//  MCContactArrayDataSource.m
//  NPushMail
//
//  Created by wuwenyu on 16/1/27.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCContactArrayDataSource.h"
#import "MCContactGroupCell.h"
#import "MCContactCell.h"
#import "UITableView+Common.h"
#import "MCContactManager.h"
#import "UIAlertView+Blocks.h"

@implementation MCContactArrayDataSource {
    NSString *_groupCellIdentifier;
    NSString *_contactCellIdentifier;
    ContactCellConfigureBlock _configureCellBlock;
}

- (id)initWithGroupModels:(NSMutableArray *)amodels contactModels:(NSMutableArray *)bmodels groupCellIdentifier:(NSString *)aCellIdentifier contactCellIdentifier:(NSString *)bCellIdentifier configureCellBlock:(ContactCellConfigureBlock)aConfigureCellBlock {
    self = [super init];
    if (self) {
        _groupModels = amodels;
        _contactModels = bmodels;
        _groupCellIdentifier = aCellIdentifier;
        _contactCellIdentifier = bCellIdentifier;
        _configureCellBlock = [aConfigureCellBlock copy];
    }
    return self;
}

- (id)modelAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [_groupModels objectAtIndex:indexPath.row];
    }
    NSArray *arr = _contactModels[indexPath.section-1];
    return [arr objectAtIndex:indexPath.row];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _indexTitles;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _groupModels.count;
    }
    NSArray *arr = _contactModels[section-1];
    return arr.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _contactModels.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
       cell = (MCContactGroupCell *)[tableView dequeueReusableCellWithIdentifier:_groupCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else {
        cell = (MCContactCell *)[tableView dequeueReusableCellWithIdentifier:_contactCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [tableView addDownLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
    id model = [self modelAtIndexPath:indexPath];
    _configureCellBlock(model, cell, indexPath);
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0) {
        return YES;
    }
    return NO;
}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
//    __weak MCContactArrayDataSource *weakSelf = self;
//    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Cancel")];
//    RIButtonItem *sureItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Msg_DelMsgCell") action:^{
//        NSMutableArray *array = weakSelf.contactModels[indexPath.section-1];
//        MCContactModel *model = [array objectAtIndex:indexPath.row];
//        [[MCContactManager sharedInstance] deleteContacts:@[model]];
//        [array removeObjectAtIndex:indexPath.row];
//        if (array.count == 0) {
//            [weakSelf.contactModels removeObjectAtIndex:indexPath.section-1];
//            [weakSelf.indexTitles removeObjectAtIndex:indexPath.section - 1];
//            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationBottom];
//        }else{
//            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
//        }
//        if (weakSelf.contactModels.count == 0) {
//            [tableView reloadData];
//        }
//        //友盟统计事件
//        [MCUmengManager addEventWithKey:mc_contact_delete label:@"联系人删除"];
//    }];
//    UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_Common_Notice") message:PMLocalizedStringWithKey(@"PM_Contact_deleteNotice") cancelButtonItem:cancelItem otherButtonItems:sureItem, nil];
//    [alertV show];
//}

@end
