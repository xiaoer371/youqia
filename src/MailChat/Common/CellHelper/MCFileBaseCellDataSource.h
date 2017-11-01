//
//  MCFileBaseCellDataSource.h
//  NPushMail
//
//  Created by wuwenyu on 16/3/15.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TableViewCellConfigureBlock)(id model, id cell, NSIndexPath *indexPath);

typedef void (^deleteDataSourceCellBlock)(id model);

@interface MCFileBaseCellDataSource : NSObject<UITableViewDataSource>
@property (nonatomic, strong)     NSMutableArray *models;
@property (nonatomic, copy)    deleteDataSourceCellBlock deleteDataSourceCellBlock;

- (id)initWithModels:(NSMutableArray *)models cellIdentifier:(NSString *)aCellIdentifier configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock;
- (id)modelAtIndexPath:(NSIndexPath *)indexPath;

@end
