//
//  MCGestuerPassWordViewController.m
//  NPushMail
//
//  Created by zhang on 16/4/13.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCGestuerPassWordViewController.h"
#import "MCGestureManagerCellDataSource.h"
#import "MCGestureManagerCell.h"
#import "MCGestureSetViewController.h"
#import "MCAppSetting.h"
#import "UIAlertView+Blocks.h"
#import "PCCircleViewConst.h"

@interface MCGestuerPassWordViewController () <UITableViewDelegate>

@end

static const CGFloat headerViewHeight = 20;

@implementation MCGestuerPassWordViewController {
    NSMutableArray *_titleAry;
    MCGestureManagerCellDataSource *_dataSource;
    UITableView *_tableView;
    BOOL _gestureOn;
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadDataSource];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSubViews];
    // Do any additional setup after loading the view from its nib.
}

- (void)loadDataSource {
    _gestureOn = AppSettings.gesturePasswordFlag;
    if (_gestureOn) {
        _titleAry = [NSMutableArray arrayWithObjects:@"PM_Mine_SetingTouchId", @"PM_Mine_GesturePassword", @"PM_Mine_Modify_GesturePassword", nil];
    }else {
        _titleAry = [NSMutableArray arrayWithObjects:@"PM_Mine_SetingTouchId", @"PM_Mine_GesturePassword", nil];
    }
    if (_dataSource) {
        _dataSource.titles = _titleAry;
        [_tableView reloadData];
    }
}

- (void)initSubViews {
    __weak MCGestuerPassWordViewController *weakSelf = self;
    ContactCellConfigureBlock tableViewConfigureBlock = ^(id model, id cell, NSIndexPath *indexPath) {
        if ([cell isMemberOfClass:[MCGestureManagerCell class]]) {
            MCGestureManagerCell *gestureCell = (MCGestureManagerCell *)cell;
            [gestureCell configureGestureSettingCellWithTitle:model];
            gestureCell.gestureBlock = ^(BOOL isOn, BOOL needVerificationGesture){
                if (isOn) {
                    MCGestureSetViewController *v = [[MCGestureSetViewController alloc] initWithCtrlType:GestureViewControllerTypeSetting];
                    [weakSelf.navigationController pushViewController:v animated:YES];
                }else {
                    if (needVerificationGesture) {
                        //关闭手势,先验证手势密码，验证完成后关闭并直接清空手势密码设置
                        MCGestureSetViewController *gestureVc = [[MCGestureSetViewController alloc] initWithCtrlType:GestureViewControllerTypeVerify];
                        gestureVc.verifyBlock = ^(BOOL result) {
                            if (result) {
                                [PCCircleViewConst saveGesture:nil Key:gestureOneSaveKey];
                                [PCCircleViewConst saveGesture:nil Key:gestureFinalSaveKey];
                                AppSettings.gesturePasswordFlag = NO;
                            }
                            [weakSelf loadDataSource];
                        };
                        [weakSelf.navigationController pushViewController:gestureVc animated:YES];
                    }else {
                        [weakSelf loadDataSource];
                    }
                }
            };
            gestureCell.touchIdSetResultBlock = ^(BOOL success) {
                [weakSelf loadDataSource];
            };
        }
    };
    _dataSource = [[MCGestureManagerCellDataSource alloc] initWithContactModels:_titleAry contactCellIdentifier:@"MCGestureManagerCell" configureCellBlock:tableViewConfigureBlock];
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, CGRectGetHeight(self.view.frame) - NAVIGATIONBARHIGHT)];
    _tableView.delegate = self;
    _tableView.backgroundColor = AppStatus.theme.backgroundColor;
    _tableView.dataSource = _dataSource;
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    _tableView.separatorColor = AppStatus.theme.tableViewSeparatorColor;
    _tableView.sectionIndexColor = [UIColor colorWithHexString:@"aaaaaa"];
    [_tableView registerNib:[UINib nibWithNibName:@"MCGestureManagerCell" bundle:nil] forCellReuseIdentifier:@"MCGestureManagerCell"];
    [self.view addSubview:_tableView];
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, headerViewHeight)];
    headerView.backgroundColor = AppStatus.theme.backgroundColor;
    _tableView.tableHeaderView = headerView;
}

#pragma mark -   UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = [_dataSource modelAtIndexPath:indexPath];
    if ([title isEqualToString:@"PM_Mine_Modify_GesturePassword"]) {
        //修改手势密码
        MCGestureSetViewController *v = [[MCGestureSetViewController alloc] initWithCtrlType:GestureViewControllerTypeModify];
        [self.navigationController pushViewController:v animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
