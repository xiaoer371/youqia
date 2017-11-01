//
//  MCGestureManagerCellDataSource.m
//  NPushMail
//
//  Created by wuwenyu on 16/4/14.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCGestureManagerCellDataSource.h"
#import "MCGestureManagerCell.h"
#import "UITableView+Common.h"

@implementation MCGestureManagerCellDataSource {
    NSString *_cellIdentifier;
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
    return [_titles objectAtIndex:indexPath.row];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell = (MCGestureManagerCell *)[tableView dequeueReusableCellWithIdentifier:_cellIdentifier];
    [tableView addUpAndDownLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
    id model = [self modelAtIndexPath:indexPath];
    _configureCellBlock(model, cell, indexPath);
    return cell;
}

@end
