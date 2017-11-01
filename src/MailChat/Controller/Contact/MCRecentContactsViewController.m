//
//  MCRecentContactsViewController.m
//  NPushMail
//
//  Created by wuwenyu on 16/4/6.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCRecentContactsViewController.h"
#import "MCContactCell.h"
#import "MCContactModel.h"
#import "MCRecentContactCellDataSource.h"
#import "MCCellDataSource.h"
#import "UISearchBar+MCExtension.h"
#import "MCContactManager.h"
#import "MCServerAPI.h"
#import "MCServerAPI+EIS.h"
#import "NSString+JSON.h"
#import "MCContactInfoConfig.h"
#import "MCContactInfoViewController.h"
#import "MCRefreshHelper.h"
#import "MCContactSearchViewController.h"
#import "MCBaseNavigationViewController.h"
#import "UIAlertView+Blocks.h"

@interface MCRecentContactsViewController ()<UITableViewDelegate, SRRefreshDelegate, MGSwipeTableCellDelegate>

@property(nonatomic, strong) NSMutableArray *personalContacts;
@property(nonatomic, strong) MCRecentContactCellDataSource *cellDataSource;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *recentContacts;
@property(nonatomic, strong) NSMutableArray *sectionIndexArray;
@end

static CGFloat recentContactHeaderViewHeight = 25;

@implementation MCRecentContactsViewController {
    ContactSourceType _sourceType;
    ContactDidSelectedBlock _didSelectedBlock;
    SRRefreshView *_refreshView;
}

- (id)initWithContactSourceType:(ContactSourceType)type didSelectedBlock:(ContactDidSelectedBlock)block {
    if (self = [super init]) {
        _sourceType = type;
        _didSelectedBlock = block;
    }
    return self;
}

#pragma mark - lifecycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadDataSource];
    [self synContactsInfo];
}

- (void)viewDidAppear:(BOOL)animated {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = YES;
    [self initDataAndViews];
    // Do any additional setup after loading the view from its nib.
}

- (void)loadDataSource {
    __weak MCRecentContactsViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf getRecentContactList];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.cellDataSource.indexTitles = _sectionIndexArray;
            [_tableView reloadData];
        });
    });
}

- (void)initDataAndViews {
    _recentContacts = [NSMutableArray new];
    _sectionIndexArray = [NSMutableArray new];
    _personalContacts = [NSMutableArray new];
    if (_sourceType == ContactEnterpriseSameDomin) {
        self.viewTitle = PMLocalizedStringWithKey(@"PM_Contacts_Type_En");
    }else {
        self.viewTitle = PMLocalizedStringWithKey(@"PM_Contacts_Type_Personal");
    }
    self.rightNavigationBarButtonItem.image = AppStatus.theme.mailStyle.mailListSearchImage;
    ContactCellConfigureBlock tableViewConfigureBlock = ^(id model, id cell, NSIndexPath *indexPath) {
        [self configureContactTableViewCellWithModel:model cell:cell indexPath:indexPath];
    };
    _cellDataSource = [[MCRecentContactCellDataSource alloc] initWithContactModels:_recentContacts contactCellIdentifier:@"MCContactCell" configureCellBlock:tableViewConfigureBlock];
    _cellDataSource.indexTitles = _sectionIndexArray;
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeigth- NAVIGATIONBARHIGHT)];
    if (_sourceType == ContactPersonalSourceType) {
        _tableView.frame = CGRectMake(0, 25, ScreenWidth, ScreenHeigth - TOOLBAR_HEIGHT*2 - NAVIGATIONBARHIGHT);
    }
    _tableView.delegate = self;
    _tableView.backgroundColor = AppStatus.theme.backgroundColor;
    _tableView.dataSource = _cellDataSource;
    _tableView.tableFooterView = nil;
    _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    _tableView.separatorColor = AppStatus.theme.tableViewSeparatorColor;
    _tableView.sectionIndexColor = AppStatus.theme.fontTintColor;
    [_tableView registerNib:[UINib nibWithNibName:@"MCContactCell" bundle:nil] forCellReuseIdentifier:@"MCContactCell"];
    [self.view addSubview:_tableView];
    
    _refreshView = [MCRefreshHelper createRefreshView];
    _refreshView.delegate = self;
    [_tableView addSubview:_refreshView];
}

#pragma mark - dataSource

- (void)getRecentContactList {
    if (_sectionIndexArray) {
        [_sectionIndexArray removeAllObjects];
        [_recentContacts removeAllObjects];
    }
    if (_sourceType == ContactEnterpriseSameDomin) {
        NSString* currentEmail = AppStatus.currentUser.email;
        NSRange range = [currentEmail rangeOfString:@"@"];
        NSString* domin = [currentEmail substringFromIndex:(range.location + 1)];
        DDLogVerbose(@"%@",domin);
        _personalContacts = [[[MCContactManager sharedInstance] getSameDominContactInfoByDomin:domin] mutableCopy];
    }else {
        _personalContacts = [[[MCContactManager sharedInstance] getPersonalContacts] mutableCopy];
    }

    for (MCContactModel *md in _personalContacts) {
        if (![_sectionIndexArray containsObject:md.pinyinFirstChar]) {
            [_sectionIndexArray addObject:md.pinyinFirstChar];
        }
    }
    
    _sectionIndexArray = [[_sectionIndexArray sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
    _cellDataSource.indexTitles = _sectionIndexArray;
    for (NSString *firstChar in _sectionIndexArray) {
        if ([firstChar isEqualToString:@"#"]) {
            [_sectionIndexArray removeObject:firstChar];
            [_sectionIndexArray insertObject:@"#" atIndex:_sectionIndexArray.count];
            break;
        }
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    for (NSString *firstChar in _sectionIndexArray) {
        [dic setObject:[NSMutableArray new] forKey:firstChar];
    }
    for (MCContactModel *md in _personalContacts) {
        [[dic objectForKey:md.pinyinFirstChar] addObject:md];
    }
    for (int i = 0; i < _sectionIndexArray.count; i ++) {
        [_recentContacts addObject:[dic objectForKey:[_sectionIndexArray objectAtIndex:i]]];
    }
}

- (void)synContactsInfo {
    __weak MCRecentContactsViewController *weakSelf = self;
    [[MCContactManager sharedInstance] updatePersonalContacts:weakSelf.personalContacts success:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakSelf getRecentContactList];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.cellDataSource.indexTitles = _sectionIndexArray;
                [_tableView reloadData];
                [_refreshView endRefreshWithResult:PMLocalizedStringWithKey(@"PM_Contact_EnterpriseSuccess")];
            });
        });
    } failure:^(NSError *error) {
        [_refreshView endRefreshWithResult:PMLocalizedStringWithKey(@"PM_Contact_EnterpriseErr")];
        DDLogInfo(@"%@",[error description]);
    }];
}

#pragma mark -   UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 57;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == _tableView) {
        return recentContactHeaderViewHeight;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == _tableView) {
        UIView *sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, recentContactHeaderViewHeight)];
        sectionView.backgroundColor = AppStatus.theme.backgroundColor;
        UILabel *indexLab = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, 100, 15)];
        indexLab.textAlignment = NSTextAlignmentLeft;
        indexLab.font = [UIFont systemFontOfSize:11];
        indexLab.backgroundColor = AppStatus.theme.backgroundColor;
        indexLab.textColor = AppStatus.theme.fontTintColor;
        indexLab.text = _sectionIndexArray[section];
        UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0, recentContactHeaderViewHeight - 0.3, ScreenWidth, 0.3)];
        lineV.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
        [sectionView addSubview:indexLab];
        [sectionView addSubview:lineV];
        return sectionView;
    }
    return nil;
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MCContactModel *model;
    NSArray *contacts = _recentContacts[indexPath.section];
    model = contacts[indexPath.row];
    MCContactInfoViewController *v = [[MCContactInfoViewController alloc] initFromType:fromContact contactModel:model canEditable:YES isEnterprise:model.isCompanyUser];
    [self.navigationController pushViewController:v animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshView scrollViewDidEndDraging];
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
    __block NSMutableArray *contacts = _recentContacts[indexPath.section];
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
                [sSelf.recentContacts removeObjectAtIndex:indexPath.section];
                [sSelf.sectionIndexArray removeObjectAtIndex:indexPath.section];
                [sSelf.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationBottom];
            }else{
                [sSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
            }
            if (sSelf.recentContacts.count == 0) {
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
        [sSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

#pragma mark - Refresh delegate

- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [self synContactsInfo];
}

#pragma mark - 配置cell
- (void)configureContactTableViewCellWithModel:(id)model cell:(id)cell indexPath:(NSIndexPath *)indexPath {
    if ([cell isMemberOfClass:[MCContactCell class]]) {
        MCContactCell *contactCell = (MCContactCell *)cell;
        contactCell.delegate = self;
        [contactCell configureCellWithModel:model];
    }
}

- (void)leftNavigationBarButtonItemAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightNavigationBarButtonItemAction:(id)sender {
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    MCContactSearchViewController *v = [[MCContactSearchViewController alloc] init];
    MCBaseNavigationViewController *navigationController = [[MCBaseNavigationViewController alloc]initWithRootViewController:v];
    [self.navigationController presentViewController:navigationController animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
