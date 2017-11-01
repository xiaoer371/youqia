//
//  MCUserInfoViewController.m
//  NPushMail
//
//  Created by zhang on 16/4/13.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCUserInfoViewController.h"
#import "MCAccountInfoCell.h"
#import "MCAccountConfig.h"
#import "MCAddFileManager.h"
#import "UIActionSheet+Blocks.h"
#import "UIAlertView+Blocks.h"
#import "MCMailAttachment.h"
#import "MCServerViewController.h"
#import "MCAccountManager.h"
#import "MCContactManager.h"
#import "MCLoginMainViewController.h"
#import "MCBaseNavigationViewController.h"
#import "MCNickChangeViewController.h"
#import "MCWorkSpaceManager.h"
#import "MCNotificationCenter.h"
#import "MCGmailAuth.h"
#import "MCGmailLoginViewController.h"
#import "OIDWebViewController.h"
#import "MCLoginMainViewController.h"
#import "MCProfileViewController.h"
@interface MCUserInfoViewController () <UITableViewDataSource,UITableViewDelegate,MCAddFileManagerDelegate>

@property (nonatomic,strong) UITableView *mcAcountInfoTableView;
@property (nonatomic,strong) MCAccount   *account;
@property (nonatomic,strong) NSArray     *titles;
@property (nonatomic,strong) MCAddFileManager *addFileManager;
@property (nonatomic,strong) MCAccountConfig *accountCofig;
@property(nonatomic, readonly, nullable) MCGmailLoginViewController *gmailLoginViewController;
@end


static NSString *const  kMCUserInfoTablViewCellId = @"kMCUserInfoTablViewCellId";
const static NSInteger  kMCUserInfoTableViewCellSecionCount = 2;
const static CGFloat    kMCUserInfoTableViewFootViewMarge = 16;
@implementation MCUserInfoViewController

- (id)initWithAccout:(MCAccount*)account {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _account = account;
        _accountCofig = [[MCAccountConfig alloc]initWithAccount:account];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewTitle = _account.email;
    _mcAcountInfoTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeigth - NAVIGATIONBARHIGHT)];
    _mcAcountInfoTableView.tableFooterView = [self tableViewFootView];
    _mcAcountInfoTableView.delegate = self;
    _mcAcountInfoTableView.dataSource = self;
    [_mcAcountInfoTableView registerClass:[MCAccountInfoCell class] forCellReuseIdentifier:kMCUserInfoTablViewCellId];
    _mcAcountInfoTableView.separatorColor = AppStatus.theme.tableViewSeparatorColor;
    _mcAcountInfoTableView.backgroundColor = AppStatus.theme.backgroundColor;
    [self.view addSubview:_mcAcountInfoTableView];
}

- (UIView*)tableViewFootView {
    UIView *tableViewFootView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 76.0f)];
    tableViewFootView.backgroundColor = AppStatus.theme.backgroundColor;
    UIButton *loginOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginOutButton.frame = CGRectMake(kMCUserInfoTableViewFootViewMarge, kMCUserInfoTableViewFootViewMarge, tableViewFootView.frame.size.width - kMCUserInfoTableViewFootViewMarge*2, tableViewFootView.frame.size.height - kMCUserInfoTableViewFootViewMarge*2);
    [loginOutButton setTitle:PMLocalizedStringWithKey(@"PM_Mine_ExitCurrentAccount") forState:UIControlStateNormal];
    [loginOutButton addTarget:self action:@selector(loginOutAccountAction:) forControlEvents:UIControlEventTouchUpInside];
    loginOutButton.layer.cornerRadius = 3.0f;
    [loginOutButton setBackgroundColor:[UIColor colorWithHexString:@"f54e46"]];
    [tableViewFootView addSubview:loginOutButton];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.5)];
    line.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
    [tableViewFootView addSubview:line];
    return tableViewFootView;
}

#pragma mark - UITableViewDelegate UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kMCUserInfoTableViewCellSecionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    return 2;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MCAccountInfoCell *cell;
    
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"MCAccountInfoCell" owner:nil options:nil];
    if (indexPath.section == 0) {
        cell = array[indexPath.row];
        cell.title = self.titles[indexPath.row];
        cell.account = _account;
    } else {
        
        if (indexPath.row == 0 ) {
            cell = array[2];
            BOOL ccSelf = self.accountCofig.ccForYourself;
            cell.mcSwitch.on = ccSelf;
            __weak typeof(self) weekSelf = self;
            cell.mcSwitchONComplete = ^(BOOL on) {
                weekSelf.accountCofig.ccForYourself = on;
            };
            
        } else {
            cell = array[3];
        }
        
        cell.title = self.titles[indexPath.row + 2];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return  cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return  20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && indexPath.section == 0) {
        return 55;
    }
    return 44;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *sectionHeadview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
    sectionHeadview.backgroundColor = [UIColor colorWithHexString:@"f7f7f9"];
    if (section > 0) {
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.5)];
        line.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
        [sectionHeadview addSubview:line];
    }
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, sectionHeadview.frame.size.height - 0.5, ScreenWidth, 0.5)];
    line2.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
    [sectionHeadview addSubview:line2];
    return sectionHeadview;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            _addFileManager = [[MCAddFileManager alloc]initManagerWithDelegate:self];
            __weak typeof(self) weakSelf = self;
            RIButtonItem *photoItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_UUInput_PhotoAlbum") action:^{
                weakSelf.addFileManager.addFileSource = MCAddFileSourceTypePhotoLibrary;
                weakSelf.addFileManager.mcAddFilesManagerImageCount = 1;
                [weakSelf.addFileManager sourceShow];
                //友盟统计
                [MCUmengManager addEventWithKey:mc_me_account_head];
            }];
            RIButtonItem *camareItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Login_TakePhoto") action:^{
                weakSelf.addFileManager.addFileSource = MCAddFileSourceTypeCamera;
                [weakSelf.addFileManager sourceShow];
                //友盟统计
                [MCUmengManager addEventWithKey:mc_me_account_head];
            }];
            UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil cancelButtonItem:[RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Cancel")] destructiveButtonItem:photoItem otherButtonItems: camareItem,nil];
            [actionSheet showInView:self.view];
            
        } else {
            //TODO:昵称修改
            //友盟统计
            [MCUmengManager addEventWithKey:mc_me_account_name];
            MCNickChangeViewController *mcNickChangeViewController = [[MCNickChangeViewController alloc]initNickViewWithAccount:_account];
            [self.navigationController pushViewController:mcNickChangeViewController animated:YES];
        }
        
    } else {
        switch (indexPath.row) {
            case 0://写信抄送自己
            {
                //友盟统计
                [MCUmengManager addEventWithKey:mc_me_account_cc];
            }
                break;
            case 1://服务器配置
            {
                //友盟统计
                [MCUmengManager addEventWithKey:mc_me_account_server];
                
                
                if ([self.account.email containsString:@"gmail.com"]) {
                    [self gotoGmailAuth];
                    return;
                }
                MCServerViewController *mcServerViewController = [[MCServerViewController alloc]initWithAccount:_account];
                MCBaseNavigationViewController *nav = [[MCBaseNavigationViewController alloc]initWithRootViewController:mcServerViewController];
                [self presentViewController:nav animated:YES completion:nil];
            }
                break;
        }
    }
}
#pragma mark - MCAddFileManagerDelegate

- (void)manager:(MCAddFileManager*)mcAddFileManager didAddFiles:(NSArray*)files finish:(BOOL)finish{
    
    MCAccountInfoCell *cell = [_mcAcountInfoTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UIImage *oldImage = cell.mcAvatar.image;
    MCMailAttachment *attachment = [files firstObject];
    cell.mcAvatar.image = attachment.thumbImage;
    
    [SVProgressHUD showWithStatus:PMLocalizedStringWithKey(@"PM_Mine_PostAvatar") maskType:SVProgressHUDMaskTypeClear];
    [[MCAccountManager shared] changeAccount:self.account avatar:attachment.thumbImage success:^{
        MCContactModel *contact = [[MCContactManager sharedInstance] getContactWithEmail:self.account.email];
        if (contact) {
            contact.headChecksum = self.account.avatar;
        }
        [SVProgressHUD showSuccessWithStatus:PMLocalizedStringWithKey(@"PM_Common_Save_Success")];
    } failure:^(NSError *error) {
        cell.mcAvatar.image = oldImage;
        [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_Mine_ChangeAvatarError")];
    }];
}

//TODO:退出账号
- (void)loginOutAccountAction:(UIButton*)sender {
    
    RIButtonItem *sureItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Main_AccountLogout") action:^{
        [SVProgressHUD showWithStatus:PMLocalizedStringWithKey(@"PM_Main_AccountLogoutState") maskType:SVProgressHUDMaskTypeClear];
        //友盟统计
        [MCUmengManager addEventWithKey:mc_me_account_exit];
        __weak typeof(self) weakSelf = self;
        [self.loginManager logoutAccount:_account Success:^(id response) {
            [SVProgressHUD dismiss];
            NSNumber *responseNub = (NSNumber*)response;
            BOOL isCurrentUserOut = [responseNub boolValue];
            NSArray *accounts = [[MCAccountManager shared] getAllAccounts];
            if (accounts.count == 0) {
                MCLoginMainViewController *mcLoginMainViewController = [[MCLoginMainViewController alloc]init];
                mcLoginMainViewController.mcLoginPopType = MCLoginPopOptionOther;
                MCBaseNavigationViewController *navigationController = [[MCBaseNavigationViewController alloc]initWithRootViewController:mcLoginMainViewController];
                [weakSelf presentViewController:navigationController animated:YES completion:nil];
                [weakSelf.navigationController popToRootViewControllerAnimated:NO];
            }
            else if(isCurrentUserOut) {
                [weakSelf.loginManager loginWithAccount:accounts[0]];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            } else {
                [MCNotificationCenter postNotification:MCNotificationDidLogoutOtherAccount object:nil];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
            
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_Main_AccountLogoutFailure")];
        }];
    }];
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Cancel")];
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:PMLocalizedStringWithKey(@"PM_Main_AccountLogoutOrNot") cancelButtonItem:cancelItem destructiveButtonItem:nil otherButtonItems:sureItem, nil];
    [actionSheet showInView:self.view];
}

//pravite
- (NSArray*)titles {
    if (!_titles) {
        _titles = @[PMLocalizedStringWithKey(@"PM_Mine_avatorTitle"),
                    PMLocalizedStringWithKey(@"PM_Mine_nameTitle"),
                    PMLocalizedStringWithKey(@"PM_Main_CcToSelf"),
                    PMLocalizedStringWithKey(@"PM_ServerSetting_set")];
    }
    return  _titles;
}

#pragma mark - Gmail

- (void)gotoGmailAuth
{
    MCGmailLoginViewController *gmailLoginViewController = [[MCGmailLoginViewController alloc]init];
    [self.navigationController pushViewController:gmailLoginViewController animated:NO];
}

@end
