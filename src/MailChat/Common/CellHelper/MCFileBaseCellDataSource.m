//
//  MCFileBaseCellDataSource.m
//  NPushMail
//
//  Created by wuwenyu on 16/3/15.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCFileBaseCellDataSource.h"
#import "MCFileManagerCell.h"
#import "MCFileCore.h"
#import "MCFileBaseModel.h"

@implementation MCFileBaseCellDataSource {
    NSString *_cellIdentifier;
    TableViewCellConfigureBlock _configureCellBlock;
}

- (id)initWithModels:(NSMutableArray *)amodels cellIdentifier:(NSString *)aCellIdentifier configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock {
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MCFileBaseModel *model = [self modelAtIndexPath:indexPath];
    [_models removeObjectAtIndex:indexPath.row];
    [[MCFileCore sharedInstance] deleteFileWithModel:model];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
    if (self.deleteDataSourceCellBlock) {
        self.deleteDataSourceCellBlock(model);
    }
}

@end
