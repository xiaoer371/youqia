//
//  MCContactSearchViewController.m
//  NPushMail
//
//  Created by wuwenyu on 16/8/11.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCContactSearchViewController.h"
#import "MCCellDataSource.h"
#import "MCContactCell.h"
#import "MCContactModel.h"
#import "MCContactInfoViewController.h"
#import "MCContactManager.h"

@interface MCContactSearchViewController ()
@property(nonatomic, strong) NSMutableArray *searchRusltArray;
@end

@implementation MCContactSearchViewController {
    MCCellDataSource *_dataSource;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //刷新搜索结果
    [self searchBar:self.searchBar textDidChange:self.searchBar.textField.text];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSubViews];
}

- (void)initSubViews {
    _searchRusltArray = [NSMutableArray arrayWithCapacity:0];
    [self.mainTableView registerNib:[UINib nibWithNibName:@"MCContactCell" bundle:nil] forCellReuseIdentifier:@"MCContactCell"];
    TableViewCellConfigureBlock configureSearchCell = ^(MCContactCell *cell, MCContactModel *model, NSIndexPath *indexPath) {
        [cell configureCellWithModel:model];
    };
    _dataSource = [[MCCellDataSource alloc] initWithModels:_searchRusltArray cellIdentifier:@"MCContactCell" configureCellBlock:configureSearchCell];
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
    MCContactModel *model = _searchRusltArray[indexPath.row];
    MCContactInfoViewController *v = [[MCContactInfoViewController alloc] initFromType:fromContact contactModel:model canEditable:YES isEnterprise:model.isCompanyUser];
    [self.navigationController pushViewController:v animated:YES];
}

-(void)searchBar:(MCSearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSString *searchStr = [searchText trim];
    __weak MCContactSearchViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray* contacts = [[MCContactManager sharedInstance] getContacts];
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF.account contains[c] %@ or SELF.displayName contains[c] %@ or SELF.enterpriseUserName contains[c] %@", searchStr, searchStr, searchStr];
        NSArray* ary =[contacts filteredArrayUsingPredicate:predicate];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.searchRusltArray removeAllObjects];
            [weakSelf.searchRusltArray addObjectsFromArray:ary];
            [weakSelf.mainTableView reloadData];
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
