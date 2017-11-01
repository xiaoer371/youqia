//
//  MCSelectedRootContactCellDataSource.h
//  NPushMail
//
//  Created by wuwenyu on 16/4/27.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ContactCellConfigureBlock)(id model, id cell, NSIndexPath *index);

@interface MCSelectedRootContactCellDataSource : NSObject<UITableViewDataSource>
- (id)initWithModels:(NSArray *)models customGroups:(NSArray *)groups branchs:(NSArray *)branchs branchCellIdentifier:(NSString *)aCellIdentifier contactCellIdentifier:(NSString *)cCellIdentifier configureCellBlock:(ContactCellConfigureBlock)aConfigureCellBlock;
@property (nonatomic, strong) NSArray *models;
@property (nonatomic, strong) NSArray *branchs;
@property (nonatomic, strong) NSArray *groups;
- (id)modelAtIndexPath:(NSIndexPath *)indexPath;
@end
