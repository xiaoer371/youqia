//
//  MCCellDataSource.m
//  NPushMail
//
//  Created by wuwenyu on 16/1/26.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCCellDataSource.h"

@implementation MCCellDataSource {
    NSString *_cellIdentifier;
    TableViewCellConfigureBlock _configureCellBlock;
}

- (id)initWithModels:(NSArray *)amodels cellIdentifier:(NSString *)aCellIdentifier configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock {
    self = [super init];
    if (self) {
        _models = amodels;
        _cellIdentifier = aCellIdentifier;
        _configureCellBlock = [aConfigureCellBlock copy];
    }
    return self;
}

- (id)modelAtIndexPath:(NSIndexPath *)indexPath {
    return _models[(NSUInteger) indexPath.row];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _models.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier
                                                            forIndexPath:indexPath];
    id model = [self modelAtIndexPath:indexPath];
    _configureCellBlock(cell, model, indexPath);
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

@end
