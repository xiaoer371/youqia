//
//  MCMailSignatureViewController.m
//  NPushMail
//
//  Created by zhang on 16/4/13.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCMailSignatureViewController.h"
#import "MCAccountManager.h"
#import "MCSignatureCell.h"
#import "UIAlertView+Blocks.h"
#import "iCarousel.h"
#import "MCSegmentControl.h"
#import "MCAppSetting.h"
@interface MCMailSignatureViewController ()<UITableViewDataSource,UITableViewDelegate,iCarouselDataSource,iCarouselDelegate,MCSignatureCellDelegate>
@property (nonatomic,strong)NSArray *accounts;
@property (nonatomic,strong)UITableView *mcTablView;
@property (nonatomic,strong)UIView *mcSignatureView;
@property (nonatomic,assign)NSInteger currentSenmentTag;
@property (nonatomic,strong)UITextView *signatureTextView;
@property (nonatomic,strong)MCAccountManager *accountManager;
@property (nonatomic,strong)UIView *mcTitleNagationView;
@property (nonatomic,strong)MCSegmentControl *segmentCtrl;

@property (nonatomic,assign)NSInteger priviousSegmentIndex;

@end

const static CGFloat kMCTableViewCellHight = 152.0;
static NSString *const kMCTableViewCellid = @"kMCTableViewCellid";

@implementation MCMailSignatureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _accountManager = [MCAccountManager shared];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _accounts = [_accountManager getAllAccounts];
    [self setUpViews];
    
}
//views
- (void)setUpViews {
    _currentSenmentTag = 0;
    [self.rightNavigationBarButtonItem setTitle:PMLocalizedStringWithKey(@"PM_Msg_GroupNameSave")];
    CGRect frame = CGRectMake(0, 10, ScreenWidth, ScreenHeigth - TOOLBAR_HEIGHT);
    iCarousel*mcCarousel = [[iCarousel alloc] initWithFrame:frame];
    mcCarousel.dataSource = self;
    mcCarousel.delegate = self;
    mcCarousel.decelerationRate = 1.0;
    mcCarousel.scrollSpeed = 1.0;
    mcCarousel.type = iCarouselTypeLinear;
    mcCarousel.pagingEnabled = YES;
    mcCarousel.clipsToBounds = YES;
    mcCarousel.bounceDistance = 0.2;
//    mcCarousel.backgroundColor = [UIColor redColor];
    [self.view addSubview:mcCarousel];
    _priviousSegmentIndex = mcCarousel.currentItemIndex;
    __block typeof(self)weekSelf = self;
    _segmentCtrl = [[MCSegmentControl alloc] initWithFrame: CGRectMake(0, 0, ScreenWidth, TOOLBAR_HEIGHT) Items:@[PMLocalizedStringWithKey(@"PM_Mine_signatureSetEach"),PMLocalizedStringWithKey(@"PM_Mine_signatureSetTogether")] selectedBlock:^(NSInteger index) {
        weekSelf.currentSenmentTag = index;
        [mcCarousel scrollToItemAtIndex:index animated:NO];
        [_mcTablView reloadData];
    }];
    [self.view addSubview:_segmentCtrl];
}

//choose setting type
- (void)unifiedSignature:(UIButton*)sender {
    
    if (sender.tag == _currentSenmentTag) {
        return;
    }
    [self.view endEditing:YES];
    [sender setTitleColor:AppStatus.theme.fontTintColor  forState:UIControlStateNormal];
    UIButton*btn = (UIButton*)[self.view viewWithTag:_currentSenmentTag];
    [btn setTitleColor:AppStatus.theme.tintColor forState:UIControlStateNormal];
    _currentSenmentTag = sender.tag;
    if (_currentSenmentTag == 1) {
        [_mcTablView reloadData];
    }
}

#pragma mark iCarousel Delegate

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return 2;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    switch (index) {
        case 0:{
            return self.mcTablView;
            break;
        }
        case 1: {
            return self.mcSignatureView;
            break;
        }
        default:
            break;
    }
    return nil;
}


- (void)carouselDidScroll:(iCarousel *)carousel{
    if (_segmentCtrl) {
        float offset = carousel.scrollOffset;
        if (offset > 0) {
            [_segmentCtrl moveIndexWithProgress:offset];
            if (carousel.currentItemIndex != _priviousSegmentIndex) {
                _priviousSegmentIndex = carousel.currentItemIndex;
                [_segmentCtrl setCurrentIndex:carousel.currentItemIndex];
            }
        }
    }
}

- (void)carouselDidEndDecelerating:(iCarousel *)carousel{
    if (_segmentCtrl) {
        [_segmentCtrl endMoveIndex:carousel.currentItemIndex];
    }
    self.currentSenmentTag = carousel.currentItemIndex;
}

- (UITableView*)mcTablView {
    
    if (!_mcTablView) {
        _mcTablView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, ScreenWidth, ScreenHeigth - 124)];
        _mcTablView.tableFooterView = [UIView new];
        _mcTablView.backgroundColor = AppStatus.theme.backgroundColor;
        _mcTablView.delegate = self;
        _mcTablView.dataSource = self;
        _mcTablView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _mcTablView.separatorColor = AppStatus.theme.tableViewSeparatorColor;
    }
    return _mcTablView;
}

- (UIView*)mcSignatureView {
    
    if (!_mcSignatureView) {
        _mcSignatureView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, _mcTablView.frame.size.height)];
        _mcSignatureView.backgroundColor = AppStatus.theme.backgroundColor;
        _signatureTextView = [[UITextView alloc]initWithFrame:CGRectMake(0, 27, _mcSignatureView.frame.size.width, 200)];
        _signatureTextView.font = [UIFont systemFontOfSize:15.0f];
        _signatureTextView.text = AppSettings.mcMailAllSignature;
        [_mcSignatureView addSubview:_signatureTextView];
        UIView*line = [[UIView alloc]initWithFrame:CGRectMake(0, _signatureTextView.frame.origin.y, ScreenWidth, 0.5)];
        line.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
        [_mcSignatureView addSubview:line];
        UIView*line2 = [[UIView alloc]initWithFrame:CGRectMake(0, _signatureTextView.frame.origin.y + _signatureTextView.frame.size.height , ScreenWidth, 0.5)];
        line2.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
        [_mcSignatureView addSubview:line2];
    }
    return _mcSignatureView;
}

#pragma mark UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _accounts.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MCSignatureCell*cell = [tableView dequeueReusableCellWithIdentifier:kMCTableViewCellid];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MCSignatureCell" owner:nil options:nil] firstObject];
    }
    cell.delegate = self;
    cell.mcAccount = _accounts[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.separatorInset = UIEdgeInsetsMake(0, -12, 0, 0);
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return kMCTableViewCellHight;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

//TODO:保存签名
- (void)rightNavigationBarButtonItemAction:(id)sender {
    
    if (_currentSenmentTag == 1) {
        //分别设置签名
        RIButtonItem *buttonItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Sure") action:^{
            [self updateSignatureSetUnified:YES];
            //友盟统计
            [MCUmengManager addEventWithKey:mc_me_signature_unify];
        }];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:PMLocalizedStringWithKey(@"PM_Mine_Setting") message:@"是否统一设置" cancelButtonItem:[RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Cancel")] otherButtonItems:buttonItem, nil];
        [alertView show];
        
    } else {
        [self updateSignatureSetUnified:NO];
        //友盟统计
        [MCUmengManager addEventWithKey:mc_me_signature_divide];
    }
}

- (void)updateSignatureSetUnified:(BOOL)isUnified {
    
    for (MCAccount *account in _accounts) {
        //统一设置
        if (isUnified) {
            account.signature = _signatureTextView.text;
        }
        //设置当前账号
        if ([AppStatus.currentUser isEqual:account]) {
            AppStatus.currentUser.signature = account.signature;
        }
        //更新数据
        [_accountManager updateAccount:account];
    }
    if (isUnified) {
        AppSettings.mcMailAllSignature = _signatureTextView.text;
    }
    [SVProgressHUD showSuccessWithStatus:PMLocalizedStringWithKey(@"PM_Common_Save_Success")];
}
//signatureDelegate
- (void)signatureCell:(MCSignatureCell *)signatureCell beginEditting:(UITextView *)textView {
    NSIndexPath *indexPath = [self.mcTablView indexPathForCell:signatureCell];
    
    CGFloat offset = _mcTablView.frame.size.height - (indexPath.row+1) *kMCTableViewCellHight;
    if (offset < 0) {
        offset = 0;
    }
    if (offset - 300 < 0 ) {
        [_mcTablView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 300, 0)];
        [_mcTablView setContentInset:UIEdgeInsetsMake(0, 0, 300, 0)];
        [_mcTablView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}


@end
