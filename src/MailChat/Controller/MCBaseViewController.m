//
//  MCBaseViewController.m
//  NPushMail
//
//  Created by zhang on 15/12/23.
//  Copyright © 2015年 sprite. All rights reserved.
//


#import "MCBaseViewController.h"
#import "MCAppDelegate.h"
#import "NSString+Extension.h"
#import "MCNotificationCenter.h"
#import "MobClick.h"
#import "UIView+MCExpand.h"
#import "MCAccountManager.h"
#import "MCContactManager.h"
#import "MCLoginMainViewController.h"
#import "MCBaseNavigationViewController.h"
#import "UIActionSheet+Blocks.h"

@interface MCBaseViewController ()<UIGestureRecognizerDelegate>
@property (nonatomic, assign) BOOL downViewIsShow;
@property (nonatomic,assign) CGFloat angle;
@end

@implementation MCBaseViewController{
    NetworkStatus oldNetWorkStatus;
    NetworkStatus currentNetWorkStatus;
    NSString *_previousAccountName;//切换账号时的上一个账号
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _loginManager = [MCLoginManager new];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
   self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self.changeAccountArrow setHidden:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = AppStatus.theme.backgroundColor;
    _previousAccountName = AppStatus.currentUser.email;
    [self setUpNavigationBarItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mcAccountDidChange:) name:MCNotificationDidChangeAccount object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mcAccountDidChange:) name:MCNotificationDidLogoutOtherAccount object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
}

- (void)setUpNavigationBarItem {
    
    _leftNavigationBarButtonItem = [[UIBarButtonItem alloc]init];
    [_leftNavigationBarButtonItem setTarget:self];
    [_leftNavigationBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0],NSForegroundColorAttributeName:AppStatus.theme.navgationBarTitleTextColor} forState:UIControlStateNormal];
    _leftNavigationBarButtonItem.imageInsets = UIEdgeInsetsMake(0, -5, 0, 0);
    [_leftNavigationBarButtonItem setTitlePositionAdjustment:UIOffsetMake(5, 0) forBarMetrics:UIBarMetricsDefault];
    _leftNavigationBarButtonItem.image  = [AppStatus.theme.commonBackImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [_leftNavigationBarButtonItem setAction:@selector(leftNavigationBarButtonItemAction:)];
    
    _rightNavigationBarButtonItem = [[UIBarButtonItem alloc]init];
    [_rightNavigationBarButtonItem setTarget:self];
    [_rightNavigationBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0],NSForegroundColorAttributeName:AppStatus.theme.navgationBarTitleTextColor} forState:UIControlStateNormal];
    [_rightNavigationBarButtonItem setTitlePositionAdjustment:UIOffsetMake(-5, 0) forBarMetrics:UIBarMetricsDefault];
    _rightNavigationBarButtonItem.imageInsets = UIEdgeInsetsMake(0, -5, 0, 5);
    [_rightNavigationBarButtonItem setAction:@selector(rightNavigationBarButtonItemAction:)];
    
    self.navigationItem.leftBarButtonItem = _leftNavigationBarButtonItem;
    self.navigationItem.rightBarButtonItem = _rightNavigationBarButtonItem;
    self.navigationItem.titleView = self.navigationBarTitleView;
    [self.view bringSubviewToFront:self.navigationController.navigationBar];
}
//添加搜索按钮
- (void)addSearchNavigationBarButtonItem {
    
    _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_searchButton addTarget:self action:@selector(searchNavigationBarButtonItemAction:)
                forControlEvents:UIControlEventTouchUpInside];
    _searchButton.frame = CGRectMake(0, 0, kMCBaseViewNavBarSearchButtonSize, kMCBaseViewNavBarSearchButtonSize);
    _searchNavigationBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_searchButton];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -5;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,_rightNavigationBarButtonItem,negativeSpacer,_searchNavigationBarButtonItem];
    self.navigationBarTitleView.mc_width = kMCBaseViewNavBarTitleViewWidth;
    _currentUserLable.mc_width = kMCBaseViewNavBarTitleViewWidth;
    _navBarTitleLable.mc_width = kMCBaseViewNavBarTitleViewWidth;
    self.navigationItem.titleView = nil;
    self.navigationItem.titleView = self.navigationBarTitleView;
    [_rightNavigationBarButtonItem setImageInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [_rightNavigationBarButtonItem setTitlePositionAdjustment:UIOffsetMake(-10, 0) forBarMetrics:UIBarMetricsDefault];
}

- (UIView*)navigationBarTitleView{
    
    if (!_navigationBarTitleView) {
        _navigationBarTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth - 120, kMCBaseViewNavBarTitleViewHight)];
        _navigationBarTitleView.backgroundColor = [UIColor clearColor];
        
        //界面标题
        _navBarTitleLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 8, _navigationBarTitleView.mc_width, kMCBaseViewNavBarTitleHight)];
        _navBarTitleLable.font = [UIFont boldSystemFontOfSize:kMCBaseViewNavBarTitleFont];
        _navBarTitleLable.textAlignment = NSTextAlignmentCenter;
        _navBarTitleLable.backgroundColor = [UIColor clearColor];
        _navBarTitleLable.textColor = AppStatus.theme.navgationBarTitleTextColor;
        [_navigationBarTitleView addSubview:_navBarTitleLable];
        
        _indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.indicatorView.frame = CGRectMake(0, 2, kMCBaseViewIndicatorViewSize, kMCBaseViewIndicatorViewSize);
        [_navigationBarTitleView addSubview:_indicatorView];
        //当前用户标题
        _currentUserLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 24, _navigationBarTitleView.mc_width, kMCBaseViewCurrentUserLableHight)];
        _currentUserLable.backgroundColor = [UIColor clearColor];
        _currentUserLable.lineBreakMode = NSLineBreakByTruncatingMiddle; //账号过长省略中间
        _currentUserLable.font = [UIFont systemFontOfSize:kMCBaseViewCurrentUserLableFont];
        _currentUserLable.text = [AppStatus.currentUser.email isEmail]?AppStatus.currentUser.email:PMLocalizedStringWithKey(@"Anonymous");
        _currentUserLable.textColor = AppStatus.theme.navgationBarTitleTextColor;
        _currentUserLable.textAlignment = NSTextAlignmentCenter;
        [_navigationBarTitleView addSubview:_currentUserLable];
    }
    
    return _navigationBarTitleView;
}

//多账号页面相关调整
- (void)addRootViewSearchNavigationBarButtonItem {
    [self setCurrentUserLabelFrame];
}

- (void)setRootCtrlNavigationBarTitleView {
    [self setCurrentUserLabelFrame];
}

- (void)setCurrentUserLabelFrame {
    CGSize size = [AppStatus.currentUser.email mcStringSizeWithFont:kMCBaseViewCurrentUserLableFont maxWidth:(ScreenWidth - 150) maxHight:kMCBaseViewCurrentUserLableHight];
    _currentUserLable.frame = CGRectMake((_navigationBarTitleView.mc_width - size.width)/2, 24, size.width, kMCBaseViewCurrentUserLableHight);
    self.changeAccountArrow.frame = CGRectMake(CGRectGetMaxX(_currentUserLable.frame) + 5, 32, 8, 4);
    self.changeAccountBtn.frame = CGRectMake(0, 0, CGRectGetWidth(_navigationBarTitleView.frame), CGRectGetHeight(_navigationBarTitleView.frame));
}

- (UIImageView *)changeAccountArrow {
    if (!_changeAccountArrow) {
        _changeAccountArrow = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_currentUserLable.frame) + 5, 32, 8, 4)];
        _changeAccountArrow.image = [UIImage imageNamed:@"changeAccountArrow.png"];
        _changeAccountArrow.transform = CGAffineTransformMakeRotation(0);
        self.angle = M_PI;
        [_navigationBarTitleView addSubview:_changeAccountArrow];
    }
    return _changeAccountArrow;
}

- (MCDownMenuView *)changeAccountDownView {
    if (!_changeAccountDownView) {
        __weak MCBaseViewController *weakSelf = self;
        NSArray *accounts = [[MCAccountManager shared] getAllAccounts];
        CGFloat height = accounts.count * 49 + 40;
        if (height > (ScreenHeigth - NAVIGATIONBARHIGHT)) {
            height = ScreenHeigth - NAVIGATIONBARHIGHT;
        }
        CGRect frame = CGRectMake(0, NAVIGATIONBARHIGHT, ScreenWidth, height);
        _changeAccountDownView = [[MCDownMenuView alloc] initWithFrame:frame dataArray:accounts selectedMenuBlock:^(id obj, NSIndexPath *index) {
            MCAccount *act = (MCAccount *)obj;
            weakSelf.downViewIsShow = !weakSelf.downViewIsShow;
            DDLogInfo(@"%@", act.email);
            if ([act.email isEqualToString:AppStatus.currentUser.email]) {
                return;
            }
            //友盟统计
            [MCUmengManager addEventWithKey:mc_me_change];
            [weakSelf.loginManager loginWithAccount:act];
            
        } cellIdentifier:@"MCTopAccountInfoCell"];
        _changeAccountDownView.dissMissBlock = ^{
            [weakSelf changeAccountArrowAnimation];
            weakSelf.downViewIsShow = NO;
        };
        _changeAccountDownView.addAccountBlock = ^{
            //友盟统计
            [MCUmengManager addEventWithKey:mc_me_add];
            weakSelf.downViewIsShow = NO;
            MCLoginMainViewController *mCLoginMainViewController = [[MCLoginMainViewController alloc]init];
            mCLoginMainViewController.mcLoginPopType = MCLoginPopOptionCanPop;
            MCBaseNavigationViewController *navigationController = [[MCBaseNavigationViewController alloc]initWithRootViewController:mCLoginMainViewController];
            [weakSelf presentViewController:navigationController animated:YES completion:nil];
        };
        _changeAccountDownView.delteAccountBlock = ^(MCAccount *act){
            [weakSelf loginOutAccount:act];
            weakSelf.downViewIsShow = NO;
        };
        [_changeAccountDownView setUpTableViewInWindow];
    }
    return _changeAccountDownView;
}

- (UIButton *)changeAccountBtn {
    if (!_changeAccountBtn) {
        _changeAccountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeAccountBtn.frame = CGRectMake(0, 0, CGRectGetWidth(_navigationBarTitleView.frame), CGRectGetHeight(_navigationBarTitleView.frame));
        [_changeAccountBtn addTarget:self action:@selector(changeAccountAction) forControlEvents:UIControlEventTouchUpInside];
        [_navigationBarTitleView addSubview:self.changeAccountBtn];
    }
    return _changeAccountBtn;
}

- (void)changeAccountAction {
    self.downViewIsShow = YES;
    [self changeAccountArrowAnimation];
    [self.changeAccountDownView showInWindow];
}

- (void)changeAccountArrowAnimation {
    __weak MCBaseViewController *weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.changeAccountArrow.transform = CGAffineTransformMakeRotation(weakSelf.angle);
    } completion:^(BOOL finished) {
        if (weakSelf.angle != 0) {
            weakSelf.angle = 0;
        } else {
            weakSelf.angle = M_PI;
        }
    }];
}

- (void)applicationEnterBackground {
    if (self.downViewIsShow) {
        self.downViewIsShow = NO;
        [self.changeAccountDownView dismissInWindow];
    }
}

#pragma mark-NavigationBarButtonItemActions
- (void)leftNavigationBarButtonItemAction:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightNavigationBarButtonItemAction:(id)sender{
    
}

- (void)searchNavigationBarButtonItemAction:(id)sender{
    
}


#pragma mark - Public
- (void)startAnimationIndicatorView {
    
    CGSize titleSize = [_navBarTitleLable.text mcStringSizeWithFont:kMCBaseViewNavBarTitleFont maxWidth:MAXFLOAT maxHight:kMCBaseViewIndicatorViewSize];
    [_navBarTitleLable moveToX:kMCBaseViewIndicatorViewSize/2];
    CGFloat x = _navBarTitleLable.frame.origin.x+(_navBarTitleLable.frame.size.width/2 - titleSize.width/2-kMCBaseViewIndicatorViewSize);
    [_indicatorView moveToX:x];
    [_indicatorView startAnimating];
}

- (void)stopAnimationInducatorView {
   
    [_navBarTitleLable moveToX:0];
    [_indicatorView stopAnimating];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:[NSString stringWithUTF8String:object_getClassName(self)]];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:[NSString stringWithUTF8String:object_getClassName(self)]];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer{
    //判断是否为rootViewController
    if (self.navigationController && self.navigationController.viewControllers.count == 1) {
        return NO;
    }
    return YES;
}
//TODO:切换账号

- (void)mcAccountDidChange:(NSNotification*)info {
    _currentUserLable.text = AppStatus.currentUser.email;
    [self setCurrentUserLabelFrame];
    NSArray *accounts = [[MCAccountManager shared] getAllAccounts];
    CGFloat height = accounts.count * 49 + 40;
    if (height > (ScreenHeigth - NAVIGATIONBARHIGHT)) {
        height = ScreenHeigth - NAVIGATIONBARHIGHT;
    }
    CGRect frame = CGRectMake(0, NAVIGATIONBARHIGHT, ScreenWidth, height);
    self.changeAccountDownView.originFrame = frame;
    self.changeAccountDownView.frame = CGRectMake(0, NAVIGATIONBARHIGHT, self.changeAccountDownView.frame.size.width, 0);
    self.changeAccountDownView.dataAry = accounts;
}

- (void)loginOutAccount:(MCAccount *)act {
    
    RIButtonItem *sureItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Main_AccountLogout") action:^{
        [SVProgressHUD showWithStatus:PMLocalizedStringWithKey(@"PM_Main_AccountLogoutState") maskType:SVProgressHUDMaskTypeClear];
        //友盟统计
        [MCUmengManager addEventWithKey:mc_me_account_exit];
        __weak typeof(self) weakSelf = self;
        [self.loginManager logoutAccount:act Success:^(id response) {
            [SVProgressHUD dismiss];
            [weakSelf.changeAccountDownView dismissInWindow];
            
            NSNumber *responseNub = (NSNumber*)response;
            BOOL isCurrentUserOut = [responseNub boolValue];
            
            NSArray *accounts = [[MCAccountManager shared] getAllAccounts];
            if (accounts.count == 0) {
                MCLoginMainViewController *mcLoginMainViewController = [[MCLoginMainViewController alloc]init];
                mcLoginMainViewController.mcLoginPopType = MCLoginPopOptionOther;
                MCBaseNavigationViewController *navigationController = [[MCBaseNavigationViewController alloc]initWithRootViewController:mcLoginMainViewController];
                [weakSelf presentViewController:navigationController animated:YES completion:nil];
            } else if (isCurrentUserOut) {
                [weakSelf.loginManager loginWithAccount:accounts[0]];
            } else {
                [MCNotificationCenter postNotification:MCNotificationDidLogoutOtherAccount object:nil];
            }
            
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_Main_AccountLogoutFailure")];
        }];
    }];
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Cancel")];
    NSString *title = [NSString stringWithFormat:@"%@%@",PMLocalizedStringWithKey(@"PM_Main_AccountLogoutOrNot"), act.email];
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:title cancelButtonItem:cancelItem destructiveButtonItem:nil otherButtonItems:sureItem, nil];
    [actionSheet showInView:self.view];
}




@end
