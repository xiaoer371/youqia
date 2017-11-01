//
//  MCMailListFolderDataSource.h
//  NPushMail
//
//  Created by admin on 8/24/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCMailBox.h"
#import "MCMailModel.h"
#import "MCMailBoxSyncPool.h"

static const NSInteger kMailListFirstPageSize = 20;
static const NSInteger kMailListPageSize = 10;

typedef UITableViewCell* (^MCConfigTableViewCellBlock)(UITableView *tableView, NSIndexPath *indexPath, id data);

@interface MCMailListViewModel : NSObject<UITableViewDataSource>

#pragma mark - Properties

@property (nonatomic,weak) UITableView *tableView;
@property (nonatomic, strong) MCMailBoxSyncManager *syncManager;
@property (nonatomic,strong) MCMailBox *folder;
@property (atomic,strong) NSObject *syncObj;
@property (nonatomic, strong) NSArray *mailList;
@property (nonatomic, assign) NSInteger windowSize;
@property (nonatomic, assign) MCMailFlags mailFlag;
/**
 *  Total unread count
 */
@property (nonatomic,assign) NSInteger unreadCount;

/**
 *  配置TableViewCell，请注意循环引用问题
 */
@property (nonatomic,copy) MCConfigTableViewCellBlock tableViewCellBlock;


#pragma mark - .ctor

- (instancetype)initWithFolder:(MCMailBox *)folder tableView:(UITableView *)tableView;

#pragma mark - Public 

- (void)loadNewMailsSuccess:(SuccessBlock)success failure:(FailureBlock)failure;

- (void)loadMoreMailsSuccess:(SuccessBlock)success failure:(FailureBlock)failure;

- (void)calculateUnreadCount;

- (MCMailModel *)mailForIndexPath:(NSIndexPath *)indexPath;

- (void)sortMails:(MCMailFlags)mailFlag;

- (void)deleteMails:(NSArray*)mails;

- (void)insertMail:(MCMailModel*)mail;
@end

@interface MCMailListViewModel (Protected)
- (void)sortMails:(MCMailFlags)mailFlag;
- (void)updateMails:(NSArray *)newMails;
@end
