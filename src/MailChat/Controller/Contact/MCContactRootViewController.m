//
//  MCContactRootViewController.m
//  NPushMail
//
//  Created by wuwenyu on 15/12/31.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import "MCContactRootViewController.h"
#import "MCContactCell.h"
#import "MCContactGroupCell.h"
#import "MCAccount.h"
#import "MCContactModel.h"
#import "MCGroup.h"
#import "UIColor+Hex.h"
#import "MCServerAPI.h"
#import "MCServerAPI+EIS.h"
#import "MCContactInfoViewController.h"
#import "MCEnterpriseOrganizationViewController.h"
#import "MCFileManagerViewController.h"
#import "MCContactManager.h"
#import "NSString+JSON.h"
#import "MCContactInfoConfig.h"
#import "MCBaseNavigationViewController.h"
#import "MCSelectedContactsRootViewController.h"
#import "MCRecentContactsViewController.h"
#import "MCMessageGroupsViewController.h"
#import "UIView+MJExtension.h"
#import "MCNotificationCenter.h"
#import "MCContactArrayDataSource.h"
#import "MCRefreshHelper.h"
#import "MCContactSearchViewController.h"
#import "MCAddContactViewController.h"
#import "UIView+MCExpand.h"
#import "UIAlertView+Blocks.h"
#import "MCAccountConfig.h"

@interface MCContactRootViewController ()<UITableViewDelegate,SRRefreshDelegate, MGSwipeTableCellDelegate>

@property (nonatomic, assign) BOOL resfreshing;
@end

static CGFloat sectionHeaderViewHeight = 25;

@implementation MCContactRootViewController {
    BOOL _isSearch;
    NSMutableArray *_groups;
    SRRefreshView *_refreshView;
    BOOL _isCurrentPage;
}

#pragma mark - lifecycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.changeAccountArrow setHidden:NO];
    _isCurrentPage = YES;
    if (!_resfreshing) {
        [self loadDataSource];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _isCurrentPage = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:MCNotificationDidChangeAccount object:nil];
    [self initDataAndViews];
}

- (void)refreshData {
    //刷新数据
    if (_isCurrentPage) {
        [self loadDataSource];
    }
}

- (void)initDataAndViews {
    _sectionIndexArray = [NSMutableArray arrayWithCapacity:0];
    _searchRusltArray = [NSMutableArray arrayWithCapacity:0];
    _groupList = [NSMutableArray arrayWithCapacity:0];
    _importantContacts = [NSMutableArray arrayWithCapacity:0];
    _weightsContacts = [NSMutableArray arrayWithCapacity:0];
    _contacts = [NSMutableArray arrayWithCapacity:0];
    _currentAccount = AppStatus.currentUser;
    
    [self.leftNavigationBarButtonItem setImage:nil];
    [self setNavgationBarRightBtns];
    self.navBarTitleLable.text = PMLocalizedStringWithKey(@"PM_Main_Tab_Contact_Email");
    self.currentUserLable.text = AppStatus.currentUser.email;
    
    ContactCellConfigureBlock tableViewConfigureBlock = ^(id model, id cell, NSIndexPath *indexPath) {
        [self configureContactTableViewCellWithModel:model cell:cell indexPath:indexPath];
    };
    _cellDataSource = [[MCContactArrayDataSource alloc] initWithGroupModels:_groupList contactModels:_contacts groupCellIdentifier:@"MCContactGroupCell" contactCellIdentifier:@"MCContactCell" configureCellBlock:tableViewConfigureBlock];
    _cellDataSource.indexTitles = _sectionIndexArray;
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeigth- NAVIGATIONBARHIGHT - TOOLBAR_HEIGHT)];
    _tableView.delegate = self;
    _tableView.backgroundColor = AppStatus.theme.backgroundColor;
    _tableView.dataSource = _cellDataSource;
    UIView *footerView = [[UIView alloc] init];
    _tableView.tableFooterView = footerView;
    _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    _tableView.separatorColor = AppStatus.theme.tableViewSeparatorColor;
    _tableView.sectionIndexColor = AppStatus.theme.fontTintColor;
    [_tableView registerNib:[UINib nibWithNibName:@"MCContactCell" bundle:nil] forCellReuseIdentifier:@"MCContactCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"MCContactGroupCell" bundle:nil] forCellReuseIdentifier:@"MCContactGroupCell"];
    [self.view addSubview:_tableView];
    
    _refreshView = [MCRefreshHelper createRefreshView];
    _refreshView.delegate = self;
    [_tableView addSubview:_refreshView];
}

- (void)setNavgationBarRightBtns {
    [self addSearchNavigationBarButtonItem];
    self.rightNavigationBarButtonItem.image = [[UIImage imageNamed:@"addContactIcon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.searchButton setImage:AppStatus.theme.mailStyle.mailListSearchImage forState:UIControlStateNormal];
}

- (void)addSearchNavigationBarButtonItem {
    [super addSearchNavigationBarButtonItem];
    [self addRootViewSearchNavigationBarButtonItem];
}

//- (void)setCurrentUserLabelFrame {
//    CGSize size = [AppStatus.currentUser.email mcStringSizeWithFont:kMCBaseViewCurrentUserLableFont maxWidth:2000 maxHight:kMCBaseViewCurrentUserLableHight];
//    if (size.width > 160) {
//        self.navigationBarTitleView.frame = CGRectMake(0, 0, ScreenWidth - 200, kMCBaseViewNavBarTitleViewHight);
//    }
//    self.currentUserLable.frame = CGRectMake((self.navigationBarTitleView.mc_width - size.width)/2, 24, size.width, kMCBaseViewCurrentUserLableHight);
//    self.changeAccountArrow.frame = CGRectMake(CGRectGetMaxX(self.currentUserLable.frame) + 5, 32, 8, 4);
//    self.changeAccountBtn.frame = CGRectMake(0, 0, CGRectGetWidth(self.navigationBarTitleView.frame), CGRectGetHeight(self.navigationBarTitleView.frame));
//}

#pragma mark - dataSource

- (void)loadDataSource {
    @synchronized (self) {
        _resfreshing = YES;
        __weak MCContactRootViewController *weakSelf = self;
        _currentAccount = AppStatus.currentUser;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakSelf updateGroups];
            [weakSelf updateContacts];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
                weakSelf.resfreshing = NO;
            });
        });
    }
}

- (void)updateGroups {
    [_groupList removeAllObjects];
    MCAccountConfig *accountConfig = AppStatus.accountData.accountConfig;
    if (!_currentAccount.isFreeMail) {
        [_groupList addObject:@"PM_Contacts_Type_En"];
    }
    if (!accountConfig.oaUserIs35Mail) {
        //对只开通OA未开通邮局的OA账号屏蔽企业通讯录(和当前邮箱账号无关，只和OA账号有关)
        [_groupList removeAllObjects];
    }
    [_groupList addObject:@"PM_Contacts_Type_Personal"];
    [_groupList addObject:@"PM_ContactMessageGroups"];
    _cellDataSource.groupModels = _groupList;
}

- (void)updateContacts {
    if (_sectionIndexArray) {
        [_sectionIndexArray removeAllObjects];
        [_importantContacts removeAllObjects];
        [_weightsContacts removeAllObjects];
        [_contacts removeAllObjects];
    }
    _importantContacts = [[MCContactManager sharedInstance] getImportantContactsWithImportFlag:YES];
    _weightsContacts = [[[MCContactManager sharedInstance] getTopWeightedContacts] mutableCopy];
    NSComparator cmptr = ^(MCContactModel* obj1, MCContactModel* obj2){
        return [obj1.pinyinFirstChar compare:obj2.pinyinFirstChar];
    };
    [_importantContacts sortUsingComparator:cmptr];
    
    for (MCContactModel *md in _weightsContacts) {
        if (![_sectionIndexArray containsObject:md.pinyinFirstChar]) {
            [_sectionIndexArray addObject:md.pinyinFirstChar];
        }
    }
    _sectionIndexArray = [[_sectionIndexArray sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
    for (NSString *firstChar in _sectionIndexArray) {
        if ([firstChar isEqualToString:@"#"]) {
            [_sectionIndexArray removeObject:firstChar];
            [_sectionIndexArray insertObject:@"#" atIndex:_sectionIndexArray.count];
            break;
        }
    }
    _cellDataSource.indexTitles = _sectionIndexArray;
    if (_importantContacts.count > 0) {
        [_sectionIndexArray insertObject:@"⭐️" atIndex:0];
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    for (NSString *firstChar in _sectionIndexArray) {
        [dic setObject:[NSMutableArray new] forKey:firstChar];
    }
    
    /**
     * 星标联系人
     */
    for (MCContactModel *md in _importantContacts) {
        [[dic objectForKey:@"⭐️"] addObject:md];
    }
    /**
     *  权重联系人
     */
    for (MCContactModel *md in _weightsContacts) {
        [[dic objectForKey:md.pinyinFirstChar] addObject:md];
    }
    for (int i = 0; i < _sectionIndexArray.count; i ++) {
        [_contacts addObject:[dic objectForKey:[_sectionIndexArray objectAtIndex:i]]];
    }
    _cellDataSource.contactModels = _contacts;
}

- (void)synContactsInfo {
    __weak MCContactRootViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *recentContactsAry = [[MCContactManager sharedInstance] getPersonalContacts];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MCContactManager sharedInstance] updatePersonalContacts:recentContactsAry success:^{
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [weakSelf updateContacts];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.tableView reloadData];
                        [self -> _refreshView endRefreshWithResult:PMLocalizedStringWithKey(@"PM_Contact_EnterpriseSuccess")];
                    });
                });
                
            } failure:^(NSError *error) {
                [_refreshView endRefreshWithResult:PMLocalizedStringWithKey(@"PM_Contact_EnterpriseErr")];
                DDLogInfo(@"%@",[error description]);
            }];
        });
    });
}

#pragma mark -   UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 57;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == _tableView) {
        if (section != 0) {
            return sectionHeaderViewHeight;
        }
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == _tableView) {
        if (section != 0) {
            UIView *sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, sectionHeaderViewHeight)];
            sectionView.backgroundColor = AppStatus.theme.backgroundColor;
            UILabel *indexLab = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, 100, 15)];
            indexLab.textAlignment = NSTextAlignmentLeft;
            indexLab.font = [UIFont systemFontOfSize:11];
            indexLab.backgroundColor = AppStatus.theme.backgroundColor;
            indexLab.textColor = AppStatus.theme.fontTintColor;
            indexLab.layer.masksToBounds = YES;
            indexLab.text = _sectionIndexArray[section - 1];
            if (_importantContacts.count > 0) {
                if (section == 1) {
                    indexLab.text = PMLocalizedStringWithKey(@"PM_Contacts_Type_Import");
                    [indexLab setMj_x:13];
                }
            }
            UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0, sectionHeaderViewHeight - 0.3, ScreenWidth, 0.3)];
            lineV.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
            [sectionView addSubview:indexLab];
            [sectionView addSubview:lineV];
            return sectionView;
        }
    }
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MCContactModel *model;
    if (tableView == _tableView) {
        if (indexPath.section != 0) {
            NSArray *contacts = _contacts[indexPath.section - 1];
            model = contacts[indexPath.row];
            //直接跳转到联系人详情
            MCContactInfoViewController *v = [[MCContactInfoViewController alloc] initFromType:fromContact contactModel:model canEditable:YES isEnterprise:model.isCompanyUser];
            [self.navigationController pushViewController:v animated:YES];
//            if (model.youqiaFlag) {
//                
//            }else {
//                //去检查是否使用过邮洽，然后才跳转
//                
//            }
        }else {
            
            NSString *groupName = [_groupList objectAtIndex:indexPath.row];
            if ([groupName isEqualToString:@"PM_Contacts_Type_En"]) {
                //企业联系人
                if (_currentAccount.isEIS) {
                    MCEnterpriseOrganizationViewController *v = [[MCEnterpriseOrganizationViewController alloc] initWithEisFlag:_currentAccount.isEIS haveChangeFrame:NO didSelectedBlock:^(id model, NSIndexPath *index, id ctrl) {
                        
                    }];
                    [self.navigationController pushViewController:v animated:YES];
                }else {
                    //第三方企业联系人，同域。
                    MCRecentContactsViewController *v = [[MCRecentContactsViewController alloc] initWithContactSourceType:ContactEnterpriseSameDomin didSelectedBlock:nil];
                    [self.navigationController pushViewController:v animated:YES];
                }
                
                return;
            }
            if ([groupName isEqualToString:@"PM_Contacts_Type_Personal"]) {
                //往来联系人
                MCRecentContactsViewController *v = [[MCRecentContactsViewController alloc] initWithContactSourceType:ContactRecentsSourceType didSelectedBlock:nil];
                [self.navigationController pushViewController:v animated:YES];
                return;
            }
            if ([groupName isEqualToString:@"PM_ContactMessageGroups"]) {
                //消息群组
                MCMessageGroupsViewController *v = [[MCMessageGroupsViewController alloc] initWithFromCtrlType:SelectedMsgGroupFromContactList selectedGroupBlock:nil];
                [self.navigationController pushViewController:v animated:YES];
                return;
            }
        }
    }else {
        MCContactModel *obj = _searchRusltArray[indexPath.row];
        MCContactInfoViewController *v = [[MCContactInfoViewController alloc] initFromType:fromContact contactModel:obj canEditable:YES isEnterprise:obj.isCompanyUser];
        [self.navigationController pushViewController:v animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (tableView == _tableView) {
        if (section == 0) {
            //第一版先隐藏编辑分组
            return 0;
        }
        return 0;
    }
    return 0;
}

//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (indexPath.section == 0) {
//        return  UITableViewCellEditingStyleNone;
//    }
//    return UITableViewCellEditingStyleDelete;
//}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshView scrollViewDidEndDraging];
}

#pragma mark - 配置cell
- (void)configureContactTableViewCellWithModel:(id)model cell:(id)cell indexPath:(NSIndexPath *)indexPath {
    if ([cell isMemberOfClass:[MCContactGroupCell class]]) {
        MCContactGroupCell *groupCell = (MCContactGroupCell *)cell;
        if (_contacts.count == 0) {
            groupCell.arrorRightConstraint.constant = 20;
        }else {
            groupCell.arrorRightConstraint.constant = 0;
        }
        [groupCell configureCellWithModel:model];
    }
    if ([cell isMemberOfClass:[MCContactCell class]]) {
        MCContactCell *contactCell = (MCContactCell *)cell;
        contactCell.delegate = self;
        [contactCell configureCellWithModel:model];
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
    MCContactCell *cell1 = (MCContactCell*)cell;
    NSIndexPath *indexPath =[self.tableView indexPathForCell:cell1];
    __block NSMutableArray *contacts = _contacts[indexPath.section - 1];
    MCContactModel *model = contacts[indexPath.row];
    
    swipeSettings.transition = MGSwipeTransitionBorder;
    cell.rightExpansion.buttonIndex = 0;
    cell.rightExpansion.fillOnTrigger = YES;
    cell.rightExpansion.threshold = 2;
    
    __weak typeof(self) weakSelf = self;
    CGFloat padding = 5;
    // 删除按钮
    MGSwipeButton *trashBtn = [MGSwipeButton buttonWithTitle:PMLocalizedStringWithKey(@"PM_Msg_DelMsgCell") backgroundColor:[UIColor colorWithHexString:@"f54e46"] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
        __strong typeof(self) sSelf = weakSelf;
        NSIndexPath *indexPath = [sSelf.tableView indexPathForCell:sender];
        RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Cancel")];
        RIButtonItem *sureItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Msg_DelMsgCell") action:^{
            [[MCContactManager sharedInstance] deleteContacts:@[model]];
            [contacts removeObjectAtIndex:indexPath.row];
            if (contacts.count == 0) {
                [sSelf.contacts removeObjectAtIndex:indexPath.section-1];
                [sSelf.sectionIndexArray removeObjectAtIndex:indexPath.section - 1];
                [sSelf.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationBottom];
            }else{
                [sSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
            }
            if (sSelf.contacts.count == 0) {
                [sSelf.tableView reloadData];
            }
            //友盟统计事件
            [MCUmengManager addEventWithKey:mc_contact_delete label:@"联系人删除"];
            }];
            UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_Common_Notice") message:PMLocalizedStringWithKey(@"PM_Contact_deleteNotice") cancelButtonItem:cancelItem otherButtonItems:sureItem, nil];
        [alertV show];

        return YES;
    }];
    trashBtn.buttonWidth = 100;
    
    BOOL isImportant = model.importantFlag;
    MGSwipeButton * topBtn = [MGSwipeButton buttonWithTitle:isImportant? PMLocalizedStringWithKey(@"PM_Contact_cancelImportantContact"):PMLocalizedStringWithKey(@"PM_Contact_settingImportantContact") backgroundColor:[UIColor colorWithHexString:@"f5b146"] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
        __strong typeof(self) sSelf = weakSelf;
        model.importantFlag = !model.importantFlag;
        [[MCContactManager sharedInstance] updateImportFlagWithEmail:model.account importFlag:!isImportant];
        [sSelf loadDataSource];
        return YES;
    }];
    topBtn.buttonWidth = 40;
    
    return @[trashBtn,topBtn];
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

#pragma mark - custom method
//编辑分组
- (void)editGroup {
    //友盟统计事件
    //[MobClick event:@"Contact_edit_group" label:@"编辑分组"];
}

#pragma mark - Refresh delegate

- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [self synContactsInfo];
}

- (void)rightNavigationBarButtonItemAction:(id)sender {
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    MCAddContactViewController *v = [[MCAddContactViewController alloc] initWithContactEditType:addContact contactModel:nil];
    MCBaseNavigationViewController *navigationController = [[MCBaseNavigationViewController alloc]initWithRootViewController:v];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)searchNavigationBarButtonItemAction:(id)sender {
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    MCContactSearchViewController *v = [[MCContactSearchViewController alloc] init];
    MCBaseNavigationViewController *navigationController = [[MCBaseNavigationViewController alloc]initWithRootViewController:v];
    [self.navigationController presentViewController:navigationController animated:NO completion:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MCNotificationDidChangeAccount object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
