//
//  MCContactMailsViewController.m
//  NPushMail
//
//  Created by zhang on 2016/12/27.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCContactMailsViewController.h"
#import "MCMailDetailViewController.h"
#import "MCNotificationCenter.h"
#import "MCVIPMailListCell.h"
#import "MCMailManager.h"
#import "MCMailBoxManager.h"
#import "UIScrollView+EmptyDataSet.h"
#import "MJRefresh.h"
@interface MCContactMailsViewController ()<UITableViewDelegate,UITableViewDataSource,MCMailDetailViewControllerDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
@property (nonatomic,strong)MCMailListTableView *tableView;
//data
@property (nonatomic,strong)NSArray *mailList;
@property (nonatomic,strong)MCMailManager *mailManager;
@property (nonatomic,strong)MCMailBoxManager *boxManager;
@end

@implementation MCContactMailsViewController

- (id)initWithContact:(MCContactModel*)contact {
    if (self = [super init]) {
        self.contactModel = contact;
        self.mailList = [NSArray new];
        self.mailManager = [[MCMailManager alloc]initWithAccount:AppStatus.currentUser];
        self.boxManager = [MCMailBoxManager new];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setSubViews];
    [self loadContactMails];
}

- (void)setSubViews {
    self.tableView = [[MCMailListTableView alloc]init];
    self.tableView.frame = CGRectMake(0, 0, ScreenWidth, CGRectGetHeight(self.view.frame));
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.rowHeight = 86.0f;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    [self.tableView registerNib:[MCVIPMailListCell mailCellNib] forCellReuseIdentifier:kMCVipMailCellIdentity];
    [self.view addSubview:self.tableView];
    [self addRefreshFunction];
}

- (void)loadContactMails {
    NSInteger count = self.mailList.count;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray*array = [self.mailManager getContactMailsWithEmail:self.contactModel.account fromIndex:self.mailList.count];
        NSMutableArray *mails = [self.mailList mutableCopy];
        [mails addObjectsFromArray:array];
        self.mailList = [mails copy];
        dispatch_async(dispatch_get_main_queue(), ^{
           [self.tableView reloadData];
           [self.tableView.footer endRefreshing];
            if (self.mailList.count - count < 20) {
                self.tableView.footer = nil;
            }
        });
    });
}

//添加上下刷新控件
- (void)addRefreshFunction {
    
    MJRefreshBackStateFooter *refreshBackStateFooter = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
        [self loadContactMails];
    }];
    refreshBackStateFooter.stateLabel.textColor = AppStatus.theme.fontTintColor;
    refreshBackStateFooter.mj_h = 60.0;
    self.tableView.footer = refreshBackStateFooter;
}

#pragma mark - delegate DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mailList.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCVIPMailListCell *cell = [tableView dequeueReusableCellWithIdentifier:kMCVipMailCellIdentity];
    cell.separatorInset = UIEdgeInsetsMake(0,16, 0, 0);
    MCMailModel *mail = self.mailList[indexPath.row];
    cell.loadAvatar = NO;
    cell.model = mail;
    if (!cell.model.messageContentString) {
        [self.mailManager loadMailContent:cell.model inFolder:nil urgent:NO success:nil failure:nil];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MCVIPMailListCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    MCMailBox *box = [self.boxManager getMailBoxWithAccount:AppStatus.currentUser.accountId path:cell.model.folder];
    MCMailDetailViewController *detailViewController = [[MCMailDetailViewController alloc]initWithMail:cell.model manager:self.mailManager delegate:self];
    detailViewController.mailbox = box;
    [self.navigationController pushViewController:detailViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - MCMailDetailViewControllerDelegate
- (void)mailDetailViewHandleMail:(MCMailModel *)mail tag:(MCMailTags)tags mark:(BOOL)mark {
    if (mark) {
        mail.tags = mail.tags|tags;
    } else {
        mail.tags = mail.tags&(~tags);
    }
    [self.mailManager updateTagsMails:@[mail]];
    //发送stateChange通知；
    [MCNotificationCenter postNotification:MCNotificationContactMailStateChange object:mail userInfo:@{@"state":@(tags),@"mark":@(mark)}];
}
- (void)mailDetailViewHandleMail:(MCMailModel *)mail from:(MCMailBox *)fromBox moveTo:(MCMailBox *)mailBox {
    NSMutableArray *mails = [self.mailList mutableCopy];
    if ([mails containsObject:mail]) {
        NSInteger index = [mails indexOfObject:mail];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [mails removeObject:mail];
        self.mailList = [mails copy];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        MCMailBox *box = [self.boxManager getMailBoxWithAccount:AppStatus.currentUser.accountId path:mail.folder];
        [self.mailManager moveMails:@[mail] fromFolder:box toFolder:mailBox success:nil failure:nil];
    }
    
}
- (void)mailDetailViewHandleMail:(MCMailModel *)mail setRead:(BOOL)read {
    [self.mailManager setReadFlag:read forMails:@[mail] success:nil failure:nil];
}

- (MCMailModel*)mailDetailViewReadOtherFromMail:(MCMailModel *)mail toNext:(BOOL)next {
    MCMailModel *nextMail = nil;
    NSInteger index = [self.mailList indexOfObject:mail];
    if (index != NSNotFound) {
        index = next?index+1:index -1;
        if (index >=0 && index < self.mailList.count) {
            nextMail = self.mailList[index];
            return nextMail;
        }
    }
    return nil;
}

#pragma mark - DZNEmptyDataSetSource Methods
- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:PMLocalizedStringWithKey(@"PM_Mail_NoneMails") attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0],NSForegroundColorAttributeName:AppStatus.theme.fontTintColor}];
    return attributedString;
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return 0;
}

- (UIImage*)imageForEmptyDataSet:(UIScrollView *)scrollView {
    
    return [UIImage imageNamed:@"mc_mailLlist_empty.png"];
}

- (UIColor*)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView {
    return AppStatus.theme.backgroundColor;
}

#pragma mark - DZNEmptyDataSetDelegate Methods

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return YES;
}

@end
