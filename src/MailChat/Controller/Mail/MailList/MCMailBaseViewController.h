//
//  MCMailBaseViewController.h
//  NPushMail
//
//  Created by zhang on 2016/12/21.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCMailViewController.h"
#import "MCMailModel.h"
#import "MCMailBox.h"
#import "MCMailListTableView.h"
#import "MCMailListViewModel.h"
#import "MCRepealView.h"
#import "MCAppSetting.h"

@interface MCMailBaseViewController : UIViewController
@property (nonatomic,strong)MCMailListTableView *tableView;
@property (nonatomic,strong)MCMailBox *folder;
@property (nonatomic,strong)NSArray *folders;
@property (nonatomic,strong)MCMailListViewModel *viewModel;
@property (nonatomic,strong)MCMailManager *mailManager;
@property (nonatomic,strong)MCMailViewController *parentVC;

@property (nonatomic,strong) RTDraggableBadge *tabBarbadge;
@property (nonatomic,assign)BOOL loadAvatarForMailList;

@property (nonatomic,strong)MCRepealView *repealView;
- (void)guideShow;

- (void)setViews;

- (void)receivewApnsNotificationInfoMail:(MCMailModel*)mail;

- (BOOL)receivewMqttNotificationInfoMailInCurrentFolder:(MCMailModel*)mail;

- (void)loadMailDataSourceWithFolder:(MCMailBox*)folder;

- (void)receivewContactMailStateChange:(MCMailModel*)mail tags:(MCMailTags)tags mark:(BOOL)mark;

- (BOOL)navigationBarleftItemAction;

- (void)navigationBarRightItemAction;

- (void)navigationSearchItemAction;
//
- (void)loadMailsError:(NSError*)error;
//store mails
- (void)markReadMails:(NSArray*)mails markRead:(BOOL)markRead;
//刷新未读数
- (void)resetUnreadIcon;

- (void)resetState;
@end
