//
//  MCIMGropCellDataSource.m
//  NPushMail
//
//  Created by zhang on 16/7/19.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMGropCellDataSource.h"
#import "MCIMGroupModel.h"
#import "MCIMGroupManager.h"
#import "MCIMConversationManager.h"
@implementation MCIMGropCellDataSource {
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    MCIMGroupModel *model = _models[indexPath.row];
    model.isSaved = NO;
    [[MCIMGroupManager shared] updateGroup:model];
    MCIMConversationModel *conversationModel = [[MCIMConversationManager shared] conversationForGroup:model];
    [conversationModel setPeer:model];
    [_models removeObject:model];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    if (_deleteDataSourceBlock) {
        _deleteDataSourceBlock();
    }
}

@end
