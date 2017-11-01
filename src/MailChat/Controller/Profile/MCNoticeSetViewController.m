//
//  MCNoticeSetViewController.m
//  NPushMail
//
//  Created by swhl on 16/12/5.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCNoticeSetViewController.h"
#import "MCGestureManagerCell.h"
#import "MCAlertSettingCellDataSource.h"
#import "MCAppSetting.h"
#import "MCAccountConfig.h"
#import "MCApnsPush.h"

@interface MCNoticeSetViewController ()<UITableViewDelegate>

@property (nonatomic, strong) MCAccount  *account;

@property (nonatomic, strong) UITableView  *tableView;

@end

@implementation MCNoticeSetViewController{
    MCAlertSettingCellDataSource *_dataSource;
     NSMutableArray* _titleAry;
}
- (instancetype)initWithAccount:(MCAccount *)account
{
    self = [super init];
    if (self) {
        self.account = account;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _titleAry = [NSMutableArray new];
    self.viewTitle = self.account.email;
    [self loadDataSource];
    [self setUp];
}

- (void)setUp
{
    __weak MCNoticeSetViewController *weakSelf = self;
    ContactCellConfigureBlock tableViewConfigureBlock = ^(id model, id cell, NSIndexPath *indexPath) {
        if ([cell isMemberOfClass:[MCGestureManagerCell class]]) {
            [cell configureApnsRemindCellWithTitle:model index:indexPath email:weakSelf.account.email];
        }
    };
    
    _dataSource = [[MCAlertSettingCellDataSource alloc] initWithContactModels:_titleAry contactCellIdentifier:@"MCGestureManagerCell" configureCellBlock:tableViewConfigureBlock];
    _dataSource.type = MCNoticeAccountSetDetail;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeigth - NAVIGATIONBARHIGHT)  style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.backgroundColor = AppStatus.theme.backgroundColor;
    _tableView.dataSource = _dataSource;
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.separatorColor = AppStatus.theme.tableViewSeparatorColor;
    [_tableView registerNib:[UINib nibWithNibName:@"MCGestureManagerCell" bundle:nil] forCellReuseIdentifier:@"MCGestureManagerCell"];
    [self.view addSubview:_tableView];
    
}

- (void)loadDataSource {
    
    if ([[[UIApplication sharedApplication] currentUserNotificationSettings] types] == UIUserNotificationTypeNone) {
        [_titleAry removeAllObjects];
        return;
    }
    
    if (_titleAry.count < 1) {
        
        NSArray *array;
        if ([MCApnsPush isOaUserWithEmail:self.account.email]) {
            array =@[PMLocalizedStringWithKey(@"PM_Mine_mailPushTitle"),PMLocalizedStringWithKey(@"PM_Mine_msgPushTitle"),PMLocalizedStringWithKey(@"PM_Msg_SetOA_Notice")];
        }else{
            array =@[PMLocalizedStringWithKey(@"PM_Mine_mailPushTitle"),PMLocalizedStringWithKey(@"PM_Mine_msgPushTitle")];
        }
        [_titleAry addObject:array];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
