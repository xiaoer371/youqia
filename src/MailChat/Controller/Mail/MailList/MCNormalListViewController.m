//
//  MCNormalListViewController.m
//  NPushMail
//
//  Created by zhang on 2016/12/21.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCNormalListViewController.h"
#import "MCContactInfoViewController.h"
#import "MCVIPMailListCell.h"
#import "MCMailEditingView.h"
#import "MCMailManagerView.h"
#import "MJRefresh.h"
#import "MCMailMoveViewController.h"
#import "MCMailDetailViewController.h"
#import "MCMailComposerViewController.h"
#import "MCBaseNavigationViewController.h"
#import "MCMailSearchViewController.h"

@interface MCNormalListViewController () <UITableViewDelegate,MCMailEditingViewDelegate,MCMailManagerViewDelegate,MGSwipeTableCellDelegate,MCMailDetailViewControllerDelegate,MailListCellDelegate>

@property (nonatomic,strong)MCMailEditingView *editingView;
@property (nonatomic,strong)MCMailManagerView *managerView;
//data
@property (nonatomic,strong)NSMutableDictionary *didSelectMails;

@property (nonatomic,assign)BOOL tableViewEditting;

@end

const static CGFloat kMCMailListViewCellHight   = 86.0;
const static CGFloat kMCMailListViewCellThresholdForRead = 0.8;
const static CGFloat kMCMailListViewCellThresholdForOther = 1.0;
const static CGFloat kMCMailListViewCellButtonWidth = 78.0;
const static CGFloat kMCMailListViewCellPadding = 15.0;

@implementation MCNormalListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _didSelectMails = [NSMutableDictionary new];
    // Do any additional setup after loading the view from its nib.
}

- (void)setViews {
    [super setViews];
    [self.tableView registerNib:[MCVIPMailListCell mailCellNib] forCellReuseIdentifier:kMCVipMailCellIdentity];
    [self.tableView registerNib:[MCVIPMailListCell avatarMailCellNib] forCellReuseIdentifier:kMCVipAvatarMailCellIdentity];
    self.tableView.rowHeight = kMCMailListViewCellHight;
    [self addRefreshFunction];
}

- (void)setNavigationBarEdittingState:(BOOL)editState{
    self.parentVC.changeAccountBtn.userInteractionEnabled = !editState;
    self.tableViewEditting = editState;
    [self.parentVC.rightNavigationBarButtonItem setTitle:editState?PMLocalizedStringWithKey(@"PM_Common_Cancel"):nil];
    [self.parentVC.leftNavigationBarButtonItem setTitle:editState?PMLocalizedStringWithKey(@"PM_Mail_SelectAll"):nil];
    [self.parentVC.rightNavigationBarButtonItem setImage:editState?nil:AppStatus.theme.mailStyle.mailListRightImage];
    [self.parentVC.leftNavigationBarButtonItem setImage:editState?nil:AppStatus.theme.mailStyle.mailListLeftImage];
    [self.parentVC.searchButton setImage:editState?nil:AppStatus.theme.mailStyle.mailListSearchImage forState:UIControlStateNormal];
    self.parentVC.searchNavigationBarButtonItem.enabled = !editState;
}


#pragma mark -views
- (MCMailEditingView*)mailEditingView{
    
    if (!_editingView) {
        _editingView = [[MCMailEditingView alloc]init];
        _editingView.delegate = self;
    }
    return _editingView;
}
- (MCMailManagerView*)mailManagerView{
    if (!_managerView) {
        _managerView = [[MCMailManagerView alloc]init];
        _managerView.delegate = self;
        [self.parentVC.tabBarController.tabBar addSubview:_managerView];
    }
    return _managerView;
}

- (void)resetState {
    [self.editingView reset];
}

//TODO:加载邮件
- (void)loadMailDataSourceWithFolder:(MCMailBox *)folder {
    [super loadMailDataSourceWithFolder:folder];
    __weak typeof(self)weakSelf = self;
    self.viewModel = [[MCMailListViewModel alloc]initWithFolder:folder tableView:self.tableView];
    self.viewModel.tableViewCellBlock = ^UITableViewCell*(UITableView *tableView, NSIndexPath *indexPath, id data){
        NSString *reuseIdentity = weakSelf.loadAvatarForMailList?kMCVipAvatarMailCellIdentity: kMCVipMailCellIdentity;
        MCVIPMailListCell *cell  = [tableView dequeueReusableCellWithIdentifier:reuseIdentity];
        cell.delegate = weakSelf;
        cell.cellDelegate = weakSelf;
        cell.loadAvatar = weakSelf.loadAvatarForMailList;
        [cell.contentView setExclusiveTouch:YES];
        cell.rightSwipeSettings.transition = MGSwipeTransitionStatic;
        cell.separatorInset = UIEdgeInsetsMake(0, weakSelf.loadAvatarForMailList?57:16, 0, 0);
        cell.mailBox = weakSelf.folder;
        cell.model = data;
        cell.isSelected = weakSelf.didSelectMails[@(cell.model.messageUid)]?YES:NO;
        if (!cell.model.messageContentString) {
            [weakSelf.mailManager loadMailContent:cell.model inFolder:weakSelf.folder urgent:NO success:nil failure:nil];
        }
        return cell;
    };
    
    self.tableView.dataSource = self.viewModel;
    [self.tableView reloadData];
    [self.parentVC startAnimationIndicatorView];
    [self.tableView.refreshView endRefresh];
    [self.viewModel loadNewMailsSuccess:^(id response) {
        DDLogVerbose(@"loadNewMailsSuccess");
        [weakSelf.tableView reloadData];
        [weakSelf guideShow];
        [weakSelf cancelAllState];
        [weakSelf resetUnreadIcon];
        
    } failure:^(NSError *error) {
        [weakSelf cancelAllState];
    }];
    [self haveMails];
}

- (void)navigationBarRightItemAction {
    
    //取消编辑状态 dismiss state
    if (self.tableView.editing) {
        [self setNavigationBarEdittingState:NO];
        [self.managerView setShow:NO];
        [self.didSelectMails removeAllObjects];
        [self cancelAllState];
        [UIView animateWithDuration:0.2 animations:^{
            self.tableView.editing = NO;
        } completion:^(BOOL finished) {
            [self mailManagerShowWithDidSelectMails:[self.didSelectMails allValues]];
            [self.tableView reloadData];
        }];
        
    } else {
        //进入写信
        [MCUmengManager addEventWithKey:mc_mail_write];
        MCMailComposerViewController*mailCompserViewController = [[MCMailComposerViewController alloc]init];
        if (self.folder.type == MCMailFolderTypeDrafts ||
            self.folder.type == MCMailFolderTypePending) {
            mailCompserViewController.mailDraftManagerCallback = ^(MCMailDraftPendingManagerType draftManagerType ,MCMailModel *model) {
                [self mailDraftManagerCompleteWith:draftManagerType mail:model];
            };
        }
        mailCompserViewController.mailManager = self.mailManager;
        [self.navigationController pushViewController:mailCompserViewController animated:YES];
    }
}

- (BOOL)navigationBarleftItemAction {
    if (self.tableViewEditting) {
        if ([self.didSelectMails allKeys].count < self.viewModel.mailList.count) {
            for (MCMailModel *model in self.viewModel.mailList) {
                [self.didSelectMails setObject:model forKey:@(model.messageUid)];
            }
        } else {
            [self.didSelectMails removeAllObjects];
        }
        [self mailManagerShowWithDidSelectMails:[self.didSelectMails allValues]];
        [self.tableView reloadData];
        return NO;
    }
    return YES;
}

- (void)navigationSearchItemAction {
    NSArray *mails = [self.viewModel.mailList copy];
    
    MCMailSearchViewController *searchViewController = [[MCMailSearchViewController alloc]initMails:mails mailManager:self.mailManager processMailCallback:^(NSArray *mails, id obj, MCMailProcessType processType) {
        if (processType == MCMailProcessMove) {
            [self deleteOrMoveMails:mails toFloder:obj];
        } else{
            [self processMails:mails processType:processType];
        }
    }];
    searchViewController.mailbox = self.folder;
    MCBaseNavigationViewController *baseNav = [[MCBaseNavigationViewController alloc]initWithRootViewController:searchViewController];
    [self presentViewController:baseNav animated:NO completion:nil];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MCVIPMailListCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    MCMailModel *mail = cell.model;
    //编辑状态下 选择邮件编辑
    if (tableView.editing) {
        [cell changeMSelectedState];
        if (cell.isSelected) {
            [_didSelectMails setObject:mail forKey:@(mail.messageUid)];
        } else {
            [_didSelectMails removeObjectForKey:@(mail.messageUid)];
        }
        [self mailManagerShowWithDidSelectMails:[_didSelectMails allValues]];
        
    } else if(self.folder.type == MCMailFolderTypeDrafts||
              self.folder.type == MCMailFolderTypePending) {
        //进入写信编辑
        MCMailComposerOptionType type = self.folder.type == MCMailFolderTypePending?MCMailComposerFromPending:MCMailComposerFromDraft;
        MCMailComposerViewController *composerViewController = [[MCMailComposerViewController alloc]initWithMail:mail mailComposerOptionType:type];
        composerViewController.mailDraftManagerCallback = ^(MCMailDraftPendingManagerType draftManagerType ,MCMailModel *model) {
            [self mailDraftManagerCompleteWith:draftManagerType mail:model];
        };
        composerViewController.mailManager = self.mailManager;
        [self.navigationController pushViewController:composerViewController animated:YES];
        
    } else {
        //查看邮件详情
        
        MCMailDetailViewController *mCMailDetailViewController = [[MCMailDetailViewController alloc] initWithMail:mail manager:self.mailManager delegate:self];
        mCMailDetailViewController.mailbox = self.folder;
        [self.navigationController pushViewController:mCMailDetailViewController animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  UITableViewCellEditingStyleNone;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableViewDidRefresh {
    
    __weak typeof(self)weakSelf = self;
    [self.viewModel loadNewMailsSuccess:^(id obj){
        [self resetUnreadIcon];
        [weakSelf.tableView reloadData];
        [weakSelf.tableView endRefreshWithResult:LoadMailResultLatestMails];
        [self cancelAllState];
        
    } failure:^(NSError *error) {
        //error
        [weakSelf cancelAllState];
        [weakSelf loadMailsError:error];
    }];
}

//添加上下刷新控件
- (void)addRefreshFunction {
    
    if (self.folder.type == MCMailFolderTypeStarred ||
        self.folder.type == MCMailFolderTypePending) {
        self.tableView.footer = nil;
        
    } else {
        
        if (!self.tableView.footer) {
            MJRefreshBackStateFooter *refreshBackStateFooter = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
                //上啦加载更多邮件
                __weak typeof(self)weakSelf = self;
                [self.viewModel loadMoreMailsSuccess:^(id obj){
                    [weakSelf.tableView reloadData];
                    [weakSelf resetUnreadIcon];
                    [weakSelf cancelAllState];
                }failure:^(NSError *error){
                    [weakSelf cancelAllState];
                }];
            }];
            refreshBackStateFooter.stateLabel.textColor = AppStatus.theme.fontTintColor;
            refreshBackStateFooter.mj_h = 60.0;
            self.tableView.footer = refreshBackStateFooter;
        }
    }
}

#pragma mark Swipe Delegate
-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction{
    return YES;
}
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
            
            [self markReadMails:@[model] markRead:!model.isRead];
            //[sender hideSwipeAnimated:YES];
            [sender  refreshButtons:YES];
            return YES;
        }];
        
        read.buttonWidth = kMCMailListViewCellButtonWidth + 20;
        //草稿箱 待发送 ，不予标记已读未读
        if (self.folder.type == MCMailFolderTypeDrafts ||
            self.folder.type == MCMailFolderTypePending) {
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
            //do something
            [self deleteOrMoveMails:@[model] toFloder:nil];
            [sender refreshContentView];
            return YES;
        }];
        trash.buttonWidth = kMCMailListViewCellButtonWidth;
        //收藏
        MGSwipeButton * flag = [MGSwipeButton buttonWithTitle:model.isStar? PMLocalizedStringWithKey(@"PM_Mail_UnCollection"):PMLocalizedStringWithKey(@"PM_Mail_Collection") backgroundColor:[UIColor colorWithHexString:@"f5b146"] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            //友盟事件统计
            [MCUmengManager addEventWithKey:mc_mail_list_star];
            
            [self markStarMails:@[model] markStar:!model.isStar];
            [sender hideSwipeAnimated:YES];
            [sender refreshButtons:YES];
            return YES;
        }];
        flag.buttonWidth = kMCMailListViewCellButtonWidth;
        //移动
        MGSwipeButton * move = [MGSwipeButton buttonWithTitle:PMLocalizedStringWithKey(@"PM_Mail_MoveMail") backgroundColor:[UIColor colorWithHexString:@"c7c7cc"] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            //友盟事件统计
            [MCUmengManager addEventWithKey:mc_mail_list_move];
            [self moveMails:@[model]];
            return YES;
        }];
        move.buttonWidth = kMCMailListViewCellButtonWidth;
        
        BOOL isBacklog = model.tags&MCMailTagBacklog;
        NSString *backlogTitle = isBacklog?PMLocalizedStringWithKey(@"PM_Common_Complite"):PMLocalizedStringWithKey(@"PM_Mail_backlogMails");
        UIColor *backlogColor = [UIColor colorWithHexString:isBacklog?@"4cd964":@"c7c7cc"];
        MGSwipeButton * backlog = [MGSwipeButton buttonWithTitle:backlogTitle backgroundColor:backlogColor padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            [self markTagsMail:model tags:MCMailTagBacklog mark:!isBacklog showRepealView:YES];
            [MCUmengManager backlogEvent:isBacklog?mc_mail_backlog_normalListBacklog:mc_mail_backlog_normalListUnBacklog];
            [sender refreshContentView];
            return YES;
        }];
        
        //草稿箱，待发送只能删除；
        if (self.folder.type == MCMailFolderTypeDrafts ||
            self.folder.type == MCMailFolderTypePending) {
            return @[trash];
        }
        if (self.folder.type == MCMailFolderTypeStarred) {
            return @[trash,flag,backlog];
        }
        
        if (self.folder.type == MCMailFolderTypeSent||
            self.folder.type == MCMailFolderTypeTrash||
            self.folder.type == MCMailFolderTypeSpam) {
            return @[trash,flag,move];
        }
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

- (void)tapAvatar:(MCVIPMailListCell *)cell contact:(MCContactModel *)contact {
    
    if (self.tableViewEditting || !contact) {
        return;
    }
    MCContactInfoViewController *contactViewControllerr = [[MCContactInfoViewController alloc]initFromType:fromReadMail contactModel:contact canEditable:NO isEnterprise:contact.isCompanyUser];
    [self.navigationController pushViewController:contactViewControllerr animated:YES];
}

#pragma mark - MCMailEditingViewDelegate
- (void)mailEditingView:(MCMailEditingView *)mailEditingView intoEditing:(BOOL)edit {
    
    [self.tableView setTableHeaderView:nil];
    [self.tableView setEditing:YES animated:YES];
    [self setNavigationBarEdittingState:YES];
    [self.mailManagerView setShow:YES];
}

- (void)mailEditingView:(MCMailEditingView *)mailEditingView classify:(MCMailFlags)mailflag {
    //收藏夹筛选处理
    [self.viewModel sortMails:mailflag];
    [self.tableView reloadData];
    [self haveMails];
    [self resetUnreadIcon];
}

- (MCMailBox*)mailEditingView:(MCMailEditingView *)mailEditingView canEditing:(BOOL)editable {
    return self.folder;
}

#pragma mark - MCMailManagerViewDelegate
- (void)mailManagerView:(MCMailManagerView *)mailManagerView didSelectedProcessType:(MCMailProcessType)mailProcessType{
    NSArray *mails = [_didSelectMails allValues];
    if (mailProcessType == MCMailProcessDelete) {
        [self navigationBarRightItemAction];
        [self processMails:mails processType:mailProcessType];
    } else{
        [self processMails:mails processType:mailProcessType];
        [self navigationBarRightItemAction];
    }
}
- (void)processMails:(NSArray*)mails processType:(MCMailProcessType)processType {
  
    switch (processType) {
        case MCMailProcessRead:{
            [self markReadMails:mails markRead:YES];
        }
            break;
        case MCMailProcessUnread:{
            [self markReadMails:mails markRead:NO];
        }
            break;
        case MCMailProcessStarred:{
            [self markStarMails:mails markStar:YES];
        }
            break;
        case MCMailProcessUnstarred:{
            [self markStarMails:mails markStar:NO];
        }
            break;
        case MCMailProcessMove:{
            //move
            [self moveMails:mails];
        }
            break;
        case MCMailProcessDelete:{
            [self deleteOrMoveMails:mails toFloder:nil];
        }break;
            
        case MCMailProcessUnVip:{
            [self mailDetailViewHandleMail:mails[0] tag:MCMailTagImportant mark:NO];
        }break;
            
        case MCMailProcessVip:{
            [self mailDetailViewHandleMail:mails[0] tag:MCMailTagImportant mark:YES];
        }break;
        case MCMailProcessBacklog :{
            [self mailDetailViewHandleMail:mails[0] tag:MCMailTagBacklog mark:YES];
        }break;
        case MCMailProcessUnBackLog:{
            [self mailDetailViewHandleMail:mails[0] tag:MCMailTagBacklog mark:NO];
        }break;
            
        default:
            break;
    }
}

//TODO：move
- (void)moveMails:(NSArray*)mails {
    MCMailMoveViewController *mailMoveViewController = [[MCMailMoveViewController alloc] initWithCurrentMailBox:self.folder manager:self.mailManager moveComplete:^(MCMailBox *mailbox) {
        [self deleteOrMoveMails:mails toFloder:mailbox];
    }];
    MCBaseNavigationViewController *navigationController = [[MCBaseNavigationViewController alloc]initWithRootViewController:mailMoveViewController];
    [self presentViewController:navigationController animated:YES completion:NULL];
}

- (void)mailManagerShowWithDidSelectMails:(NSArray*)didSelectMails {
    
    [UIView performWithoutAnimation:^{
        if (didSelectMails.count < self.viewModel.mailList.count ||self.viewModel.mailList.count == 0) {
            [self.parentVC.leftNavigationBarButtonItem setTitle:self.tableViewEditting?PMLocalizedStringWithKey(@"PM_Mail_SelectAll"):nil];
        } else {
            [self.parentVC.leftNavigationBarButtonItem setTitle:PMLocalizedStringWithKey(@"PM_Mail_UnSelectAll")];
        }
    }];
    [self.managerView resetItemShowWithMaisl:didSelectMails folder:self.folder];
}

#pragma mark - MCMailDetailViewControllerDelegate
- (void)mailDetailViewHandleMail:(MCMailModel *)mail tag:(MCMailTags)tags mark:(BOOL)mark {
    [self markTagsMail:mail tags:tags mark:mark showRepealView:NO];
}
- (void)mailDetailViewHandleMail:(MCMailModel *)mail from:(MCMailBox *)fromBox moveTo:(MCMailBox *)mailBox {
    [self deleteOrMoveMails:@[mail] toFloder:mailBox];
}
- (void)mailDetailViewHandleMail:(MCMailModel *)mail setRead:(BOOL)read {
    [self markReadMails:@[mail] markRead:read];
}
- (MCMailModel*)mailDetailViewReadOtherFromMail:(MCMailModel *)mail toNext:(BOOL)next {
    MCMailModel *nextMail = nil;
    NSInteger index = [self.viewModel.mailList indexOfObject:mail];
    if (index != NSNotFound) {
        index = next?index+1:index -1;
        if (index >0 && index <= self.viewModel.mailList.count) {
            nextMail = self.viewModel.mailList[index];
            return nextMail;
        }
    }
    return nil;
}


- (void)receivewContactMailStateChange:(MCMailModel *)mail tags:(MCMailTags)tags mark:(BOOL)mark {
    if ([self.viewModel.mailList containsObject:mail]) {
        NSInteger index = [self.viewModel.mailList indexOfObject:mail];
        mail = [self.viewModel.mailList objectAtIndex:index];
        [self markTagsMail:mail tags:tags mark:mark showRepealView:NO];
    }
}
//Private
#pragma mark - 已读未读、收藏、删除
- (void)deleteOrMoveMails:(NSArray*)mails toFloder:(MCMailBox*)mailBox {
    [self.viewModel deleteMails:mails];
    [self resetUnreadIcon];
    //同步删除或移动邮件
    [self.mailManager moveMails:mails fromFolder:self.folder toFolder:mailBox success:nil failure:nil];
}
- (void)markReadMails:(NSArray*)mails markRead:(BOOL)markRead {
    __block typeof(self)weakSelf = self;
    [self.mailManager setReadFlag:markRead forMails:mails success:^(id response) {
        [weakSelf.viewModel calculateUnreadCount];
        [weakSelf resetUnreadIcon];
    } failure:nil];
}
- (void)markStarMails:(NSArray*)mails markStar:(BOOL)markStar {
    [self.mailManager setStarFlag:markStar forMails:mails success:nil failure:nil];
}

- (void)markTagsMail:(MCMailModel*)mail tags:(MCMailTags)tags mark:(BOOL)mark showRepealView:(BOOL)show{
    
    if (mark) {
        mail.tags = mail.tags|tags;
    } else {
        mail.tags = mail.tags&(~tags);
    }
    [self.mailManager updateTagsMails:@[mail]];
    
    if (tags == MCMailTagBacklog && show) {
        self.repealView.message = mark?PMLocalizedStringWithKey(@"PM_Mail_BacklogNote"):PMLocalizedStringWithKey(@"PM_Mail_BacklogFinishNote");
        self.repealView.doItemTitle = PMLocalizedStringWithKey(@"PM_Mail_RepealMails");
        [self.repealView showWithUndoBlock:^{
            [self markTagsMail:mail tags:tags mark:!mark showRepealView:NO];
        } commitBlock:nil];
    }
}

//Private
//取消等待状态
- (void)cancelAllState {
    [self.tableView.footer endRefreshing];
    [self.parentVC stopAnimationInducatorView];
    [self haveMails];
}
//是否有邮件
- (void)haveMails {
    BOOL haveMails = self.viewModel.mailList.count > 0?YES:NO;
    if ((self.viewModel.mailFlag != MCMailFlagNone ||haveMails) &&!self.tableViewEditting) {
        if (![self.tableView.tableHeaderView isKindOfClass:[MCMailEditingView class]]) {
            self.tableView.tableHeaderView = self.mailEditingView;
        }
    } else {
        self.tableView.tableHeaderView = nil;
    }
}

//TODO:草稿箱待发送操作
- (void)mailDraftManagerCompleteWith:(MCMailDraftPendingManagerType)draftManagerType mail:(MCMailModel*)mail {
    if (draftManagerType == MCMailDraftManagerTypeNew) {
        if ([self.viewModel.mailList containsObject:mail]) {
            [self.viewModel deleteMails:@[mail]];
        }
        [self.viewModel insertMail:mail];
    } else {
        
        [self.mailManager moveMails:@[mail] fromFolder:self.folder toFolder:self.folder success:nil failure:nil];
        if ([self.viewModel.mailList containsObject:mail]) {
            [self.viewModel deleteMails:@[mail]];
        }
    }
}

@end
