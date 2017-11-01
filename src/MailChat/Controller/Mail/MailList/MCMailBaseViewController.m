//
//  MCMailBaseViewController.m
//  NPushMail
//
//  Created by zhang on 2016/12/21.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCMailBaseViewController.h"
#import "MCBaseNavigationViewController.h"
#import "MCMailDetailViewController.h"
#import "MCIMChatViewController.h"
#import "MCServerViewController.h"
#import "MCWebViewController.h"

#import "MCMailBoxManager.h"
#import "MCAccountManager.h"
#import "MCMailSentErrorView.h"
#import "UIAlertView+Blocks.h"
#import "MCContactManager.h"
#import "MCIMConversationManager.h"
#import "MCViewDisplay.h"
#import "MCFeaturesGuideHelper.h"
#import "MCSmartMailListViewModel.h"
#import "UIScrollView+EmptyDataSet.h"
#import "MCAccountConfig.h"
@interface MCMailBaseViewController () <UITableViewDelegate,MCMailTableViewDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>

@property (nonatomic,strong)MCMailSentErrorView *sentErrorView;

/**
 是否在当前页面，用于功能引导图的显示控制
 */
@property (nonatomic,assign) BOOL isCurrentPage;
@end

static NSString *const kMCNoteUrl = @"http://api.mailchat.cn:81/EmptyMailList.html";

@implementation MCMailBaseViewController

- (id)init {
    if (self = [super init]) {
        self.loadAvatarForMailList = YES;
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.isCurrentPage = YES;
    //根据是不是加载头像刷新列表
    if (self.loadAvatarForMailList != AppSettings.loadAvatarCellForMailList) {
        [self.tableView reloadData];
        self.loadAvatarForMailList = AppSettings.loadAvatarCellForMailList;
    }
    [self.repealView dismiss];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.isCurrentPage = NO;
    [self.repealView dismiss];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sentMailFailure:) name:MCNotificationSentMailFailure object:nil];
}

- (void)guideShow {
    if (!AppSettings.isFirstShowGuideForMailListContrller) {
        return;
    }
    BOOL haveMails = self.viewModel.mailList.count > 0?YES:NO;
    BOOL haveImportantMails = NO;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    NSIndexPath *importantIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    CGRect importantRectInWindow = CGRectMake(0, NAVIGATIONBARHIGHT, ScreenWidth, 44);
    if ([self.viewModel isMemberOfClass:[MCSmartMailListViewModel class]]) {
        MCSmartMailListViewModel *viewModel = (MCSmartMailListViewModel *)self.viewModel;
        haveImportantMails = viewModel.importantMailCount > 0?YES:NO;
    }else {
        importantRectInWindow = CGRectZero;
    }
    if (haveImportantMails) {
        CGRect importantRectInTableView = [self.tableView rectForRowAtIndexPath:importantIndexPath];
        importantRectInWindow = [self.tableView convertRect:importantRectInTableView toView:window];
        importantRectInWindow = CGRectMake(0, importantRectInWindow.origin.y - 44, importantRectInWindow.size.width, importantRectInWindow.size.height + 44);
    }
    
    CGRect rectInTableView = CGRectZero;
    CGRect rectInWindow = CGRectZero;
    if (haveMails) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        NSInteger sections = [self.tableView numberOfSections];
        if (sections > 1) {
            indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        }
        rectInTableView = [self.tableView rectForRowAtIndexPath:indexPath];
        rectInWindow = [self.tableView convertRect:rectInTableView toView:window];
    }else {
        importantRectInWindow = CGRectZero;
    }
    
    if (self.isCurrentPage) {
        MCFeaturesGuideHelper *guideView = [[MCFeaturesGuideHelper alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeigth) mailListCellRect:rectInWindow importantMailRect:importantRectInWindow  guideType:MCFeaturesGuideMailList];
        [guideView show];
    }
}

- (MCMailViewController*)parentVC {
    return (MCMailViewController*)self.parentViewController;
}

- (MCMailManager*)mailManager {
    if (!_mailManager) {
        _mailManager = [[MCMailManager alloc]initWithAccount:AppStatus.currentUser];
    }
    return _mailManager;
}

- (void)setViews {
    self.tableView = [[MCMailListTableView alloc]init];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.delegate = self;
    self.tableView.refreshDelegate = self;
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    [self.view addSubview:self.tableView];
    self.repealView = [MCRepealView shared];
}

- (MCMailSentErrorView*)sentErrorView {
    if (!_sentErrorView) {
        CGRect frame = CGRectMake(0, -44, ScreenWidth, 44);
        _sentErrorView = [[MCMailSentErrorView alloc]initWithFrame:frame needClearItem:YES];
        __weak typeof(self)weak = self;
        _sentErrorView.dismissCallback = ^{
            [weak showSentMailErrorView:NO];
        };
        _sentErrorView.didSelectedPendingBox = ^{
            [weak.parentVC didSelectedPendingBox];
        };
        [self.view addSubview:_sentErrorView];
    }
    return _sentErrorView;
}
//发件失败提醒显示
- (void)showSentMailErrorView:(BOOL)show{
    
    if (!show && !_sentErrorView) {
        return;
    }
    
    if ((show && self.sentErrorView.frame.origin.y == 0)||(show && self.folder.type == MCMailFolderTypePending)) {
        return;
    }
    [self.view bringSubviewToFront:self.sentErrorView];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = CGRectZero;
        if (show) {
            rect = self.tableView.frame;
            rect.origin.y += CGRectGetHeight(_sentErrorView.frame);
            rect.size.height -= CGRectGetHeight(_sentErrorView.frame);
            self.tableView.frame = rect;
            rect = self.sentErrorView.frame;
            rect.origin.y = 0;
            self.sentErrorView.frame = rect;
        } else {
            rect = self.tableView.frame;
            rect.origin.y = 0;
            rect.size.height = self.view.frame.size.height;
            self.tableView.frame = rect;
            rect = self.sentErrorView.frame;
            rect.origin.y = -CGRectGetHeight(_sentErrorView.frame);
            self.sentErrorView.frame = rect;
        }
        
    } completion:^(BOOL finished) {
        if (!show) {
            [self.sentErrorView removeFromSuperview];
            self.sentErrorView = nil;
        }
    }];
    AppStatus.accountData.accountConfig.sentErrorNote = show;
}

#pragma mark - DZNEmptyDataSetSource Methods

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    if (self.folder.type == MCMailFolderTypeInbox) {
        return nil;
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:PMLocalizedStringWithKey(@"PM_Mail_NoneMails") attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0],NSForegroundColorAttributeName:AppStatus.theme.fontTintColor}];
    return attributedString;
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state
{
    if (self.folder.type != MCMailFolderTypeInbox) {
        return nil;
    }
    NSString *text = PMLocalizedStringWithKey(@"PM_Mail_NoneMailsNote");
    UIFont *font = [UIFont systemFontOfSize:16.0];
    UIColor *textColor = AppStatus.theme.tintColor;
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    [attributes setObject:font forKey:NSFontAttributeName];
    [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}


- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return 0;
}

- (UIImage*)imageForEmptyDataSet:(UIScrollView *)scrollView {
    
    if (self.folder.type == MCMailFolderTypeInbox) {
        return [UIImage imageNamed:@"mc_mailLlist_receiveNote.png"];
    }
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

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView
{
    return YES;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return YES;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button
{
    MCWebViewController *webController = [[MCWebViewController alloc] initWithUrl:[NSURL URLWithString:kMCNoteUrl]];
    [self.navigationController pushViewController:webController animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.tableView.refreshView scrollViewDidScroll];
    [self.repealView dismiss];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self.tableView.refreshView scrollViewDidEndDraging];
    [self.repealView dismiss];
}

//TODO:sentFailure
- (void)sentMailFailure:(NSNotification*)info {
    BOOL selectPendingBox = [info.object boolValue];
    if (selectPendingBox) {
        [MCViewDisplay gotoMailListViewController];
        [self.parentVC didSelectedPendingBox];
        [self showSentMailErrorView:NO];
    } else {
        [self showSentMailErrorView:YES];
    }
}

//TODO:验证邮箱账号是否产生错误
- (void)loadMailsError:(NSError *)error {
    //验证常见的邮件密码错误
    if (error.code == 5) { // MCOErrorAuthentication
        AppStatus.currentUser.status = MCAccountStatusUnValidated;
        [[MCAccountManager shared] updateAccount:AppStatus.currentUser];
        
        RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Cancel")];
        RIButtonItem *setItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Mine_Setting") action:^{
            MCServerViewController *serverViewController = [[MCServerViewController alloc]initWithAccount:AppStatus.currentUser];
            MCBaseNavigationViewController *navigatianViewController = [[MCBaseNavigationViewController alloc]initWithRootViewController:serverViewController];
            [self presentViewController:navigatianViewController animated:YES completion:nil];
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
    [self.tableView endRefreshWithResult:LoadMailResultNoNewMails];
}

//TODO:未读数刷新
- (void)resetUnreadIcon {
    NSString *unreadCountString = self.viewModel.unreadCount <= 0?nil:[NSString stringWithFormat:@"%ld",(long)self.viewModel.unreadCount];
    self.tabBarbadge  = [self.parentVC.tabBarItem rt_setBadgeValue:unreadCountString withHandle:nil];
    __weak typeof(self) weakSelf = self;
    self.tabBarbadge.dragOutblock = ^(id sender){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.isRead == %d",0];
        NSArray *unreadArray = [weakSelf.viewModel.mailList filteredArrayUsingPredicate:predicate];
        if (unreadArray.count > 0) {
            [weakSelf markReadMails:unreadArray markRead:YES];
        } else {
            weakSelf.viewModel.unreadCount = 0;
            weakSelf.folder.unreadCount = 0;
        }
    };
    weakSelf.folder.unreadCount = weakSelf.viewModel.unreadCount;
}


#pragma mark - public
- (void)receivewApnsNotificationInfoMail:(MCMailModel*)mail{
    self.mailManager = nil;
    if (mail.boxId == self.folder.uid) {
        if (![self.viewModel.mailList containsObject:mail]) {
            [self.viewModel insertMail:mail];
        } else {
            NSInteger index = [self.viewModel.mailList indexOfObject:mail];
            mail = [self.viewModel.mailList objectAtIndex:index];
            
            [self.tableView reloadData];
        }
        [self markReadMails:@[mail] markRead:YES];
    } else {
        [self.mailManager setReadFlag:YES forMails:@[mail] success:nil failure:nil];
    }
    mail.isDeleted = YES;
    mail.isRead = YES;
    MCMailBoxManager *boxManager = [MCMailBoxManager new];
    MCMailBox *box = [boxManager getBoxWithId:mail.boxId];
    MCMailDetailViewController *detailViewController = [[MCMailDetailViewController alloc]initWithMail:mail manager:self.mailManager delegate:self];
    detailViewController.mailbox = box;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (BOOL)receivewMqttNotificationInfoMailInCurrentFolder:(MCMailModel*)mail {
    
    return NO;
}

- (void)receivewContactMailStateChange:(MCMailModel *)mail tags:(MCMailTags)tags mark:(BOOL)mark {
    
}

- (void)loadMailDataSourceWithFolder:(MCMailBox*)folder{
    
    if (folder.type == MCMailFolderTypePending) {
        AppStatus.accountData.accountConfig.sentErrorNote = NO;
        [self showSentMailErrorView:NO];
    } else {
        BOOL sentErrorState = AppStatus.accountData.accountConfig.sentErrorNote;
        [self showSentMailErrorView:sentErrorState];
    }
    [self resetState];
}

- (BOOL)navigationBarleftItemAction{return YES;}

- (void)navigationBarRightItemAction{}

- (void)navigationSearchItemAction{}

- (void)resetState {}
@end
