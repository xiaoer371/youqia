//
//  MCSelectedContactsRootViewController.m
//  NPushMail
//
//  Created by wuwenyu on 16/3/29.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCSelectedContactsRootViewController.h"
#import "MCContactModel.h"
#import "MCContactCell.h"
#import "MCEnterpriseBranchCell.h"
#import "UIView+MJExtension.h"
#import "MCGroup.h"
#import "MCSelectedSubContactsViewController.h"
#import "MCRecentContactsViewController.h"
#import "MCShowSelectedMembersBottomView.h"
#import "MCSelectedRootContactCellDataSource.h"
#import "MCCellDataSource.h"
#import "MCContactManager.h"
#import "MCEnterpriseStructTree.h"
#import "MCEnterpriseContactCellItem.h"
#import "UISearchBar+MCExtension.h"
#import "MCSelectedContactsHeaderView.h"
#import "TITokenField.h"
#import "MCIMGroupManager.h"
#import "MCIMConversationManager.h"
#import "MCIMChatViewController.h"
#import "MCMessageGroupsViewController.h"
#import "MCIMGroupManager.h"
#import "MCIMConversationManager.h"
#import "MCIMChatViewController.h"
#import "MCIMNoMessageView.h"
#import "UIAlertView+Blocks.h"

@interface MCSelectedContactsRootViewController ()<UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UITextFieldDelegate>
@property(nonatomic, strong) NSMutableArray *selectedModels;
@property(nonatomic, strong) UITableView *searchTableView;
@property(nonatomic, strong) MCIMNoMessageView *noMessageView;
@end

static const CGFloat selectedHeaderViewHeight = 57;

@implementation MCSelectedContactsRootViewController {
    UILabel *_titleLablel;
    SelectedModelsBlock _selectedModelsBlock;
    SelectedMsgGroupModelBlock _selectedMsgGroupBlock;
    SelectedContactType _fromCtrlType;
    NSArray *_alreadyExistsModels;
    UISearchDisplayController *_searchDisplay;
    UISearchBar *_searchBar;
    MCSelectedRootContactCellDataSource *_cellDataSource;
    MCCellDataSource *_searchResultCellDataSource;
    NSMutableArray *_searchRusltArray;
    MCSelectedContactsHeaderView *_selectedHeaderView;
    int tapContactCount;
}

- (id)initWithSelectedModelsBlock:(SelectedModelsBlock)block selectedMsgGroupModelBlock:(SelectedMsgGroupModelBlock)msgGroupBlock formCtrlType:(SelectedContactType)type alreadyExistsModels:(NSArray *)models {
    if (self = [super init]) {
        _selectedModelsBlock = [block copy];
        _selectedMsgGroupBlock = [msgGroupBlock copy];
        _fromCtrlType = type;
        _alreadyExistsModels = models;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.changeAccountArrow setHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _selectedModels = [NSMutableArray new];
    if (_fromCtrlType == SelectedContactFromMailSendMsgs) {
        [_selectedModels addObjectsFromArray:_alreadyExistsModels];
    }
    _searchRusltArray = [NSMutableArray new];
    [self.leftNavigationBarButtonItem setImage:nil];
    [self.leftNavigationBarButtonItem setTitle:PMLocalizedStringWithKey(@"PM_Common_Cancel")];
    [self setNavgationBarRightBtns];
    [self loadSubViews];
    // Do any additional setup after loading the view from its nib.
}

- (void)loadDataSource {
    __weak MCSelectedContactsRootViewController *weakSelf = self;
    self.currentAccount = AppStatus.currentUser;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf updateGroups];
        [weakSelf updateContacts];
        [weakSelf setSelectedStatus];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
        });
    });
}

- (void)loadSubViews {
    __weak typeof(self) weakSelf = self;
    _selectedHeaderView = [[MCSelectedContactsHeaderView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, selectedHeaderViewHeight) models:_selectedModels removeBlock:^(id model) {
        [weakSelf removeSelectedModel:model];
    }];
    _selectedHeaderView.textField.delegate = self;
    _selectedHeaderView.textField.returnKeyType = UIReturnKeyDone;
    [_selectedHeaderView.textField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_selectedHeaderView];

    self.tableView.frame = CGRectMake(0, selectedHeaderViewHeight, ScreenWidth, ScreenHeigth - NAVIGATIONBARHIGHT - selectedHeaderViewHeight);
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView setEditing:YES];
    [self.tableView setAllowsSelectionDuringEditing:YES];
    
    TableViewCellConfigureBlock configureSearchCell = ^(MCContactCell *cell, MCContactModel *model, NSIndexPath *indexPath) {
        [cell configureCellWithModel:model];
    };
    _searchResultCellDataSource = [[MCCellDataSource alloc] initWithModels:_searchRusltArray cellIdentifier:@"MCContactCell" configureCellBlock:configureSearchCell];
    _searchTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, selectedHeaderViewHeight, ScreenWidth, ScreenHeigth- NAVIGATIONBARHIGHT - selectedHeaderViewHeight)];
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

- (void)setNavgationBarRightBtns {
    [self.rightNavigationBarButtonItem setImage:[UIImage imageNamed:@"addLinkman111.png"]];
    if (_alreadyExistsModels.count>0 || self.selectedModels.count>0) {
        
       [self.rightNavigationBarButtonItem setTitle:[NSString stringWithFormat:@"%@(%lu)",PMLocalizedStringWithKey(@"PM_Contact_LaunchChatOrEmail"),self.selectedModels.count]];
    }else{
        [self.rightNavigationBarButtonItem setTitle:[NSString stringWithFormat:@"%@",PMLocalizedStringWithKey(@"PM_Contact_LaunchChatOrEmail")]];
    }
}

- (MCIMNoMessageView *)noMessageView
{
    if (!_noMessageView) {
        _noMessageView = [[MCIMNoMessageView alloc] initWithCreatType:MCNODateSourceAlertNoFile imageName:@"mc_contactNoSearchResult.png" text:PMLocalizedStringWithKey(@"PM_File_noContactSearchResultNotice")];
        _noMessageView.hidden = YES;
        _noMessageView.mj_h = ScreenHeigth - NAVIGATIONBARHIGHT;
        _noMessageView.mj_y = -60;
        if (iPhone4) {
            _noMessageView.imageName = @"mc_contactNoSearchResult1.png";
            _noMessageView.textLabel.mj_y = _noMessageView.textLabel.mj_y - 80;
        }
    }
    return _noMessageView;
}

- (void)updateGroups {
    [super updateGroups];
    [self.groupList removeLastObject];
//    [self.groupList removeObjectAtIndex:self.groupList.count-2];
    if (_fromCtrlType != SelectedContactFromWriteMail && _fromCtrlType != SelectedContactChatInfo && _fromCtrlType != SelectedContactForwordChat) {
        [self.groupList addObject:@"PM_ContactMessageGroups"];
//        [self.groupList insertObject:@"PM_ContactMessageGroups" atIndex:self.groupList.count-1];
    }
}

//移除选中的联系人
- (void)removeSelectedModel:(id)model {
    MCContactModel *obj = (MCContactModel *)model;
    for (NSArray *models in self.contacts) {
        for (MCContactModel *model1 in models) {
            if ([model1.account isEqualToString:obj.account]) {
                model1.isSelect = NO;
                model1.cantEdit = NO;
            }
        }
    }
    [self setContactsCounts];
    [self.tableView reloadData];
}

- (void)setSelectedStatus {
    if (_alreadyExistsModels &&_alreadyExistsModels.count > 0) {
        for (NSArray *models in self.contacts) {
            for (MCContactModel *model in models) {
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
}

- (void)setBlockSelectedStatus {
    if (_selectedModels && _selectedModels.count > 0) {
        for (NSArray *models in self.contacts) {
            for (MCContactModel *model in models) {
                for (MCContactModel *obj in _selectedModels) {
                    if ([obj.account isEqualToString:model.account]) {
                        model.isSelect = YES;
                    }
                }
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MCContactModel *model;
    if (tableView == self.tableView) {
        if (indexPath.section != 0) {
            //点击联系人
            NSArray *contacts = self.contacts[indexPath.section - 1];
            model = contacts[indexPath.row];
            MCContactCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if (model.cantEdit) {
                return;
            }
            [cell changeSelectedState];
            NSArray *visibleCellIndexPaths = [tableView indexPathsForVisibleRows];
            NSMutableArray *visibleContactCellPaths = [NSMutableArray new];
            for (NSIndexPath * path in visibleCellIndexPaths) {
                if (path.section != 0) {
                    [visibleContactCellPaths addObject:path];
                }
            }
            [tableView reloadRowsAtIndexPaths:visibleContactCellPaths withRowAnimation:UITableViewRowAnimationNone];
            [self setSelectedModelsWithModel:model];
            [self setContactsCounts];
        }else {
            NSString *groupName = [self.groupList objectAtIndex:indexPath.row];
            if ([groupName isEqualToString:@"PM_Contacts_Type_En"] ||[groupName isEqualToString:@"PM_Contacts_Type_Personal"]) {
                //企业联系人和邮洽联系人
                MCGroup *group = [[MCGroup alloc] init];
                group.name = groupName;
                __weak typeof(self) weakSelf = self;
                selectedModelsWithRefreshBlock block = ^(id models, BOOL needRefreshFlage) {
                    __strong MCSelectedContactsRootViewController *sSelf = weakSelf;
                    sSelf->_selectedModels = models;
                    if (needRefreshFlage) {
                        sSelf->_selectedModelsBlock(_selectedModels);
                    }else {
                        [sSelf setSelectedStatus];
                    }
                    sSelf->_selectedHeaderView.models = _selectedModels;
                    [sSelf->_selectedHeaderView.collectionView reloadData];
                    [sSelf->_selectedHeaderView updateSubViews];
                    [weakSelf setContactsCounts];
                };
                
                MCSelectedSubContactsViewController *v = [[MCSelectedSubContactsViewController alloc] initWithGroup:group subBranchs:nil selectedBlock:block formCtrlType:_fromCtrlType selectedModels:_selectedModels alreadyExistsModels:_alreadyExistsModels];
                [self.navigationController pushViewController:v animated:YES];
                return;
            }
            if ([groupName isEqualToString:@"PM_ContactMessageGroups"]) {
                //消息群组
                __weak typeof(self) weakSelf = self;
                MCMessageGroupsViewController *v = [[MCMessageGroupsViewController alloc] initWithFromCtrlType:SelectedMsgGroupFromSelectedContact selectedGroupBlock:^(id model) {
                    if (_selectedMsgGroupBlock) {
                        [weakSelf.navigationController dismissViewControllerAnimated:NO completion:nil];
                        _selectedMsgGroupBlock(model);
                    }
                }];
                [self.navigationController pushViewController:v animated:YES];
                return;
            }
        }
    }else {
        model = [_searchResultCellDataSource modelAtIndexPath:indexPath];
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
            [self.tableView reloadData];
        }
    }
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

- (void)setContactsCounts {
    if (self.selectedModels.count > 0 ||_alreadyExistsModels.count>0) {
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
        }
        if (_selectedModels.count > 0) {
            _selectedHeaderView.searchPlaceholderLabel.text = PMLocalizedStringWithKey(@"PM_Contact_SearchBarPlaceHolder");
            [_selectedHeaderView.searchPlaceholderLabel setHidden:NO];
        }else {
            [_selectedHeaderView resetTextFieldStatus];
        }
        textField.text = kMCTextEmpty;
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
    if (_selectedModelsBlock) {
        _selectedModelsBlock(_selectedModels);
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)leftNavigationBarButtonItemAction:(id)sender {
    __weak MCSelectedContactsRootViewController *weakSelf = self;
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

- (void)dismissCtrl {
    [self resetCacheContactsData];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
