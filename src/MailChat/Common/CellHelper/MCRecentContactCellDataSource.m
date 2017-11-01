//
//  MCRecentContactCellDataSource.m
//  NPushMail
//
//  Created by wuwenyu on 16/4/6.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCRecentContactCellDataSource.h"
#import "MCContactCell.h"
#import "UITableView+Common.h"
#import "MCContactManager.h"
#import "UIAlertView+Blocks.h"

@implementation MCRecentContactCellDataSource {
    NSString *_contactCellIdentifier;
    ContactCellConfigureBlock _configureCellBlock;
}

- (id)initWithContactModels:(NSMutableArray *)bmodels contactCellIdentifier:(NSString *)cellIdentifier configureCellBlock:(ContactCellConfigureBlock)aConfigureCellBlock {
    self = [super init];
    if (self) {
        _contactModels = bmodels;
        _contactCellIdentifier = cellIdentifier;
        _configureCellBlock = [aConfigureCellBlock copy];
    }
    return self;
}

- (id)modelAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *arr = _contactModels[indexPath.section];
    return [arr objectAtIndex:indexPath.row];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _indexTitles;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = _contactModels[section];
    return arr.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _contactModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell = (MCContactCell *)[tableView dequeueReusableCellWithIdentifier:_contactCellIdentifier];
    [tableView addDownLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
    id model = [self modelAtIndexPath:indexPath];
    _configureCellBlock(model, cell, indexPath);
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
//    __weak MCRecentContactCellDataSource *weakSelf = self;
//    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Cancel")];
//    RIButtonItem *sureItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Msg_DelMsgCell") action:^{
//        NSMutableArray *array = weakSelf.contactModels[indexPath.section];
//        MCContactModel *model = [array objectAtIndex:indexPath.row];
//        [[MCContactManager sharedInstance] deleteContacts:@[model]];
//        [array removeObjectAtIndex:indexPath.row];
//        if (array.count == 0) {
//            [weakSelf.contactModels removeObjectAtIndex:indexPath.section];
//            [weakSelf.indexTitles removeObjectAtIndex:indexPath.section];
//            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
//        }else{
//            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
//        }
//        //友盟统计事件
//        [MCUmengManager addEventWithKey:mc_contact_delete label:@"联系人删除"];
//    }];
//    UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_Common_Notice") message:PMLocalizedStringWithKey(@"PM_Contact_deleteNotice") cancelButtonItem:cancelItem otherButtonItems:sureItem, nil];
//    [alertV show];
//}

@end
