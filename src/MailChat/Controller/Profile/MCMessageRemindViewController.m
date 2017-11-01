//
//  MCMessageRemindViewController.m
//  NPushMail
//
//  Created by zhang on 16/4/13.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCMessageRemindViewController.h"
#import "MCAlertSettingCellDataSource.h"
#import "MCGestureManagerCell.h"
#import "MCAlertHelpView.h"
#import "MCPlaceHolderTextView.h"
#import "MCAccountConfig.h"
#import "MCAppSetting.h"
#import "MCAccountManager.h"
#import "MCNotificationAccountCell.h"
#import "MCNoticeSetViewController.h"
#import "MCApnsPush.h"

@interface MCMessageRemindViewController ()<UITableViewDelegate> {
    UITableView *_tableView;
    NSMutableArray* _titleAry;
    MCAlertSettingCellDataSource *_dataSource;
}

@end

static const CGFloat sectionFooterViewHeight = 80;

@implementation MCMessageRemindViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _titleAry = [NSMutableArray new];
    self.viewTitle = PMLocalizedStringWithKey(@"PM_Mine_NewMailAlert");
    [self loadDataSource];
    [self initSubViews];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:[UIApplication sharedApplication]];
    
    
}

- (void)applicationWillEnterForeground
{
    [self loadDataSource];
    [_tableView reloadData];
}


- (void)initSubViews {
    ContactCellConfigureBlock tableViewConfigureBlock = ^(id model, id cell, NSIndexPath *indexPath) {
        if ([cell isMemberOfClass:[MCGestureManagerCell class]]) {
            [cell configureApnsRemindCellWithTitle:model index:indexPath email:nil];
        }
    };
    _dataSource = [[MCAlertSettingCellDataSource alloc] initWithContactModels:_titleAry contactCellIdentifier:@"MCGestureManagerCell" configureCellBlock:tableViewConfigureBlock];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeigth - NAVIGATIONBARHIGHT)  style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.backgroundColor = AppStatus.theme.backgroundColor;
    _tableView.dataSource = _dataSource;
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.separatorColor = AppStatus.theme.tableViewSeparatorColor;
    [_tableView registerNib:[UINib nibWithNibName:@"MCGestureManagerCell" bundle:nil] forCellReuseIdentifier:@"MCGestureManagerCell"];
    
    [_tableView registerNib:[UINib nibWithNibName:@"MCNotificationAccountCell" bundle:nil] forCellReuseIdentifier:@"SetAccountNotice"];
    [self.view addSubview:_tableView];
    
    MCAlertHelpView *headerView = [[MCAlertHelpView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 86)];
    headerView.backgroundColor = AppStatus.theme.backgroundColor;
    _tableView.tableHeaderView = headerView;

}

- (void)loadDataSource {
    
    MCAlertHelpView *headerView  = (MCAlertHelpView*)_tableView.tableHeaderView;
    [headerView refreshsubLabelText];
    
    if ([[[UIApplication sharedApplication] currentUserNotificationSettings] types] == UIUserNotificationTypeNone) {
        [_titleAry removeAllObjects];
        return;
    }
    
    if (_titleAry.count < 1) {
        
        NSArray *array;
        NSArray *accounts = [[MCAccountManager shared] getAllAccounts];
        BOOL oaUserExist = NO;
        for (MCAccount *account in accounts) {
            if ([MCApnsPush isOaUserWithEmail:account.email]) {
                oaUserExist = YES;
                break;
            }
        }
        if (oaUserExist) {
            array =@[PMLocalizedStringWithKey(@"PM_Mine_mailPushTitle"),PMLocalizedStringWithKey(@"PM_Mine_msgPushTitle"),PMLocalizedStringWithKey(@"PM_Msg_SetOA_Notice")];

        }else{
            array =@[PMLocalizedStringWithKey(@"PM_Mine_mailPushTitle"),PMLocalizedStringWithKey(@"PM_Mine_msgPushTitle")];
        }
        
        [_titleAry addObject:array];
        if (accounts > 0) {
            [_titleAry addObject:accounts];
        }
    }
}

#pragma mark -   UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (_titleAry.count <1) {
        return 0;
    }
    switch (section) {
        case 0:
        case 1:
            return 50;
            break;
        case 2:
            return 100;
            break;
        default:
            break;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_titleAry.count > 1  && indexPath.section ==1) {
        NSArray *accounts  = _titleAry[1];
        id model =  accounts[indexPath.row];
        if ([model isKindOfClass:[MCAccount class]]) {
            MCAccount *account = (MCAccount *)model;
            MCNoticeSetViewController *vc = [[MCNoticeSetViewController alloc] initWithAccount:account];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if ([[[UIApplication sharedApplication] currentUserNotificationSettings] types] == UIUserNotificationTypeNone) {
        return nil;
    }
    
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, sectionFooterViewHeight)];
    headerView.backgroundColor =AppStatus.theme.backgroundColor;// [UIColor clearColor];
    
    CGFloat height;
    if (section == 2) {
        height = 100;
    }else height = 50;
    
    MCPlaceHolderTextView* mTextView = [[MCPlaceHolderTextView alloc]initWithFrame:CGRectMake(7.5, 0, ScreenWidth-15, height)];
    mTextView.editable = NO;
    mTextView.backgroundColor =AppStatus.theme.backgroundColor;// [UIColor clearColor];
    mTextView.font = [UIFont systemFontOfSize:14];
    switch (section) {
        case 0:
            mTextView.text = PMLocalizedStringWithKey(@"PM_Main_Push_Msg_Close_Notice");
            break;
        case 1:
            mTextView.text = PMLocalizedStringWithKey(@"PM_Push_Account_Set");
            break;
        case 2:
            mTextView.text = PMLocalizedStringWithKey(@"PM_Main_Push_ShowDetail_Close_Notice");
            break;
        default:
            break;
    }
    mTextView.textColor = AppStatus.theme.fontTintColor;
    [headerView addSubview:mTextView];
    return headerView;
}

- (void)leftNavigationBarButtonItemAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
