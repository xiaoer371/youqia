//
//  MCIMGropCellDataSource.h
//  NPushMail
//
//  Created by zhang on 16/7/19.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TableViewCellConfigureBlock)(id model, id cell, NSIndexPath *indexPath);

@interface MCIMGropCellDataSource : NSObject<UITableViewDataSource>

@property(nonatomic, strong) NSMutableArray *models;

@property(nonatomic, copy)dispatch_block_t deleteDataSourceBlock;

- (id)initWithModels:(NSMutableArray *)models cellIdentifier:(NSString *)aCellIdentifier configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock;
- (id)modelAtIndexPath:(NSIndexPath *)indexPath;


@end
