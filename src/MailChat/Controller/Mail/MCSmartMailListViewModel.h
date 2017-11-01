//
//  MCSmartMailListDataSource.h
//  NPushMail
//
//  Created by admin on 8/29/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCMailListViewModel.h"
#import "MCMailManager.h"

typedef void(^ShowMoreMails)(NSInteger section);

@interface MCSmartMailListViewModel : MCMailListViewModel

@property (nonatomic,readonly) BOOL haveMoreVipMails;

@property (nonatomic,readonly) BOOL haveMoreBacklogMails;

@property (nonatomic,readonly) NSInteger importantMailCount;
@property (nonatomic,readonly) NSInteger backlogMailCount;

@property (nonatomic,copy) ShowMoreMails showMoreMailsCallback;

- (void)exchangeMailCellIfNeeded:(MCMailModel *)mail;

- (void)toggleImportantMailAtIndexPath:(NSIndexPath *)indexPath;

- (void)toggleBacklogMail:(MCMailModel*)mail AtIndexPath:(NSIndexPath *)indexPath;

- (NSArray *)mailListOfSection:(NSInteger)section;

- (NSIndexPath *)indexPathOfMail:(MCMailModel *)mail;

- (NSInteger)otherMailListSection;

- (void)reloadData;

#pragma mark - Delete and undo

- (void)deleteMails:(NSArray*)mails;

- (NSArray*)allVipMails;

- (void)commit;
- (void)undo;

- (CGFloat)heightForRowWitIndexPath:(NSIndexPath*)indexPath;
@end
