//
//  MCCellDataSource.h
//  NPushMail
//
//  Created by wuwenyu on 16/1/26.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TableViewCellConfigureBlock)(id model, id cell, NSIndexPath *indexPath);

@interface MCCellDataSource : NSObject<UITableViewDataSource>

@property(nonatomic, strong) NSArray *models;
- (id)initWithModels:(NSArray *)models cellIdentifier:(NSString *)aCellIdentifier configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock;
- (id)modelAtIndexPath:(NSIndexPath *)indexPath;

@end
