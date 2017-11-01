//
//  MCSmartMailListDataSource.m
//  NPushMail
//
//  Created by admin on 8/29/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCSmartMailListViewModel.h"
#import "MCMailModel.h"
#import "MCContactManager.h"
#import "MCVipMailListCell.h"
#import "MCMoreMailsCell.h"
#import "MCSeparatorCell.h"
#import "MCAppSetting.h"

static NSInteger kSmartMailListImportantSectionCount = 3;
static NSInteger kSmartMailListBacklogSectionCount = 3;

@interface MCSmartMailListViewModel ()

@property (nonatomic, strong) NSMutableArray *importantMailList;
@property (nonatomic, strong) NSMutableArray *backlogMailList;
@property (nonatomic, strong) NSMutableArray *otherMailList;
@property (nonatomic, strong) NSArray *undoMailList;
@property (nonatomic, strong) NSArray *unBacklogMailList;

@end

@implementation MCSmartMailListViewModel


#pragma mark - Lifecycle
- (BOOL)haveMoreVipMails
{
    return self.importantMailList.count > kSmartMailListImportantSectionCount;
}

- (BOOL)haveMoreBacklogMails {
    return self.backlogMailList.count > kSmartMailListBacklogSectionCount;
}

- (NSInteger)importantMailCount
{
    return self.importantMailList.count;
}

- (NSInteger)backlogMailCount {
    return self.backlogMailList.count;
}

- (NSArray*)allVipMails {
    return self.importantMailList;
}

#pragma mark - Public
- (void)updateMails:(NSArray *)newMails {
    [super updateMails:newMails];
    self.backlogMailList = [[self.syncManager getLocalBackLogMails] mutableCopy];
    [self filterImportantMails:self.mailList];
}

- (NSArray *)mailListOfSection:(NSInteger)section
{
    if (section == 0) {
        return [self.importantMailList copy];
    }else if (section != [self otherMailListSection]){
        return [self.backlogMailList copy];
    }else {
        return [self.otherMailList copy];
    }
}

- (MCMailModel *)mailForIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row < self.importantMailList.count) {
            return self.importantMailList[indexPath.row];
        }
        
    } else if (indexPath.section == 1 && self.backlogMailCount > 0) {
        if (indexPath.row < self.backlogMailList.count) {
            return self.backlogMailList[indexPath.row];
        }
    } else if (indexPath.row < self.otherMailList.count) {
        return self.otherMailList[indexPath.row];
    }
    DDLogError(@"Mail not found for indexPath = %@",indexPath);
    return nil;
}

- (void)insertMail:(MCMailModel *)mail {
    NSMutableArray *currentMails = [self.mailList mutableCopy];
    if (!currentMails) {
        currentMails = [NSMutableArray new];
    }
    [currentMails insertObject:mail atIndex:0];
    self.mailList = [currentMails copy];
    [self reloadData];
    [self.tableView reloadData];
}


- (void)deleteMails:(NSArray *)mails {
    
    @synchronized (self.syncObj) {
        self.undoMailList = [self.mailList copy];
        self.unBacklogMailList = [self.backlogMailList copy];
        NSMutableArray *mMailList = [self.mailList mutableCopy];
        [mMailList removeObjectsInArray:mails];
        self.mailList = [mMailList copy];
        NSMutableArray *backlogMailList = [self.backlogMailList mutableCopy];
        NSInteger oldCount = backlogMailList.count;
        [backlogMailList removeObjectsInArray:mails];
        NSInteger newCount = backlogMailList.count;
        self.backlogMailList = [backlogMailList mutableCopy];
        [self filterImportantMails:self.mailList];
        if (self.mailList.count == 0 || newCount != oldCount) {
            [self.tableView reloadData];
        } else {
            [UIView performWithoutAnimation:^{
                [self.tableView beginUpdates];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:[self numberOfSectionsInTableView:self.tableView] - 1] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
            }];
            
        }
    }
    [self calculateUnreadCount];
}

- (void)undo
{
    if (self.syncObj) {
        self.mailList = [self.undoMailList copy];
        NSInteger oldCount = self.backlogMailCount;
        self.backlogMailList = [self.unBacklogMailList mutableCopy];
        NSInteger newCount = self.backlogMailCount;
        [self filterImportantMails:self.mailList];
        if (self.mailList.count == 1 || oldCount != newCount) {
            [self.tableView reloadData];
        } else {
            
            NSMutableIndexSet *indexSet = [NSMutableIndexSet new];
            [indexSet addIndex:0];
            [indexSet addIndex:[self numberOfSectionsInTableView:self.tableView] - 1];
            [UIView performWithoutAnimation:^{
                [self.tableView beginUpdates];
                [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
            }];
        }
        [self calculateUnreadCount];
    }
}

- (void)commit
{
    self.undoMailList = nil;
    self.unBacklogMailList = nil;
}

- (void)exchangeMailCellIfNeeded:(MCMailModel *)mail
{
    NSIndexPath *indexPath = [self indexPathOfMail:mail];
    if (indexPath.section == 0) {
        if (!mail.tags & MCMailTagImportant) {
            [self toggleImportantMailAtIndexPath:indexPath];
        }
    }
    else {
        if (mail.tags & MCMailTagImportant) {
            [self toggleImportantMailAtIndexPath:indexPath];
        }
    }
}

- (void)toggleBacklogMail:(MCMailModel*)mail AtIndexPath:(NSIndexPath *)indexPath {
    @synchronized (self.syncObj) {
        NSIndexPath *toIndexPath = nil;
        if (indexPath.section == 1 && self.backlogMailCount > 0) {
            
            if (!mail.isRead&&(mail.tags & MCMailTagImportant)) {
                NSInteger rowToInsert = [[self class] rowForMail:mail toInsertAtList:self.importantMailList];
                toIndexPath = [NSIndexPath indexPathForRow:rowToInsert inSection:1];
                [self.backlogMailList removeObject:mail];
                [self.importantMailList insertObject:mail atIndex:rowToInsert];
                
                if (self.backlogMailCount > 0) {
                    [UIView performWithoutAnimation:^{
                        [self.tableView beginUpdates];
                        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
                        [self.tableView endUpdates];
                    }];
                } else {
                    [self.tableView reloadData];
                }
            } else {
                NSInteger rowToInsert = [[self class] rowForMail:mail toInsertAtList:self.otherMailList];
                toIndexPath = [NSIndexPath indexPathForRow:rowToInsert inSection:2];
                [self.backlogMailList removeObject:mail];
                [self.otherMailList insertObject:mail atIndex:rowToInsert];
                
                if (self.backlogMailCount > 0) {
                    [UIView performWithoutAnimation:^{
                        [self.tableView beginUpdates];
                        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
                        [self.tableView insertRowsAtIndexPaths:@[toIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                        [self.tableView endUpdates];
                    }];
                    
                } else {
                    [self.tableView reloadData];
                }
            }
            
        } else  if (indexPath.section == 0){
            NSInteger rowToInsert = [[self class] rowForMail:mail toInsertAtList:self.backlogMailList];
            toIndexPath = [NSIndexPath indexPathForRow:rowToInsert inSection:0];
            [self.importantMailList removeObject:mail];
            [self.backlogMailList insertObject:mail atIndex:rowToInsert];
            
            
            if (self.backlogMailCount == 1) {
                [self.tableView reloadData];
            } else {
                [UIView performWithoutAnimation:^{
                    [self.tableView beginUpdates];
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.tableView endUpdates];
                }];
            }
            
        } else {
            NSInteger rowToInsert = [[self class] rowForMail:mail toInsertAtList:self.backlogMailList];
            toIndexPath = [NSIndexPath indexPathForRow:rowToInsert inSection:0];
            [self.otherMailList removeObject:mail];
            [self.backlogMailList insertObject:mail atIndex:rowToInsert];
            
            if (self.backlogMailCount == 1) {
                [self.tableView reloadData];
            } else {
            [UIView performWithoutAnimation:^{
                [self.tableView beginUpdates];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
            }];
            
            }
        }
    }
}

- (void)toggleImportantMailAtIndexPath:(NSIndexPath *)indexPath
{
    @synchronized (self.syncObj) {
        NSIndexPath *toIndexPath = nil;
        if (indexPath.section == 0) {
            MCMailModel *mail = self.importantMailList[indexPath.row];
            NSInteger rowToInsert = [[self class] rowForMail:mail toInsertAtList:self.otherMailList];
            toIndexPath = [NSIndexPath indexPathForRow:rowToInsert inSection:self.backlogMailCount > 0 ? 2:1];
            
            [self.importantMailList removeObjectAtIndex:indexPath.row];
            [self.otherMailList insertObject:mail atIndex:rowToInsert];
            
            [UIView performWithoutAnimation:^{
                [self.tableView beginUpdates];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView insertRowsAtIndexPaths:@[toIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
            }];
        }
        else {
            
            MCMailModel *mail = self.otherMailList[indexPath.row];
            NSInteger rowToInsert = [[self class] rowForMail:mail toInsertAtList:self.importantMailList];
            
            [self.otherMailList removeObjectAtIndex:indexPath.row];
            [self.importantMailList insertObject:mail atIndex:rowToInsert];
            [UIView performWithoutAnimation:^{
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
            }];
        }
    }
}

#pragma mark - Table View DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    DDLogVerbose(@"numberOfSectionsInTableView");
    if (self.mailList.count > 0) {
        
        if (self.backlogMailCount > 0) {
            return 3;
        }
        return 2;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger sectionCount = [self numberOfSectionsInTableView:tableView];
    if (sectionCount == 0) {
        return 0;
    } else if (sectionCount == 2) {
        
        switch (section) {
            case 0:{
                
                if (!self.importantMailList) {
                    return 1;
                } else if (self.importantMailList.count <= kSmartMailListImportantSectionCount) {
                    return self.importantMailList.count +1;
                }
                return kSmartMailListImportantSectionCount +2;
            }
             break;
                
            case 1: {
                 return self.otherMailList.count;
            }
             break;
        }
        
    }else {
        switch (section) {
            case 0:
            {
                if (!self.importantMailList) {
                    return 1;
                } else if (self.importantMailList.count <= kSmartMailListImportantSectionCount) {
                    return self.importantMailList.count +1;
                }
                return kSmartMailListImportantSectionCount +2;
            }
                break;
            case 1:
            {
                if (self.backlogMailList.count <= kSmartMailListBacklogSectionCount) {
                    return self.backlogMailList.count +1;
                }
                return kSmartMailListBacklogSectionCount +2;
            }
                break;
            case 2:
            {
                 return self.otherMailList.count;
            }
                break;
        }
        
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCMailModel *mail = nil;
    
    NSInteger sectionCount = [self numberOfSectionsInTableView:tableView];
    if (sectionCount == 0) {
        return nil;
    } else if (sectionCount == 2) {
        switch (indexPath.section) {
            case 0:
            {
                if (self.haveMoreVipMails && indexPath.row == kSmartMailListImportantSectionCount) {
                    MCMoreMailsCell *cell = [tableView dequeueReusableCellWithIdentifier:kMCMoreMailsCellId];
                    cell.separatorInset = UIEdgeInsetsMake(0,0,0,0);
                    cell.mailCount = self.importantMailList.count;
                    cell.showMoreMailsCallback = ^ {
                        if (self.showMoreMailsCallback) {
                            self.showMoreMailsCallback (indexPath.section);
                        }
                    };
                    return cell;
                    
                } else if (indexPath.row == [self tableView:tableView numberOfRowsInSection:0] -1) {
                    MCSeparatorCell *cell = [tableView dequeueReusableCellWithIdentifier:kMCSparatorCellId];
                    return cell;
                }
                @try {
                    mail = _importantMailList[indexPath.row];
                } @catch (NSException *exception) {} @finally {}
               
            }
                break;
            case 1:
            {
                @try {
                    mail = _otherMailList[indexPath.row];
                } @catch (NSException *exception) {} @finally {}
            }
                break;
        }
    } else {
        switch (indexPath.section) {
            case 0:
            {
                if (self.haveMoreVipMails && indexPath.row == kSmartMailListImportantSectionCount) {
                    MCMoreMailsCell *cell = [tableView dequeueReusableCellWithIdentifier:kMCMoreMailsCellId];
                    cell.separatorInset = UIEdgeInsetsMake(0,0,0,0);
                    cell.mailCount = self.importantMailList.count;
                    cell.showMoreMailsCallback = ^ {
                        if (self.showMoreMailsCallback) {
                            self.showMoreMailsCallback (indexPath.section);
                        }
                    };
                    return cell;
                    
                } else if (indexPath.row == [self tableView:tableView numberOfRowsInSection:0] -1) {
                    MCSeparatorCell *cell = [tableView dequeueReusableCellWithIdentifier:kMCSparatorCellId];
                    return cell;
                }
                @try {
                    mail = _importantMailList[indexPath.row];
                } @catch (NSException *exception) {} @finally {}
            }
                break;
            case 1:
            {
                if (self.haveMoreBacklogMails && indexPath.row == kSmartMailListBacklogSectionCount) {
                    MCMoreMailsCell *cell = [tableView dequeueReusableCellWithIdentifier:kMCMoreMailsCellId];
                    cell.separatorInset = UIEdgeInsetsMake(0,0,0,0);
                    cell.mailCount = self.backlogMailList.count;
                    cell.showMoreMailsCallback = ^ {
                        if (self.showMoreMailsCallback) {
                            self.showMoreMailsCallback (indexPath.section);
                        }
                    };
                    return cell;
                    
                } else if (indexPath.row == [self tableView:tableView numberOfRowsInSection:1] -1) {
                    MCSeparatorCell *cell = [tableView dequeueReusableCellWithIdentifier:kMCSparatorCellId];
                    return cell;
                }
                @try {
                    mail = _backlogMailList[indexPath.row];
                } @catch (NSException *exception) {} @finally {}
            }
                break;
            case 2:
            {
                @try {
                    mail = _otherMailList[indexPath.row];
                } @catch (NSException *exception) {} @finally {}
            }
                break;
        }
    }
    
    return self.tableViewCellBlock(tableView,indexPath,mail);
}

- (CGFloat)heightForRowWitIndexPath:(NSIndexPath*)indexPath {
    
    if (indexPath.section == 0) {
        if (self.haveMoreVipMails && indexPath.row == kSmartMailListImportantSectionCount) {
            return 40;
            
        } else if (indexPath.row == [self tableView:self.tableView numberOfRowsInSection:indexPath.section]-1) {
            return 12;
        }
    }
    
    if (self.backlogMailCount > 0) {
        if (indexPath.section == 1) {
            if (self.haveMoreBacklogMails && indexPath.row == kSmartMailListBacklogSectionCount) {
                return 40;
                
            } else if (indexPath.row == [self tableView:self.tableView numberOfRowsInSection:1]-1) {
                return 12;
            }
        }
    }
    
    return 86;
}

- (void)filterImportantMails:(NSArray *)mails
{
    DDLogVerbose(@"filterImportantMails");
    NSMutableArray *importantList = [NSMutableArray new];
    NSMutableArray *otherList = [[NSMutableArray alloc] initWithCapacity:mails.count];
    
    for (MCMailModel *mail in mails) {
        if ([self.backlogMailList containsObject:mail]) {
            NSInteger index = [self.backlogMailList indexOfObject:mail];
            MCMailModel *backlogMail = [self.backlogMailList objectAtIndex:index];
            mail.tags = backlogMail.tags;
            [self.backlogMailList replaceObjectAtIndex:index withObject:mail];
        } else if (!mail.isRead&&mail.tags & MCMailTagImportant) {
            [importantList addObject:mail];
        }
        else {
            [otherList addObject:mail];
        }
    }
    @synchronized (self.syncObj) {
        _importantMailList = importantList;
        _otherMailList = otherList;
    }
}

- (void)reloadData
{
    [self filterImportantMails:self.mailList];
}

#pragma mark - Private

- (NSIndexPath *)indexPathOfMail:(MCMailModel *)mail
{
    NSUInteger rowIndex = NSNotFound;
    
    rowIndex = [self.backlogMailList indexOfObject:mail];
    if (rowIndex != NSNotFound) {
        return [NSIndexPath indexPathForRow:rowIndex inSection:1];
    }
    rowIndex = [self.importantMailList indexOfObject:mail];
    if (rowIndex != NSNotFound) {
        return [NSIndexPath indexPathForRow:rowIndex inSection:0];
    }
    rowIndex = [self.otherMailList indexOfObject:mail];
    if (rowIndex != NSNotFound) {
        return [NSIndexPath indexPathForRow:rowIndex inSection:[self otherMailListSection]];
    }
    
    return nil;
}


- (NSInteger)otherMailListSection {
    if (self.backlogMailCount > 0) {
        return 2;
    }
    return 1;
}

#pragma mark - Class methods

+ (NSUInteger)rowForMail:(MCMailModel *)mail toInsertAtList:(NSArray *)mails
{
    for (NSInteger i = 0; i < mails.count; i++) {
        MCMailModel *m = mails[i];
        if ([mail.receivedDate compare:m.receivedDate] != NSOrderedAscending) {
            return i;
        }
    }
    
    return mails.count;
}

@end
