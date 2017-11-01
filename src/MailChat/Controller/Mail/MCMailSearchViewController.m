//
//  MCMailSearchViewController.m
//  NPushMail
//
//  Created by zhang on 16/8/23.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCMailSearchViewController.h"
#import "MCMailDetailViewController.h"
#import "MCMailMoveViewController.h"
#import "MCBaseNavigationViewController.h"
#import "MCAppSetting.h"
#import "MCSearchBar.h"
#import "MCVIPMailListCell.h"
#import "MJRefresh.h"
#import "MCMailComposerViewController.h"
#import "MCContactInfoViewController.h"
@interface MCMailSearchViewController () <MCSearchBarDelegate,UITableViewDelegate,UITableViewDataSource,MGSwipeTableCellDelegate,MCMailDetailViewControllerDelegate,MailListCellDelegate>

@property (nonatomic,strong)UIButton *mcSearchServerButton;
@property (nonatomic,strong)UIView *searchLoadingView;
@property (nonatomic,strong)UILabel *noSearchResultView;
@property (nonatomic,strong)NSArray *mails;
@property (nonatomic,strong)NSMutableArray *searchMails;

@property (nonatomic,strong)MCMailManager *mailManager;
@property (nonatomic,copy)MCMailProcessBlock mailProcessCallback;

//是否加载无头像列表
@property (nonatomic,assign)BOOL toLoadAvatarForMailList;
@property (nonatomic,strong)NSString *mcSearchText;
@property (nonatomic,assign)NSInteger searchIndex;
@end

static NSString * const kMCMailCellIdentifier = @"MCMailCell";
static NSString * const KMCMailCellWithOutAvatarIdentifier = @"MCMailCellWithOutAvatar";
static NSString * const kMCMailListCell = @"MCMailListCell";

const static CGFloat kMCMailListViewCellHight   = 86.0;
const static CGFloat kMCMailListViewCellThresholdForRead = 0.8;
const static CGFloat kMCMailListViewCellThresholdForOther = 1.0;
const static CGFloat kMCMailListViewCellButtonWidth = 78.0;
const static CGFloat kMCMailListViewCellPadding = 15.0;

@implementation MCMailSearchViewController

- (id)initMails:(NSArray *)mails mailManager:(MCMailManager *)mailManager processMailCallback:(MCMailProcessBlock)mailProcessCallback{
    
    NSArray *scopes = @[PMLocalizedStringWithKey(@"PM_Mail_All"),
                        PMLocalizedStringWithKey(@"PM_Mail_MailSubject"),
                        PMLocalizedStringWithKey(@"PM_Mail_MailTo"),
                        PMLocalizedStringWithKey(@"PM_Mail_MailFrom")];
    
    if (self = [super initWithScopes:scopes]) {
        self.mails = mails;
        self.mailManager = mailManager;
        self.mailProcessCallback = mailProcessCallback;
        self.searchMails = [NSMutableArray new];
        _searchIndex = 0;
        _mcSearchText = @"";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    [self.mainTableView registerNib:[MCVIPMailListCell mailCellNib] forCellReuseIdentifier:kMCVipMailCellIdentity];
    [self.mainTableView registerNib:[MCVIPMailListCell avatarMailCellNib] forCellReuseIdentifier:kMCVipAvatarMailCellIdentity];
    self.mainTableView.rowHeight = kMCMailListViewCellHight;
    [self.mailManager beginSearchWithLocMails:_mails];
    _toLoadAvatarForMailList = AppSettings.loadAvatarCellForMailList;
}

#pragma mark -setup
- (UIButton*)mcSearchServerButton{
    if (!_mcSearchServerButton) {
        _mcSearchServerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _mcSearchServerButton.frame = CGRectMake(0, 0, ScreenWidth, 60);
        [_mcSearchServerButton addTarget:self action:@selector(searchBarSearchButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_mcSearchServerButton setTitle:PMLocalizedStringWithKey(@"PM_Mail_SearchServer") forState:UIControlStateNormal];
        [_mcSearchServerButton setTitleColor:AppStatus.theme.tintColor forState:UIControlStateNormal];
    }
    return _mcSearchServerButton;
}

- (UIView*)searchLoadingView {
    if (!_searchLoadingView) {
        _searchLoadingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 92)];
        _searchLoadingView.backgroundColor = [UIColor whiteColor];
        UIActivityIndicatorView*loadView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loadView.center = _searchLoadingView.center;
        [loadView startAnimating];
        [_searchLoadingView addSubview:loadView];
    }
    return _searchLoadingView;
}
//无结果标签
- (UILabel*)noSearchResultView {
    if (!_noSearchResultView) {
        _noSearchResultView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 92)];
        _noSearchResultView.font = [UIFont boldSystemFontOfSize:18.0f];
        _noSearchResultView.textAlignment = NSTextAlignmentCenter;
        _noSearchResultView.textColor = [UIColor grayColor];
        _noSearchResultView.text = PMLocalizedStringWithKey(@"PM_Mail_NoResults");
    }
    return _noSearchResultView;
}

#pragma mark - MCMailDetaiViewControllerDelegate

- (void)mailDetailViewHandleMail:(MCMailModel *)mail setRead:(BOOL)read {
    [self markReadMail:mail markRead:read];
}
- (void)mailDetailViewHandleMail:(MCMailModel *)mail from:(MCMailBox *)fromBox moveTo:(MCMailBox *)mailBox {
    [self deleteOrMoveMail:mail toFloder:mailBox];
}

- (void)mailDetailViewHandleMail:(MCMailModel *)mail tag:(MCMailTags)tags mark:(BOOL)mark {
    if (tags == MCMailTagBacklog) {
        self.mailProcessCallback(@[mail],nil,mark?MCMailProcessBacklog:MCMailProcessUnBackLog);
    } else {
        self.mailProcessCallback(@[mail],nil,mark?MCMailProcessVip:MCMailProcessUnVip);
    }
}

- (MCMailModel*)mailDetailViewReadOtherFromMail:(MCMailModel *)mail toNext:(BOOL)next {
    MCMailModel *nextMail = nil;
    NSInteger index = [self.mails indexOfObject:mail];
    if (index != NSNotFound) {
        index = next?index+1:index -1;
        if (index >=0 && index <self.mails.count) {
            nextMail = self.mails[index];
            return nextMail;
        }
    }
    return nil;
}

#pragma mark - UITableViewDelegate UITablViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _searchMails.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellid = _toLoadAvatarForMailList?kMCVipAvatarMailCellIdentity:kMCVipMailCellIdentity;
    MCVIPMailListCell*cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    cell.delegate = self;
    cell.cellDelegate = self;
    cell.loadAvatar = _toLoadAvatarForMailList;
    [cell.contentView setExclusiveTouch:YES];
    cell.rightSwipeSettings.transition = MGSwipeTransitionStatic;

    cell.separatorInset = UIEdgeInsetsMake(0, _toLoadAvatarForMailList?57:16, 0, 0);
    cell.mailBox = self.mailbox;
    MCMailModel *mail = _searchMails[indexPath.row];
    cell.model = mail;
    if (!mail.messageContentString) {
        [self.mailManager loadMailContent:mail inFolder:self.mailbox urgent:NO success:nil failure:nil];
    }
    return cell;
}

//delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchBar.textField resignFirstResponder];
    MCMailModel *mail = _searchMails [indexPath.row];
    
    if (_mailbox.type == MCMailFolderTypeDrafts) {
        MCMailComposerViewController *composerViewController = [[MCMailComposerViewController alloc]initWithMail:mail mailComposerOptionType:MCMailComposerFromDraft];
        [self.navigationController pushViewController:composerViewController animated:YES];
        
    } else if (_mailbox.type == MCMailFolderTypePending ){
        MCMailComposerViewController *composerViewController = [[MCMailComposerViewController alloc]initWithMail:mail mailComposerOptionType:MCMailComposerFromPending];
        [self.navigationController pushViewController:composerViewController animated:YES];
    }else {
        if (!mail.isRead) {
            self.mailProcessCallback(@[mail],nil,MCMailProcessRead);
        }
        MCMailDetailViewController *mailDetailViewController = [[MCMailDetailViewController alloc]initWithMail:mail manager:self.mailManager delegate:self];
        mailDetailViewController.mailbox = _mailbox;
        [self.navigationController pushViewController:mailDetailViewController animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark Swipe Delegate
-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;{
    return YES;
}
//TODO:cell左右滑动 已读未读、收藏、删除、移动操作
-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell
  swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings
         expansionSettings:(MGSwipeExpansionSettings*) expansionSettings {
    
    MCVIPMailListCell *listCell = (MCVIPMailListCell*)cell;
    MCMailModel*model = listCell.model;
    //已读未读
    if (direction == MGSwipeDirectionLeftToRight) {
        swipeSettings.transition = MGSwipeTransitionBorder;
        cell.leftExpansion.buttonIndex = 0;
        cell.leftExpansion.fillOnTrigger = NO;
        cell.leftExpansion.threshold = kMCMailListViewCellThresholdForRead;
        MGSwipeButton*read = [MGSwipeButton buttonWithTitle:model.isRead?PMLocalizedStringWithKey(@"PM_Mail_SetUnRead"):PMLocalizedStringWithKey(@"PM_Mail_SetRead") backgroundColor:[UIColor colorWithHexString:@"52b2ea"] padding:kMCMailListViewCellPadding callback:^BOOL(MGSwipeTableCell *sender) {
            //友盟事件统计
            [MCUmengManager addEventWithKey:mc_mail_list_read];
            [self markReadMail:model markRead:!model.isRead];
            [sender  refreshButtons:YES];
            return YES;
        }];
        
        read.buttonWidth = kMCMailListViewCellButtonWidth + 20;
        //草稿箱 待发送 ，不予标记已读未读
        if (_mailbox.type == MCMailFolderTypeDrafts || _mailbox.type == MCMailFolderTypePending) {
            return nil;
        }
        return @[read];
        
    } else {
        cell.rightExpansion.buttonIndex = -1;
        cell.rightExpansion.fillOnTrigger = YES;
        cell.rightExpansion.threshold = kMCMailListViewCellThresholdForOther;
        CGFloat padding = kMCMailListViewCellPadding;
        //删除
        MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:PMLocalizedStringWithKey(@"PM_Mail_DeleteMail") backgroundColor:[UIColor colorWithHexString:@"f54e46"] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            //友盟事件统计
            [MCUmengManager addEventWithKey:mc_mail_list_delete];
            [self deleteOrMoveMail:model toFloder:nil];
            return YES;
        }];
        trash.buttonWidth = kMCMailListViewCellButtonWidth;
        //收藏
        MGSwipeButton * flag = [MGSwipeButton buttonWithTitle:model.isStar? PMLocalizedStringWithKey(@"PM_Mail_UnCollection"):PMLocalizedStringWithKey(@"PM_Mail_Collection") backgroundColor:[UIColor colorWithHexString:@"f5b146"] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            //友盟事件统计
            [MCUmengManager addEventWithKey:mc_mail_list_star];
            self.mailProcessCallback(@[model],nil,model.isStar?MCMailProcessUnstarred:MCMailProcessStarred);
            [sender hideSwipeAnimated:YES];
            [sender refreshButtons:YES];
            return YES;
        }];
        flag.buttonWidth = kMCMailListViewCellButtonWidth;
        //移动
        MGSwipeButton * move = [MGSwipeButton buttonWithTitle:PMLocalizedStringWithKey(@"PM_Mail_MoveMail") backgroundColor:[UIColor colorWithHexString:@"c7c7cc"] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            //友盟事件统计
            [MCUmengManager addEventWithKey:mc_mail_list_move];
            
            MCMailMoveViewController *moveViewController = [[MCMailMoveViewController alloc]initWithCurrentMailBox:_mailbox manager:self.mailManager moveComplete:^(MCMailBox *toBox) {
                [self deleteOrMoveMail:model toFloder:toBox];
            }];
            MCBaseNavigationViewController *nav = [[MCBaseNavigationViewController alloc]initWithRootViewController:moveViewController];
            [self presentViewController:nav animated:YES completion:nil];
            
            return YES;
        }];
        move.buttonWidth = kMCMailListViewCellButtonWidth;
        //草稿箱，待发送只能删除；
        if (_mailbox.type == MCMailFolderTypeDrafts || _mailbox.type == MCMailFolderTypePending) {
            return @[trash];
        }
        if (_mailbox.type == MCMailFolderTypeStarred) {
            return @[trash,flag];
        }
        return @[trash, flag, move];
    }
    return nil;
}

- (void)tapAvatar:(MCVIPMailListCell *)cell contact:(MCContactModel *)contact {
    MCContactInfoViewController *contactInfoViewController = [[MCContactInfoViewController alloc]initFromType:fromReadMail contactModel:contact canEditable:NO isEnterprise:contact.isCompanyUser];
    [self.navigationController pushViewController:contactInfoViewController animated:YES];
}

#pragma mark - MCSearchBarDelegate

-(void)searchBar:(MCSearchBar *)searchBar textDidChange:(NSString *)searchText {
    _mcSearchText = searchText;
    if ([searchText trim].length == 0) return;
    NSArray *searchMails = [self.mailManager searchLocMailsSearchText:searchText searchKind:_searchIndex];
    _searchMails = [searchMails mutableCopy];
    [self.mainTableView reloadData];
    self.mainTableView.footer = nil;
    self.mainTableView.tableFooterView = self.mcSearchServerButton;
}
-(void)searchBarSearchAction:(MCSearchBar *)searchBar{
    [self searchMailsWithSearchText:_mcSearchText];
    [self.searchBar.textField resignFirstResponder];
}

//Private
- (void)searchBarSearchButtonClicked:(UIButton*)sender {
    [self searchMailsWithSearchText:_mcSearchText];
    [self.searchBar.textField resignFirstResponder];
}

- (void)selectedIndex:(NSInteger)index {
    _searchIndex = index;
    [self searchMailsWithSearchText:_mcSearchText];
}

//搜索服务器
- (void)searchMailsWithSearchText:(NSString*)searchText{
    
    if ([searchText trim].length == 0) {
        [_searchMails removeAllObjects];
        [self.mainTableView reloadData];
        return;
    }
    self.mainTableView.tableFooterView = self.searchLoadingView;
    NSArray *mails = [self.mailManager searchLocMailsSearchText:searchText searchKind:_searchIndex];
    _searchMails = [mails mutableCopy];
    [self.mainTableView reloadData];
    __block typeof(self)weakSelf = self;
    [self.mailManager searchFromServerWithFolder:_mailbox success:^(id response) {
        NSArray *searchRusltArray = (NSArray*)response;
        [weakSelf searchResultMails:searchRusltArray];
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mainTableView.tableFooterView = mails.count > 0?nil:weakSelf.noSearchResultView;
        });
    }];
}

- (void)searchResultMails:(NSArray*)mails {
    self.mainTableView.tableFooterView = mails.count > 0?nil:self.noSearchResultView;
    if (mails.count > 0) {
        _searchMails = [mails mutableCopy];
        [self.mainTableView reloadData];
        [self.mainTableView.footer endRefreshing];
        if (!self.mainTableView.footer) {
            MJRefreshBackStateFooter *refreshBackStateFooter = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
                __block typeof(self)weakSelf = self;
                [self.mailManager loadMoreSearchWithfolder:_mailbox success:^(id response) {
                    NSArray *resultMails = (NSArray*)response;
                    [weakSelf searchResultMails:resultMails];
                } failure:nil];
                
            }];
            self.mainTableView.footer = refreshBackStateFooter;
        }
    } else {
        self.mainTableView.footer = nil;
        self.mainTableView.tableFooterView = self.noSearchResultView;
    }
}

//标识已读未读 删除
- (void)markReadMail:(MCMailModel*)mail markRead:(BOOL)markRead {
    if (self.mailProcessCallback) {
        self.mailProcessCallback(@[mail],nil,markRead?MCMailProcessRead:MCMailProcessUnread);
    }
}
- (void)deleteOrMoveMail:(MCMailModel*)mail toFloder:(MCMailBox*)mailBox {
    self.mailProcessCallback(@[mail],mailBox,mailBox?MCMailProcessMove:MCMailProcessDelete);
    [self.mailManager deleteSearchMails:@[mail]];
    NSInteger index = [_searchMails indexOfObject:mail];
    if (index != NSNotFound) {
        [_searchMails removeObject:mail];
        [self.mainTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

@end
