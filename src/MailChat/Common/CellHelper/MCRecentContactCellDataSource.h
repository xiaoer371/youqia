//
//  MCRecentContactCellDataSource.h
//  NPushMail
//
//  Created by wuwenyu on 16/4/6.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ContactCellConfigureBlock)(id model, id cell, NSIndexPath *index);

@interface MCRecentContactCellDataSource : NSObject<UITableViewDataSource>
- (id)initWithContactModels:(NSMutableArray *)bmodels contactCellIdentifier:(NSString *)cellIdentifier configureCellBlock:(ContactCellConfigureBlock)aConfigureCellBlock;
- (id)modelAtIndexPath:(NSIndexPath *)indexPath;
@property (nonatomic, assign) NSMutableArray *contactModels;
@property (nonatomic, strong) NSMutableArray *indexTitles;
@end
