//
//  MCDebugViewController.m
//  NPushMail
//
//  Created by swhl on 16/7/6.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCDebugViewController.h"
#import "MCAppSetting.h"
#import "OpenUDID+MCMQTTClientId.h"
#import "MCNickChangeViewController.h"

@interface MCDebugViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataRowArray;
@property (nonatomic, strong) NSArray *dataSecArray;
@property (nonatomic) enum MCDDEBUGTYPE type;


@end

@implementation MCDebugViewController

- (instancetype)initWithDebugType:(enum MCDDEBUGTYPE)type
{
    self = [super init];
    if (self) {
        self.type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.viewTitle = @"调试模式";
    
    [self.view addSubview:self.tableView];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSecArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = self.dataRowArray[section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DEBUGCell" forIndexPath:indexPath];
    if (self.type ==MCDDEBUGTYPE_35Mail) {
        if (indexPath.section  ==0) {
            [self serverSetting:cell indexPath:indexPath];
        }else if(indexPath.section == 2){
            /// oa  代理服务器设置
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if(indexPath.section == 3 /*联系人权重*/){
            if (AppSettings.showWeight) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }else cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }else{
        
        if (indexPath.section == 1) {
            // oa  代理服务器设置
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    NSArray *array = self.dataRowArray[indexPath.section];
    cell.textLabel.text =array[indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
    label.font = [UIFont systemFontOfSize:13.0f];
    label.textColor = [UIColor lightGrayColor];
    label.text = self.dataSecArray[section];
    [aView addSubview:label];
    return aView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (self.type) {
        case MCDDEBUGTYPE_35Mail:
        {
            switch (indexPath.section) {
                case 0:
                {
                    if (indexPath.row ==0) {
                        [AppSettings setIsTestServer:YES];
                    }else{
                        [AppSettings setIsTestServer:NO];
                    }
                    [tableView reloadData];
                    [SVProgressHUD showSuccessWithStatus:@"切换成功，请重启应用"];
                }
                    break;
                case 1:[self clearMQttClientId]; break;
                case 2:[self settingOAProxyServer]; break;
                case 3:[self showAccountWeight:indexPath]; break;
                default:
                    break;
            }
        }
            break;
        case MCDDEBUGTYPE_other:
        {
            switch (indexPath.section) {
                case 0:[self clearMQttClientId];break;
                case 1:[self settingOAProxyServer]; break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}


- (void)serverSetting:(UITableViewCell *)cell indexPath:(NSIndexPath*)indexPath
{
    if (AppSettings.isTestServer) {
        if(indexPath.row == 0){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        if(indexPath.row == 0){
            cell.accessoryType = UITableViewCellAccessoryNone;
        }else cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

- (void)showAccountWeight:(NSIndexPath *)indexPath
{
    [AppSettings setShowWeight:!AppSettings.showWeight];
    [self.tableView reloadData];
    return;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if(AppSettings.showWeight){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else cell.accessoryType = UITableViewCellAccessoryNone;
    
}

- (void)settingOAProxyServer {
    MCNickChangeViewController *mcNickChangeViewController = [[MCNickChangeViewController alloc] initWithAccount:nil settingType:settingOaServer];
    [self.navigationController pushViewController:mcNickChangeViewController animated:YES];
}

- (void)clearMQttClientId
{
    NSString *newClientId = [[OpenUDID uuidThatDifferentEvery] lowercaseString];
    [AppSettings resetClientId:newClientId];
    [SVProgressHUD showSuccessWithStatus:@"清除成功，请重启应用"];
}


-(NSArray *)dataSecArray
{
    if (!_dataSecArray) {
        if (self.type == MCDDEBUGTYPE_35Mail) {
            _dataSecArray  = @[@"当前服务器",@"清理MQTT连接错误",@"OA代理服务器设置",@"联系人权重"];
        }else {
            _dataSecArray = @[@"清理MQTT连接错误", @"OA代理服务器设置"];
        }
    }
    return _dataSecArray;
}

-(NSArray *)dataRowArray
{
    if (!_dataRowArray) {
        
        if (self.type == MCDDEBUGTYPE_35Mail) {
            _dataRowArray  = @[@[@"正式服务器",@"测试服务器"],@[@"清理"],@[@"设置"],@[@"是否显示权重"]];
        }else{
            _dataRowArray = @[@[@"清理"], @[@"设置"]];
        }
    }
    return _dataRowArray;
}

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeigth) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"DEBUGCell"];
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
