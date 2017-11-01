//
//  MCContactArrayDataSource.h
//  NPushMail
//
//  Created by wuwenyu on 16/1/27.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ContactCellConfigureBlock)(id model, id cell, NSIndexPath *index);

@interface MCContactArrayDataSource : NSObject<UITableViewDataSource>

- (id)initWithGroupModels:(NSMutableArray *)amodels contactModels:(NSMutableArray *)bmodels groupCellIdentifier:(NSString *)aCellIdentifier contactCellIdentifier:(NSString *)bCellIdentifier configureCellBlock:(ContactCellConfigureBlock)aConfigureCellBlock;
- (id)modelAtIndexPath:(NSIndexPath *)indexPath;
@property (nonatomic, assign) NSMutableArray *groupModels;
@property (nonatomic, assign) NSMutableArray *contactModels;
@property (nonatomic, strong) NSMutableArray *indexTitles;
@end
