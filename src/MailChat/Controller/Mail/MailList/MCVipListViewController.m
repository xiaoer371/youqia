//
//  MCVipListViewController.m
//  NPushMail
//
//  Created by zhang on 2016/12/21.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCVipListViewController.h"
#import "MCMailDetailViewController.h"
#import "MCMailSelectedViewController.h"
#import "MCMailComposerViewController.h"
#import "MCBaseNavigationViewController.h"
#import "MCMailSearchViewController.h"
#import "MCMailMoveViewController.h"
#import "MCContactInfoViewController.h"
#import "MCWebViewController.h"

#import "MCViPMailListCell.h"
#import "MCSeparatorCell.h"
#import "MCMoreMailsCell.h"
#import "MCVipSectionHeaderView.h"

#import "MJRefresh.h"
#import "MCModelConversion.h"
#import "MCAccountConfig.h"
#import "MCMailTagManager.h"
#import "MCRepealView.h"
#import "MCMailBoxManager.h"
#import "MCContactManager.h"
#import "CustomIOSAlertView.h"
@interface MCVipListViewController ()<UITableViewDelegate,MCMailTableViewDelegate,MGSwipeTableCellDelegate,MailListCellDelegate>

@property (nonatomic,strong)MCSmartMailListViewModel *viewModel;

@end

const static CGFloat kMCVIPMailViewCellButtonWidth = 85.0;
const static CGFloat kMCMailListViewCellThresholdForOther = 1.0;
const static CGFloat kMCMailListViewCellPadding = 15.0;

static NSString *const kMCTableViewSectionHeaderIdentity = @"tableViewSectionHeaderIndentity";
static NSString *const kMCTableViewSectionFooterIdentity = @"tableViewSectionFooderIndentity";

static NSString *const kMCVipMailsNoteUrl = @"http://www.mailchat.cn/newsinfo.aspx?Id=17";

@implementation MCVipListViewController
@dynamic viewModel;
- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (void)setViews {
    [super setViews];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    longPressGesture.minimumPressDuration = 0.5;
    [self.tableView addGestureRecognizer:longPressGesture];
    
    [self.tableView registerNib:[MCVIPMailListCell mailCellNib] forCellReuseIdentifier:kMCVipMailCellIdentity];
    [self.tableView registerNib:[MCVIPMailListCell avatarMailCellNib] forCellReuseIdentifier:kMCVipAvatarMailCellIdentity];
    [self.tableView registerNib:[MCMoreMailsCell registNib] forCellReuseIdentifier:kMCMoreMailsCellId];
    [self.tableView registerNib:[MCSeparatorCell registNib] forCellReuseIdentifier:kMCSparatorCellId];
    [self.tableView registerClass:[MCVipSectionHeaderView class] forHeaderFooterViewReuseIdentifier:kMCTableViewSectionHeaderIdentity];
    
    [self addRefreshFunction];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.viewModel heightForRowWitIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.viewModel.mailList.count == 0) {
        return 0;
    }
    return 40;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    MCVipSectionHeaderView *sectionHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kMCTableViewSectionHeaderIdentity];
    sectionHeader.showVipNoteCallBack = ^{
        [self showVipMailsNoteAction];
    };
    sectionHeader.title = [self titleWithSection:section];
    sectionHeader.showVipNoteItem = section == 0?NO:YES;
    return sectionHeader;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSString*)titleWithSection:(NSInteger)section {
    NSString *title = nil;
    if (section == 0) {
        if (self.viewModel.importantMailCount == 0) {
            title = PMLocalizedStringWithKey(@"PM_Mail_NotImaportantAndUnreadMails");
        } else {
            title = PMLocalizedStringWithKey(@"PM_Mail_UnReadAndVipMail");
        }
        
    } else if (section == 1){
        if (self.viewModel.backlogMailCount > 0) {
            title = PMLocalizedStringWithKey(@"PM_Mail_backlogMails");
        } else {
            title = PMLocalizedStringWithKey(@"PM_Mail_OtherMails");
        }
    } else {
        title = PMLocalizedStringWithKey(@"PM_Mail_OtherMails");
    }
    return title;
}

//delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    MCVIPMailListCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    MCMailBoxManager*boxManager = [MCMailBoxManager new];
    MCMailBox *box = [boxManager getMailBoxWithAccount:self.folder.accountId path:cell.model.folder];
    MCMailDetailViewController *detailViewController = [[MCMailDetailViewController alloc]initWithMail:cell.model manager:self.mailManager delegate:self];
    detailViewController.mailbox = box;
    [self.navigationController pushViewController:detailViewController animated:YES];
    if (indexPath.section == 0) {
        [MCUmengManager importantEvent:mc_mail_important_view];
    }
}

//showMoreMails
- (void)showMoreMailsWithSection:(NSInteger)section {
 
    MCMailSelectedViewController *selectedViewController = [[MCMailSelectedViewController alloc]initWithMails:[self.viewModel mailListOfSection:section] selectType:MCSelectNormal didProcessMails:^(NSArray *mails, id obj, MCMailProcessType processType) {
        [self dealMails:mails toBox:obj processType:processType];
    }];
    selectedViewController.folder = self.folder;
    selectedViewController.mailManager = self.mailManager;
    selectedViewController.sectionTitle = [self titleWithSection:section];
    MCBaseNavigationViewController *nav = [[MCBaseNavigationViewController alloc]initWithRootViewController:selectedViewController];
    [self presentViewController:nav animated:NO completion:nil];
}
#pragma mark refresh
- (void)tableViewDidRefresh {
    __weak typeof(self) weak = self;
    [self.viewModel loadNewMailsSuccess:^(id response) {
        [self resetUnreadIcon];
        [weak.tableView reloadData];
        [weak.tableView.refreshView endRefreshWithResult:@"刷新成功"];
    } failure:^(NSError *error) {
        [weak.tableView.refreshView endRefreshWithResult:@"刷新失败"];
        [self loadMailsError:error];
    }];
}

//添加上下刷新控件
- (void)addRefreshFunction {
    if (!self.tableView.footer) {
        __weak typeof(self) weakSelf = self;
        MJRefreshBackStateFooter *refreshBackStateFooter = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
            [weakSelf.viewModel loadMoreMailsSuccess:^(id response) {
                [weakSelf resetUnreadIcon];
                [weakSelf.tableView reloadData];
                [weakSelf.tableView.footer endRefreshing];
            } failure:^(NSError *error) {
                [weakSelf.tableView.footer endRefreshing];
            }];
        }];
        refreshBackStateFooter.stateLabel.textColor = AppStatus.theme.fontTintColor;
        refreshBackStateFooter.mj_h = 60.0;
        self.tableView.footer = refreshBackStateFooter;
    }
}

//TODO:cell左右滑动 已读未读、收藏、删除、移动操作
-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell
  swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings
         expansionSettings:(MGSwipeExpansionSettings*) expansionSettings {
    
    MCVIPMailListCell *listCell = (MCVIPMailListCell*)cell;
    MCMailModel *mail = listCell.model;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (!indexPath) {
        return @[];
    }
    //已读未读
    if (direction == MGSwipeDirectionLeftToRight) {
        
        swipeSettings.transition = MGSwipeTransitionBorder;
        cell.leftExpansion.buttonIndex = 0;
        cell.leftExpansion.fillOnTrigger = NO;
        cell.leftExpansion.threshold = 0.8;
        
        NSString *rightButttonTitle = mail.isRead?PMLocalizedStringWithKey(@"PM_Mail_SetUnRead"):PMLocalizedStringWithKey(@"PM_Mail_SetRead");
        MGSwipeButton*rightButtton = [MGSwipeButton buttonWithTitle:rightButttonTitle backgroundColor:[UIColor colorWithHexString:@"52b2ea"] padding:kMCMailListViewCellPadding callback:^BOOL(MGSwipeTableCell *sender) {
            //友盟事件统计
            [MCUmengManager addEventWithKey:mc_mail_list_read];
            [sender  refreshButtons:YES];
            [self markReadMails:@[mail] markRead:!mail.isRead];
            
            if (indexPath.section == 0) {
                NSString *event = mail.isRead ? mc_mail_important_read : mc_mail_important_unread;
                [MCUmengManager importantEvent:event];
            }
            
            if (indexPath.section == [self.viewModel otherMailListSection] && mail.tags&MCMailTagImportant && !mail.isRead) {
                [self.viewModel toggleImportantMailAtIndexPath:indexPath];
            }
            return YES;
        }];
        
        rightButtton.buttonWidth = kMCVIPMailViewCellButtonWidth + 20;
        return @[rightButtton];
        
    } else if (indexPath.section == 1 && self.viewModel.backlogMailCount > 0){
        cell.rightExpansion.buttonIndex = 0;
        cell.rightExpansion.fillOnTrigger = YES;
        cell.rightExpansion.threshold = 1.1;
        CGFloat padding = kMCMailListViewCellPadding;
        MGSwipeButton * finish = [MGSwipeButton buttonWithTitle:PMLocalizedStringWithKey(@"PM_Common_Complite") backgroundColor:[UIColor colorWithHexString:@"4cd964"] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            [self markBacklogMail:mail mark:NO repealShow:YES];
            [MCUmengManager backlogEvent:mc_mail_backlog_vipListUnBacklog];
            return YES;
        }];
        return @[finish];
    } else {
        cell.rightExpansion.buttonIndex = -1;
        cell.rightExpansion.fillOnTrigger = YES;
        cell.rightExpansion.threshold = kMCMailListViewCellThresholdForOther;
        CGFloat padding = kMCMailListViewCellPadding;
        //删除
        MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:PMLocalizedStringWithKey(@"PM_Mail_DeleteMail") backgroundColor:[UIColor colorWithHexString:@"f54e46"] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            //友盟事件统计
            [MCUmengManager addEventWithKey:mc_mail_list_delete];
            if (mail.tags & MCMailTagImportant) {
                [MCUmengManager importantEvent:mc_mail_important_delete];
            }
            [self deleteOrMoveMails:@[mail] fromFolder:self.folder toFolder:nil
                         repealShow:YES];
            [sender refreshContentView];
            [sender refreshButtons:YES];
            return YES;
        }];
        trash.buttonWidth = kMCVIPMailViewCellButtonWidth;
        MGSwipeButton * flag = [MGSwipeButton buttonWithTitle:mail.tags& MCMailTagImportant? PMLocalizedStringWithKey(@"PM_Mail_UnMarkVIPMail"):PMLocalizedStringWithKey(@"PM_Mail_MrakVIPMail") backgroundColor:[UIColor colorWithHexString:@"f5b146"] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            [self markVipWithMails:@[mail] markVip:!mail.tags&MCMailTagImportant repealShow:YES];
            [sender refreshContentView];
            return YES;
        }];
        flag.buttonWidth = kMCVIPMailViewCellButtonWidth;
        //待办
        MGSwipeButton * backlog = [MGSwipeButton buttonWithTitle:PMLocalizedStringWithKey(@"PM_Mail_backlogMails") backgroundColor:[UIColor colorWithHexString:@"c7c7cc"] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            [self markBacklogMail:mail mark:YES repealShow:YES];
            [MCUmengManager backlogEvent:mc_mail_backlog_vipListBacklog];
            return YES;
        }];
        backlog.buttonWidth = kMCVIPMailViewCellButtonWidth;
        return @[trash, flag, backlog];
    }
    return nil;
}
-(void) swipeTableCell:(MGSwipeTableCell*) cell didChangeSwipeState:(MGSwipeState) state gestureIsActive:(BOOL) gestureIsActive {
    if (state == MGSwipeStateSwipingLeftToRight||
        state == MGSwipeStateSwipingRightToLeft) {
        [self.repealView dismiss];
    }
}
/*data*/
- (void)loadMailDataSourceWithFolder:(MCMailBox *)folder {
    DDLogVerbose(@"loadDataSource");
    [super loadMailDataSourceWithFolder:folder];
    __weak typeof(self) weakSelf = self;
    self.viewModel = [[MCSmartMailListViewModel alloc] initWithFolder:self.folder tableView:self.tableView];
    [self resetUnreadIcon];
    self.viewModel.tableViewCellBlock = ^UITableViewCell*(UITableView *tableView, NSIndexPath *indexPath, id data){
        NSString *reuseIdentity = weakSelf.loadAvatarForMailList ? kMCVipAvatarMailCellIdentity : kMCVipMailCellIdentity;
        MCVIPMailListCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentity];
        cell.delegate = weakSelf;
        cell.cellDelegate = weakSelf;
        cell.loadAvatar = weakSelf.loadAvatarForMailList;
        cell.model = data;
        cell.separatorInset = UIEdgeInsetsMake(0, weakSelf.loadAvatarForMailList?57:16, 0, 0);
        if (!cell.model.messageContentString) {
            [weakSelf.mailManager loadMailContent:cell.model inFolder:weakSelf.folder urgent:NO success:nil failure:nil];
        }
        return cell;
    };
    self.tableView.dataSource = self.viewModel;
    [self.tableView reloadData];
    MCBaseViewController*vc = (MCBaseViewController*)self.parentViewController;
    [vc startAnimationIndicatorView];
    [self.tableView.refreshView endRefresh];
    __weak typeof(self)weak = self;
    [self.viewModel loadNewMailsSuccess:^(id response) {
        DDLogVerbose(@"loadNewMailsSuccess");
        [weak.tableView reloadData];
        [weakSelf guideShow];
        [vc stopAnimationInducatorView];
        //性能需求暂时去掉
        [self analysisSentBox];
        [self resetUnreadIcon];
    } failure:^(NSError *error) {
        [self loadMailsError:error];
        [vc stopAnimationInducatorView];
    }];
    
    //show more
    __weak typeof(self)w = self;
    self.viewModel.showMoreMailsCallback = ^(NSInteger section) {
        [w showMoreMailsWithSection:section];
    };
}

- (void)tapAvatar:(MCVIPMailListCell *)cell contact:(MCContactModel *)contact {
    if (contact == nil) {
        return;
    }
    MCContactInfoViewController *contactInfoViewController = [[MCContactInfoViewController alloc]initFromType:fromReadMail contactModel:contact canEditable:NO isEnterprise:NO];
    [self .navigationController pushViewController:contactInfoViewController animated:YES];
}

#pragma mark - MCMailDetailViewControllerDelegate

- (void)mailDetailViewHandleMail:(MCMailModel *)mail  from:(MCMailBox*)fromBox moveTo:(MCMailBox *)mailBox {
    [self deleteOrMoveMails:@[mail] fromFolder:fromBox toFolder:mailBox repealShow:YES];
}

- (void)mailDetailViewHandleMail:(MCMailModel *)mail setRead:(BOOL)read {
    [self markReadMails:@[mail] markRead:read];
    if (!read) {
        NSIndexPath *indexPath = [self.viewModel indexPathOfMail:mail];
        if (indexPath.section == [self.viewModel otherMailListSection]) {
            if (mail.tags & MCMailTagImportant) {
                [self.viewModel toggleImportantMailAtIndexPath:indexPath];
            }
        }
    }
}

- (void)mailDetailViewHandleMail:(MCMailModel *)mail tag:(MCMailTags)tags mark:(BOOL)mark {
    if (tags == MCMailTagBacklog) {
        [self markBacklogMail:mail mark:mark repealShow:NO];
    } else {
        [self markVipWithMails:@[mail] markVip:mark repealShow:NO];
    }
}

- (MCMailModel*)mailDetailViewReadOtherFromMail:(MCMailModel *)mail toNext:(BOOL)next {
    MCMailModel *nextMail = nil;
    NSIndexPath *indexPath = [self.viewModel indexPathOfMail:mail];
    NSArray *mails = [self.viewModel mailListOfSection:indexPath.section];
    NSInteger index = [mails indexOfObject:mail];
    if (index != NSNotFound) {
        index = next?index+1:index -1;
        if (index >=0 && index < mails.count) {
            nextMail = mails[index];
            return nextMail;
        }
    }
    return nil;
}
//bar action
- (void)navigationBarRightItemAction {
    [super navigationBarRightItemAction];
    MCMailComposerViewController *mailComposerViewController = [[MCMailComposerViewController alloc]init];
    [self.navigationController pushViewController:mailComposerViewController animated:YES];
}

- (void)navigationSearchItemAction {
    
    NSArray *mails = [self.viewModel.mailList copy];
    MCMailSearchViewController *searchViewController = [[MCMailSearchViewController alloc]initMails:mails mailManager:self.mailManager processMailCallback:^(NSArray *mails, id obj, MCMailProcessType processType) {
        [self dealMails:mails toBox:obj processType:processType];
    }];
    
    searchViewController.mailbox = self.folder;
    MCBaseNavigationViewController *baseNav = [[MCBaseNavigationViewController alloc]initWithRootViewController:searchViewController];
    [self presentViewController:baseNav animated:NO completion:nil];
}
#pragma mark - 已读未读、收藏、删除
//删除移动并同步状态
- (void)deleteOrMoveMails:(NSArray*)mails  fromFolder:(MCMailBox*)fromBox toFolder:(MCMailBox*)toBox repealShow:(BOOL)repealShow{
    
    self.repealView.message = toBox?PMLocalizedStringWithKey(@"PM_Mail_DidMoveMails"):PMLocalizedStringWithKey(@"PM_Mail_DidDeleteMails");
    self.repealView.doItemTitle = PMLocalizedStringWithKey(@"PM_Mail_RepealMails");
    [self.viewModel deleteMails:mails];
    if (repealShow) {
        __weak typeof(self)weak = self;
        [self.repealView showWithUndoBlock:^{
            [weak.viewModel undo];
            [weak resetUnreadIcon];
        } commitBlock:^{
            [weak.viewModel commit];
            [weak.mailManager moveMails:mails fromFolder:fromBox toFolder:toBox success:nil failure:nil];
        }];
        
    } else {
        [self.mailManager moveMails:mails fromFolder:fromBox toFolder:toBox success:nil failure:nil];
    }
    [self resetUnreadIcon];
    //保存需撤销邮件
    
}
//设置并同步已读未读状态
- (void)markReadMails:(NSArray*)mails markRead:(BOOL)markRead {
    __block typeof(self)weakSelf = self;
    [self.mailManager setReadFlag:markRead forMails:mails success:^(id response) {
        [weakSelf.viewModel calculateUnreadCount];
        [weakSelf resetUnreadIcon];
    } failure:nil];
}
//收藏与否
- (void)markStarMails:(NSArray*)mails markStar:(BOOL)markStar {
    [self.mailManager setStarFlag:markStar forMails:mails success:nil failure:nil];
}

- (void)markVipWithMails:(NSArray*)mails markVip:(BOOL)markVip repealShow:(BOOL)repealShow {
    
    for (MCMailModel *mail in mails) {
        if (markVip) {
            mail.tags = mail.tags | MCMailTagImportant;
            [MCUmengManager importantEvent:mc_mail_important_set_important];
        } else {
            mail.tags = mail.tags &(~MCMailTagImportant);
            [MCUmengManager importantEvent:mc_mail_important_set_unimportant];
        }
        
        NSIndexPath *indexPath = [self.viewModel indexPathOfMail:mail];
        if (indexPath.section == 0) {
            if (!(mail.tags & MCMailTagImportant)) {
                [self.viewModel toggleImportantMailAtIndexPath:indexPath];
            }
        }else {
            if (mail.tags & MCMailTagImportant && !mail.isRead) {
                [self.viewModel toggleImportantMailAtIndexPath:indexPath];
            }
        }
    }
    [self.mailManager updateTagsMails:mails];
    //添加邮件权重
    NSInteger weight = markVip ? kMailChatContactWeightSetImportant : -kMailChatContactWeightSetImportant;
    [self addWeigth:weight withMails:mails];
    //展示撤销
    if (repealShow) {
        __weak typeof(self)weak = self;
        self.repealView.message = markVip?PMLocalizedStringWithKey(@"PM_Mail_DidMarkVip"):PMLocalizedStringWithKey(@"PM_Mail_DidUnMarkVip");
        self.repealView.doItemTitle = PMLocalizedStringWithKey(@"PM_Mail_RepealMails");
        [self.repealView showWithUndoBlock:^{
            [weak markVipWithMails:mails markVip:!markVip repealShow:NO];
        } commitBlock:^{}];
    }
}

- (void)markBacklogMail:(MCMailModel*)mail mark:(BOOL)mark repealShow:(BOOL)repealShow {
    if (mark) {
        mail.tags = mail.tags | MCMailTagBacklog;
    } else {
        mail.tags = mail.tags &(~MCMailTagBacklog);
    }
    [self.viewModel toggleBacklogMail:mail AtIndexPath:[self.viewModel indexPathOfMail:mail]];
    [self.mailManager updateTagsMails:@[mail]];
    if (repealShow) {
        self.repealView.message = mark?PMLocalizedStringWithKey(@"PM_Mail_BacklogSmartNote"):PMLocalizedStringWithKey(@"PM_Mail_BacklogFinishNote");
        self.repealView.doItemTitle = PMLocalizedStringWithKey(@"PM_Mail_RepealMails");
        [self.repealView showWithUndoBlock:^{
            [self markBacklogMail:mail mark:!mark repealShow:NO];
        } commitBlock:nil];
    }
}
- (void)receivewContactMailStateChange:(MCMailModel *)mail tags:(MCMailTags)tags mark:(BOOL)mark {
    NSIndexPath *indexPath = [self.viewModel indexPathOfMail:mail];
    if (indexPath) {
        NSArray *mails = [self.viewModel mailListOfSection:indexPath.section];
        mail = [mails objectAtIndex:indexPath.row];
        if (tags == MCMailTagBacklog) {
            [self markBacklogMail:mail mark:mark repealShow:NO];
        } else {
            [self markVipWithMails:@[mail] markVip:mark repealShow:NO];
        }
    }
}
//邮件编辑
//loogPress
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint p = [gestureRecognizer locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
        if (indexPath&&self.viewModel.backlogMailCount > 0 && indexPath.section == 1) {
            return;
        }
        [self beginEditingForIndexPath:indexPath];
    }
}
//become editing
- (void)beginEditingForIndexPath:(NSIndexPath*)indexPath{
    NSArray *mails = [self.viewModel mailListOfSection:indexPath.section];

    MCMailSelectedViewController *selectedViewController = [[MCMailSelectedViewController alloc]initWithMails:mails selectType:MCSelectDo didProcessMails:^(NSArray *mails, id obj, MCMailProcessType processType) {
        [self dealMails:mails toBox:obj processType:processType];
    }];
    selectedViewController.folder = self.folder;
    selectedViewController.mailManager = self.mailManager;
    selectedViewController.sectionTitle = [self titleWithSection:indexPath.section];
    MCBaseNavigationViewController *nav  = [[MCBaseNavigationViewController alloc]initWithRootViewController:selectedViewController];
    [self presentViewController:nav animated:NO completion:nil];
}

#pragma mark - Private
- (void)analysisSentBox
{
    MCAccountConfig *config = AppStatus.accountData.accountConfig;
    if (config.isSentMailAnalysised) {
        return;
    }
    
    MCMailBoxManager *boxManager = [[MCMailBoxManager alloc] init];
    MCMailBox *sentBox = [boxManager getMailBoxWithAccount:AppStatus.currentUser.accountId type:MCMailFolderTypeSent];
    if (!sentBox) {
        DDLogError(@"Cannot get sentBox for analysing important contacts");
        return;
    }
    
    MCMailTagManager *tagManager = [[MCMailTagManager alloc] init];
    [tagManager analysisSentBox:sentBox success:^{
        config.isSentMailAnalysised = YES;
//        [self.viewModel reloadData];
//        [self.tableView reloadData];
    } failure:^(NSError *error) {
        DDLogError(@"Analyis sentBox error = %@",error);
    }];
}

//add contact weight
- (void)addWeigth:(NSInteger)weigth withMails:(NSArray*)mails {
    
    for (MCMailModel *mail in  mails) {
        if (!mail.from.email) {
            return;
        }
        MCContactModel *contact = [MCModelConversion contactModelWithMailAddress:mail.from];
        [[MCContactManager sharedInstance] addWeight:weigth toContact:contact];
    }
}

//dealMails
- (void)dealMails:(NSArray*)mails toBox:(MCMailBox*)toBox  processType:(MCMailProcessType)processType  {
    switch (processType) {
        case MCMailProcessRead:
        {
            [self markReadMails:mails markRead:YES];
        }
            break;
        case MCMailProcessUnread:
        {
            [self markReadMails:mails markRead:NO];
        }
            break;
        case MCMailProcessStarred:
        {
            [self markStarMails:mails markStar:YES];
        }
            break;
        case MCMailProcessUnstarred:
        {
            [self markStarMails:mails markStar:NO];
        }
            break;
        case MCMailProcessMove:
        case MCMailProcessDelete:
        {
            [self deleteOrMoveMails:mails fromFolder:self.folder toFolder:toBox repealShow:NO];
        }
            break;
        case MCMailProcessVip:{
            [self markVipWithMails:mails markVip:YES repealShow:NO];
        }
            break;
        case MCMailProcessUnVip:{
            [self markVipWithMails:mails markVip:NO repealShow:NO];
        }
            break;
        case MCMailProcessUnBackLog:{
            [self mailDetailViewHandleMail:mails[0] tag:MCMailTagBacklog mark:NO];
        }break;
        case MCMailProcessBacklog:{
            [self mailDetailViewHandleMail:mails[0] tag:MCMailTagBacklog mark:YES];
            
        }
        default:
            break;
    }
}
//Note Action
- (void)showVipMailsNoteAction{
    MCWebViewController *webViewController = [[MCWebViewController alloc]initWithUrl:[NSURL URLWithString:kMCVipMailsNoteUrl]];
    [self.navigationController pushViewController:webViewController animated:YES];
}
@end
