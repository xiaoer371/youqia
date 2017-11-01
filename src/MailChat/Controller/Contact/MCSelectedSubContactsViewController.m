//
//  MCSelectedSubContactsViewController.m
//  NPushMail
//
//  Created by wuwenyu on 16/3/29.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCSelectedSubContactsViewController.h"
#import "MCGroup.h"
#import "MCBranchInfo.h"
#import "MCContactModel.h"
#import "UISearchBar+MCExtension.h"
#import "MCSelectedContactsCellDataSource.h"
#import "MCCellDataSource.h"
#import "MCContactCell.h"
#import "MCEnterpriseBranchCell.h"
#import "MCContactManager.h"
#import "MCEnterpriseStructTree.h"
#import "MCEnterpriseContactCellItem.h"
#import "MCSelectedContactsHeaderView.h"
#import "MCShowEnterpriseHeaderView.h"
#import "MCAccountConfig.h"
#import "MCIMNoMessageView.h"
#import "UIView+MJExtension.h"
#import "UIAlertView+Blocks.h"

@interface MCSelectedSubContactsViewController ()<UITableViewDelegate, UISearchBarDelegate,UISearchDisplayDelegate, UITextFieldDelegate>
@property(nonatomic, strong) NSMutableArray *contacts;//当前分组下的人员
@property(nonatomic, strong) NSMutableArray *selectedModels;
@property(nonatomic, strong) UITableView *mainTabelV;
@property(nonatomic, strong) UITableView *searchTableView;
@property(nonatomic, strong) MCIMNoMessageView *noMessageView;
@property(nonatomic, strong) selectedModelsWithRefreshBlock selectedBlock;

@end

static const CGFloat branchCellHeight = 45;
static const CGFloat employeeCellHeight = 57;
static const CGFloat selectedHeaderViewHeight = 57;

@implementation MCSelectedSubContactsViewController {
    id _currentGroup;
    NSArray *_subBranchs;
    /**
     *  顶部显示当前组织层级的
     */
    NSMutableArray *_enterpriseNavItems;
    SelectedContactType _fromCtrlType;
    MCSelectedContactsHeaderView *_selectedHeaderView;
    MCShowEnterpriseHeaderView *_showEnterpriseHeaderView;
    NSArray *_alreadyExistsModels;//最开始已选的人员
    UIView *_headerView;
    UIImageView *_selectedIndicator;
    UISearchBar *_searchBar;
    BOOL _isSearch;
    UISearchDisplayController *_searchDisplayCtrl;
    NSMutableArray *_searchRusltArray;//搜索结果
    MCSelectedContactsCellDataSource *_cellDataSource;
    MCCellDataSource *_searchResultCellDataSource;
    SelectedModelsBlock _sureSelectedBlock;
}

- (id)initWithGroup:(id)group subBranchs:(NSArray *)subBranchs selectedBlock:(selectedModelsWithRefreshBlock)block formCtrlType:(SelectedContactType)type selectedModels:(NSArray *)selectedModels  alreadyExistsModels:(NSArray *)models {
    if (self = [super init]) {
        _currentGroup = group;
        _subBranchs = subBranchs;
        _selectedBlock = block;
        _fromCtrlType = type;
        _selectedModels = [selectedModels mutableCopy];
        _alreadyExistsModels = models;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.extendedLayoutIncludesOpaqueBars = YES;
    [self initSubViews];
    [self loadDataSource];
    // Do any additional setup after loading the view.
}

//移除选中的联系人
- (void)removeSelectedModel:(id)model {
    MCContactModel *obj = (MCContactModel *)model;
    for (MCContactModel *model in self.contacts) {
        if ([model.account isEqualToString:obj.account]) {
            model.isSelect = NO;
            model.cantEdit = NO;
        }
    }
    [self setContactsCounts];
    [self.mainTabelV reloadData];
}

- (void)setSelectedStatus {
    if (_alreadyExistsModels &&_alreadyExistsModels.count > 0) {
        for (MCContactModel *model in _contacts) {
            for (MCContactModel *obj in _alreadyExistsModels) {
                if ([obj.account isEqualToString:model.account]) {
                    model.isSelect = YES;
                    //已存在的成员不可编辑
                    model.cantEdit = YES;
                }
            }
        }
    }
}

- (void)setBlockSelectedStatus {
    if (_selectedModels && _selectedModels.count > 0) {
        for (MCContactModel *model in _contacts) {
            for (MCContactModel *obj in _selectedModels) {
                if ([obj.account isEqualToString:model.account]) {
                    model.isSelect = YES;
                }
            }
        }
    }
}

- (void)initSubViews {
    /**
     *  导航栏
     */
    [self.leftNavigationBarButtonItem setImage:nil];
    [self.leftNavigationBarButtonItem setTitle:PMLocalizedStringWithKey(@"PM_Common_Cancel")];
    [self.rightNavigationBarButtonItem setImage:[UIImage imageNamed:@"addLinkman111.png"]];
    [self setContactsCounts];
    _enterpriseNavItems = [NSMutableArray new];
    if ([_currentGroup isMemberOfClass:[MCGroup class]]) {
        MCGroup *group = _currentGroup;
        self.viewTitle = group.name;
        if ([group.name isEqualToString:@"PM_Contacts_Type_En"]) {
            [self setDefaultEnterpriseTreeInfo];
        }else {
            _enterpriseNavItems = [NSMutableArray arrayWithObjects:PMLocalizedStringWithKey(@"PM_Main_Tab_Contact_Email"), PMLocalizedStringWithKey(group.name), nil];
        }
    }
    if ([_currentGroup isMemberOfClass:[MCEnterpriseContactCellItem class]]) {
        MCEnterpriseContactCellItem *obj = _currentGroup;
        self.viewTitle = obj.branchInfo.name;
        [self setDefaultEnterpriseTreeInfo];
        NSMutableArray *parentsItems = [_tree getParentBranchItemsWithBranchId:obj.branchInfo.branchId];
        [_enterpriseNavItems addObjectsFromArray:parentsItems];
    }
    
    _contacts = [NSMutableArray new];
    _searchRusltArray = [NSMutableArray new];
    /**
     *  选择搜索框
     */
    __weak typeof(self) weakSelf = self;
    _selectedHeaderView = [[MCSelectedContactsHeaderView alloc] initWithFrame:CGRectMake(0, NAVIGATIONBARHIGHT, ScreenWidth, selectedHeaderViewHeight) models:_selectedModels removeBlock:^(id model) {
        MCContactModel *obj = (MCContactModel *)model;
        [weakSelf removeSelectedModel:obj];
    }];
    _selectedHeaderView.textField.delegate = self;
    _selectedHeaderView.textField.returnKeyType = UIReturnKeyDone;
    [_selectedHeaderView.textField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_selectedHeaderView];
    
    /**
     *  显示当前组织架构层级的view
     */
    _showEnterpriseHeaderView = [[MCShowEnterpriseHeaderView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_selectedHeaderView.frame), ScreenWidth, 44) models:_enterpriseNavItems selectedItemBlock:^(id model) {
        if ([model isKindOfClass:[NSString class]]) {
            NSString *obj = (NSString *)model;
            if ([obj isEqualToString:PMLocalizedStringWithKey(@"PM_Main_Tab_Contact_Email")]) {
                //回到选择联系人第一级
                    if (self->_selectedModels) {
                        if (self->_selectedBlock) {
                            self->_selectedBlock(self->_selectedModels, NO);
                        }
                    }
                    [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            }
            NSString *company = AppStatus.accountData.accountConfig.company;
            if (company) {
                if ([obj isEqualToString:PMLocalizedStringWithKey(@"PM_Contacts_Type_En")] || [obj isEqualToString:company]) {
                    //回到企业通讯录首页
                    MCGroup *group = [[MCGroup alloc] init];
                    group.name = @"PM_Contacts_Type_En";
                    MCSelectedSubContactsViewController *v = [[MCSelectedSubContactsViewController alloc] initWithGroup:group subBranchs:nil selectedBlock:weakSelf.selectedBlock formCtrlType:_fromCtrlType selectedModels:weakSelf.selectedModels alreadyExistsModels:_alreadyExistsModels];
                    [weakSelf.navigationController pushViewController:v animated:YES];
                }
            }
        }
        if ([model isMemberOfClass:[MCEnterpriseContactCellItem class]]) {
            MCEnterpriseContactCellItem *obj = (MCEnterpriseContactCellItem *)model;
            [weakSelf selectedBranchWithItem:obj];
        }
    }];
    [self.view addSubview:_showEnterpriseHeaderView];
    
    ContactCellConfigureBlock tableViewConfigureBlock = ^(id model, id cell, NSIndexPath *indexPath) {
        [weakSelf configureContactTableViewCellWithModel:model cell:cell indexPath:indexPath];
    };
    _cellDataSource = [[MCSelectedContactsCellDataSource alloc] initWithModels:_contacts branchs:_subBranchs branchCellIdentifier:@"MCEnterpriseBranchCell" contactCellIdentifier:@"MCContactCell" configureCellBlock:tableViewConfigureBlock];
    _mainTabelV = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_showEnterpriseHeaderView.frame), ScreenWidth, ScreenHeigth - selectedHeaderViewHeight - NAVIGATIONBARHIGHT - 44)];
    _mainTabelV.delegate = self;
    _mainTabelV.backgroundColor = AppStatus.theme.backgroundColor;
    _mainTabelV.dataSource = _cellDataSource;
    _mainTabelV.tableFooterView = [[UIView alloc] init];
    _mainTabelV.sectionIndexBackgroundColor = [UIColor whiteColor];
    _mainTabelV.separatorColor = AppStatus.theme.tableViewSeparatorColor;
    _mainTabelV.sectionIndexColor = [UIColor colorWithHexString:@"aaaaaa"];
    [_mainTabelV registerNib:[UINib nibWithNibName:@"MCContactCell" bundle:nil] forCellReuseIdentifier:@"MCContactCell"];
    [_mainTabelV registerNib:[UINib nibWithNibName:@"MCEnterpriseBranchCell" bundle:nil] forCellReuseIdentifier:@"MCEnterpriseBranchCell"];
    [self.view addSubview:_mainTabelV];
    [_mainTabelV setEditing:YES];
    _mainTabelV.allowsSelectionDuringEditing = YES;
    
    TableViewCellConfigureBlock configureSearchCell = ^(MCContactCell *cell, MCContactModel *model, NSIndexPath *indexPath) {
        [cell configureCellWithModel:model];
    };
    _searchResultCellDataSource = [[MCCellDataSource alloc] initWithModels:_searchRusltArray cellIdentifier:@"MCContactCell" configureCellBlock:configureSearchCell];
    _searchTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_selectedHeaderView.frame), ScreenWidth, ScreenHeigth- NAVIGATIONBARHIGHT - selectedHeaderViewHeight)];
    _searchTableView.delegate = self;
    _searchTableView.backgroundColor = AppStatus.theme.backgroundColor;
    _searchTableView.dataSource = _searchResultCellDataSource;
    _searchTableView.tableFooterView = [[UIView alloc] init];
    _searchTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    _searchTableView.separatorColor = AppStatus.theme.tableViewSeparatorColor;
    _searchTableView.sectionIndexColor = AppStatus.theme.fontTintColor;
    [_searchTableView registerNib:[UINib nibWithNibName:@"MCContactCell" bundle:nil] forCellReuseIdentifier:@"MCContactCell"];
    [self.view addSubview:_searchTableView];
    [_searchTableView setEditing:YES];
    [_searchTableView setAllowsSelectionDuringEditing:YES];
    [_searchTableView setHidden:YES];
    
    [self.view addSubview:self.noMessageView];
}

- (MCIMNoMessageView *)noMessageView
{
    if (!_noMessageView) {
        _noMessageView = [[MCIMNoMessageView alloc] initWithCreatType:MCNODateSourceAlertNoFile imageName:@"mc_contactNoSearchResult.png" text:PMLocalizedStringWithKey(@"PM_File_noContactSearchResultNotice")];
        _noMessageView.hidden = YES;
        _noMessageView.mj_h = ScreenHeigth - NAVIGATIONBARHIGHT;
        _noMessageView.mj_y = 0;
        if (iPhone4) {
            _noMessageView.imageName = @"mc_contactNoSearchResult1.png";
            _noMessageView.textLabel.mj_y = _noMessageView.textLabel.mj_y - 60;
        }
    }
    return _noMessageView;
}

//设置默认的顶部组织架构层级（包含联系人->企业通讯录/公司名）
- (void)setDefaultEnterpriseTreeInfo {
    if (AppStatus.accountData.accountConfig.company) {
        _enterpriseNavItems = [NSMutableArray arrayWithObjects:PMLocalizedStringWithKey(@"PM_Main_Tab_Contact_Email"), AppStatus.accountData.accountConfig.company, nil];
    }else {
        _enterpriseNavItems = [NSMutableArray arrayWithObjects:PMLocalizedStringWithKey(@"PM_Main_Tab_Contact_Email"), PMLocalizedStringWithKey(@"PM_Contacts_Type_En"), nil];
    }
}

- (void)loadDataSource {
    if ([_currentGroup isMemberOfClass:[MCGroup class]]) {
        MCGroup *group = _currentGroup;
        if ([group.name isEqualToString:@"PM_Contacts_Type_Personal"]) {
            //邮洽联系人
            self.viewTitle = PMLocalizedStringWithKey(@"PM_Contacts_Type_Personal");
            _contacts = [[[MCContactManager sharedInstance] getPersonalContacts] mutableCopy];
            _cellDataSource.models = _contacts;
        }
        
        if ([group.name isEqualToString:@"PM_Contacts_Type_En"]) {
            //企业联系人
            if (!AppStatus.currentUser.isEIS) {
                self.viewTitle = PMLocalizedStringWithKey(@"PM_Contacts_Type_En");
                NSString* currentEmail = AppStatus.currentUser.email;
                NSRange range = [currentEmail rangeOfString:@"@"];
                NSString* domin = [currentEmail substringFromIndex:(range.location + 1)];
                DDLogVerbose(@"%@",domin);
                _contacts = [[[MCContactManager sharedInstance] getSameDominContactInfoByDomin:domin] mutableCopy];
                _cellDataSource.models = _contacts;
                [self setSelectedStatus];
                [self setBlockSelectedStatus];
                [_mainTabelV reloadData];
                return;
            }
            self.viewTitle = PMLocalizedStringWithKey(@"PM_Contacts_Type_En");
            if (AppStatus.accountData.accountConfig.company) {
                self.viewTitle = AppStatus.accountData.accountConfig.company;
            }
            [self loadEnterpriseDataSource];
            return;
        }
    }
    
    if ([_currentGroup isMemberOfClass:[MCEnterpriseContactCellItem class]]) {
        MCEnterpriseContactCellItem *item = _currentGroup;
        if (!item.childrenBranchItems) {
            item.childrenBranchItems = [_tree getChildrenBranchItemsWithBranchId:item.branchInfo.branchId];
        }
        if (!item.childrenContactModels) {
            item.childrenContactModels = [_tree getChildrenContactModelsWithBranchId:item.branchInfo.branchId];
        }
        _subBranchs = item.childrenBranchItems;
        _cellDataSource.branchs = _subBranchs;
        _contacts = item.childrenContactModels;
        _cellDataSource.models = _contacts;
    }

    [self setSelectedStatus];
    [self setBlockSelectedStatus];
    [_mainTabelV reloadData];
}

- (void)loadEnterpriseDataSource {
    __weak typeof(self) weakSelf = self;
    dispatch_queue_t kBgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(kBgQueue, ^ {
        NSMutableArray* branchInfoMessageArray = [NSMutableArray arrayWithCapacity:0];
        branchInfoMessageArray = [[[MCContactManager sharedInstance] getAllEnterpriseBranchs] mutableCopy];
        weakSelf.tree = [[MCEnterpriseStructTree alloc] initWithBranchInfo:branchInfoMessageArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            //先显示顶层部门
            _subBranchs = weakSelf.tree.rootNodeItemArray;
            _cellDataSource.branchs = _subBranchs;
            [weakSelf setSelectedStatus];
            [weakSelf setBlockSelectedStatus];
            [weakSelf.mainTabelV reloadData];
            [SVProgressHUD dismiss];
        });
    });
}

- (void)configureContactTableViewCellWithModel:(id)model cell:(id)cell indexPath:(NSIndexPath *)indexPath {
    if ([cell isMemberOfClass:[MCContactCell class]]) {
        MCContactCell *contactCell = (MCContactCell *)cell;
        [contactCell configureCellWithModel:model];
    }
    if ([cell isMemberOfClass:[MCEnterpriseBranchCell class]]) {
        MCEnterpriseBranchCell *branchCell = cell;
        [branchCell configureCellWithModel:model];
    }
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _mainTabelV) {
        if (_subBranchs && _subBranchs.count > 0) {
            if (indexPath.section == 0) {
                return branchCellHeight;
            }
            return employeeCellHeight;
        }
        return employeeCellHeight;
    }else {
        return employeeCellHeight;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == _mainTabelV) {
        id obj = [_cellDataSource modelAtIndexPath:indexPath];
        if (_subBranchs && _subBranchs.count > 0) {
            if (indexPath.section == 0) {
                //点击部门
                if ([obj isMemberOfClass:[MCEnterpriseContactCellItem class]]) {
                    MCEnterpriseContactCellItem *branchObj = obj;
                    [self selectedBranchWithItem:branchObj];
                }
            }else {
                //点击成员
                MCContactCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                if ([obj isMemberOfClass:[MCContactModel class]]) {
                    MCContactModel *model = obj;
                    if (model.cantEdit) {
                        return;
                    }
                    [cell changeSelectedState];
                    [self setSelectedModelsWithModel:model];
                    [self setContactsCounts];
                }
            }
            
        }else {
            //没有部门只有成员
            MCContactCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if ([obj isMemberOfClass:[MCContactModel class]]) {
                MCContactModel *model = obj;
                if (model.cantEdit) {
                    return;
                }
                [cell changeSelectedState];
                [self setSelectedModelsWithModel:model];
                [self setContactsCounts];
            }
        }
    }else {
        MCContactModel *model = [_searchResultCellDataSource modelAtIndexPath:indexPath];
        if ([model.account isEmail]) {
            [[MCContactManager sharedInstance] getOrCreateContactWithEmail:model.account name:model.account];
            MCContactCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if (model.cantEdit) {
                return;
            }
            [cell changeSelectedState];
            [self setSelectedModelsWithModel:model];
            [self setContactsCounts];
            _selectedHeaderView.textField.text = kMCTextEmpty;
            [_searchTableView setHidden:YES];
            [_searchRusltArray removeAllObjects];
            [_searchTableView reloadData];
            [_mainTabelV reloadData];
        }
    }
}

//点击部门的操作
- (void)selectedBranchWithItem:(MCEnterpriseContactCellItem *)item {
    MCSelectedSubContactsViewController *v = [[MCSelectedSubContactsViewController alloc] initWithGroup:item subBranchs:item.childrenBranchItems selectedBlock:_selectedBlock formCtrlType:_fromCtrlType selectedModels:_selectedModels alreadyExistsModels:_alreadyExistsModels];
    v.tree = _tree;
    [self.navigationController pushViewController:v animated:YES];
}

- (void)setContactsCounts {
    if (self.selectedModels.count > 0 || _alreadyExistsModels.count>0) {
        [UIView performWithoutAnimation:^{
            [self.rightNavigationBarButtonItem setTitle:[NSString stringWithFormat:@"%@(%lu)", PMLocalizedStringWithKey(@"PM_Contact_LaunchChatOrEmail"), (unsigned long)self.selectedModels.count]];
        }];
    }else {
        [UIView performWithoutAnimation:^{
            [self.rightNavigationBarButtonItem setTitle:[NSString stringWithFormat:@"%@", PMLocalizedStringWithKey(@"PM_Contact_LaunchChatOrEmail")]];
        }];
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  UITableViewCellEditingStyleNone;
}

- (void)setSelectedModelsWithModel:(MCContactModel *)model {
    BOOL isExist = NO;
    for (MCContactModel *obj in _selectedModels) {
        if ([obj.account  isEqualToString:model.account]) {
            isExist = YES;
            if (!model.isSelect) {
                NSInteger index = [_selectedModels indexOfObject:obj];
                [_selectedModels removeObject:obj];
                NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
                [_selectedHeaderView.collectionView deleteItemsAtIndexPaths:@[path]];
                [_selectedHeaderView removeItemWithModel:nil];
            }
            break;
        }
    }
    if (!isExist) {
        if (model.isSelect) {
            [_selectedModels addObject:model];
            NSIndexPath *path = [NSIndexPath indexPathForRow:_selectedModels.count - 1 inSection:0];
            [_selectedHeaderView.collectionView insertItemsAtIndexPaths:@[path]];
            [_selectedHeaderView.collectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
            [_selectedHeaderView insertItemWithModel:nil];
        }
    }
    _selectedHeaderView.textField.text = kMCTextEmpty;
}

- (void)setAllSelectedStatusWithCell:(MCContactCell *)cell tableView:(UITableView *)tableView {
    if (!cell.isSelected) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
        id group = [_cellDataSource modelAtIndexPath:path];
        if ([group isMemberOfClass:[MCGroup class]]) {
            MCEnterpriseBranchCell *groupCell = [tableView cellForRowAtIndexPath:path];
            [groupCell setSelectedStatusWithNO];
        }
        
    }
}

- (void)scrollViewWillBeginDragging:(UITableView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldChanged:(id)sender {
    [_searchTableView setEditing:YES];
    [self resetSearchFieldStatus];
    UITextField *textField = (UITextField *)sender;
    if ([textField.text length] == 1) {
        [_noMessageView setHidden:NO];
        if (_selectedModels.count == 0) {
            [_selectedHeaderView resetTextFieldStatus];
        }else {
            [_selectedHeaderView.searchPlaceholderLabel setHidden:NO];
            _selectedHeaderView.searchPlaceholderLabel.text = PMLocalizedStringWithKey(@"PM_Contact_SearchBarPlaceHolder");
        }
    }else {
        [_searchTableView setHidden:NO];
        [_selectedHeaderView.searchIconImageView setHidden:YES];
        [_selectedHeaderView.searchPlaceholderLabel setHidden:YES];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray* contacts = [[MCContactManager sharedInstance] getContacts];
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF.account contains[c] %@ or SELF.displayName contains[c] %@", [textField.text trim], [textField.text trim]];
        NSArray* ary =[contacts filteredArrayUsingPredicate:predicate];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_searchRusltArray removeAllObjects];
            [_searchRusltArray addObjectsFromArray:ary];
            if (_selectedModels) {
                for (MCContactModel *obj in _searchRusltArray) {
                    
                    for (MCContactModel *model in _selectedModels) {
                        if ([model.account isEqualToString:obj.account]) {
                            obj.isSelect = YES;
                        }
                    }
                    
                    for (MCContactModel *model in _alreadyExistsModels) {
                        if ([model.account isEqualToString:obj.account]) {
                            //已存在的成员不可编辑
                            model.cantEdit = YES;
                        }
                    }
                }
            }
            if (_searchRusltArray.count == 0) {
                //为搜索到结果
                NSString *contentStr = [textField.text trim];
                if ([contentStr isEmail]) {
                    MCContactModel *tempModel = [MCContactModel contactWithEmail:contentStr emailNickName:contentStr];
                    [_searchRusltArray addObject:tempModel];
                    [_searchTableView setEditing:NO];
                }
            }
            [_noMessageView setHidden:_searchRusltArray.count > 0 ? YES : NO];
            [_searchTableView reloadData];
        });
    });
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [_searchTableView setHidden:NO];
    [_selectedHeaderView.searchIconImageView setHidden:YES];
    [_noMessageView setHidden:_searchRusltArray.count > 0 ? YES : NO];
    if (textField.text.length == 1) {
        _selectedHeaderView.searchPlaceholderLabel.text = PMLocalizedStringWithKey(@"PM_Contact_SearchBarPlaceHolder");
        [_selectedHeaderView.searchPlaceholderLabel setHidden:NO];
    }else {
        [_selectedHeaderView.searchPlaceholderLabel setHidden:YES];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@""] && [textField.text isEqualToString:kMCTextEmpty]){
        if (_selectedModels.count > 0) {
            //删除最后一个联系人
            MCContactModel *model = [_selectedModels lastObject];
            model.isSelect = NO;
            [self setSelectedModelsWithModel:model];
            [self removeSelectedModel:model];
        }else {
            [_selectedHeaderView.textField resignFirstResponder];
            [_searchTableView setHidden:YES];
            [_noMessageView setHidden:YES];
            textField.text = kMCTextEmpty;
        }
        if (_selectedModels.count > 0) {
            _selectedHeaderView.searchPlaceholderLabel.text = PMLocalizedStringWithKey(@"PM_Contact_SearchBarPlaceHolder");
            [_selectedHeaderView.searchPlaceholderLabel setHidden:NO];
        }else {
            [_selectedHeaderView resetTextFieldStatus];
        }
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    textField.text = kMCTextEmpty;
    [_searchTableView setHidden:YES];
    [_noMessageView setHidden:YES];
    if (_selectedModels.count == 0) {
        [_selectedHeaderView resetTextFieldStatus];
    }
    return YES;
}

- (void)resetSearchFieldStatus {
    [_searchTableView setHidden:NO];
    [_searchRusltArray removeAllObjects];
    [_searchTableView reloadData];
}

- (void)rightNavigationBarButtonItemAction:(id)sender {
    if (_selectedModels.count == 0) {
        [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_Msg_ErrNoContacts")];
        return;
    }
    [self resetCacheContactsData];
    if (_selectedBlock) {
        _selectedBlock(_selectedModels, YES);
    }
    UIViewController *rootViewController = [self.navigationController.viewControllers firstObject];
    [rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)leftNavigationBarButtonItemAction:(id)sender {
    __weak MCSelectedSubContactsViewController *weakSelf = self;
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Cancel")];
    RIButtonItem *sureItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Sure") action:^{
        [weakSelf dismissCtrl];
    }];
    if (self.selectedModels.count > 0) {
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_Common_Notice") message:PMLocalizedStringWithKey(@"PM_Contact_cancelSelectNotice") cancelButtonItem:cancelItem otherButtonItems:sureItem, nil];
        [alertV show];
    }else {
        [self dismissCtrl];
    }
}

- (void)resetCacheContactsData {
    //状态重置，因为数据是缓存中的，下次进来会使用上次的数据
    for (MCContactModel *model in _selectedModels) {
        model.cantEdit = NO;
        model.isSelect = NO;
    }
    for (MCContactModel *model in _alreadyExistsModels) {
        model.cantEdit = NO;
        model.isSelect = NO;
    }
}

- (void)dismissCtrl {
    [self resetCacheContactsData];
    UIViewController *rootViewController = [self.navigationController.viewControllers firstObject];
    [rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
