//
//  MCMailListViewController.m
//  NPushMail
//
//  Created by zhang on 15/12/23.
//  Copyright © 2015年 sprite. All rights reserved.
//
#import "MCMailListViewController.h"
#import "MCLoginManager.h"
#import "MCMailListCell.h"
#import "MCNoMailView.h"
#import "MCMailBoxListView.h"
#import "MCMailEditingView.h"
#import "MCMailManagerView.h"
#import "MCMailListTableView.h"
#import "MCMailSentErrorView.h"

#import "MJRefresh.h"
#import "MCMailMoveViewController.h"
#import "MCMailDetailViewController.h"
#import "MCMailComposerViewController.h"
#import "MCBaseNavigationViewController.h"
#import "MCNotificationCenter.h"
#import "MCMailSearchManager.h"
#import "MCAppSetting.h"
#import "MCServerViewController.h"
#import "UIAlertView+Blocks.h"
#import "MCWebViewController.h"
#import "UIBarButtonItem+note.h"
#import "MCTabBarController.h"
#import "MCViPMailViewController.h"
#import "MCMailSearchViewController.h"
#import "MCFeaturesGuideHelper.h"
#import "UIView+MCExpand.h"
#import "MCMailListViewModel.h"
#import "MCViewDisplay.h"

#import "MCContactManager.h"
#import "MCIMConversationManager.h"
#import "MCIMChatViewController.h"
#import "MCMailBoxManager.h"
//邮件加载数量
const static CGFloat kMCMailListViewCellHight   = 96.0;
const static CGFloat kMCMailListViewCellThresholdForRead = 0.8;
const static CGFloat kMCMailListViewCellThresholdForOther = 1.0;
const static CGFloat kMCMailListViewCellButtonWidth = 78.0;
const static CGFloat kMCMailListViewCellPadding = 15.0;
static NSString * const kMCMailCellIdentifier = @"MCMailCell";
static NSString * const KMCMailCellWithOutAvatarIdentifier = @"MCMailCellWithOutAvatar";
static NSString * const kMCMailListCell = @"MCMailListCell";

@interface MCMailListViewController ()<MGSwipeTableCellDelegate,UITableViewDelegate,MCMailBoxListViewDelegate,MCMailEditingViewDelegate,MCMailManagerViewDelegate,MCMailTableViewDelegate,MCMailDetailViewControllerDelegate>
//邮件列表
@property (nonatomic,strong)MCMailListTableView *mailTableView;
//编辑栏
@property (nonatomic,strong)MCMailEditingView *mailEditingView;
//邮件操作选项栏
@property (nonatomic,strong)MCMailManagerView *mailManagerView;
//文件夹列表
@property (nonatomic,strong)MCMailBoxListView *mailBoxListView;
//nomailView
@property (nonatomic,strong)MCNoMailView *mcNoMailView;

@property (nonatomic,strong)MCMailSentErrorView *errorView;
//dataSource
@property (nonatomic,strong)NSMutableDictionary *didSelectMails;
//是否编辑状态
@property (nonatomic,assign)BOOL tableViewEditting;
//是否加载无头像列表
@property (nonatomic,assign)BOOL toLoadAvatarForMailList;

@property (nonatomic,assign)BOOL isSmartBox;

@property (nonatomic,assign)BOOL newMailsNoteShowEnable;

@property (nonatomic,strong) MCMailManager *mailManager;
@property (nonatomic,strong) MCViPMailViewController *vipViewController;
@property (nonatomic,strong) RTDraggableBadge *tabBarbadge;

@property (nonatomic,copy)searchMailComplete mailListSearchComplete;

@property (nonatomic,strong) MCMailListViewModel *viewModel;

@end

@implementation MCMailListViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MCNotificationDidChangeAccount object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MCNotificationDidReceiveApnsMailPush object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MCNotificationDidReceiveMqttMailPush object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MCNotificationSentMailFailure object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isSmartBox = YES;
        _didSelectMails = [NSMutableDictionary new];
        _mailBoxModel = [MCMailBox new];
        self.newMailsNoteShowEnable = YES;
    }
    return self;
}

- (MCMailManager *)mailManager
{
    if (!_mailManager) {
        _mailManager = [[MCMailManager alloc]initWithAccount:AppStatus.currentUser];
    }
    return _mailManager;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _tabBarbadge.dragEnabled = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.changeAccountArrow setHidden:NO];
    _tabBarbadge.dragEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.automaticallyAdjustsScrollViewInsets = YES;
    if (_toLoadAvatarForMailList != AppSettings.loadAvatarCellForMailList) {
        if (_mailTableView) {
            [_mailTableView reloadData];
        }
    }
    _toLoadAvatarForMailList = AppSettings.loadAvatarCellForMailList;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    //加载页面视图
    [self addSearchNavigationBarButtonItem];
    [self addRootViewSearchNavigationBarButtonItem];
    [self loadSubViews];
    [self.navBarTitleLable setText:_mailBoxModel.name];
    [self addRefreshFunction];
    
    [self toLoadAllFolders];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mcReloadMailData:) name:MCNotificationDidChangeAccount object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mcReceiveApnsMails:) name:MCNotificationDidReceiveApnsMailPush object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mcReceiveMqttNotfication:) name:MCNotificationDidReceiveMqttMailPush object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mcSentMailFailure:) name:MCNotificationSentMailFailure object:nil];
    if (AppSettings.isFirstShowGuideForMailListContrller) {
        MCFeaturesGuideHelper *guideView = [[MCFeaturesGuideHelper alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeigth) guideType:MCFeaturesGuideMailList];
        [guideView show];
    }
    [self feedbackForVipMails];
    
}

//- (void)setCurrentUserLabelFrame {
//    CGSize size = [AppStatus.currentUser.email mcStringSizeWithFont:kMCBaseViewCurrentUserLableFont maxWidth:(ScreenWidth - 200) maxHight:kMCBaseViewCurrentUserLableHight];
//    if (size.width > 160) {
//        self.navigationBarTitleView.frame = CGRectMake(0, 0, ScreenWidth - 200, kMCBaseViewNavBarTitleViewHight);
//    }
//    self.currentUserLable.frame = CGRectMake((self.navigationBarTitleView.mc_width - size.width)/2, 24, size.width, kMCBaseViewCurrentUserLableHight);
//    self.changeAccountArrow.frame = CGRectMake(CGRectGetMaxX(self.currentUserLable.frame) + 5, 32, 8, 4);
//    self.changeAccountBtn.frame = CGRectMake(0, 0, CGRectGetWidth(self.navigationBarTitleView.frame), CGRectGetHeight(self.navigationBarTitleView.frame));
//}

#pragma mark - 初始化view
-(void)loadSubViews {
    
    _vipViewController = [[MCViPMailViewController alloc]initWithDelegate:self];
    
    [self setNavigationBarEdittingState:NO];
    _mailTableView = [[MCMailListTableView alloc]init];
    _mailTableView.delegate = self;
    _mailTableView.refreshDelegate = self;
    _mailTableView.tableFooterView = [UIView new];
    [self.view addSubview:_mailTableView];
}
#pragma mark -views
- (MCMailEditingView*)mailEditingView{
    
    if (!_mailEditingView) {
        _mailEditingView = [[MCMailEditingView alloc]init];
        _mailEditingView.delegate = self;
    }
    return _mailEditingView;
}
- (MCMailManagerView*)mailManagerView{
    if (!_mailManagerView) {
        _mailManagerView = [[MCMailManagerView alloc]init];
        _mailManagerView.delegate = self;
        [self.tabBarController.tabBar addSubview:_mailManagerView];
    }
    return _mailManagerView;
}
- (MCMailBoxListView*)mailBoxListView{
    
    if (!_mailBoxListView) {
        _mailBoxListView = [[MCMailBoxListView alloc]init];
        _mailBoxListView.delegate = self;
        [_mailBoxListView show];
    }
    return _mailBoxListView;
}

- (MCNoMailView*)mcNoMailView {
    if (!_mcNoMailView) {
        _mcNoMailView = [[MCNoMailView alloc]initWithNoteBlock:^(NSString*url){
            MCWebViewController *webController = [[MCWebViewController alloc] initWithUrl:[NSURL URLWithString:url]];
            [self.navigationController pushViewController:webController animated:YES];
        }];
        [self.mailTableView addSubview:_mcNoMailView];
    }
    return _mcNoMailView;
}
- (MCMailSentErrorView*)errorView {
    if (!_errorView) {
        CGRect frame = CGRectMake(0, -44, ScreenWidth, 44);
        _errorView = [[MCMailSentErrorView alloc]initWithFrame:frame needClearItem:YES];
        __weak typeof(self)weak = self;
        _errorView.dismissCallback = ^{
            [weak showSentMailErrorView:NO];
        };
        _errorView.didSelectedPendingBox = ^{
            [weak didSelectedPendingBox];
        };
        [self.view addSubview:_errorView];
    }
    return _errorView;
}

- (void)setNavigationBarEdittingState:(BOOL)editState{

    _tableViewEditting = editState;
    [self.rightNavigationBarButtonItem setTitle:editState?PMLocalizedStringWithKey(@"PM_Common_Cancel"):nil];
    [self.leftNavigationBarButtonItem setTitle:editState?PMLocalizedStringWithKey(@"PM_Mail_SelectAll"):nil];
    [self.rightNavigationBarButtonItem setImage:editState?nil:AppStatus.theme.mailStyle.mailListRightImage];
    [self.leftNavigationBarButtonItem setImage:editState?nil:AppStatus.theme.mailStyle.mailListLeftImage];
    [self.searchButton setImage:editState?nil:AppStatus.theme.mailStyle.mailListSearchImage forState:UIControlStateNormal];
    self.searchNavigationBarButtonItem.enabled = !editState;
}

//TODO:

- (void)showSentMailErrorView:(BOOL)show{
    
    if (!show && !_errorView) {
        return;
    }
    
    if ((show && self.errorView.frame.origin.y == 0)||(show && _mailBoxModel.type == MCMailFolderTypePending)) {
        return;
    }
    [self.view bringSubviewToFront:_errorView];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = CGRectZero;
        if (show) {
            rect =  _vipViewController.view.frame;
            rect.origin.y += CGRectGetHeight(_errorView.frame);
            rect.size.height -= CGRectGetHeight(_errorView.frame);
            _vipViewController.view.frame = rect;
            rect = self.mailTableView.frame;
            rect.origin.y += CGRectGetHeight(_errorView.frame);
            rect.size.height -= CGRectGetHeight(_errorView.frame);
            self.mailTableView.frame = rect;
            rect = self.errorView.frame;
            rect.origin.y = 0;
            self.errorView.frame = rect;
        } else {
            rect =  _vipViewController.view.frame;
            rect.origin.y = 0;
            rect.size.height = self.view.frame.size.height;
            _vipViewController.view.frame = rect;
            rect = self.mailTableView.frame;
            rect.origin.y = 0;
            rect.size.height = self.view.frame.size.height;
            self.mailTableView.frame = rect;
            rect = self.errorView.frame;
            rect.origin.y = -CGRectGetHeight(_errorView.frame);
            self.errorView.frame = rect;
        }
        
    } completion:^(BOOL finished) {
        if (!show) {
            [self.errorView removeFromSuperview];
            self.errorView = nil;
        }
    }];
    [AppSettings setSentErrorNoteStateWithKey:AppStatus.currentUser.email value:show];
}

#pragma mark- UITableViewDelegate UITablViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kMCMailListViewCellHight;
}
//delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MCMailListCell*cell = [self.mailTableView cellForRowAtIndexPath:indexPath];
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
        
    } else if(_mailBoxModel.type == MCMailFolderTypeDrafts|_mailBoxModel.type == MCMailFolderTypePending) {
       //进入写信编辑
        MCMailComposerViewController *composerViewController = [[MCMailComposerViewController alloc]initWithMail:mail mailComposerOptionType:MCMailComposerFromDraftAndPending];
        composerViewController.mailDraftManagerCallback = ^(MCMailDraftPendingManagerType draftManagerType ,MCMailModel *model) {
            [self mailDraftManagerCompleteWith:draftManagerType mail:model];
        };
        composerViewController.mailManager = self.mailManager;
        [self.navigationController pushViewController:composerViewController animated:YES];
    
    } else {
        //查看邮件详情
        
        MCMailDetailViewController *mCMailDetailViewController = [[MCMailDetailViewController alloc] initWithMail:mail manager:self.mailManager delegate:self];
        //标示已读状态
        if (!mail.isRead) {
            [self markReadMails:@[mail] markRead:YES];
        }
        mCMailDetailViewController.mailbox = _mailBoxModel;
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
        [weakSelf.mailTableView reloadData];
        [weakSelf.mailTableView endRefreshWithResult:LoadMailResultLatestMails];
        [self cancelAllState];
    
    } failure:^(NSError *error) {
        //error
        [weakSelf cancelAllState];
        if (error.code == 5) { // MCOErrorAuthentication
            RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Cancel")];
            RIButtonItem *setItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Mine_Setting") action:^{
                MCServerViewController *serverViewController = [[MCServerViewController alloc]initWithAccount:AppStatus.currentUser];
                MCBaseNavigationViewController *navigatianViewController = [[MCBaseNavigationViewController alloc]initWithRootViewController:serverViewController];
                [weakSelf presentViewController:navigatianViewController animated:YES completion:nil];
            }];
            
            NSString *errorMessage = error.userInfo[@"MCOIMAPResponseKey"];
            NSString *message = [NSString stringWithFormat:@"%@%@",AppStatus.currentUser.email,PMLocalizedStringWithKey(@"PM_Login_AccountValidationFailNote")];
            if (errorMessage) {
                message = [message stringByAppendingString:@"\n"];
                message = [message stringByAppendingString:errorMessage];
            }
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:PMLocalizedStringWithKey(@"PM_Login_AccountValidation") message:message cancelButtonItem:cancelItem otherButtonItems:setItem, nil];
            [alertView show];
        }
        [_mailTableView endRefreshWithResult:LoadMailResultNoNewMails];
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_mailTableView.refreshView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_mailTableView.refreshView scrollViewDidEndDraging];
}

#pragma mark Swipe Delegate
-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction{
    return YES;
}

-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell
  swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings
         expansionSettings:(MGSwipeExpansionSettings*) expansionSettings {
    
    MCMailListCell *listCell = (MCMailListCell*)cell;
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
        if (_mailBoxModel.type == MCMailFolderTypeDrafts || _mailBoxModel.type == MCMailFolderTypePending) {
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
        //草稿箱，待发送只能删除；
        if (_mailBoxModel.type == MCMailFolderTypeDrafts || _mailBoxModel.type == MCMailFolderTypePending) {
            return @[trash];
        }
        if (_mailBoxModel.type == MCMailFolderTypeStarred) {
            return @[trash,flag];
        }
        return @[trash, flag, move];
    }
    return nil;
}

#pragma mark - MCMailEditingViewDelegate
- (void)mailEditingView:(MCMailEditingView *)mailEditingView intoEditing:(BOOL)edit {
    
    [_mailTableView setTableHeaderView:nil];
    [_mailTableView setEditing:YES animated:YES];
    [self setNavigationBarEdittingState:YES];
    [self.mailManagerView setShow:YES];
}

- (void)mailEditingView:(MCMailEditingView *)mailEditingView classify:(MCMailFlags)mailflag {
    //收藏夹筛选处理
    [self.viewModel sortMails:mailflag];
    [self.mailTableView reloadData];
    [self isHaveMails];
    [self resetUnreadIcon];
}

- (MCMailBox*)mailEditingView:(MCMailEditingView *)mailEditingView canEditing:(BOOL)editable {
    return _mailBoxModel;
}

#pragma mark - MCMailManagerViewDelegate
- (void)mailManagerView:(MCMailManagerView *)mailManagerView didSelectManagerOption:(MCMailManagerOption)mailManagerOption{
    
    NSArray *mails = [_didSelectMails allValues];
    switch (mailManagerOption) {
        case MCMailManagerOptionRead:
        {
            [self markReadMails:mails markRead:YES];
        }
            break;
        case MCMailManagerOptionUnRead:
        {
            [self markReadMails:mails markRead:NO];
        }
            break;
        case MCMailManagerOptionStar:
        {
            [self markStarMails:mails markStar:YES];
        }
            break;
        case MCMailManagerOptionUnStar:
        {
            [self markStarMails:mails markStar:NO];
        }
            break;
        case MCMailManagerOptionMove:
        {
            //move
            [self moveMails:mails];
        }
            break;
        case MCMailManagerOptionDelete:
        {
            [self rightNavigationBarButtonItemAction:nil];
            [self deleteOrMoveMails:mails toFloder:nil];
            return;

        }break;
        default:
        break;
    }
    [self rightNavigationBarButtonItemAction:nil];
}
//TODO：move
- (void)moveMails:(NSArray*)mails {
    MCMailMoveViewController *mailMoveViewController = [[MCMailMoveViewController alloc] initWithCurrentMailBox:_mailBoxModel manager:self.mailManager moveComplete:^(MCMailBox *mailbox) {
        [self deleteOrMoveMails:mails toFloder:mailbox];
    }];
    MCBaseNavigationViewController *navigationController = [[MCBaseNavigationViewController alloc]initWithRootViewController:mailMoveViewController];
    [self presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark - MCMailBoxListViewDelegate
- (void)mailBoxListView:(MCMailBoxListView *)mailBoxListView didSelectMailBox:(MCMailBox *)mailBoxModel smartBox:(BOOL)smartBox{
    _mailBoxModel = mailBoxModel;
    [self cancelAllState];
    if (smartBox) {
        _vipViewController.folder = mailBoxModel;
        [self addChildViewController:_vipViewController];
        [self.view addSubview:_vipViewController.view];
         self.navBarTitleLable.text = PMLocalizedStringWithKey(@"PM_Mail_SmartBox");
        [_vipViewController loadDataSource];
        AppSettings.userFeedbackVipMailInfoDate = [NSDate date];
    } else {
        if (mailBoxModel.type == MCMailFolderTypePending) {
            [self showSentMailErrorView:NO];
        }
        [_vipViewController.view removeFromSuperview];
        [_vipViewController removeFromParentViewController];
        self.navBarTitleLable.text = mailBoxModel.name;
        [self loadDataSourceWithMailBox:mailBoxModel];
        [self addRefreshFunction];
        [self.mailEditingView reset];
        [self resetUnreadIcon];
    }
    _isSmartBox = smartBox;
    AppSettings.smartBoxSelectEnable = smartBox;
    //调转邮件列表最顶端
    [_mailTableView setContentOffset:CGPointMake(0,0) animated:NO];
}
#pragma mark - LoadFolders
- (void)toLoadAllFolders {
    
    [self cancelAllState];
    BOOL firstLoadingMails = NO;
    NSArray *folders = [self.mailManager getLocalFoldersWithUserId:AppStatus.currentUser.accountId];
    if (folders.count > 0) {
        firstLoadingMails = YES;
        [self loadingMailsWithFolders:folders];
    } else {
        self.mailBoxListView.folders = folders;
    }
    //同步文件夹
    __weak typeof(self) weak = self;
    [self.mailManager getAllFoldersSuccess:^(id response) {
        NSArray *array = (NSArray*)response;
        MCMailBox *box = [array firstObject];
        if (box.accountId != AppStatus.currentUser.accountId) {
            return;
        }
        if (!firstLoadingMails) {
            [weak loadingMailsWithFolders:array];
        } else {
            NSInteger index = [array indexOfObject:weak.mailBoxModel];
            if (index != NSNotFound) {
                box = [array objectAtIndex:index];
                box.unreadCount = weak.mailBoxModel.unreadCount;
                weak.mailBoxModel = box;
                if (box.type == MCMailFolderTypeInbox && self.mailBoxListView.smartBoxSelectEnable) {
                    _vipViewController.folder = box;
                } else {
                    box.selectable = YES;
                }
            }
            weak.mailBoxListView.folders = array;
        }
        
    } failure:nil];
    
}

- (void)loadingMailsWithFolders:(NSArray*)folders {
    
    MCMailBox *box = [folders firstObject];
    _mailBoxModel = box;
    self.mailBoxListView.folders = folders;
    
    if (self.mailBoxListView.smartBoxSelectEnable) {
        _isSmartBox = YES;
        _vipViewController.folder = _mailBoxModel;
        [self addChildViewController:_vipViewController];
        [self.view addSubview:_vipViewController.view];
        self.navBarTitleLable.text = PMLocalizedStringWithKey(@"PM_Mail_SmartBox");
        [self.vipViewController loadDataSource];
        AppSettings.userFeedbackVipMailInfoDate = [NSDate date];
    } else {
        _isSmartBox = NO;
        self.navBarTitleLable.text = _mailBoxModel.name;
        [self loadDataSourceWithMailBox:_mailBoxModel];
    }
}

//加载邮件
- (void)loadDataSourceWithMailBox:(MCMailBox*)box {
    
    __weak typeof(self)weakSelf = self;
    self.viewModel = [[MCMailListViewModel alloc] initWithFolder:box tableView:self.mailTableView];
    self.viewModel.tableViewCellBlock = ^UITableViewCell*(UITableView *tableView, NSIndexPath *indexPath, id data){
        NSString *cellid = weakSelf.toLoadAvatarForMailList?kMCMailCellIdentifier:KMCMailCellWithOutAvatarIdentifier;
        MCMailListCell*cell = [tableView dequeueReusableCellWithIdentifier:cellid];
        if (!cell) {
            NSArray *array=[[NSBundle mainBundle] loadNibNamed:kMCMailListCell owner:nil options:nil];
            cell = _toLoadAvatarForMailList?[array firstObject]:[array lastObject];
            cell.delegate = weakSelf;
            [cell.contentView setExclusiveTouch:YES];
            cell.rightSwipeSettings.transition = MGSwipeTransitionStatic;
        }
        cell.separatorInset = UIEdgeInsetsMake(0, weakSelf.toLoadAvatarForMailList?57:16, 0, 0);
        cell.mailBoxModel = weakSelf.mailBoxModel;
        cell.model = data;
        cell.isSelected = weakSelf.didSelectMails[@(cell.model.messageUid)]?YES:NO;
        if (!cell.model.messageContentString) {
            [weakSelf.mailManager loadMailContent:cell.model inFolder:weakSelf.mailBoxModel urgent:NO success:nil failure:nil];
        }
        return cell;
    };
    
    self.mailTableView.dataSource = self.viewModel;
    [self.mailTableView reloadData];
    [self startAnimationIndicatorView];
    [self.mailTableView.refreshView endRefresh];
    [self.viewModel loadNewMailsSuccess:^(id response) {
        DDLogVerbose(@"loadNewMailsSuccess");
        [weakSelf.mailTableView reloadData];
        [weakSelf cancelAllState];
        [weakSelf resetUnreadIcon];
        
    } failure:^(NSError *error) {
        [weakSelf cancelAllState];
    }];
    [self isHaveMails];
}

#pragma mark NavigationBarItemAction
- (void)leftNavigationBarButtonItemAction:(id)sender {
    //进入可编辑状态
    if (_mailTableView.editing) {
        if ([_didSelectMails allKeys].count < self.viewModel.mailList.count) {
            for (MCMailModel *model in self.viewModel.mailList) {
                [_didSelectMails setObject:model forKey:@(model.messageUid)];
            }
        } else {
            [_didSelectMails removeAllObjects];
        }
        [self mailManagerShowWithDidSelectMails:[_didSelectMails allValues]];
        [_mailTableView reloadData];
        
    } else {
        //文件夹列表弹出与否
        self.mailBoxListView.change = !self.mailBoxListView.change;
        [self.leftNavigationBarButtonItem showBarButtonNote:NO];
        self.newMailsNoteShowEnable = YES;
    }
}

- (void)rightNavigationBarButtonItemAction:(id)sender {
    //取消编辑状态 dismiss state
    if (self.mailTableView.editing) {
        [self setNavigationBarEdittingState:NO];
        [_mailManagerView setShow:NO];
        [_didSelectMails removeAllObjects];
        [self cancelAllState];
        [UIView animateWithDuration:0.2 animations:^{
            _mailTableView.editing = NO;
        } completion:^(BOOL finished) {
            [self mailManagerShowWithDidSelectMails:[_didSelectMails allValues]];
            [_mailTableView reloadData];
        }];
        
    } else {
        //进入写信
        [MCUmengManager addEventWithKey:mc_mail_write];
        MCMailComposerViewController*mailCompserViewController = [[MCMailComposerViewController alloc]init];
        if (_mailBoxModel.type == MCMailFolderTypeDrafts || _mailBoxModel.type == MCMailFolderTypePending) {
            mailCompserViewController.mailDraftManagerCallback = ^(MCMailDraftPendingManagerType draftManagerType ,MCMailModel *model) {
                [self mailDraftManagerCompleteWith:draftManagerType mail:model];
            };
        }
        mailCompserViewController.mailManager = self.mailManager;
        [self.navigationController pushViewController:mailCompserViewController animated:YES];
    }
}

- (void)searchNavigationBarButtonItemAction:(id)sender {
    NSArray*mails = nil;
    searchMailComplete searchCallback = nil;
    if (_isSmartBox) {
        mails = [_vipViewController.searchMails copy];
        searchCallback = _vipViewController.vipSearchMailComplete;
    } else {
        mails = [self.viewModel.mailList copy];
        searchCallback = self.mailListSearchComplete;
    }
    MCMailSearchViewController *mailSearchViewController = [[MCMailSearchViewController alloc]initMails:mails mailManager:self.mailManager searchCompleteDelete:searchCallback];
    mailSearchViewController.mailbox = _mailBoxModel;
    MCBaseNavigationViewController *baseNav = [[MCBaseNavigationViewController alloc]initWithRootViewController:mailSearchViewController];
    [self presentViewController:baseNav animated:NO completion:nil];
}

- (searchMailComplete)mailListSearchComplete {
    searchMailComplete mailListSearch = ^(MCMailModel *mail,id obj,MCSearchOperation op) {
        BOOL contain = [self.viewModel.mailList containsObject:mail];
        switch (op) {
            case MCSearchMarkRead: {
                NSNumber *nub = (NSNumber*)obj;
                if (contain) {
                    [self markReadMails:@[mail] markRead:[nub boolValue]];
                } else {
                    [self.mailManager setReadFlag:[nub boolValue] forMails:@[mail] success:nil failure:nil];
                }
            }
                break;
            case MCSearchMarkStar: {
                [self markStarMails:@[mail] markStar:!mail.isStar];
            }
                break;
            case MCSearchMarkDelete:
                if (contain) {
                    [self deleteOrMoveMails:@[mail] toFloder:(MCMailBox*)obj];
                } else {
                    [self.mailManager moveMails:@[mail] fromFolder:_mailBoxModel toFolder:(MCMailBox*)obj success:nil failure:nil];
                }
                break;
        }
    };
    return mailListSearch;
}

#pragma mark - MCMailDetailViewControllerDelegate 
- (void)mailDetailViewHandleMail:(MCMailModel *)mail moveTo:(MCMailBox *)mailBox {
    [self deleteOrMoveMails:@[mail] toFloder:mailBox];
}
- (void)mailDetailViewHandleMail:(MCMailModel *)mail setRead:(BOOL)read {
    [self markReadMails:@[mail] markRead:read];
}
#pragma mark - 已读未读、收藏、删除
//删除移动并同步状态
- (void)deleteOrMoveMails:(NSArray*)mails toFloder:(MCMailBox*)mailBox {
    [self.viewModel deleteMails:mails];
    [self resetUnreadIcon];
    //同步删除或移动邮件
    [self.mailManager moveMails:mails fromFolder:_mailBoxModel toFolder:mailBox success:nil failure:nil];
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

#pragma mark private
- (void)mailManagerShowWithDidSelectMails:(NSArray*)didSelectMails {
    
    [UIView performWithoutAnimation:^{
        if (didSelectMails.count < self.viewModel.mailList.count ||self.viewModel.mailList.count == 0) {
            [self.leftNavigationBarButtonItem setTitle:_mailTableView.editing?PMLocalizedStringWithKey(@"PM_Mail_SelectAll"):nil];
        } else {
            [self.leftNavigationBarButtonItem setTitle:PMLocalizedStringWithKey(@"PM_Mail_UnSelectAll")];
        }
    }];
    [_mailManagerView resetItemShowWithMaisl:didSelectMails folder:_mailBoxModel];
}

//取消等待状态
- (void)cancelAllState {
    
    [_mailTableView.footer endRefreshing];
    [self stopAnimationInducatorView];
    [self isHaveMails];
}
//是否有邮件
- (void)isHaveMails {
    BOOL haveMails = self.viewModel.mailList.count > 0?YES:NO;
     if ((self.viewModel.mailFlag != MCMailFlagNone ||haveMails) &&!_tableViewEditting) {
        
        if (![_mailTableView.tableHeaderView isKindOfClass:[MCMailEditingView class]]) {
            _mailTableView.tableHeaderView = self.mailEditingView;
        }
    } else {
        _mailTableView.tableHeaderView = nil;
    }
    [self.mcNoMailView showWithBox:_mailBoxModel show:!haveMails];
}

//添加上下刷新控件
- (void)addRefreshFunction {
    
    if (_mailBoxModel.type == MCMailFolderTypeStarred |
        _mailBoxModel.type == MCMailFolderTypePending) {
        _mailTableView.footer = nil;
        
    } else {
        
        if (!_mailTableView.footer) {
            MJRefreshBackStateFooter *refreshBackStateFooter = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
                //上啦加载更多邮件
                __weak typeof(self)weakSelf = self;
                [self.viewModel loadMoreMailsSuccess:^(id obj){
                    [weakSelf.mailTableView reloadData];
                    [weakSelf resetUnreadIcon];
                    [weakSelf cancelAllState];
                }failure:^(NSError *error){
                    [weakSelf cancelAllState];
                }];
            }];
            refreshBackStateFooter.stateLabel.textColor = AppStatus.theme.fontTintColor;
            refreshBackStateFooter.mj_h = 60.0;
            _mailTableView.footer = refreshBackStateFooter;
        }
    }
}
//TODO:未读数刷新
- (void)resetUnreadIcon {
    NSString *unreadCountString = self.viewModel.unreadCount <= 0?nil:[NSString stringWithFormat:@"%ld",(long)self.viewModel.unreadCount];
    self.tabBarbadge  = [self.tabBarItem rt_setBadgeValue:unreadCountString withHandle:nil];
    __weak typeof(self) weakSelf = self;
    self.tabBarbadge.dragOutblock = ^(id sender){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.isRead == %d",0];
        NSArray *unreadArray = [weakSelf.viewModel.mailList filteredArrayUsingPredicate:predicate];
        if (unreadArray.count > 0) {
           [weakSelf markReadMails:unreadArray markRead:YES];
        } else {
            weakSelf.viewModel.unreadCount = 0;
            weakSelf.mailBoxModel.unreadCount = 0;
        }
    };
    weakSelf.mailBoxModel.unreadCount = weakSelf.viewModel.unreadCount;
}
//TODO:草稿箱待发送操作
- (void)mailDraftManagerCompleteWith:(MCMailDraftPendingManagerType)draftManagerType mail:(MCMailModel*)mail {
    if (draftManagerType == MCMailDraftManagerTypeNew) {
        if ([self.viewModel.mailList containsObject:mail]) {
            [self.viewModel deleteMails:@[mail]];
        }
        [self.viewModel insertMail:mail];
    } else {
        
        [self.mailManager moveMails:@[mail] fromFolder:_mailBoxModel toFolder:_mailBoxModel success:nil failure:nil];
        if ([self.viewModel.mailList containsObject:mail]) {
            [self.viewModel deleteMails:@[mail]];
        }
    }
    [self cancelAllState];
}

#pragma mark - receiveNotification
// 切换账号数据
- (void)mcReloadMailData:(NSNotification *)info {
    DDLogVerbose(@"Receive change account notification on mail list");
    MCAccount *newAccount = (MCAccount *)info.object;
    if (self.viewModel.folder.accountId == newAccount.accountId) {
        DDLogVerbose(@"Account id are same");
        return;
    }
    
    _mailBoxModel = nil;
    _mailManager = nil;
    [self.mailEditingView reset];
    //显示待发送标签
    BOOL sentErrorState = [AppSettings getSentErrorNoteStateWithKey:AppStatus.currentUser.email];
    [self showSentMailErrorView:sentErrorState];
    
    self.mailTableView.dataSource = nil;
    self.viewModel = nil;
    [self.mailTableView reloadData];
    if (self.mailBoxListView.smartBoxSelectEnable) {
       self.navBarTitleLable.text = PMLocalizedStringWithKey(@"PM_Mail_SmartBox");
       [self.vipViewController changeAccountResetMails];
    }
    
    [self toLoadAllFolders];
    self.newMailsNoteShowEnable = YES;
}
//TDDO:收到apns邮件通知
- (void)mcReceiveApnsMails:(NSNotification*)info {
    MCMailModel *mail = info.object;
    if (mail.boxId == _mailBoxModel.uid) {
        if (![self.viewModel.mailList containsObject:mail]) {
            [self.viewModel insertMail:mail];
        } else {
            NSInteger index = [self.viewModel.mailList indexOfObject:mail];
            mail = [self.viewModel.mailList objectAtIndex:index];
            [self.mailTableView reloadData];
        }
        [self markReadMails:@[mail] markRead:YES];
    } else {
        [self.mailManager setReadFlag:YES forMails:@[mail] success:nil failure:nil];
    }
    MCMailBoxManager *boxManager = [MCMailBoxManager new];
    MCMailBox *box = [boxManager getBoxWithId:mail.boxId];
    MCMailDetailViewController *detailViewController = [[MCMailDetailViewController alloc]initWithMail:mail manager:self.mailManager delegate:self];
    detailViewController.mailbox = box;
    [self.navigationController pushViewController:detailViewController animated:YES];
}
//TODO:receive Mqtt Notifition
-(void)mcReceiveMqttNotfication:(NSNotification*)info {
    DDLogVerbose(@"mcReceiveMqttNotfication");
    MCMailModel *mail = info.object;
    if (mail.boxId == _mailBoxModel.uid) {
// MQTT 不去刷新数据，为了性能考虑
//        if (_isSmartBox) {
//            [_vipViewController loadDataSource];
//        } else {
//            [self.viewModel loadNewMailsSuccess:nil failure:nil];
//        }
    } else {
        for (MCMailBox *box in  _mailBoxListView.folders) {
            if (box.uid == mail.boxId && box.accountId == AppStatus.currentUser.accountId) {
                if (box.unreadCount == NSNotFound) {
                    box.unreadCount = 0;
                }
                box.unreadCount += 1;
                if (self.newMailsNoteShowEnable) {
                   [self.leftNavigationBarButtonItem showBarButtonNote:YES];
                    self.newMailsNoteShowEnable = NO;
                }
            }
        }
    }
}

//TODO:sentFailure
- (void)mcSentMailFailure:(NSNotification*)info {
    
    BOOL selectPendingBox = [info.object boolValue];
    if (selectPendingBox) {
        [MCViewDisplay gotoMailListViewController];
        [self didSelectedPendingBox];
        [self showSentMailErrorView:NO];
    } else {
        [self showSentMailErrorView:YES];
    }
}
//选择待发送文件夹
- (void)didSelectedPendingBox {
    NSArray *folders = self.mailBoxListView.folders;
    for (MCMailBox *box in folders) {
        if (box.type == MCMailFolderTypePending) {
            [self.mailBoxListView resetSelectedBox:box];
            [self mailBoxListView:self.mailBoxListView didSelectMailBox:box smartBox:NO];
            return;
        }
    }
}
#pragma mark - Gmail

- (void)eventForRefreshResult:(BOOL)success
{
    NSString *typeKey = @"others";
    if (AppStatus.currentUser.type == MCMailTypeGmail){
        typeKey = @"gmail";
    }
    NSString *value = success ? @"success" : @"failure";
    [MCUmengManager addEventWithKey:mc_mail_list_refresh attributes:@{typeKey : value}];
}
//弹出智能收件箱意见反馈提示
- (void)feedbackForVipMails {
    BOOL feedback = AppSettings.isShowFeedbackVipMailInfoNote;
    if (feedback) {
        RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Cancel") action:^{
            AppSettings.userFeedbackVipMailInfoDate = [NSDate date];
        }];
        RIButtonItem *feedbackItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Mail_VipMailFeedBack") action:^{
            
            MCContactModel *helperContact = [[MCContactManager sharedInstance] helperContact];
            MCIMConversationModel *conversationModel = [[MCIMConversationManager shared] conversationForContact:helperContact];
            MCIMChatViewController *vc =[[MCIMChatViewController alloc] initWithConversationModel:conversationModel];
            [self.navigationController pushViewController:vc animated:YES];
            AppSettings.userFeedbackVipMailInfoDate = [NSDate date];
        }];
        NSString *message = PMLocalizedStringWithKey(@"PM_Mail_VipMailFeedBackNote");
        UIAlertView *feedbackAlertView = [[UIAlertView alloc]initWithTitle:message message:nil cancelButtonItem:cancelItem otherButtonItems:feedbackItem, nil];
        [feedbackAlertView show];
    }
}
@end
