//
//  MCMailViewController.m
//  NPushMail
//
//  Created by zhang on 2016/12/21.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCMailViewController.h"
#import "MCVipListViewController.h"
#import "MCNormalListViewController.h"
#import "MCMailBoxListView.h"

#import "UIBarButtonItem+note.h"
#import "MCMailManager.h"
#import "MCAppSetting.h"
@interface MCMailViewController ()<MCMailBoxListViewDelegate>
//viewController
@property (nonatomic,strong)MCVipListViewController *vipListViewController;
@property (nonatomic,strong)MCNormalListViewController *normalListViewController;
@property (nonatomic,strong)MCMailBaseViewController *currentListViewController;
//views
@property (nonatomic,strong)MCMailBoxListView *boxListView;

//data
@property (nonatomic,strong)MCMailManager *mailManager;
@property (nonatomic,strong)MCMailBox *selectedFolder;
@property (nonatomic,strong)NSArray *folders;

@property (nonatomic,assign)BOOL isSmartBox;
@property (nonatomic,assign)BOOL newMailsNotificationEnable;

@end

@implementation MCMailViewController

- (id)init {
    if (self = [super init]) {
        self.isSmartBox = NO;
        self.newMailsNotificationEnable = YES;
        self.selectedFolder = [MCMailBox new];
        self.folders = [NSArray new];
    }
    return self;
}
//get
- (MCNormalListViewController *)normalListViewController {
    if (!_normalListViewController) {
        _normalListViewController = [[MCNormalListViewController alloc]init];
    }
    return _normalListViewController;
}
- (MCVipListViewController*)vipListViewController {
    if (!_vipListViewController) {
        _vipListViewController = [[MCVipListViewController alloc]init];
    }
    return _vipListViewController;
}

- (MCMailBoxListView*)boxListView {
    if (!_boxListView) {
        _boxListView = [[MCMailBoxListView alloc]init];
        _boxListView.delegate = self;
        [_boxListView show];
    }
    return _boxListView;
}

- (MCMailManager*)mailManager {
    if (!_mailManager) {
        _mailManager = [[MCMailManager alloc]initWithAccount:AppStatus.currentUser];
    }
    return _mailManager;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.changeAccountArrow setHidden:NO];
     self.currentListViewController.tabBarbadge.dragEnabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.currentListViewController.tabBarbadge.dragEnabled = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setSubviews];
    [self loadFolders];
    [self addNotification];
}

- (void)setSubviews {
    
    [self addSearchNavigationBarButtonItem];
    [self addRootViewSearchNavigationBarButtonItem];
    [self.rightNavigationBarButtonItem setImage:AppStatus.theme.mailStyle.mailListRightImage];
    [self.leftNavigationBarButtonItem setImage:AppStatus.theme.mailStyle.mailListLeftImage];
    [self.searchButton setImage:AppStatus.theme.mailStyle.mailListSearchImage forState:UIControlStateNormal];
    self.isSmartBox = AppSettings.smartBoxSelectEnable&&AppSettings.loadImportantMails;
    self.navBarTitleLable.text = self.isSmartBox?PMLocalizedStringWithKey(@"PM_Mail_SmartBox"):self.selectedFolder.name;
    self.currentListViewController = self.isSmartBox?self.vipListViewController:self.normalListViewController;
    [self addChildViewController:self.currentListViewController];
    self.currentListViewController.view.frame = self.view.bounds;
    self.currentListViewController.view.autoresizingMask = self.view.autoresizingMask;
    [self.view addSubview:self.currentListViewController.view];
    [self.currentListViewController didMoveToParentViewController:self];
}

#pragma mark -notification
- (void)addNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mcChangeAccoutReloadMailData:) name:MCNotificationDidChangeAccount object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mcReceiveApnsMails:) name:MCNotificationDidReceiveApnsMailPush object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mcReceiveMqttNotfication:) name:MCNotificationDidReceiveMqttMailPush object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mcReceiveContactMailStateChange:) name:MCNotificationContactMailStateChange object:nil];
}

#pragma mark - MCMailBoxListViewDelegate

- (void)mailBoxListView:(MCMailBoxListView *)mailBoxListView didSelectMailBox:(MCMailBox *)mailBoxModel smartBox:(BOOL)smartBox {
    self.selectedFolder = mailBoxModel;
    if (smartBox) {
        self.navBarTitleLable.text = PMLocalizedStringWithKey(@"PM_Mail_SmartBox");
        [self transitionFromViewController:self.currentListViewController toViewController:self.vipListViewController animate:NO finish:^{
            self.currentListViewController.folder = self.selectedFolder;
            self.currentListViewController.mailManager = self.mailManager;
            [self.currentListViewController loadMailDataSourceWithFolder:self.selectedFolder];
        }];
    } else {
        self.navBarTitleLable.text = mailBoxModel.name;
        if (self.isSmartBox) {
            [self transitionFromViewController:self.currentListViewController toViewController:self.normalListViewController animate:NO finish:^{
                self.currentListViewController.folder = self.selectedFolder;
                self.currentListViewController.mailManager = self.mailManager;
                [self.currentListViewController loadMailDataSourceWithFolder:self.selectedFolder];
            }];
            self.isSmartBox = smartBox;
            AppSettings.smartBoxSelectEnable = smartBox;
            [self.currentListViewController.tableView setContentOffset:CGPointMake(0,0) animated:NO];
            return;
        }
        self.currentListViewController.folder = self.selectedFolder;
        self.currentListViewController.mailManager = self.mailManager;
        [self.currentListViewController loadMailDataSourceWithFolder:self.selectedFolder];
    }
     self.isSmartBox = smartBox;
    AppSettings.smartBoxSelectEnable = smartBox;
    [self.currentListViewController.tableView setContentOffset:CGPointMake(0,0) animated:NO];
}

- (void)transitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController animate:(BOOL)animate finish:(dispatch_block_t)finish{
    
    if (fromViewController == toViewController)   {
        return;
    }
    toViewController.view.frame = self.view.bounds;
    toViewController.view.autoresizingMask =  self.view.autoresizingMask;
    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    
    [self transitionFromViewController:fromViewController
                      toViewController:toViewController
                              duration:animate?1.0:0.0
                               options:UIViewAnimationOptionTransitionFlipFromLeft
                            animations:^{}
                            completion:^(BOOL finished){
                                [toViewController didMoveToParentViewController:self];
                                [fromViewController removeFromParentViewController];
                                self.currentListViewController = (MCMailBaseViewController*)toViewController;
                                if (finish) {
                                    finish();
                                }
                            }];
}

#pragma mark - Folder
- (void)loadFolders {
    BOOL isAlreadyLoadMails = NO;
    NSArray *folders = [self.mailManager getLocalFoldersWithUserId:AppStatus.currentUser.accountId];
    if (folders.count > 0) {
        [self loadMailsWithFolders:folders];
        isAlreadyLoadMails = YES;
    }
    __weak typeof(self)weak = self;
    [self.mailManager getAllFoldersSuccess:^(id response) {
        if (![NSThread isMainThread]) {
            DDLogDebug(@"not mainthread");
        }
        NSArray *folders = (NSArray*)response;
        if (isAlreadyLoadMails) {
            NSInteger index = [folders indexOfObject:weak.selectedFolder];
            if (index != NSNotFound) {
                MCMailBox *folder = folders[index];
                folder.selectable = YES;
                folder.unreadCount = weak.selectedFolder.unreadCount;
                weak.selectedFolder = folder;
            }
        } else {
            weak.selectedFolder = folders[0];
            [weak loadMailsWithFolders:folders];
        }
        
    } failure:nil];
    
}
//loadMails
- (void)loadMailsWithFolders:(NSArray *)folders {
    
    self.folders = folders;
    self.selectedFolder = folders[0];
    self.boxListView.folders = folders;
    
    if (self.isSmartBox){
        self.navBarTitleLable.text = PMLocalizedStringWithKey(@"PM_Mail_SmartBox");
    } else {
        self.navBarTitleLable.text = self.selectedFolder.name;
    }
    self.currentListViewController.folder = self.selectedFolder;
    self.currentListViewController.mailManager = self.mailManager;
    [self.currentListViewController loadMailDataSourceWithFolder:self.selectedFolder];
}


#pragma mark-barItemAction
- (void)leftNavigationBarButtonItemAction:(id)sender {
    BOOL doAction = [self.currentListViewController navigationBarleftItemAction];
    if (doAction) {
        self.boxListView.change = !self.boxListView.change;
        [self.leftNavigationBarButtonItem showBarButtonNote:NO];
        self.newMailsNotificationEnable = YES;
    }
}
- (void)rightNavigationBarButtonItemAction:(id)sender {
    [self.currentListViewController navigationBarRightItemAction];
}
- (void)searchNavigationBarButtonItemAction:(id)sender {
    [self.currentListViewController navigationSearchItemAction];
}


#pragma mark - notificationAction

- (void)mcChangeAccoutReloadMailData:(NSNotification*)info {
    MCAccount *account = (MCAccount*)info.object;
    if (account.accountId == self.selectedFolder.accountId) {
        return;
    }
    self.selectedFolder = nil;
    self.boxListView.folders = nil;
    self.mailManager = [[MCMailManager alloc]initWithAccount:account];
    //切换账号清空上一账号数据
    if (self.isSmartBox) {
        self.currentListViewController.viewModel = [[MCSmartMailListViewModel alloc]init];
    } else {
        self.currentListViewController.viewModel = [[MCMailListViewModel alloc]init];
    }
    self.currentListViewController.viewModel.tableView = self.currentListViewController.tableView;
    self.currentListViewController.tableView.dataSource = self.currentListViewController.viewModel;
    [self.currentListViewController.tableView reloadData];
    //加载
    [self loadFolders];
    self.newMailsNotificationEnable = YES;
}

- (void)mcReceiveApnsMails:(NSNotification*)info {
    MCMailModel *mail = (MCMailModel*)info.object;
    if (mail) {
        [self.currentListViewController receivewApnsNotificationInfoMail:mail];
    }
}
//mqtt推送添加未读数
- (void)mcReceiveMqttNotfication:(NSNotification*)info {
    MCMailModel *mail = (MCMailModel*)info.object;
    if (mail) {
        if (mail.boxId != self.selectedFolder.uid) {
            for (MCMailBox *box in self.folders) {
                if (box.uid == mail.boxId && box.accountId == AppStatus.currentUser.accountId) {
                    if (box.unreadCount == NSNotFound) {
                        box.unreadCount = 0;
                    }
                    box.unreadCount += 1;
                    if (self.newMailsNotificationEnable) {
                        [self.leftNavigationBarButtonItem showBarButtonNote:YES];
                        self.newMailsNotificationEnable = NO;
                    }
                }
            }
        }
    }
}

//切换到待发送文件夹
- (void)didSelectedPendingBox {
    for (MCMailBox *box in self.folders) {
        if (box.type == MCMailFolderTypePending) {
            [self.boxListView resetSelectedBox:box];
            [self mailBoxListView:self.boxListView didSelectMailBox:box smartBox:NO];
            return;
        }
    }
}
- (void)mcReceiveContactMailStateChange:(NSNotification*)info {
    MCMailModel*mail = (MCMailModel*)info.object;
    NSDictionary *dic = info.userInfo;
    MCMailTags tags = [[dic valueForKey:@"state"] integerValue];
    BOOL mark = [[dic valueForKey:@"mark"] boolValue];
    [self.currentListViewController receivewContactMailStateChange:mail tags:tags mark:mark];
}

@end
