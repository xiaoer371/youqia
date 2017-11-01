//
//  MCSelectedContactsCellDataSource.h
//  NPushMail
//
//  Created by wuwenyu on 16/3/30.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ContactCellConfigureBlock)(id model, id cell, NSIndexPath *index);

@interface MCSelectedContactsCellDataSource : NSObject<UITableViewDataSource>

- (id)initWithModels:(NSArray *)models branchs:(NSArray *)branchs branchCellIdentifier:(NSString *)aCellIdentifier contactCellIdentifier:(NSString *)cCellIdentifier configureCellBlock:(ContactCellConfigureBlock)aConfigureCellBlock;
@property (nonatomic, strong) NSArray *models;
@property (nonatomic, strong) NSArray *branchs;
- (id)modelAtIndexPath:(NSIndexPath *)indexPath;

@end
