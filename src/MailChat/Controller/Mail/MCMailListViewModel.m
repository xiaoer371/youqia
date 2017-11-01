//
//  MCMailListFolderDataSource.m
//  NPushMail
//
//  Created by admin on 8/24/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCMailListViewModel.h"
#import "MCAccountManager.h"

@interface MCMailListViewModel ()
@property (nonatomic,strong) MCAccount *account;
@property (nonatomic, strong) NSMutableArray *mails;
@end

@implementation MCMailListViewModel

- (instancetype)initWithFolder:(MCMailBox *)folder tableView:(UITableView *)tableView
{
    if (self = [super init]) {
        _mailFlag = MCMailFlagNone;
        _syncObj = [NSObject new];
        _tableView = tableView;
        _folder = folder;
        _account = [[MCAccountManager shared] accountWithId:folder.accountId];
        _syncManager = [[MCMailBoxSyncPool shared] syncManagerForFoler:folder];
        _windowSize = folder.showCount > kMailListFirstPageSize?folder.showCount:kMailListFirstPageSize;
        
        NSArray *localMails;
        if (folder.type == MCMailFolderTypeStarred && !folder.path) {
            localMails = [_syncManager getAllStarMails];
        } else if (folder.type == MCMailFolderTypePending){
            localMails = [_syncManager getPendingMails];
        } else {
            localMails  = [_syncManager getLocalMailsWithWindowSize:_windowSize];
        }
        [self updateMails:localMails];
    }
    return self;
}

- (NSInteger)windowSize {
    return  _folder.showCount > kMailListFirstPageSize?_folder.showCount:kMailListFirstPageSize;
}

#pragma mark - Public 

- (void)loadNewMailsSuccess:(SuccessBlock)success failure:(FailureBlock)failure
{
    [self loadMailsWithWindowSize:self.windowSize success:success failure:failure];
}

- (void)loadMoreMailsSuccess:(SuccessBlock)success failure:(FailureBlock)failure
{
    [self loadMailsWithWindowSize:_windowSize + kMailListPageSize success:^(NSArray *newMails) {
        _windowSize = newMails.count;
        if (success) {
            success(newMails);
        }
    } failure:failure];
}

- (void)updateMails:(NSArray *)newMails
{
    @synchronized (self.syncObj) {
        // Sorted by date
        self.mailList = [newMails sortedArrayUsingComparator:^NSComparisonResult(MCMailModel *obj1, MCMailModel *obj2) {
            return [obj2.receivedDate compare:obj1.receivedDate];
        }];
    }
    _mails = [_mailList mutableCopy];
    [self calculateUnreadCount];
}

- (void)deleteMails:(NSArray *)mails {
    
    NSMutableArray *indexPaths = [NSMutableArray new];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet new];
    for (MCMailModel *mail in mails) {
        NSInteger index = [_mailList indexOfObject:mail];
        if (index == NSNotFound) {
            continue;
        }
        [indexSet addIndex:index];
        [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        if (!mail.isRead) {
            self.unreadCount --;
        }
    }
    
    if (indexSet.count == 0) {
        return;
    }
    NSMutableArray *currentMails = [_mailList mutableCopy];
    [currentMails removeObjectsAtIndexes:indexSet];
    _mailList = [currentMails copy];
    [_mails removeObjectsInArray:mails];
    [_tableView beginUpdates];
    [_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
}

- (void)insertMail:(MCMailModel *)mail {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    NSMutableArray *currentMails = [_mailList mutableCopy];
    if (!currentMails) {
        currentMails = [NSMutableArray new];
    }
    [currentMails insertObject:mail atIndex:0];
    _mailList = [currentMails copy];
    [_mails insertObject:mail atIndex:0];
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
}

//sort
- (void)sortMails:(MCMailFlags)mailFlag {
    
    if (mailFlag == MCMailFlagNone) {
        _mailList = [_mails copy];
    } else if (mailFlag == MCMailFlagSeen) {
        NSMutableArray *sortArray = [NSMutableArray new];
        for (MCMailModel * mail in _mails) {
            if (!mail.isRead) {
                [sortArray addObject:mail];
            }
        }
        _mailList = sortArray;
        
    } else {
        NSMutableArray *sortArray = [NSMutableArray new];
        for (MCMailModel * mail in _mails) {
            if (mail.isStar) {
                [sortArray addObject:mail];
            }
        }
        _mailList = sortArray;
    }
    _mailFlag = mailFlag;
}

- (void)calculateUnreadCount
{
    NSInteger count = 0;
    for (MCMailModel *mail in self.mailList) {
        if (!mail.isRead) {
            count++;
        }
    }
    // 一次性赋值避免监听时候的跳动
    self.unreadCount = count;
    //记录加载数量
    self.folder.showCount = self.mailList.count;
}

- (MCMailModel *)mailForIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.mailList.count) {
        return self.mailList[indexPath.row];
    }
    
    return nil;
}

#pragma mark - Table View DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mailList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCMailModel *mail = self.mailList[indexPath.row];
    return self.tableViewCellBlock(tableView,indexPath,mail);
}

#pragma mark - Protected


#pragma mark - Private

- (void)loadMailsWithWindowSize:(NSInteger)windowSize success:(SuccessBlock)success failure:(FailureBlock)failure
{
    DDLogVerbose(@"[%s]",__func__);
    
    if (_folder.type == MCMailFolderTypePending) {
        success(nil);
        return;
    }
    
    if (_folder.type == MCMailFolderTypeStarred && !_folder.path) {
        [self updateMails: [_syncManager getAllStarMails]];
        [self sortMails:_mailFlag]; 
        [self.tableView reloadData];
        success(nil);
        return;
    }
    
    if (!_folder.path) {
        success(nil);
        DDLogDebug(@"文件夹不存在不可刷新操作");
        return;
    }
    __weak typeof(self)weakSelf = self;
    [self.syncManager getLatestMailsWithWindowSize:windowSize success:^(NSArray *newMails) {
        __strong typeof(weakSelf) sSelf = weakSelf;
        sSelf.windowSize = newMails.count;
        [sSelf updateMails:newMails];
        [sSelf sortMails:sSelf.mailFlag];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                success(newMails);
            }
        });
    } failure:^(NSError *error) {
        if (failure) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
    }];
}

@end
