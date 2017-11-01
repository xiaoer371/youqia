//
//  MCGestureManagerCellDataSource.h
//  NPushMail
//
//  Created by wuwenyu on 16/4/14.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ContactCellConfigureBlock)(id model, id cell, NSIndexPath *index);

@interface MCGestureManagerCellDataSource : NSObject<UITableViewDataSource>

- (id)initWithContactModels:(NSArray *)bmodels contactCellIdentifier:(NSString *)cellIdentifier configureCellBlock:(ContactCellConfigureBlock)aConfigureCellBlock;
- (id)modelAtIndexPath:(NSIndexPath *)indexPath;
@property (nonatomic, assign) NSArray *titles;
@end
