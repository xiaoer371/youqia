//
//  MCFileManagerViewController.m
//  NPushMail
//
//  Created by wuwenyu on 15/12/30.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import "MCFileManagerViewController.h"
#import "MCSegmentHeadView.h"
#import "MCFileCore.h"
#import "MCFileBaseModel.h"
#import "MCFileManagerCell.h"
#import "MCFileBaseCellDataSource.h"
#import "MCFileEditingView.h"
#import "UIView+MJExtension.h"
#import "UISearchBar+MCExtension.h"
#import "MCAttachPreviewViewcontroller.h"
#import "UIAlertView+Blocks.h"
#import "MCIMChatForwordViewController.h"
#import "MCMailComposerViewController.h"
#import "MCIMNoMessageView.h"
#import "UIView+MCExpand.h"

@interface MCFileManagerViewController ()<SegmentTapViewDelegate, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate, MCFileEditSelectedDelegate>
/**
 *  被选中的数据
 */
@property(nonatomic, strong) NSMutableArray *selectedModels;
@property(nonatomic, strong) UIAlertView *alertV;
@property(nonatomic, strong) MCFileEditingView *editingView;
@property(nonatomic, strong) MCIMNoMessageView *noMessageView;
@property(nonatomic, strong) UITableView *mainTableV;
@property(nonatomic, strong) UISearchDisplayController *searchDisplay;
@property(nonatomic, strong) NSMutableArray *searchRusltArray;
@property(nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation MCFileManagerViewController {
    MCFileBaseCellDataSource *_cellDataSource;
    MCFileBaseCellDataSource *_searchCellDataSource;
    UIWindow *_mainWindow;
    UISearchBar *_searchBar;
    BOOL _isEditing;
    BOOL _isSearch;
    MCFileCtrlFromType _fromCtrlType;
    selectedFilesBlock _selectedFilesBlock;
}

- (id)initWithFromType:(MCFileCtrlFromType)type selectedFileBlock:(selectedFilesBlock)block {
    if (self = [super init]) {
        _fromCtrlType = type;
        _selectedFilesBlock = block;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_mainTableV reloadData];
    if (!_editingView) {
        _editingView = [[MCFileEditingView alloc] initWithFrame:CGRectMake(0, ScreenHeigth , CGRectGetWidth(self.view.frame), TOOLBAR_HEIGHT)];
        _editingView.delegate = self;
    }
    [_mainWindow addSubview:_editingView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_editingView removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = YES;
//    self.extendedLayoutIncludesOpaqueBars = YES;
    _isEditing = YES;
    self.viewTitle = PMLocalizedStringWithKey(@"PM_Mine_FileManager");
    _dataSource = [NSMutableArray new];
    _searchRusltArray = [NSMutableArray new];
    _selectedModels = [NSMutableArray new];
    // 添加通知监听键盘的弹出与隐藏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [self initSubViews];
}

- (void)initSubViews {
    TableViewCellConfigureBlock configureSearchCell = ^(MCFileManagerCell *cell, MCFileBaseModel *model, NSIndexPath *indexPath) {
        [cell configureCellWithModel:model];
    };
    __weak MCFileManagerViewController *weakSelf = self;
    _cellDataSource = [[MCFileBaseCellDataSource alloc] initWithModels:_dataSource cellIdentifier:@"MCFileManagerCell" configureCellBlock:configureSearchCell];
    _cellDataSource.deleteDataSourceCellBlock = ^(id model){
        if (weakSelf.dataSource.count <1) {
            [weakSelf isHiddenNoMessageView:NO];
        }else [weakSelf isHiddenNoMessageView:YES];
    };
    
    _mainTableV = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeigth - NAVIGATIONBARHIGHT)];
    _mainTableV.delegate = self;
    _mainTableV.backgroundColor = [UIColor whiteColor];
    _mainTableV.dataSource = _cellDataSource;
    _mainTableV.allowsSelectionDuringEditing = YES;
    _mainTableV.tableFooterView = [[UIView alloc] init];
    [_mainTableV registerNib:[UINib nibWithNibName:@"MCFileManagerCell" bundle:nil] forCellReuseIdentifier:@"MCFileManagerCell"];
    [self.view addSubview:_mainTableV];

    if (!_noMessageView) {
        [self.view addSubview:self.noMessageView];
    }
    
    [self loadDataSource];

    if (_dataSource.count <1) {
        return;
    }
    
    [self.rightNavigationBarButtonItem setTitle:PMLocalizedStringWithKey(@"PM_Contact_Edit")];
    
    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
    _searchBar.placeholder= PMLocalizedStringWithKey(@"PM_Contact_SearchBarPlaceHolder");
    _searchBar.delegate = self;
    [_searchBar settingPlainTintStyle];
    _searchBar.showsScopeBar = YES;
    _mainTableV.tableHeaderView = _searchBar;
    
    _searchCellDataSource = [[MCFileBaseCellDataSource alloc] initWithModels:_searchRusltArray cellIdentifier:@"MCFileManagerCell" configureCellBlock:configureSearchCell];
    deleteDataSourceCellBlock searchDeleDataBlock = ^(id model) {
        [weakSelf.dataSource removeObject:model];
        if (_dataSource.count <1) {
            [weakSelf.searchDisplay setActive:NO animated:YES];
        }
        [weakSelf loadDataSource];
        [weakSelf.mainTableV reloadData];
    };
    _searchCellDataSource.deleteDataSourceCellBlock = searchDeleDataBlock;
    _searchDisplay = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    _searchDisplay.delegate = self;
    _searchDisplay.searchResultsDataSource = _searchCellDataSource;
    _searchDisplay.searchResultsDelegate = self;
    _searchDisplay.searchResultsTableView.allowsSelectionDuringEditing = YES;
    if (_fromCtrlType == MCFileCtrlFromMail || _fromCtrlType == MCFileEditSendMsg) {
        [_mainTableV setEditing:YES];
        [_searchDisplay.searchResultsTableView setEditing:YES];
        [self.rightNavigationBarButtonItem setTitle:PMLocalizedStringWithKey(@"PM_Common_Complite")];
    }
    [_searchDisplay.searchResultsTableView registerNib:[UINib nibWithNibName:@"MCFileManagerCell" bundle:nil] forCellReuseIdentifier:@"MCFileManagerCell"];
    _mainWindow = [[UIApplication sharedApplication] keyWindow];

    
}

- (void)loadDataSource {
    _dataSource = [[MCFileCore sharedInstance] getAllFiles];
    _cellDataSource.models = _dataSource;
    
    if (_dataSource.count <1) {
        [self isHiddenNoMessageView:NO];
    }else [self isHiddenNoMessageView:YES];
    
}

#pragma mark -   UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 57;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView.editing) {
        if (tableView == _mainTableV) {
            MCFileManagerCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [cell changeSelectedState];
            MCFileBaseModel *model = [_cellDataSource modelAtIndexPath:indexPath];
            [self setSelectedStatusWithModel:model];
        }else {
            //搜索结果
            id obj = [_searchCellDataSource modelAtIndexPath:indexPath];
            MCFileManagerCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if ([obj isMemberOfClass:[MCFileBaseModel class]]) {
                MCFileBaseModel *model = obj;
                [cell changeSelectedState];
                //搜索得到的cell的状态要与外层的cell的状态要一致
                for (MCFileBaseModel *obj in _dataSource) {
                    if ([model.displayName isEqualToString:obj.displayName]) {
                        obj.isSelected = model.isSelected;
                    }
                }
                [self setSelectedStatusWithModel:model];
                [_mainTableV reloadData];
            }
        }
    }else {
        MCFileBaseModel *model = nil;
        if (tableView == _mainTableV) {
            model = [_cellDataSource modelAtIndexPath:indexPath];
        }else {
            model = [_searchCellDataSource modelAtIndexPath:indexPath];
        }
        MCAttachPreviewViewcontroller *v = [[MCAttachPreviewViewcontroller alloc] initWithFile:model manager:nil fileSourceFrom:MCFileSourceFromLocLibrary];
        [self.navigationController pushViewController:v animated:YES];
    }
}

- (void)setSelectedStatusWithModel:(MCFileBaseModel *)model {
    [self setSelectedModelsWithModel:model];
    if (_selectedModels.count > 0) {
        [_editingView setBtnEnable:YES];
    }else {
        [_editingView setBtnEnable:NO];
    }
}

- (void)setSelectedModelsWithModel:(MCFileBaseModel *)model {
    BOOL isExist = NO;
    for (MCFileBaseModel *obj in _selectedModels) {
        if ([obj.displayName  isEqualToString:model.displayName]) {
            isExist = YES;
            if (!model.isSelected) {
                [_selectedModels removeObject:obj];
            }
            break;
        }
    }
    if (!isExist) {
        if (model.isSelected) {
            [_selectedModels addObject:model];
        }
    }
}


-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.editing) {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - searchBarDelagate

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope{
    
}

//搜索
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
}

#pragma mark UISearchDisplayController delegate

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
//去除系统无结果标签
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [_searchRusltArray removeAllObjects];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF.displayName contains[c] %@",searchString];
    NSArray* ary =[_dataSource filteredArrayUsingPredicate:predicate];
    [_searchRusltArray addObjectsFromArray:ary];
    
    if (_selectedModels) {
        for (MCFileBaseModel *obj in _searchRusltArray) {
            
            for (MCFileBaseModel* model in _selectedModels) {
                if ([model.displayName isEqualToString:obj.displayName]) {
                    obj.isSelected = YES;
                }
            }
        }
    }

    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    UITableView *tableView1 = self.searchDisplayController.searchResultsTableView;
    
    for( UIView *subview in tableView1.subviews ) {
        if( [subview class] == [UILabel class] ) {
            UILabel *lbl = (UILabel*)subview;
            lbl.text = @"";
        }
    }
    return YES;
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    if (_isSearch) {
        return;
    }
    _isSearch = YES;
    [_searchBar settingActiveTintStyle];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    
//    if (_mainTableV != self.searchDisplayController.searchBar.superview) {
//        [_mainTableV insertSubview:self.searchDisplayController.searchBar aboveSubview:_mainTableV];
//    }
    [_searchBar settingPlainTintStyle];
    _isSearch = NO;
}
#pragma clang diagnostic pop


#pragma mark - SegmentTapViewDelegate

-(void) selectedIndex:(NSInteger)index {

}

- (void)leftNavigationBarButtonItemAction:(id)sender {
    if (_fromCtrlType == FromMail) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightNavigationBarButtonItemAction:(id)sender {
    if (_fromCtrlType == MCFileCtrlFromMail || _fromCtrlType == MCFileEditSendMsg) {
        _selectedFilesBlock(_selectedModels);
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    [self editingStatusChange];
}

- (void)editingStatusChange {
    [_mainTableV setEditing:_isEditing animated:YES];
    [_searchDisplay.searchResultsTableView setEditing:_isEditing];
    [_editingView show:_isEditing];
    for (MCFileBaseModel *model in _selectedModels) {
        model.isSelected = NO;
    }
    [_selectedModels removeAllObjects];
    [_editingView setBtnEnable:NO];
    if (_isEditing) {
        [_mainTableV setMj_h:CGRectGetHeight(self.view.frame) - TOOLBAR_HEIGHT];
        [self.rightNavigationBarButtonItem setTitle:PMLocalizedStringWithKey(@"PM_Common_Cancel")];
    }else {
        [_mainTableV setMj_h:CGRectGetHeight(self.view.frame)];
        [self.rightNavigationBarButtonItem setTitle:PMLocalizedStringWithKey(@"PM_Contact_Edit")];
    }
    _isEditing = !_isEditing;
}

#pragma mark - MCFileEditSelectedDelegate

- (void)fileEditDidSelectOption:(MCFileEditType)type {
    switch (type) {
        case MCFileEditSendMsg:
        {
            //友盟统计
            [MCUmengManager addEventWithKey:mc_me_file_im];
            MCIMChatForwordViewController *vc =[[MCIMChatForwordViewController alloc] initWithFiles:_selectedModels];
            [self editingStatusChange];
            [_searchDisplay setActive:NO];
            [self.navigationController pushViewController:vc animated:YES];
            
        }
            break;
        case MCFileEditForMailAttachment: {
            //友盟统计
            [MCUmengManager addEventWithKey:mc_me_file_mail];
            MCMailComposerViewController *composrViewController = [[MCMailComposerViewController alloc]initWithContent:_selectedModels composerType:MCMailComposerFromFileLibrary];
            [self editingStatusChange];
            [_searchDisplay setActive:NO];
            [self.navigationController pushViewController:composrViewController animated:YES];
            break;
        }
        case MCFileEditDelete: {
            //友盟统计
            [MCUmengManager addEventWithKey:mc_me_file_delete];
            [self deleteFiles];
            break;
        }
            
        default:
            break;
    }
}

- (void)deleteFiles {
    __weak MCFileManagerViewController *weakSelf = self;
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Cancel") action:^{
    }];
    RIButtonItem *sureItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Sure") action:^{
        for (MCFileBaseModel *model in weakSelf.selectedModels) {
            [[MCFileCore sharedInstance] deleteFileWithModel:model];
            if (_mainTableV.isEditing) {
                [_searchRusltArray removeObject:model];
            }
        }
        [weakSelf loadDataSource];
        [_mainTableV reloadData];
        [_searchDisplay.searchResultsTableView reloadData];
        [weakSelf editingStatusChange];
        
        if (_dataSource.count <1) {
            [weakSelf isHiddenNoMessageView:NO];
        }else [weakSelf isHiddenNoMessageView:YES];
        
    }] ;
    _alertV = [[UIAlertView alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_Common_Notice") message:PMLocalizedStringWithKey(@"PM_Mine_sureDeletFiles") cancelButtonItem:cancelItem otherButtonItems:sureItem, nil];
    [_alertV show];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification{
    if (!_isEditing) {
        // 拿到键盘弹出时间
        double duration = [notification.userInfo [UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        // 计算transform
        CGFloat keyboardY = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
        CGFloat ty = keyboardY - ScreenHeigth;
        
        /**
         *  像这种移动后又回到原始位置的建议使用transform,因为transform可以直接清零回到原来的位置
         */
        __weak MCFileManagerViewController *weakSelf = self;
        [UIView animateWithDuration:duration animations:^{
            weakSelf.editingView.transform = CGAffineTransformMakeTranslation(0, ty);
        }];
    }
}

- (MCIMNoMessageView *)noMessageView
{
    if (!_noMessageView) {
        _noMessageView = [[MCIMNoMessageView alloc] initWithCreatType:MCNODateSourceAlertNoFile imageName:@"mc_nofile.png" text:PMLocalizedStringWithKey(@"PM_File_noFilesNotice")];
        _noMessageView.hidden = YES;
        _noMessageView.mc_height = ScreenHeigth - NAVIGATIONBARHIGHT;
        [_noMessageView moveToY:0];
    }
    return _noMessageView;
}

- (void)isHiddenNoMessageView:(BOOL)isHidden
{
    self.noMessageView.hidden = isHidden;
    if (isHidden == NO) {
        [self.rightNavigationBarButtonItem setTitle:@""];
        self.rightNavigationBarButtonItem = nil;
        _mainTableV.tableHeaderView = nil;
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
