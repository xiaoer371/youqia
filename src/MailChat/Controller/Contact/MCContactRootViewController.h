//
//  MCContactRootViewController.h
//  NPushMail
//
//  Created by wuwenyu on 15/12/31.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import "MCBaseSubViewController.h"
#import "MCCellDataSource.h"
#import "MCContactArrayDataSource.h"

@interface MCContactRootViewController : MCBaseSubViewController <UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MCContactArrayDataSource *cellDataSource;
@property (nonatomic, strong) MCContactArrayDataSource *recentContactsCellDataSource;
@property (nonatomic, strong) MCCellDataSource *searchResultCellDataSource;
@property (nonatomic, strong) NSMutableArray *groupList;
@property (nonatomic, strong) MCAccount *currentAccount;
/**
 *  星标联系人
 */
@property (nonatomic, strong) NSMutableArray *importantContacts;
/**
 *  权重联系人
 */
@property (nonatomic, strong) NSMutableArray *weightsContacts;
/**
 *  联系人（包含权重和星标）
 */
@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSMutableArray *searchRusltArray;
@property (nonatomic, strong) NSMutableArray *sectionIndexArray;
- (void)updateGroups;
- (void)updateContacts;
- (void)loadDataSource;
- (void)setNavgationBarRightBtns;

@end
