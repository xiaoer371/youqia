//
//  MCContactInfoDataSource.h
//  NPushMail
//
//  Created by wuwenyu on 16/2/17.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TableViewCellConfigureBlock)(id model, id cell, NSIndexPath *indexPath, NSMutableArray *phones, NSMutableArray *enterpriseContactInfos);

@interface MCContactInfoDataSource : NSObject<UITableViewDataSource>
- (id)initWithModels:(NSArray *)models cellIdentifier:(NSString *)aCellIdentifier configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock;
- (id)modelAtIndexPath:(NSIndexPath *)indexPath;
- (void)loadDataSource;
@property(nonatomic, strong) NSArray *models;
@end
