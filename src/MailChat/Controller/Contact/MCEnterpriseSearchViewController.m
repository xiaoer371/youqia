//
//  MCEnterpriseSearchViewController.m
//  NPushMail
//
//  Created by wuwenyu on 16/8/20.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCEnterpriseSearchViewController.h"
#import "MCCellDataSource.h"
#import "MCContactCell.h"
#import "MCContactInfoViewController.h"
#import "MCContactManager.h"
#import "MCEnterpriseContactCellItem.h"
#import "MCEnterpriseEmplyoeeCell.h"

@interface MCEnterpriseSearchViewController ()
@property(nonatomic, strong) NSMutableArray *searchRusltArray;
@property(nonatomic, assign) BOOL eisFlag;
@end

@implementation MCEnterpriseSearchViewController {
    MCCellDataSource *_dataSource;
}

- (id)initWithEisFlag:(BOOL)eisFlag {
    if (self = [super init]) {
        self.eisFlag = eisFlag;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSubViews];
    // Do any additional setup after loading the view.
}

- (void)initSubViews {
    _searchRusltArray = [NSMutableArray arrayWithCapacity:0];
    TableViewCellConfigureBlock configureSearchCell = ^(MCEnterpriseEmplyoeeCell *cell, MCEnterpriseContactCellItem *model, NSIndexPath *indexPath) {
        [cell configureCellWithEmplyoeeItem:model];
    };
    NSString *searchCellIdentifier = @"MCEnterpriseEmplyoeeCell";
    if (!_eisFlag) {
        searchCellIdentifier = @"MCContactCell";
        configureSearchCell = ^(MCContactCell *cell, MCContactModel *model, NSIndexPath *indexPath) {
            [cell configureCellWithModel:model];
        };
    }
    _dataSource = [[MCCellDataSource alloc] initWithModels:_searchRusltArray cellIdentifier:searchCellIdentifier configureCellBlock:configureSearchCell];
    [self.mainTableView registerNib:[UINib nibWithNibName:searchCellIdentifier bundle:nil] forCellReuseIdentifier:searchCellIdentifier];
    self.mainTableView.dataSource = _dataSource;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 57;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.searchBar.textField resignFirstResponder];
    id currentModel = [_searchRusltArray objectAtIndex:indexPath.row];
    if ([currentModel isMemberOfClass:[MCContactModel class]]) {
        MCContactInfoViewController *v = [[MCContactInfoViewController alloc] initFromType:fromContact contactModel:currentModel canEditable:YES isEnterprise:YES];
        [self.navigationController pushViewController:v animated:YES];
        
    }else if ([currentModel isMemberOfClass:[MCEnterpriseContactCellItem class]]) {
        MCEnterpriseContactCellItem *item = (MCEnterpriseContactCellItem *)currentModel;
        MCContactInfoViewController *v = [[MCContactInfoViewController alloc] initFromType:fromContact contactModel:item.employeeInfo canEditable:YES isEnterprise:YES];
        [self.navigationController pushViewController:v animated:YES];
    }
}

-(void)searchBar:(MCSearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSString *searchStr = [searchText trim];
    __weak MCEnterpriseSearchViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray* contacts = [NSArray new];
        if (!weakSelf.eisFlag) {
            contacts = [[MCContactManager sharedInstance] getContacts];
        }else {
            contacts = [[MCContactManager sharedInstance] getAllEnterpriseEmployees];
        }
        NSMutableArray *searchAry = [NSMutableArray new];
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF.account contains[c] %@ or SELF.displayName contains[c] %@ or SELF.enterpriseUserName contains[c] %@", searchStr, searchStr, searchStr];
        NSArray* ary =[contacts filteredArrayUsingPredicate:predicate];
        for (MCContactModel * obj in ary) {
            if (!weakSelf.eisFlag) {
                [searchAry addObject:obj];
            }else {
                MCEnterpriseContactCellItem *employeeItem = [[MCEnterpriseContactCellItem alloc] initWithItemType:@"1" parentId:nil branchInfo:nil employeeInfo:obj level:@"1" isOpen:NO];
                employeeItem.emplyoeeItemOriginX = branchItemOriginX;
                if (employeeItem) {
                    [searchAry addObject:employeeItem];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.searchRusltArray removeAllObjects];
            [weakSelf.searchRusltArray addObjectsFromArray:searchAry];
            [weakSelf.mainTableView reloadData];
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
