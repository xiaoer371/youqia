//
//  MCContactInfoDataSource.m
//  NPushMail
//
//  Created by wuwenyu on 16/2/17.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCContactInfoDataSource.h"
#import "MCContactInfoCell.h"
#import "MCContactModel.h"
#import "MCContactBaseInfo.h"
#import "UITableView+Common.h"

@implementation MCContactInfoDataSource {
    NSString *_cellIdentifier;
    TableViewCellConfigureBlock _configureCellBlock;
    NSMutableArray *_notePhones;
    NSMutableArray *_enterpriseContactInfos;
}

- (id)initWithModels:(NSArray *)amodels cellIdentifier:(NSString *)aCellIdentifier configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock {
    self = [super init];
    if (self) {
        _models = amodels;
        _cellIdentifier = aCellIdentifier;
        _configureCellBlock = [aConfigureCellBlock copy];
        [self loadDataSource];
    }
    return self;
}

- (void)loadDataSource {
    MCContactModel *model = [_models objectAtIndex:0];
    _enterpriseContactInfos = [NSMutableArray arrayWithCapacity:0];
    if (model.company) {
        MCContactBaseInfo *company = [[MCContactBaseInfo alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_ContactEnterpriseCompany") value:model.company];
        [_enterpriseContactInfos addObject:company];
    }
    if (model.enterpriseDepartMent) {
        MCContactBaseInfo *departMent = [[MCContactBaseInfo alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_ContactEnterpriseDepartMent") value:model.enterpriseDepartMent];
        [_enterpriseContactInfos addObject:departMent];
        
    }
    if (model.isLeader) {
        MCContactBaseInfo *isLeader = [[MCContactBaseInfo alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_ContactEnterprisePosition") value:PMLocalizedStringWithKey(@"PM_ContactEnterpriseLeader")];
        [_enterpriseContactInfos addObject:isLeader];
    }
    if (model.phoneNumbers) {
        NSArray *phones = [model.phoneNumbers componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        for (NSString *phoneNumber in phones) {
            if ([phoneNumber length] > 0) {
                MCContactBaseInfo *phone = [[MCContactBaseInfo alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_Contact_Phone") value:phoneNumber];
                [_enterpriseContactInfos addObject:phone];
            }
        }
    }
    if (model.notePhoneNumbers) {
        NSArray *notePhones = [model.notePhoneNumbers componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        for (NSString *phoneNumber in notePhones) {
            if ([phoneNumber length] > 0) {
                MCContactBaseInfo *notePhone = [[MCContactBaseInfo alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_Contact_Phone") value:phoneNumber];
                [_enterpriseContactInfos addObject:notePhone];
            }
        }
    }
}

- (id)modelAtIndexPath:(NSIndexPath *)indexPath {
    return _enterpriseContactInfos[(NSUInteger) indexPath.row];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _enterpriseContactInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (MCContactInfoCell *)[tableView dequeueReusableCellWithIdentifier:_cellIdentifier
                                                            forIndexPath:indexPath];
    id model = [self modelAtIndexPath:indexPath];
    _configureCellBlock(cell, model, indexPath, _notePhones, _enterpriseContactInfos);
    [tableView addUpAndDownLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
    return cell;
}

@end
