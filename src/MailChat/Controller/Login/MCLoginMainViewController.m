//
//  MCLoginMainViewController.m
//  NPushMail
//
//  Created by zhang on 16/1/18.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCLoginMainViewController.h"
#import "MCLoginDetailViewController.h"
#import "MCLoginItemCell.h"
#import "MCAppDelegate.h"
#import "UIView+MCExpand.h"
#import "OIDWebViewController.h"
#import "MCGmailProvider.h"
#import "MCGmailAuth.h"
#import "MCAccountManager.h"
#import "MCAccountConfig.h"
#import "MCGmailLoginViewController.h"
#import "MCBaseNavigationViewController.h"
#import "MCAccountManager.h"
#import "MCAccountConfig.h"
#import "MCContactManager.h"
#import "MCSetAvatorViewController.h"



@class OIDAuthState;
@class OIDServiceConfiguration;

@interface MCLoginMainViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,MCLoginAuthViewControllerDelegate>
@property (nonatomic,strong)UICollectionView *loginCollectionView;
@property (nonatomic,strong)NSArray          *loginItemData;

/// Gmail 登录提示View
@property (nonatomic, strong) ShapeLoadingView *waitView;
@property (nonatomic, strong) UIView  *wView;

@end

static NSString*const kMCLoginMainViewFooterIdentifier = @"kMCLoginMainViewFooterIdentifier";
static NSString*const kMCLoginMainViewCellIdentifier   = @"kMCLoginMainViewCellIdentifier";
const static CGFloat   kMCLoginMainViewCellItemSpace   = 2.5;
///一排3个
const static NSInteger kMCLoginMainViewCellItemCount   = 3;


@implementation MCLoginMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
}

#pragma mark - MCLoginAuthViewControllerDelegate

- (void)authViewController:(UIViewController *)vc didAuthWithAccount:(MCAccount *)account
{
    MCLoginManager *loginManager = [[MCLoginManager alloc] init];
    [loginManager loginWithValidatedAccount:account success:^(id response) {
        //登录成功
        [self loginSuccessAcccount:account];
    } failure:^(NSError *error) {
        
        [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_Login_LoginError")];
        [self.navigationController popToViewController:self animated:YES];
    }];
}

- (void)authViewController:(UIViewController *)vc didFailedWithError:(NSError *)error
{
    [self.navigationController popToViewController:self animated:YES];
    [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_Login_LoginError")];
}

#pragma mark - views
- (void)setUp {
    
    self.viewTitle = PMLocalizedStringWithKey(@"PM_Login_SelectMailLogin");
    UICollectionViewFlowLayout *lay=[[UICollectionViewFlowLayout alloc] init];
    lay.itemSize = CGSizeMake((ScreenWidth - kMCLoginMainViewCellItemSpace)/kMCLoginMainViewCellItemCount,(ScreenWidth - kMCLoginMainViewCellItemSpace)/kMCLoginMainViewCellItemCount);
    lay.minimumInteritemSpacing = 1.0;
    lay.minimumLineSpacing = 1.0;
    _loginCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeigth - NAVIGATIONBARHIGHT) collectionViewLayout:lay];
    _loginCollectionView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
    _loginCollectionView.delegate   = self;
    _loginCollectionView.dataSource = self;
    [_loginCollectionView registerClass:[MCLoginItemCell class] forCellWithReuseIdentifier:kMCLoginMainViewCellIdentifier];
    [_loginCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kMCLoginMainViewFooterIdentifier];
    [self.view addSubview:_loginCollectionView];
    
    //判断是否初始登录
    if (_mcLoginPopType == MCLoginPopOptionCanNotPop ||
        _mcLoginPopType == MCLoginPopOptionOther) {
        self.leftNavigationBarButtonItem.image = nil;
        self.leftNavigationBarButtonItem.title = @"";
        self.leftNavigationBarButtonItem.enabled = NO;
    } else {
        self.leftNavigationBarButtonItem.image = [AppStatus.theme.commonBackImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
}

#pragma mark - UICollectionViewDelegate DataSource
 
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
   return self.loginItemData.count;
    
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MCLoginItemCell*cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMCLoginMainViewCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.itemDictionary = self.loginItemData[indexPath.row];
    cell.googleNote = indexPath.row == 5?YES:NO;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  
    MCMailType mcMailType;
    switch (indexPath.row) {//区分邮箱类型
        case 0:
        case 1:
        {
            mcMailType = MCMailType35_30;
            [MCUmengManager addEventWithKey:mc_login attributes:@{@"type" : @"enterprise"}];
        }break;
        case 2: {
            mcMailType = MCMailTypeOALogin;
            //oa登录入口
            break;
        }
        case 3:
        {
            mcMailType = MCMailTypeQQ;
            [MCUmengManager addEventWithKey:mc_qq_login];
            [MCUmengManager addEventWithKey:mc_login attributes:@{@"type" : @"qq"}];
        }break;
        case 4 :
        {
            mcMailType = MCMailType163;
            [MCUmengManager addEventWithKey:mc_login attributes:@{@"type" : @"163"}];
            
        }break;
        case 5:
        {
            mcMailType  = MCMailTypeGmail;
            [MCUmengManager addEventWithKey:mc_login attributes:@{@"type" : @"gmail"}];
            MCGmailLoginViewController *gmailLoginViewController = [[MCGmailLoginViewController alloc]init];
            gmailLoginViewController.delegate = self;
            [self.navigationController pushViewController:gmailLoginViewController animated:NO];
            return;
        }
            break;
        case 6:mcMailType = MCMailTypeOutlook;break;
        case 7:mcMailType = MCMailTypeUnknown;break;
        case 8:mcMailType = MCMailTypeUnknown;break;
        case 10:mcMailType = MCMailTypeAli;break;
        case 11:mcMailType = MCMailTypeOthers;break;
        case 9:
        {
            mcMailType = MCMailTypeSina;
            [MCUmengManager addEventWithKey:mc_login attributes:@{@"type" : @"sina"}];
        }
            break;
        default:
            mcMailType = MCMailTypeUnknown;
            [MCUmengManager addEventWithKey:mc_login attributes:@{@"type" : @"other"}];
            break;
    }
    MCLoginDetailViewController*mcLoginDetailViewContrller = [[MCLoginDetailViewController alloc]init];
    mcLoginDetailViewContrller.selectIndex = indexPath.row;
    mcLoginDetailViewContrller.emailType = mcMailType;
    [self.navigationController pushViewController:mcLoginDetailViewContrller animated:YES];
}

///data
- (NSArray*)loginItemData {
    
    if (!_loginItemData) {
        _loginItemData = @[@{PMLocalizedStringWithKey(@"PM_MailType_Company"):@"mailItem_15.png"},
                           @{@"35 企业邮箱":@"mailItem_10.png"},
                          @{@"35 OA":@"mailItem_13.png"},
                          @{@"QQ/Foxmail":@"mailItem_03.png"},
                          @{@"126/163/yeah":@"mailItem_01.png"},
                          @{@"Gmail邮箱":@"mailItem_04.png"},
                         // @{@"Yeah邮箱":@"mailItem_05.png"},
                           @{@"Outlook/Hotmail":@"mailItem_09.png"},
                           @{@"189邮箱":@"mailItem_07.png"},
                           @{@"139邮箱":@"mailItem_06.png"},
                           @{@"新浪邮箱":@"mailItem_08.png"},
                           @{@"阿里云邮箱":@"mailItem_14.png"},
//                          @{@"126邮箱":@"mailItem_02.png"},
                          @{PMLocalizedStringWithKey(@"PM_MailType_Other"):@"mailItem_12.png"}];
    }
    return _loginItemData;
}
//back
- (void)leftNavigationBarButtonItemAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
