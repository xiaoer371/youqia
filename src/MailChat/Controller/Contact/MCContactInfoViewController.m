//
//  MCContactInfoViewController.m
//  NPushMail
//
//  Created by wuwenyu on 16/1/5.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCContactInfoViewController.h"
#import "MCContactModel.h"
#import "MCContactInfoHeaderView.h"
#import "MCContactInfoBottomView.h"
#import "MCContactInfoDataSource.h"
#import "MCContactInfoCell.h"
#import "MCContactBaseInfo.h"
#import "MCMailComposerViewController.h"
#import "MCIMConversationManager.h"
#import "MCIMChatViewController.h"
#import "MCContactManager.h"
#import "NSString+JSON.h"
#import "MCServerAPI+EIS.h"
#import "MCContactInfoConfig.h"
#import "MCAddContactViewController.h"
#import "MCBaseNavigationViewController.h"
#import "MCIMGroupManager.h"
#import "iCarousel.h"
#import "MCSegmentControl.h"
#import "MCRepealView.h"
#import "MCContactMailsViewController.h"

@interface MCContactInfoViewController ()<UITableViewDelegate, iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, strong) MCContactModel *contactModel;
@property (nonatomic, assign) BOOL canEditable;
@property (nonatomic, assign) lookContactType lookContactType;
@property (nonatomic, strong) MCContactInfoDataSource *tableViewDataSource;
@property (nonatomic, strong) UITableView *contactInfotableView;
@property (nonatomic, strong) UIView *emailstableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) MCContactInfoHeaderView *headerView;
@property (nonatomic, strong) MCContactInfoBottomView *bottomView;
@property (strong, nonatomic) iCarousel *myCarousel;
@property (strong, nonatomic) MCSegmentControl *mySegmentControl;
@property (nonatomic, assign) NSInteger currentSenmentTag;
@property (nonatomic, assign) NSInteger priviousSegmentIndex;
@property (nonatomic, strong) UIButton *leftNaggationBtn;
@property (nonatomic, strong) UIButton *rightNavgationBtn;
@property (nonatomic, assign) BOOL tapRightBtn;
@property (nonatomic, strong) MCRepealView *repealView;

@end

static const CGFloat headerViewHeight = 180;

@implementation MCContactInfoViewController {
    UIImageView *_barImageView;
}

#pragma mark - 初始化
- (id)initFromType:(lookContactType)lookContactType contactModel:(MCContactModel *)model canEditable:(BOOL)canEditable isEnterprise:(BOOL)isEnterprise {
    self = [super init];
    if (self) {
        self.contactModel = model;
        self.lookContactType = lookContactType;
        self.canEditable = canEditable;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDataAndViews];
    [self initNavgationItems];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _contactInfotableView.delegate = self;
    if (self.tapRightBtn) {
        animated = NO;
    }
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    self.tapRightBtn = NO;
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
//                                                  forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.shadowImage = [UIImage new];
    
    if (self.contactModel.deleteFlag) {
        if (!self.contactModel.isCompanyUser) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
    }
    _dataSource = [NSMutableArray arrayWithObject:self.contactModel];
    [_tableViewDataSource loadDataSource];
    [_headerView configureView:self.contactModel];
    [self synContactInfo];
    [_contactInfotableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _contactInfotableView.delegate = nil;
    if (self.tapRightBtn) {
        animated = NO;
        self.navigationController.navigationBar.translucent = YES;
    }
    [self.navigationController setNavigationBarHidden:NO animated:animated];
//    [self.navigationController.navigationBar setBackgroundImage:AppStatus.theme.navbarBgImage
//                                                  forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)initDataAndViews {
    _dataSource = [NSMutableArray arrayWithObject:self.contactModel];
    
    if (self.canEditable) {
        [self.rightNavigationBarButtonItem setTitle:PMLocalizedStringWithKey(@"PM_Contact_Edit")];
    }
    [self loadDataSource];
    [self newDataSourceLoadView];
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.myCarousel];
    [self.view addSubview:self.mySegmentControl];
    [self.view addSubview:self.bottomView];
}

- (void)initNavgationItems {
    _leftNaggationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftNaggationBtn.frame = CGRectMake(-10, 20, 70, 40);
    [_leftNaggationBtn setImage:[AppStatus.theme.commonBackImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [_leftNaggationBtn addTarget:self action:@selector(leftNavigationBarButtonItemAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_leftNaggationBtn];
    
    _rightNavgationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightNavgationBtn.frame = CGRectMake(ScreenWidth - 60, CGRectGetMinY(_leftNaggationBtn.frame) + 5, 60, 40);
    [_rightNavgationBtn setTitle:PMLocalizedStringWithKey(@"PM_Contact_Edit") forState:UIControlStateNormal];
    [_rightNavgationBtn addTarget:self action:@selector(rightNavigationBarButtonItemAction:) forControlEvents:UIControlEventTouchUpInside];
    [[_rightNavgationBtn titleLabel] setFont:[UIFont systemFontOfSize:15.0f]];
    [self.view addSubview:_rightNavgationBtn];
}

- (MCContactInfoHeaderView *)headerView {
    if (_headerView) {
        return _headerView;
    }
    __weak typeof(self) weakSelf = self;
    _headerView = [[MCContactInfoHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, headerViewHeight) showBottomLine:NO importantBlock:^(BOOL important) {
        if (important) {
            weakSelf.repealView.message = PMLocalizedStringWithKey(@"PM_Contact_setImportantAlertMsg");
            weakSelf.repealView.doItemTitle = nil;
            weakSelf.repealView.delaySeconds = 2.0;
            [weakSelf.repealView showWithUndoBlock:^{
            } commitBlock:^{
            }];
        }
    }];
    _headerView.contentMode = UIViewContentModeScaleAspectFill;
    _headerView.autoresizesSubviews = YES;
    return _headerView;
}

- (iCarousel *)myCarousel {
    if (_myCarousel) {
        return _myCarousel;
    }
    _myCarousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.mySegmentControl.frame) - 20, ScreenWidth, ScreenHeigth - CGRectGetMidY(self.mySegmentControl.frame) - TOOLBAR_HEIGHT + 20)];
    _myCarousel.dataSource = self;
    _myCarousel.delegate = self;
    _myCarousel.decelerationRate = 1.0;
    _myCarousel.scrollSpeed = 1.0;
    _myCarousel.type = iCarouselTypeLinear;
    _myCarousel.pagingEnabled = YES;
    _myCarousel.clipsToBounds = YES;
    _myCarousel.bounceDistance = 0.2;
    _myCarousel.currentItemIndex = 0;
    _priviousSegmentIndex = _myCarousel.currentItemIndex;
    return _myCarousel;
}

- (MCSegmentControl *)mySegmentControl {
    if (_mySegmentControl) {
        return _mySegmentControl;
    }
    __block typeof(self)weekSelf = self;
    _mySegmentControl = [[MCSegmentControl alloc] initWithFrame: CGRectMake(0, CGRectGetMaxY(self.headerView.frame), ScreenWidth, 44) Items:@[@"资料", @"往来邮件"] selectedBlock:^(NSInteger index) {
        weekSelf.currentSenmentTag = index;
        [weekSelf.myCarousel scrollToItemAtIndex:index animated:NO];
        if (index == 1) {
            [MCUmengManager addEventWithKey:mc_contact_info_mail];
        }
    }];
    return _mySegmentControl;
}

- (UITableView *)contactInfotableView {
    if (_contactInfotableView) {
        return _contactInfotableView;
    }
    TableViewCellConfigureBlock configureSearchCell = ^(MCContactInfoCell *cell, MCContactModel *model, NSIndexPath *indexPath, NSMutableArray *phones, NSMutableArray *enterpriseContactInfos) {
        [cell configureCellWithModel:model indexPath:indexPath phones:phones enterpriseInfos:enterpriseContactInfos];
    };
    _tableViewDataSource = [[MCContactInfoDataSource alloc] initWithModels:_dataSource cellIdentifier:@"MCContactInfoCell" configureCellBlock:configureSearchCell];
    _contactInfotableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeigth - TOOLBAR_HEIGHT - CGRectGetMaxY(self.mySegmentControl.frame))];
    _contactInfotableView.backgroundColor = AppStatus.theme.backgroundColor;
    _contactInfotableView.dataSource = _tableViewDataSource;
    _contactInfotableView.tableFooterView = [[UIView alloc] init];
    _contactInfotableView.separatorColor = AppStatus.theme.tableViewSeparatorColor;
    _contactInfotableView.sectionIndexBackgroundColor = [UIColor whiteColor];
    _contactInfotableView.sectionIndexColor = [UIColor colorWithHexString:@"aaaaaa"];
    [_contactInfotableView registerNib:[UINib nibWithNibName:@"MCContactInfoCell" bundle:nil] forCellReuseIdentifier:@"MCContactInfoCell"];
    //    _tableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(_headerView.frame), 0, 0, 0);
    return _contactInfotableView;
}

- (UIView *)emailstableView {
    if (!_emailstableView) {
        
        MCContactMailsViewController *contactMailsController = [[MCContactMailsViewController alloc]initWithContact:self.contactModel];
        _emailstableView = contactMailsController.view;
        _emailstableView.frame = CGRectMake(0, 0, ScreenWidth, CGRectGetHeight(self.contactInfotableView.frame));
        [self addChildViewController:contactMailsController];
    }
    return _emailstableView;
}

- (MCContactInfoBottomView *)bottomView {
    if (_bottomView) {
        return _bottomView;
    }
    _bottomView = [[MCContactInfoBottomView alloc] initWithFrame:CGRectMake(0, ScreenHeigth - TOOLBAR_HEIGHT, CGRectGetWidth(self.view.frame), TOOLBAR_HEIGHT)];
    _bottomView.backgroundColor = AppStatus.theme.toolBarBackgroundColor;
    
    __weak typeof(self)weekSelf = self;
    _bottomView.writeMailBlock = ^{
        DDLogDebug(@"写邮件");
        //友盟统计
        
        if ([AppStatus.currentUser.email isEmail]) {
            [MCUmengManager addEventWithKey:mc_contact_info_write];
            MCMailComposerViewController*composerViewController = [[MCMailComposerViewController alloc]initWithContent:weekSelf.contactModel composerType:MCMailComposerNew];
            [weekSelf.navigationController pushViewController:composerViewController animated:YES];
        }else{
            [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_IMChat_UnLogin")];
        }
    };
    _bottomView.sendMsgBlock = ^{
        DDLogDebug(@"发消息");
        //友盟统计
        [MCUmengManager addEventWithKey:mc_contact_info_im];
        if (weekSelf.contactModel.youqiaFlag) {
            [weekSelf sendMessage];
        }else
        {
            [SVProgressHUD showWithStatus:PMLocalizedStringWithKey(@"PM_Contact_SengMsg") maskType:SVProgressHUDMaskTypeNone];
            [[MCIMGroupManager shared] checkUnloginMessage:weekSelf.contactModel.account success:^(id response) {
                [weekSelf sendMessage];
                [SVProgressHUD dismiss];
            } failure:^(NSError *error) {
                [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_Msg_NetWorkError")];
            }];
        }
    };
    return _bottomView;
}

- (MCRepealView *)repealView {
    if (_repealView) {
        return _repealView;
    }
    _repealView = [MCRepealView shared];
    return _repealView;
}

#pragma mark - Actions

- (void)sendMessage
{
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[MCIMChatViewController class]]) {
            MCIMChatViewController *oldVC = (MCIMChatViewController*)vc;
            if ([oldVC.currentUserLable.text isEqualToString:self.contactModel.account]) {
                [oldVC.navigationController.navigationBar setBackgroundImage:AppStatus.theme.navbarBgImage
                                                               forBarMetrics:UIBarMetricsDefault];
                [oldVC resignResponderModifyFrame];
                [self.navigationController popToViewController:oldVC animated:YES];
                return ;
            }
        }
    }
    MCIMConversationModel *conversationModel = [[MCIMConversationManager shared] conversationForContact:self.contactModel];
    MCIMChatViewController *vc =[[MCIMChatViewController alloc] initWithConversationModel:conversationModel];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)synContactInfo {
    __weak MCContactInfoViewController *weakSelf = self;
    NSArray *contactAry = [NSArray arrayWithObject:self.contactModel];
    [[MCContactManager sharedInstance] updatePersonalContacts:contactAry success:^{
        weakSelf.contactModel = [[MCContactManager sharedInstance] getContactWithEmail:weakSelf.contactModel.account];
        [weakSelf.tableViewDataSource loadDataSource];
        [weakSelf.headerView configureView:weakSelf.contactModel];
        [weakSelf.contactInfotableView reloadData];
    } failure:^(NSError *error) {
        DDLogInfo(@"%@",[error description]);
    }];
}

#pragma mark - 加载数据源

- (void)loadDataSource {
    
}

#pragma mark - 界面刷新

- (void)newDataSourceLoadView {
    
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)leftNavigationBarButtonItemAction:(id)sender {
    switch (self.lookContactType) {
        case fromChat:
        case fromOA:
        case fromContact:{
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        case fromReadMail:{
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)rightNavigationBarButtonItemAction:(id)sender {
    self.tapRightBtn = YES;
    MCAddContactViewController *v = [[MCAddContactViewController alloc] initWithContactEditType:editContactInfo contactModel:_contactModel];
    MCBaseNavigationViewController *navigationController = [[MCBaseNavigationViewController alloc]initWithRootViewController:v];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];

}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat y = scrollView.contentOffset.y;
    /*
    if (y  > -200) {
        _barImageView.image = AppStatus.theme.navbarBgImage ;
        self.viewTitle = PMLocalizedStringWithKey(@"PM_Contact_ContactInfo");
    }else {
        _barImageView.image = [UIImage new];
        self.viewTitle = @"";
    }
     */
    if(y < -headerViewHeight)
    {
        CGRect frame = _headerView.frame;
        frame.origin.y = y;
        frame.size.height = -y;
        _headerView.frame=frame;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark iCarousel Delegate

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return 2;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    switch (index) {
        case 0:{
            return self.contactInfotableView;
            break;
        }
        case 1: {
            return self.emailstableView;
            break;
        }
        default:
            break;
    }
    return nil;
}


- (void)carouselDidScroll:(iCarousel *)carousel{
    if (self.mySegmentControl) {
        float offset = carousel.scrollOffset;
        if (offset > 0) {
            [self.mySegmentControl moveIndexWithProgress:offset];
            if (carousel.currentItemIndex != _priviousSegmentIndex) {
                _priviousSegmentIndex = carousel.currentItemIndex;
                [self.mySegmentControl setCurrentIndex:carousel.currentItemIndex];
            }
        }
    }
}

- (void)carouselDidEndDecelerating:(iCarousel *)carousel{
    if (self.mySegmentControl) {
        [self.mySegmentControl endMoveIndex:carousel.currentItemIndex];
    }
    self.currentSenmentTag = carousel.currentItemIndex;
    if (carousel.currentItemIndex == 1) {
         [MCUmengManager addEventWithKey:mc_contact_info_mail];
    }
}

@end
