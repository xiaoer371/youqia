//
//  MCAddContactCellDataSource.h
//  NPushMail
//
//  Created by wuwenyu on 16/8/15.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TableViewCellConfigureBlock)(id model, id cell, NSIndexPath *indexPath);
typedef void (^commitEditingCellBlock)(UITableView *tableView, UITableViewCellEditingStyle editingStyle, NSIndexPath *indexPath);

static const CGFloat maxPhonesCanAdd = 5;

@interface MCAddContactCellDataSource : NSObject<UITableViewDataSource>
- (id)initWithBaseInfos:(NSMutableArray *)baseInfos phones:(NSMutableArray *)phones baseInfoCellIdentifier:(NSString *)aCellIdentifier settingCellIdentifier:(NSString *)bCellIdentifier configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock commitEditingCellBlock:(commitEditingCellBlock)commitEditingCellBlock;
- (id)modelAtIndexPath:(NSIndexPath *)indexPath;
/**
 *  基础信息，如姓名，邮箱地址
 */
@property(nonatomic ,strong) NSMutableArray *baseInfos;
/**
 *  电话号码
 */
@property(nonatomic ,strong) NSMutableArray *phones;
/**
 *  是否可删除的联系人（编辑联系人的时候可删除）
 */
@property(nonatomic ,assign) BOOL enableDeleteFlag;
@end
