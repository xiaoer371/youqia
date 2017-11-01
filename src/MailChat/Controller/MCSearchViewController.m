//
//  MCSearchViewController.m
//  NPushMail
//
//  Created by wuwenyu on 16/8/11.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCSearchViewController.h"
#import "UIView+MJExtension.h"
@interface MCSearchViewController ()

@property(nonatomic, strong) NSArray *scopes;

@end

static const CGFloat scopesBarHeight = 44;

@implementation MCSearchViewController

- (id)initWithScopes:(NSArray *)scopes {
    if (self = [super init]) {
        _scopes = scopes;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.searchBar.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.searchBar.textField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.searchBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = YES;
    [self.leftNavigationBarButtonItem setImage:nil];
    [self.navigationController.navigationBar addSubview:self.searchBar];
    [self setSearchBarAnimation];
    [self.view addSubview:self.mainTableView];
}

- (UITableView *)mainTableView {
    if (!_mainTableView) {
        CGFloat tableOriginY = 0;
        if (_scopes) {
            tableOriginY = scopesBarHeight;
        }
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, tableOriginY, ScreenWidth, ScreenHeigth - NAVIGATIONBARHIGHT - tableOriginY)];
        _mainTableView.delegate = self;
        _mainTableView.backgroundColor = AppStatus.theme.backgroundColor;
        UIView *footerView = [[UIView alloc] init];
        _mainTableView.tableFooterView = footerView;
        _mainTableView.sectionIndexBackgroundColor = [UIColor clearColor];
        _mainTableView.separatorColor = AppStatus.theme.tableViewSeparatorColor;
        _mainTableView.sectionIndexColor = AppStatus.theme.fontTintColor;
    }
    return _mainTableView;
}

- (MCSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[MCSearchBar alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
        _searchBar.placeholder= PMLocalizedStringWithKey(@"PM_Contact_SearchBarPlaceHolder");
        _searchBar.delegate = self;
        [_searchBar setFont:[UIFont systemFontOfSize:14.0f]];
        if (_scopes) {
            if (!_segmentView) {
                _segmentView = [[MCSegmentHeadView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, scopesBarHeight)];
                _segmentView.lineColor = AppStatus.theme.tintColor;
                _segmentView.textSelectedColor = AppStatus.theme.tintColor;
                _segmentView.textNomalColor = AppStatus.theme.fontTintColor;
                _segmentView.delegate = self;
                [_segmentView setDataArray:_scopes];
                [self.view addSubview:_segmentView];
            }
        }
    }
    return _searchBar;
}

- (void)setSearchBarAnimation {
    __weak MCSearchViewController *weakSelf = self;
    [UIView animateWithDuration:0.1 animations:^{
        weakSelf.searchBar.textFieldBgView.mj_x = textFieldBgViewPaddingX - textFieldAnimationOffsetX;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2
                         animations:^{
                             weakSelf.searchBar.textFieldBgView.mj_x = textFieldBgViewPaddingX;
                         } completion:^(BOOL finished) {
                         }];
        
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MCSearchBarDelegate
-(BOOL)searchBarShouldBeginEditing:(MCSearchBar *)searchBar {
    return YES;
}

-(void)searchBarDidBeginEditing:(MCSearchBar *)searchBar {
    
}

-(BOOL)searchBarShouldEndEditing:(MCSearchBar *)searchBar {
    return YES;
}

-(void)searchBarDidEndEditing:(MCSearchBar *)searchBar {
    
}

-(void)searchBar:(MCSearchBar *)searchBar textDidChange:(NSString *)searchText {
    
}

-(void)searchBarSearchAction:(MCSearchBar *)searchBar {
    
}

-(void)searchBarCancelAction:(MCSearchBar *)searchBar {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)scrollViewWillBeginDragging:(UITableView *)scrollView {
    [self.searchBar.textField resignFirstResponder];
}

#pragma mark - scopes 点击回调
- (void)selectedIndex:(NSInteger)index {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
