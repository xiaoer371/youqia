//
//  MCMessageViewController.m
//  NPushMail
//
//  Created by zhang on 16/1/18.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCMessageViewController.h"
#import "MCIMChatViewController.h"
#import "MCIMConversationCell.h"
#import "MCPopoverView.h"
#import "MCSelectedContactsRootViewController.h"
#import "MCBaseNavigationViewController.h"
#import "MCIMConversationModel.h"
#import <KVOController/FBKVOController.h>
#import "MCIMConversationManager.h"
#import "MCIMService.h"
#import "MCIMGroupManager.h"
#import "MCIMSetGroupNameView.h"
#import "MCUDID.h"
#import "MCNotificationCenter.h"
#import "MCNetWorkErrorView.h"
#import "MCAccountConfig.h"
#import "MCServerAPI+OA.h"
#import "MCOAConfig.h"
#import "MCWorkSpaceManager.h"
#import "MCOAWebViewController.h"
#import "MCOALoginViewController.h"
#import "MCIMNoMessageView.h"
#import "MCAppSetting.h"
#import "UIAlertView+Blocks.h"
#import "MCAuthErrorView.h"
#import "MCContactManager.h"
#import "MCServerViewController.h"
#import "MCWebViewController.h"
#import "RSADataSigner.h"
#import "MCAdEventView.h"
#import "MCOrientationsNav.h"



@interface MCMessageViewController ()<UITableViewDelegate,MGSwipeTableCellDelegate,MCAuthErrorViewDelegate>

@property (nonatomic, strong) MCNetWorkErrorView   *networkErrView;
@property (nonatomic, strong) MCIMNoMessageView    *noMessageView;
@property (nonatomic, strong) RTDraggableBadge     *tabBarbadge;
@property (nonatomic, strong) MCAuthErrorView      *authErrorView;

@property (nonatomic, weak) id notificationObj;
/**
 *  要跳转到的OA的事务类型（点击发起事务到新建，点击列表的到待办）
 */
@property (nonatomic, assign) OAUrlType loadOaPageType;

@end

@implementation MCMessageViewController

#pragma mark - Lifecycle
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.notificationObj];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _tabBarbadge.dragEnabled = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _tabBarbadge.dragEnabled = YES;
    [self.changeAccountArrow setHidden:NO];
    
    [self showReAuthView];
    DDLogVerbose(@"AppStatus.currentUser.status  ====%d ",AppStatus.currentUser.status);

}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self initSubView];
    [self loadData];
    [self monitorIMState];
    [self setRootCtrlNavigationBarTitleView];
    
    self.notificationObj = [[NSNotificationCenter defaultCenter] addObserverForName:MCNotificationDidChangeAccount object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        @synchronized (self) {
            [self.KVOController unobserve:self.messageViewModel keyPath:@"unreadCount"];
            [self.KVOController unobserve:AppStatus.accountData.imClient keyPath:@"state"];
            [self loadData];
            [self monitorIMState];
            [self showReAuthView];
        }

    }];

    [self netWorkViewShow:!(AppStatus.networkStatus != NotReachable)];
    
    if (self.messageViewModel.dataArray.count<1) {
        [self showNomessageView:YES];
    }else [self showNomessageView:NO];
}


#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MCIMConversationModel *conversationModel = self.messageViewModel.dataArray[indexPath.row];
    if (conversationModel.unreadCount > 0) {
        [self toggleReadAtIndexPath:indexPath];
    }
    
    conversationModel.isChatting = YES;
    
    switch (conversationModel.type) {
        case MailChatConversationTypeSingle:
        case MailChatConversationTypeGroup:
        {
            MCIMChatViewController *vc =[[MCIMChatViewController alloc] initWithConversationModel:conversationModel];
            [self.navigationController pushViewController:vc animated:YES];
        }
        break;
        case MailChatConversationTypeApp:
        {
            _loadOaPageType = OATrans;
            [self oaLoginCheck];
        }
            break;
        case MailChatConversationTypeFeiba:
        {
            NSURL *url = [NSURL URLWithString:@"http://partner.flybytrip.com/wap/login"];
            MCWebViewController *vc =[[MCWebViewController alloc] initWithUrl:url title:@"机票特卖" style:MCWebViewStyleFeiBa];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case MailChatConversationTypeEvent:{
            
            NSString *str = [NSString stringWithFormat:@"http://huiyi.wlbit.com/hyvote.aspx?email=%@",AppStatus.currentUser.email];
            NSURL *url = [NSURL URLWithString:str];
            MCWebViewController *vc =[[MCWebViewController alloc] initWithUrl:url title:@"尾牙投票" style:MCWebViewStyleDefault];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case MailChatConversationTypeEventlive:
        {
//            NSString *str = @"http://wap.yy.com/mobileweb/98728087/98728087#!/live/room";
            NSString *str = @"http://live.bilibili.com/3219666";
            NSURL *url = [NSURL URLWithString:str];
            MCWebViewController *vc =[[MCWebViewController alloc] initWithUrl:url title:@"年会直播" style:MCWebViewStyleWeiYa];
            MCBaseNavigationViewController *webNav = [[MCBaseNavigationViewController alloc] initWithRootViewController:vc];
//            MCOrientationsNav * nav = [[MCOrientationsNav alloc] initWithRootViewController:vc];
//            [self.navigationController pushViewController:vc animated:YES];
            [self presentViewController:webNav animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

#pragma mark Swipe Delegate


- (BOOL)swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
{
    return (direction == MGSwipeDirectionRightToLeft);
}

- (NSArray *)swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings
{
    MCIMConversationCell *cell1 = (MCIMConversationCell*)cell;
    MCIMConversationModel *aConversationModel  = cell1.conversationModel;
    
    swipeSettings.transition = MGSwipeTransitionBorder;
    cell.rightExpansion.buttonIndex = 0;
    cell.rightExpansion.fillOnTrigger = YES;
    cell.rightExpansion.threshold = 2;
    
    __weak typeof(self) weakSelf = self;
    CGFloat padding = 5;
    // 删除按钮
    MGSwipeButton *readBtn = [MGSwipeButton buttonWithTitle:aConversationModel.unreadCount > 0 ?PMLocalizedStringWithKey(@"PM_Mail_SetRead"):PMLocalizedStringWithKey(@"PM_Mail_SetUnRead") backgroundColor:[UIColor colorWithHexString:@"dddddd"] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
        __strong typeof(self) sSelf = weakSelf;
        NSIndexPath *indexPath = [sSelf.tableView indexPathForCell:sender];
        [sSelf toggleReadAtIndexPath:indexPath];
        return YES;
    }];
    readBtn.buttonWidth = 80;
    
    MGSwipeButton *trashBtn = [MGSwipeButton buttonWithTitle:PMLocalizedStringWithKey(@"PM_Msg_DelMsgCell") backgroundColor:[UIColor colorWithHexString:@"f54e46"] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
        __strong typeof(self) sSelf = weakSelf;
        NSIndexPath *indexPath = [sSelf.tableView indexPathForCell:sender];
        [sSelf deleteCellAtIndexPath:indexPath];
        return YES;
    }];
    
    BOOL isTop = aConversationModel.onTopTime > 0;
    MGSwipeButton * topBtn = [MGSwipeButton buttonWithTitle:isTop?PMLocalizedStringWithKey(@"PM_Msg_SetMsg_NoTop"):PMLocalizedStringWithKey(@"PM_Msg_SetMsg_Top") backgroundColor:[UIColor colorWithHexString:@"f5b146"] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
        __strong typeof(self) sSelf = weakSelf;
        NSIndexPath *indexPath = [sSelf.tableView indexPathForCell:sender];
        [sSelf toggleConversationTopAtIndexPath:indexPath];
        return YES;
    }];
    
    if (aConversationModel.type == MailChatConversationTypeFeiba) {
        return @[readBtn,topBtn];
    }else{
        return @[trashBtn,readBtn,topBtn];
    }
}

- (void)swipeTableCell:(MGSwipeTableCell*) cell didChangeSwipeState:(MGSwipeState)state gestureIsActive:(BOOL)gestureIsActive
{
    NSString * str;
    switch (state) {
        case MGSwipeStateNone: str = @"None"; break;
        case MGSwipeStateSwippingLeftToRight: str = @"SwippingLeftToRight"; break;
        case MGSwipeStateSwippingRightToLeft: str = @"SwippingRightToLeft"; break;
        case MGSwipeStateExpandingLeftToRight: str = @"ExpandingLeftToRight"; break;
        case MGSwipeStateExpandingRightToLeft: str = @"ExpandingRightToLeft"; break;
    }
}

#pragma mark - NavgationViewController

-(void)rightNavigationBarButtonItemAction:(id)sender
{

    NSArray*titles = @[PMLocalizedStringWithKey(@"PM_Msg_AddChats"), PMLocalizedStringWithKey(@"PM_Msg_Send_OA")];
    CGPoint point = CGPointMake(ScreenWidth - 22,54);
    __weak MCMessageViewController *weakSelf = self;
    MCPopoverView *mcPopverView = [MCPopoverView new];
    mcPopverView.menuTitles = titles;
    [mcPopverView showFromPoint:point popoverViewStyle:MCPopoverViewStyleUp selected:^(NSInteger index) {
       
        switch (index) {
            case 0:  //(发起聊天)
            {
                //友盟统计
                [MCUmengManager addEventWithKey:mc_im_sendchat];
                MCSelectedContactsRootViewController *selectedContactsViewCottroller = [[MCSelectedContactsRootViewController alloc]initWithSelectedModelsBlock:^(id models) {
                    NSArray*contacts = (NSArray*)models;
                    if (contacts.count==0){
                        [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_Msg_ErrNoContacts")];
                        return;
                    }
                    [weakSelf creatChatWithContacts:contacts];
                    
                } selectedMsgGroupModelBlock:^(id model) {
                    MCIMConversationModel *conversationModel = [[MCIMConversationManager shared] conversationForGroup:model];
                    MCIMChatViewController *vc =[[MCIMChatViewController alloc] initWithConversationModel:conversationModel];
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                } formCtrlType:SelectedContactFromChat alreadyExistsModels:nil];
                
                MCBaseNavigationViewController *navigationController = [[MCBaseNavigationViewController alloc]initWithRootViewController:selectedContactsViewCottroller];
                
                [weakSelf presentViewController:navigationController animated:YES completion:nil];
            }
                break;
            case 1:// （oa 入口)
            {
                //友盟统计
                [MCUmengManager addEventWithKey:mc_im_sendoa];
                weakSelf.loadOaPageType = OANew;
                [weakSelf oaLoginCheck];
            }
                break;
            default:
                break;
        }
    }];
}

#pragma mark - Private

-(void)initSubView
{
    self.navBarTitleLable.text = PMLocalizedStringWithKey(@"PM_Main_Tab_Message_Email");
    
    self.leftNavigationBarButtonItem.image = nil;
    self.rightNavigationBarButtonItem.image = AppStatus.theme.chatStyle.messageNavRightImage;
    
    [self.view addSubview:self.tableView];
    
    __weak typeof(self) weakSelf = self;
    [self.KVOController observe:AppStatus keyPath:@"networkStatus" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        [weakSelf netWorkViewShow:!(AppStatus.networkStatus != NotReachable)];
    }];
    
}

- (void)loadData
{
    _messageViewModel = nil;
    __weak typeof(self) weakSelf = self;
    _messageViewModel = [[MCMessageViewModel alloc] initWithTableView:self.tableView cellDelegate:self];
    NSString *unreadCountString = [NSString stringWithFormat:@"%ld",(long)self.messageViewModel.unreadCount];
    self.tabBarbadge = [self.tabBarItem rt_setBadgeValue:unreadCountString withHandle:nil];
    self.tabBarbadge.dragOutblock = ^(id sender){
        [weakSelf clearUnreadCount];
    };
    [self.KVOController observe:self.messageViewModel keyPath:@"unreadCount" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        NSString *unreadCountString = @"";
        if (weakSelf.messageViewModel.unreadCount > 0) {
            unreadCountString = [NSString stringWithFormat:@"%ld",(long)weakSelf.messageViewModel.unreadCount];
        }
        weakSelf.tabBarbadge.text = unreadCountString;
        
        if (weakSelf.messageViewModel.dataArray.count<1) {
            [weakSelf showNomessageView:YES];
        }else [weakSelf showNomessageView:NO];
    }];
    
    if (weakSelf.messageViewModel.dataArray.count<1) {
        [weakSelf showNomessageView:YES];
    }else [weakSelf showNomessageView:NO];
}

- (void)monitorIMState
{
    // 启动消息服务
    __weak typeof(self) weakSelf = self;
    [self.KVOController observe:AppStatus.accountData.imClient keyPath:@"state" options:NSKeyValueObservingOptionNew |
     NSKeyValueObservingOptionOld  block:^(id observer, id object, NSDictionary *change) {
         [weakSelf connectStateWithDic:change];
     }];
}

- (void)clearUnreadCount
{
    [self.messageViewModel clearAllUnreadCount];
}

//发起聊天
#pragma mark - creatChatWithContacts
-(void)creatChatWithContacts:(NSArray *)contacts
{
    if (contacts.count==1) {
        MCContactModel *contactModel = contacts[0];
        
        if ([contactModel.account isEqualToString:AppStatus.currentUser.email]) {
            [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_IMChat_CurrentChat")];
            return;
        }
        
        MCIMConversationModel *conversationModel = [[MCIMConversationManager shared] conversationForContact:contactModel];
        MCIMChatViewController *vc =[[MCIMChatViewController alloc] initWithConversationModel:conversationModel];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else
    {
        NSMutableArray *newContacts =[NSMutableArray arrayWithArray:contacts];
        for (MCContactModel *contactModel in contacts) {
            if ([contactModel.account isEqualToString:AppStatus.currentUser.email]) {
                [newContacts removeObject:contactModel];
            }
        }
        
        if (newContacts.count==1) {
            MCContactModel *contactModel = newContacts[0];
            MCIMConversationModel *conversationModel = [[MCIMConversationManager shared] conversationForContact:contactModel];
            MCIMChatViewController *vc =[[MCIMChatViewController alloc] initWithConversationModel:conversationModel];
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            __weak typeof(self) weakSelf = self;
            [SVProgressHUD showWithStatus:PMLocalizedStringWithKey(@"PM_Msg_GroupCreating")];
            MCIMGroupManager *groupManager =[MCIMGroupManager shared];
            [groupManager createGroupWithGroupName:nil members:newContacts success:^(id response) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    MCIMGroupModel *group = (MCIMGroupModel* )response;
                    MCIMConversationModel *conversationModel = [[MCIMConversationManager shared] conversationForGroup:group];
                    MCIMChatViewController *vc =[[MCIMChatViewController alloc] initWithConversationModel:conversationModel];
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                    [SVProgressHUD dismiss];
                });
            } failure:^(NSError *error) {
                [SVProgressHUD dismiss];
                [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_Msg_GroupCreatErr")];
            }];
        }
    }
}


#pragma mark - connectStateWithDic

-(void)connectStateWithDic:(NSDictionary*)change
{
    if (!(AppStatus.networkStatus != NotReachable)) {
        [self stopAnimationInducatorView];
        return;
    }
    
    NSInteger new =[[change objectForKey:@"new"] integerValue];
    NSInteger old =[[change objectForKey:@"old"] integerValue];
    
    if ((new == MCIMClientStateStarting || new == MCIMClientStateConnecting) && old!= MCIMClientStateClosed) {
        
        [self startAnimationIndicatorView];
        
    }else if (new == MCIMClientStateError){
        
        [self startAnimationIndicatorView];
        
    }else if (new == MCIMClientStateConnected){
        
        [self stopAnimationInducatorView];
        
    }else if (new == MCIMClientStateClosing|| new == MCIMClientStateClosed){
        
        [self startAnimationIndicatorView];
        
    }else if (new == MCIMClientStateStarting && old == MCIMClientStateClosed){
        [self startAnimationIndicatorView];
        
    }else{
        
    }
}

#pragma mark - MGSwipeButton Actions
- (void)deleteCellAtIndexPath:(NSIndexPath *)indexPath
{
    @synchronized (self.messageViewModel.dataArray) {
        NSUInteger index = indexPath.row;
        MCIMConversationModel *conversation = self.messageViewModel.dataArray[index];
        self.messageViewModel.unreadCount -= conversation.unreadCount;
        [self.messageViewModel.dataArray removeObjectAtIndex:index];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [[MCIMConversationManager shared] removeConversation:conversation];
        
        if (self.messageViewModel.dataArray.count<1) {
            [self showNomessageView:YES];
        }
    }
}

- (void)toggleConversationTopAtIndexPath:(NSIndexPath *)indexPath
{
    @synchronized (self.messageViewModel.dataArray) {
        NSUInteger index = indexPath.row;
        MCIMConversationModel *conversation = self.messageViewModel.dataArray[index];
        conversation.onTopTime = conversation.onTopTime == 0 ? [[NSDate new] timeIntervalSince1970] : 0;
        [[MCIMConversationManager shared] updateConversation:conversation];
        [self.messageViewModel setTop:conversation];
    }
}

- (void)toggleReadAtIndexPath:(NSIndexPath *)indexPath
{
    @synchronized (self.messageViewModel.dataArray) {
        NSUInteger index = indexPath.row;
        MCIMConversationModel *conversation = self.messageViewModel.dataArray[index];
        NSUInteger oldUnreadCount = conversation.unreadCount;
        conversation.unreadCount = conversation.unreadCount > 0 ? 0 : 1;
        NSInteger delta = conversation.unreadCount - oldUnreadCount;
        self.messageViewModel.unreadCount += delta;
        [[MCIMConversationManager shared] updateConversation:conversation];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

-(void)netWorkViewShow:(BOOL)isShow
{
    if (!_networkErrView) {
        _networkErrView = [[MCNetWorkErrorView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 44) actionViewBlock:^(IMNoticeType type){
            //
        } noticeType:IMNoticeTypeNetError];
        [self.view addSubview:_networkErrView];
        [self.view sendSubviewToBack:_networkErrView];
    }
    
    if (isShow)
    {
        [UIView animateWithDuration:0.3f animations:^{
            
            self.tableView.frame =CGRectMake(0, 44, ScreenWidth, ScreenHeigth-NAVIGATIONBARHIGHT-50-44);
        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3f animations:^{
            self.tableView.frame =CGRectMake(0, 0, ScreenWidth, ScreenHeigth-NAVIGATIONBARHIGHT-50);
            
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth,  ScreenHeigth-NAVIGATIONBARHIGHT- TOOLBAR_HEIGHT) style:UITableViewStylePlain];
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.rowHeight = 66.0f;
        [_tableView setSeparatorInset:UIEdgeInsetsMake(0, 67, 0, 0)];
        _tableView.separatorColor = AppStatus.theme.tableViewSeparatorColor;
    }
    return _tableView;
}

- (MCIMNoMessageView *)noMessageView
{
    if (!_noMessageView) {
        _noMessageView = [[MCIMNoMessageView alloc] initWithFrame:CGRectMake(0, 44, ScreenWidth, ScreenHeigth-NAVIGATIONBARHIGHT-50-44)];
        _noMessageView.hidden = YES;
    }
    return _noMessageView;
}

- (void)showNomessageView:(BOOL)isShow
{
    if (!_noMessageView) {
        [self.view addSubview:self.noMessageView];
    }
    self.noMessageView.hidden = !isShow;
}

#pragma mark - MCAuthErrorViewDelegate

- (void)showReAuthView
{
    if (AppStatus.currentUser.status == MCAccountStatusUnValidated) {
        if (!_authErrorView) {
            [self.view addSubview:self.authErrorView];
        }
        _authErrorView.hidden = NO;
    }else{
        _authErrorView.hidden = YES;
    }
}

- (void)reAuth:(MCAuthErrorView *)authErrorView
{
    MCServerViewController *serverViewController = [[MCServerViewController alloc]initWithAccount:AppStatus.currentUser];
    MCBaseNavigationViewController *navigatianViewController = [[MCBaseNavigationViewController alloc]initWithRootViewController:serverViewController];
    [self presentViewController:navigatianViewController animated:YES completion:nil];
}

- (void)conversationWithHelper:(MCAuthErrorView *)authErrorView
{
    MCContactModel *helperContact = [[MCContactManager sharedInstance] helperContact];
    MCIMConversationModel *conversationModel = [[MCIMConversationManager shared] conversationForContact:helperContact];
    MCIMChatViewController *vc = [[MCIMChatViewController alloc] initWithConversationModel:conversationModel];
    [self.navigationController pushViewController:vc animated:YES];
}

- (MCAuthErrorView *)authErrorView
{
    if (!_authErrorView) {
        _authErrorView = [[MCAuthErrorView alloc] initWithType:0];
        _authErrorView.delegate = self;
    }
    return _authErrorView;
}

#pragma  mark - OA登录验证

- (void)oaLoginCheck {
    MCAccount *currentAct = AppStatus.currentUser;
    MCAccountConfig *accountConfig = AppStatus.accountData.accountConfig;
    __weak MCMessageViewController *weakSelf = self;
    if (accountConfig.isFirstSyncOAUser) {
        if (accountConfig.isOAUser) {
            //有对应的oa帐号可供登录
            if (accountConfig.oaUserName && accountConfig.oaPassword) {
                if (accountConfig.oaAccesstoken) {
                    //判断token是否过期
                    [MCOAWorkSpaceManager accesstokenExpireinProcessComplite:^(BOOL expirein) {
                        if (expirein) {
                            //重新登录
                            [self loginOaWithAccountConfig:accountConfig];
                        }else {
                            [self loadOaPage];
                        }
                    }];
                }else {
                    //去登录获取accesstoken
                    [self loginOaWithAccountConfig:accountConfig];
                }
               
            }else {
                //只判断了是oa用户，但还未输入oa密码的情况
                if (!accountConfig.oaPassword) {
                    [self goToLoginOaCtrl];
                }
            }
        }else {
            [SVProgressHUD showWithStatus:PMLocalizedStringWithKey(@"PM_Msg_MessageLoading")];
            //验证是否是OA用户
            [ServerAPI isOaUserWithEmail:currentAct.email success:^(id response) {
                MCOAConfig *oaConfig = (MCOAConfig *)response;
                if (oaConfig.isOaUser) {
                    if (oaConfig.isOaUser.oaUserFlag) {
                        [SVProgressHUD dismiss];
                        //是OA用户，不需要再验证和绑定了
                        accountConfig.isOAUser = YES;
                        accountConfig.hasWorkspace = YES;
                        accountConfig.oaUserType = 0;//OA用户
                        accountConfig.oaUserName = AppStatus.currentUser.email;
                        NSRange range = [accountConfig.oaUserName rangeOfString:@"@"];
                        accountConfig.oaDomin = [accountConfig.oaUserName substringFromIndex:(range.location + 1)];
                        accountConfig.oaPassword = AppStatus.currentUser.password;
                        [self loginOaWithAccountConfig:accountConfig];
                        
                    }else {
                        //不是OA用户，需要先去网页绑定才行，若绑定过了则需要输入一次密码。
                        [weakSelf checkOABindingStatus];
                    }
                }else {
                    [SVProgressHUD dismiss];
                    [weakSelf loadOaPage];
                }
                
            } failrue:^(NSError *error) {
                [weakSelf checkOABindingStatus];
            }];
        }
    }else {
        if (!accountConfig.oaPassword) {
            [self goToLoginOaCtrl];
        }else {
            [self loadOaPage];
        }
    }
    
}

- (void)loginOaWithAccountConfig:(MCAccountConfig *)accountConfig {
    //重新登录
    [MCOAWorkSpaceManager loginOaWithDomin:accountConfig.oaDomin accountConfig:accountConfig success:^(id response) {
        //TODO 先判断错误码，如果需要重新到登录页面则到oa登录页面
        MCOAConfig *oaConfig = (MCOAConfig *)response;
        if (oaConfig.oaUserLoginTypeType.errorcode == 12901) {
            //密码错误，到重新绑定页面
            DDLogInfo(@"OA密码错误，需重新登录");
            [self goToLoginOaCtrl];
        } else if (oaConfig.oaUserLoginTypeType.errorcode == 0) {
            if (oaConfig.oaUserLoginTypeType.accesstoken) {
                accountConfig.isFirstSyncOAUser = NO;
                [self loadOaPage];
            }
        }else {
            //弹出错误提示
            NSString *errorMsg = [NSString stringWithFormat:@"OA登录失败:%@", oaConfig.oaUserLoginTypeType.message];
            DDLogWarn(@"%@", errorMsg);
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:PMLocalizedStringWithKey(@"PM_Common_Notice") message:errorMsg cancelButtonItem:[RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Sure")] otherButtonItems:nil,nil];
            [alertView show];
        }
        
    } failrue:^(NSError *error) {
        //错误提示：登录过期，请重试
        DDLogWarn(@"%@", @"oa登录出错");
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:PMLocalizedStringWithKey(@"PM_Common_Notice") message:@"oa登录出错" cancelButtonItem:[RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Sure")] otherButtonItems:nil,nil];
        [alertView show];
    }];
}

//判断是否需要跳转到oa的登录界面
- (void)goToLoginOaCtrl {
    MCAccountConfig *accountConfig = AppStatus.accountData.accountConfig;
    //跳转到oa登录页面
    MCOALoginViewController *v = [[MCOALoginViewController alloc] initWithOaUserName:accountConfig.oaUserName domin:accountConfig.oaDomin controllerSourceType:fromMessageListCtrlType];
    [self.navigationController pushViewController:v animated:YES];
}

- (void)checkOABindingStatus {
    __weak MCMessageViewController *weakSelf = self;
    MCAccount *currentAct = AppStatus.currentUser;
    MCAccountConfig *accountConfig = AppStatus.accountData.accountConfig;
    [ServerAPI checkIsBindingOAWithEmail:currentAct.email success:^(id response) {
        [SVProgressHUD dismiss];
        MCOAConfig *oaConfig = (MCOAConfig *)response;
        accountConfig.oaUserType = 1;//个人邮箱用户
        
        if (oaConfig.checkBindingOa) {
            accountConfig.oaDomin = oaConfig.checkBindingOa.oaDomin;
            accountConfig.oaUserName = oaConfig.checkBindingOa.oaUserName;
            if (oaConfig.checkBindingOa.bindingOaFlag) {
                //绑定过OA了，则先去登录，登录完成下次不需要再登录
                accountConfig.isOAUser = YES;
                accountConfig.isFirstSyncOAUser = NO;
                accountConfig.hasWorkspace = YES;
                MCOALoginViewController *v = [[MCOALoginViewController alloc] initWithOaUserName:oaConfig.checkBindingOa.oaUserName domin:oaConfig.checkBindingOa.oaDomin controllerSourceType:fromMessageListCtrlType];
                [weakSelf.navigationController pushViewController:v animated:YES];
            }else {
                //未绑定oa，则跳到广告页
                [weakSelf loadOaPage];
            }
        }else {
            [weakSelf loadOaPage];
        }
        
    } failrue:^(NSError *error) {
        [SVProgressHUD dismiss];
        [weakSelf loadOaPage];
    }];
}

- (void)loadOaPage {
    MCOAWebViewController *v = [[MCOAWebViewController alloc] init];
    if (AppStatus.accountData.accountConfig.isOAUser) {
        //如果是OA用户
        v.destinationUrl = [ServerAPI getOaResultUrlWithPayloadUrl:nil isMQTT:YES withEndUrlType:_loadOaPageType];
    }else {
        v.destinationUrl = @"http://vip01.oa.35.com/OAFlyer/flyer.html";
    }
    [self.navigationController pushViewController:v animated:YES];

}

//- (BOOL)shouldAutorotate
//{
//    return NO;
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskLandscapeLeft;
//}


@end
