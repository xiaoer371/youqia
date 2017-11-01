//
//  MCEnterpriseOrganizationViewController.m
//  NPushMail
//
//  Created by wuwenyu on 16/3/2.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCEnterpriseOrganizationViewController.h"
#import "MCEnterpriseStructTree.h"
#import "MCEnterpriseOrganizationDataSource.h"
#import "MCCellDataSource.h"
#import "MCEnterpriseContactCellItem.h"
#import "MCEnterpriseEmplyoeeCell.h"
#import "MCEnterpriseBranchCell.h"
#import "MCContactManager.h"
#import "MCServerAPI.h"
#import "MCServerAPI+EIS.h"
#import "MCContactCell.h"
#import "UISearchBar+MCExtension.h"
#import "MCContactInfoViewController.h"
#import "MCEnterpriseSyncConfig.h"
#import "MCAccountConfig.h"
#import "MCAppSetting.h"
#import "MCContactInfoViewController.h"
#import "MCRefreshHelper.h"
#import "MCEnterpriseSearchViewController.h"
#import "MCBaseNavigationViewController.h"

@interface MCEnterpriseOrganizationViewController ()<UITableViewDelegate, SRRefreshDelegate>

@end

static const float branchCellHeight = 44;
static const float employeeCellHeight = 57;

@implementation MCEnterpriseOrganizationViewController {
    NSMutableArray*         _rootBranchArray;//根部门
    NSMutableArray*         _itemShowArray;//每次需要显示的数据源
    MCEnterpriseStructTree*    _tree;
    BOOL                     _eisFlag;
    MCEnterpriseOrganizationDataSource *_tableDataSource;
    /**
     *  是否需要调整VIEW的位置
     */
    BOOL _haveChangeFrame;
    ContactDidSelectedBlock _didSelectedBlock;
    SRRefreshView *_refreshView;
}

-(id) initWithEisFlag:(BOOL)eisFlag haveChangeFrame:(BOOL)haveChangeFrame didSelectedBlock:(ContactDidSelectedBlock)block {
    self = [super init];
    if (self) {
        _eisFlag = eisFlag;
        _haveChangeFrame = haveChangeFrame;
        _didSelectedBlock = block;
    }
    return self;
}

#pragma mark - lifeCrcle

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _rootBranchArray = [NSMutableArray arrayWithCapacity:0];
    _itemShowArray = [NSMutableArray arrayWithCapacity:0];
    self.view.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeigth);
    [self loadSubViews];
    if (!AppStatus.accountData.accountConfig.isBusinessContactDisabled) {
        if (!AppStatus.accountData.accountConfig.eisSyncTimestamp) {
            [_refreshView setLoadingWithExpansion];
        }
        else{
            [self loadDataSource];
        }
    }
}

- (void)changeAccountLoadData {
    //避免同步太慢或者失败的情况下此页面还显示切换前的用户的联系人
    [_itemShowArray removeAllObjects];
    _tableDataSource.showItems = _itemShowArray;
    [_mainTabelV reloadData];
    
    _eisFlag = AppStatus.currentUser.isEIS;
    if (_tableDataSource) {
        _tableDataSource.eisFlag = _eisFlag;
    }
    [self synEnterpriseContacts];
}

- (void)synEnterpriseContacts {
    if (!_eisFlag) {
        [self loadNoEisAccountData];
        return;
    }

    [[MCContactManager sharedInstance] updateEnterpriseContactsSuccess:^{
        [self loadDataSource];
        [_refreshView endRefreshWithResult:PMLocalizedStringWithKey(@"PM_Contact_EnterpriseSuccess")];
    } failure:^(NSError *error) {
        [_refreshView endRefreshWithResult:PMLocalizedStringWithKey(@"PM_Contact_EnterpriseErr")];
        NSDictionary *errorInfo = error.userInfo;
        NSString *errorStr = [errorInfo.allValues lastObject];
        if (errorStr) {
            [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_Contact_EnterpriseErr")];
        }
    }];
}

-(void) loadDataSource {
    if (!_eisFlag) {
        [self loadNoEisAccountData];
        return;
    }
    
    dispatch_queue_t kBgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(kBgQueue, ^ {
        NSMutableArray* branchInfoMessageArray = [NSMutableArray arrayWithCapacity:0];
        branchInfoMessageArray = [[[MCContactManager sharedInstance] getAllEnterpriseBranchs] mutableCopy];
        _tree = [[MCEnterpriseStructTree alloc] initWithBranchInfo:branchInfoMessageArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            //先显示顶层部门
            _itemShowArray = _tree.rootNodeItemArray;
            _tableDataSource.showItems = _itemShowArray;
            [_mainTabelV reloadData];
        });
    });
}

- (void)loadNoEisAccountData {
    //2.0域目前只显示同个域的联系人
    if (_itemShowArray) {
        [_itemShowArray removeAllObjects];
    }
    NSString* currentEmail = AppStatus.currentUser.email;
    NSRange range = [currentEmail rangeOfString:@"@"];
    NSString* domin = [currentEmail substringFromIndex:(range.location + 1)];
    DDLogVerbose(@"%@",domin);
    _itemShowArray = [[[MCContactManager sharedInstance] getSameDominContactInfoByDomin:domin] mutableCopy];
    _tableDataSource.showItems = _itemShowArray;
    
    [self performSelector:@selector(delayAction:) withObject:nil afterDelay:2];

}

- (void)delayAction:(id)sender
{
    [_refreshView endRefreshWithResult:PMLocalizedStringWithKey(@"PM_Contact_EnterpriseSuccess")];
    [_mainTabelV reloadData];
}

- (void)loadSubViews {
    self.viewTitle = PMLocalizedStringWithKey(@"PM_Contacts_Type_En");
    self.rightNavigationBarButtonItem.image = AppStatus.theme.mailStyle.mailListSearchImage;
    self.automaticallyAdjustsScrollViewInsets = YES;

    ContactCellConfigureBlock tableViewConfigureBlock = ^(id model, id cell, NSIndexPath *indexPath) {
        [self configureContactTableViewCellWithModel:model cell:cell indexPath:indexPath];
    };
    _tableDataSource = [[MCEnterpriseOrganizationDataSource alloc] initWithEisFlag:_eisFlag showItems:_itemShowArray branchCellIdentifier:@"MCEnterpriseBranchCell" emplyoeeCellIdentifier:@"MCEnterpriseEmplyoeeCell" contactCellIdentifier:@"MCContactCell" configureCellBlock:tableViewConfigureBlock];
    _mainTabelV = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeigth - NAVIGATIONBARHIGHT)];
    if (_haveChangeFrame) {
        _mainTabelV.frame = CGRectMake(0, 25, ScreenWidth, ScreenHeigth - TOOLBAR_HEIGHT*2 - NAVIGATIONBARHIGHT);
    }
    _mainTabelV.delegate = self;
    _mainTabelV.backgroundColor = AppStatus.theme.backgroundColor;
    _mainTabelV.dataSource = _tableDataSource;
    _mainTabelV.tableFooterView = [[UIView alloc] init];
    _mainTabelV.sectionIndexBackgroundColor = [UIColor clearColor];
    _mainTabelV.separatorColor = AppStatus.theme.tableViewSeparatorColor;
    _mainTabelV.sectionIndexColor = AppStatus.theme.fontTintColor;
    _mainTabelV.tableFooterView = [[UIView alloc] init];
    [_mainTabelV registerNib:[UINib nibWithNibName:@"MCContactCell" bundle:nil] forCellReuseIdentifier:@"MCContactCell"];
    [_mainTabelV registerNib:[UINib nibWithNibName:@"MCEnterpriseBranchCell" bundle:nil] forCellReuseIdentifier:@"MCEnterpriseBranchCell"];
    [_mainTabelV registerNib:[UINib nibWithNibName:@"MCEnterpriseEmplyoeeCell" bundle:nil] forCellReuseIdentifier:@"MCEnterpriseEmplyoeeCell"];
    [self.view addSubview:_mainTabelV];

    _refreshView = [MCRefreshHelper createRefreshView];
    _refreshView.delegate = self;
    [_mainTabelV addSubview:_refreshView];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!_eisFlag) {
        return employeeCellHeight;
    }
    MCEnterpriseContactCellItem *tmpItem = nil;
    if (tableView == _mainTabelV) {
        tmpItem = [_itemShowArray objectAtIndex:indexPath.row];
    }
    if (tmpItem.branchInfo) {
        return branchCellHeight;
    }
    return employeeCellHeight;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MCEnterpriseContactCellItem* currentItem = nil;
    if (tableView == _mainTabelV) {
        if (!_eisFlag) {
            MCContactModel *model = [_itemShowArray objectAtIndex:indexPath.row];
            MCContactInfoViewController *v = [[MCContactInfoViewController alloc] initFromType:fromContact contactModel:model canEditable:YES isEnterprise:YES];
            if (_haveChangeFrame) {
                if (_didSelectedBlock) {
                    _didSelectedBlock(model, indexPath, v);
                }
                return;
            }
            [self.navigationController pushViewController:v animated:YES];
            return;
        }
        currentItem = [_itemShowArray objectAtIndex:indexPath.row];
        if (currentItem.branchInfo) {
            //点击部门，则展开或闭合其子部门和子员工项
            if (currentItem.isOpen) {//如果是已展开，则关闭
                if (indexPath.row+1 < _itemShowArray.count){//确保有下一项存在
                    MCEnterpriseContactCellItem* nextItemObj = [_itemShowArray objectAtIndex:indexPath.row + 1];//下一个item
                    //如果下一个item的层级和当前的item层级一致的话，说明当前的item是没有子员工和子部门的
                    if ([nextItemObj.itemLevel isEqualToString:currentItem.itemLevel]) {
                        
                        currentItem.isOpen = NO;
                        //当前需要刷新的cell,主要是剪头的复位设置
                        NSIndexPath* currentRfreshItemPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
                        NSMutableArray* currentRfreshItemPathArray = [NSMutableArray arrayWithCapacity:0];
                        [currentRfreshItemPathArray addObject:currentRfreshItemPath];
                        [tableView reloadRowsAtIndexPaths:currentRfreshItemPathArray withRowAnimation:UITableViewRowAnimationNone];//刷新部门箭头样式
                        return;
                    }
                    
                    //当前需要刷新的cell,主要是剪头的复位设置
                    NSIndexPath* currentRfreshItemPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
                    NSMutableArray* currentRfreshItemPathArray = [NSMutableArray arrayWithCapacity:0];
                    [currentRfreshItemPathArray addObject:currentRfreshItemPath];
                    
                    NSMutableArray* pathArray = [NSMutableArray arrayWithCapacity:0];
                    
                    int j = 1;
                    
                    //闭合的时候找比当前level高的全部闭合,由于是有序的，所以只需要找比当前高level的就行
                    while (nextItemObj && [nextItemObj.itemLevel intValue]> [currentItem.itemLevel intValue]) {
                        //找到下一项，加入到当前显示队列中
                        NSIndexPath* path = [NSIndexPath indexPathForRow:indexPath.row + j inSection:0];
                        [pathArray addObject:path];
                        //如果是部门，当每次点击都得刷新当前部门得闭合状态
                        if (nextItemObj.branchInfo) {
                            nextItemObj.isOpen = NO;
                        }
                        j++;
                        if (indexPath.row + j <= _itemShowArray.count-1) {
                            nextItemObj = [_itemShowArray objectAtIndex:indexPath.row + j];
                        }else{
                            nextItemObj = nil;//跳出循环
                        }
                        
                    }
                    
                    NSRange removeRange = NSMakeRange(indexPath.row+1, j-1);
                    [_itemShowArray removeObjectsInRange:removeRange];
                    currentItem.isOpen = NO;
                    _tableDataSource.showItems = _itemShowArray;
                    [tableView deleteRowsAtIndexPaths:pathArray
                                     withRowAnimation:UITableViewRowAnimationNone];
                    [tableView reloadRowsAtIndexPaths:currentRfreshItemPathArray withRowAnimation:UITableViewRowAnimationNone];//刷新部门箭头样式
                }else{
                    currentItem.isOpen = NO;
                    _tableDataSource.showItems = _itemShowArray;
                    //最后一个部门若是没有成员的情况下，只需要复位箭头位置即可
                    NSIndexPath* currentRfreshItemPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
                    NSMutableArray* currentRfreshItemPathArray = [NSMutableArray arrayWithCapacity:0];
                    [currentRfreshItemPathArray addObject:currentRfreshItemPath];
                    [tableView reloadRowsAtIndexPaths:currentRfreshItemPathArray withRowAnimation:UITableViewRowAnimationNone];//刷新部门箭头样式
                }
                
            }else {
                //则展开
                if (!currentItem.childrenBranchItems) {
                    currentItem.childrenBranchItems = [_tree getChildrenBranchItemsWithBranchId:currentItem.branchInfo.branchId];
                }
                if (!currentItem.childrenEmplyoeeItems) {
                    currentItem.childrenEmplyoeeItems = [_tree getChildrenEmplyoeeItemsWithBranchId:currentItem.branchInfo.branchId];
                }
                NSMutableArray* toShowAry = [NSMutableArray arrayWithCapacity:0];
                for (int i = 0; i < currentItem.childrenEmplyoeeItems.count; i++) {
                    MCEnterpriseContactCellItem *tempObj = [currentItem.childrenEmplyoeeItems objectAtIndex:i];
                    [toShowAry addObject:tempObj];
                }
                for (int i = 0; i < currentItem.childrenBranchItems.count; i++) {
                    MCEnterpriseContactCellItem *tempObj = [currentItem.childrenBranchItems objectAtIndex:i];
                    [toShowAry addObject:tempObj];
                }
                
                NSRange range = NSMakeRange(indexPath.row+1, toShowAry.count);
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                //插入数据源
                [_itemShowArray insertObjects:toShowAry atIndexes:indexSet];
                NSMutableArray* pathArray = [NSMutableArray arrayWithCapacity:0];
                for (int i = 1; i <= toShowAry.count; i++) {
                    NSIndexPath* path = [NSIndexPath indexPathForRow:indexPath.row + i inSection:0];
                    [pathArray addObject:path];
                }
                currentItem.isOpen = YES;
                _tableDataSource.showItems = _itemShowArray;
                [tableView insertRowsAtIndexPaths:pathArray
                                 withRowAnimation:UITableViewRowAnimationNone];
                NSIndexPath* currentItemPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
                NSMutableArray* currentItemPathArray = [NSMutableArray arrayWithCapacity:0];
                [currentItemPathArray addObject:currentItemPath];
                [tableView reloadRowsAtIndexPaths:currentItemPathArray withRowAnimation:UITableViewRowAnimationNone];
            }
            return;
        }
        //点击员工的操作
        currentItem = [_itemShowArray objectAtIndex:indexPath.row];
        MCContactInfoViewController *v = [[MCContactInfoViewController alloc] initFromType:fromContact contactModel:currentItem.employeeInfo canEditable:YES isEnterprise:YES];
        if (_haveChangeFrame) {
            if (_didSelectedBlock) {
                _didSelectedBlock(currentItem.employeeInfo, indexPath, v);
            }
            return;
        }
        [self.navigationController pushViewController:v animated:YES];
        
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
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

#pragma mark - Refresh delegate

- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [self synEnterpriseContacts];
}

- (void)configureContactTableViewCellWithModel:(id)model cell:(id)cell indexPath:(NSIndexPath *)indexPath {
    if ([cell isMemberOfClass:[MCEnterpriseBranchCell class]]) {
        [cell configureCellWithBranchItem:model];
    }
    if ([cell isMemberOfClass:[MCEnterpriseEmplyoeeCell class]]) {
        [cell configureCellWithEmplyoeeItem:model];
    }
    if ([cell isMemberOfClass:[MCContactCell class]]) {
        [cell configureCellWithModel:model];
    }
}


- (void)leftNavigationBarButtonItemAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightNavigationBarButtonItemAction:(id)sender {
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    MCEnterpriseSearchViewController *v = [[MCEnterpriseSearchViewController alloc] initWithEisFlag:_eisFlag];
    MCBaseNavigationViewController *navigationController = [[MCBaseNavigationViewController alloc]initWithRootViewController:v];
    [self.navigationController presentViewController:navigationController animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
