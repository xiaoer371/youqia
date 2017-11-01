//
//  MCFeedBackViewController.m
//  NPushMail
//
//  Created by zhang on 16/4/13.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCFeedBackViewController.h"
#import "MCPlaceHolderTextView.h"
#import "MCStatusBarOverlay.h"
#import "UIActionSheet+Blocks.h"
#import "UIAlertView+Blocks.h"
#import "MCAddAttachmentViewCell.h"
#import "MCAddFileManager.h"
#import "MCMailManager.h"
#import "MCMailAddress.h"
#import "MCTool.h"
#import "MCDeviceHelper.h"
#import "MCAccountManager.h"
const static CGFloat kMCFeedBackViewTitleViewHight = 27.0;
const static CGFloat kMCFeedBackViewFontSize = 15.0;
const static CGFloat kMCFeedBackViewImageSize = 40;
const static CGFloat kMCFeedBackViewSpace = 15.0;
const static CGFloat kMCFeedBackTextViewHight = 190;
static NSString *const kMCFeedBackCollectionViewCellId = @"kMCFeedBackCollectionViewCellId";

@interface MCFeedBackImageCell()

@property (nonatomic,strong)UIImageView*feedBackImageView;
@property (nonatomic,strong)UIImage*feedBackImage;
@end


@implementation MCFeedBackImageCell

- (id)initWithFrame:(CGRect)frame{
    
    if (self == [super initWithFrame:frame]) {
        _feedBackImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kMCFeedBackViewImageSize, kMCFeedBackViewImageSize)];
        [self.contentView addSubview:_feedBackImageView];
    }
    
    return self;
    
}

- (void)setFeedBackImage:(UIImage *)feedBackImage{
    _feedBackImageView.image = feedBackImage;
}

@end




@interface MCFeedBackViewController ()<UITextViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,MCAddFileManagerDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong)MCPlaceHolderTextView *feedBackTextView;
@property (nonatomic,strong)UICollectionView *imageCollectinView;
@property (nonatomic,strong)UIView * selectActionView;
@property (nonatomic,strong)NSMutableArray *attachments;
@property (nonatomic,strong)MCAddFileManager *addFileManager;
@property (nonatomic,strong)MCMailAttachment *mailchatLogs;
@property (nonatomic,assign)BOOL addImageFinish;
@end

@implementation MCFeedBackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _attachments = [NSMutableArray new];
        _addFileManager = [[MCAddFileManager alloc]initManagerWithDelegate:self];

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _attachments = [NSMutableArray new];
    [self setUp];
}

- (void)setUp {
    [self.rightNavigationBarButtonItem setTitle:[NSString stringWithFormat:@"%@  ",PMLocalizedStringWithKey(@"PM_Mine_FeedBackAction")]];
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeigth - NAVIGATIONBARHIGHT)];
    tableView.backgroundColor = AppStatus.theme.backgroundColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorColor = AppStatus.theme.tableViewSeparatorColor;
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:tableView];
    _addImageFinish = YES;
}

#pragma mark UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"CellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        if (indexPath.section == 0) {
            
            _feedBackTextView = [[MCPlaceHolderTextView alloc]initWithFrame:CGRectMake(kMCFeedBackViewSpace/2, 0, ScreenWidth - kMCFeedBackViewSpace, kMCFeedBackTextViewHight)];
            _feedBackTextView.backgroundColor = [UIColor clearColor];
            _feedBackTextView.font = [UIFont systemFontOfSize:kMCFeedBackViewFontSize];
            _feedBackTextView.placeholder = PMLocalizedStringWithKey(@"PM_Mine_Suggestions_PlaceHolder");
            _feedBackTextView.placeHoderColor = AppStatus.theme.fontTintColor;
            _feedBackTextView.delegate = self;
            [cell addSubview:_feedBackTextView];
            
        } else {
            
            UICollectionViewFlowLayout *lay=[[UICollectionViewFlowLayout alloc] init];
            lay.itemSize = CGSizeMake(kMCFeedBackViewImageSize,kMCFeedBackViewImageSize);
            lay.minimumInteritemSpacing = 5.0f;
            lay.minimumLineSpacing = 5.0f;
            lay.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
            lay.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            _imageCollectinView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, kMCFeedBackViewImageSize + 10) collectionViewLayout:lay];
            _imageCollectinView.backgroundColor = [UIColor whiteColor];
            _imageCollectinView.delegate = self;
            _imageCollectinView.dataSource = self;
            [_imageCollectinView registerClass:[MCAddAttachmentViewCell class] forCellWithReuseIdentifier:kMCFeedBackCollectionViewCellId];
            
            UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toSelectImages:)];
            _selectActionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _imageCollectinView.frame.size.width, _imageCollectinView.frame.size.height)];
            _selectActionView.backgroundColor = [UIColor clearColor];
            [_selectActionView addGestureRecognizer:tap];
            [_imageCollectinView  addSubview:_selectActionView];
            [cell addSubview:_imageCollectinView];
            
            
            UIButton*toSelectButton = [UIButton buttonWithType:UIButtonTypeCustom];
            toSelectButton.frame = CGRectMake(ScreenWidth - 110, 0, 110, kMCFeedBackViewImageSize + 10);
            [toSelectButton addTarget:self action:@selector(toSelectImages:) forControlEvents:UIControlEventTouchUpInside];
            [toSelectButton setTitleColor:[UIColor colorWithHexString:@"c3c3c3"] forState:UIControlStateNormal];
            [toSelectButton setTitle:PMLocalizedStringWithKey(@"PM_Mine_FeedBackChooseImage") forState:UIControlStateNormal];
            toSelectButton.titleLabel.font = [UIFont systemFontOfSize:kMCFeedBackViewFontSize];
            [toSelectButton setImage:[UIImage imageNamed:@"cellArror.png"] forState:UIControlStateNormal];
            toSelectButton.imageEdgeInsets = UIEdgeInsetsMake(0, 90, 0, 0);
            [_imageCollectinView addSubview:toSelectButton];
            
        }
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return 190;
    }
    return 50;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, kMCFeedBackViewTitleViewHight)];
    sectionView.backgroundColor = [UIColor clearColor];
    UILabel *sectionTitle = [[UILabel alloc]initWithFrame:CGRectMake(kMCFeedBackViewSpace, 0, ScreenWidth - kMCFeedBackViewSpace, kMCFeedBackViewTitleViewHight)];
    sectionTitle.text =  section ==0 ?PMLocalizedStringWithKey(@"PM_Mine_FeedBackNote"):PMLocalizedStringWithKey(@"PM_Mine_FeedBackImageNote");
    sectionTitle.textColor = AppStatus.theme.fontTintColor;
    sectionTitle.backgroundColor = [UIColor clearColor];
    sectionTitle.font = [UIFont systemFontOfSize:12.0];
    [sectionView addSubview:sectionTitle];
    if (section !=0) {
        UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.5)];
        line1.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
        [sectionView addSubview:line1];
    }
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, sectionView.frame.size.height - 0.5, ScreenWidth, 0.5)];
    line2.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
    [sectionView addSubview:line2];
    
    return sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kMCFeedBackViewTitleViewHight;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat sectionHeaderHeight = kMCFeedBackViewTitleViewHight;
    //固定section 随着cell滚动而滚动
    if (scrollView.contentOffset.y <= sectionHeaderHeight&&scrollView.contentOffset.y >= 0) {
        scrollView.contentInset = UIEdgeInsetsMake(- scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(- sectionHeaderHeight, 0, 0, 0);
    }
}

#pragma mark - UICollectionViewDelegate UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _attachments.count;
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MCAddAttachmentViewCell * cell  = [collectionView dequeueReusableCellWithReuseIdentifier:kMCFeedBackCollectionViewCellId forIndexPath:indexPath];
    cell.mailAttachment = _attachments[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    RIButtonItem *deleteItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Mail_DeleteMail") action:^{
        [_attachments removeObjectAtIndex:indexPath.row];
        [collectionView deleteItemsAtIndexPaths:@[indexPath]];
        [self changeSelectActionViewFrame];
    }];
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil cancelButtonItem:[RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Cancel")] destructiveButtonItem:deleteItem otherButtonItems: nil];
    [actionSheet showInView:self.view];
}

//TODO:选择添加图片
- (void)toSelectImages:(id)sender{

    [self.view endEditing:YES];
    RIButtonItem *photoItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_UUInput_PhotoAlbum") action:^{
        _addFileManager.addFileSource = MCAddFileSourceTypePhotoLibrary;
        [_addFileManager sourceShow];
    }];
    RIButtonItem *cameraItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Login_TakePhoto") action:^{
        _addFileManager.addFileSource = MCAddFileSourceTypeCamera;
        [_addFileManager sourceShow];
    }];
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil cancelButtonItem:[RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Cancel")] destructiveButtonItem:photoItem otherButtonItems:cameraItem, nil];
    [actionSheet showInView:self.view];
}

#pragma mark MCAddFielManagerDelegate

- (void)manager:(MCAddFileManager *)mcAddFileManager didAddFiles:(NSArray *)files finish:(BOOL)finish{

    [_attachments addObjectsFromArray:files];
    [_imageCollectinView reloadData];
    [self changeSelectActionViewFrame];
}

//TODO:feedback
- (void)rightNavigationBarButtonItemAction:(id)sender {
    
    if (_feedBackTextView.text.length == 0) {
        [SVProgressHUD showInfoWithStatus:PMLocalizedStringWithKey(@"PM_Mine_PleaseInputFeedBackContent")];
        return;
    }
    if (!_addImageFinish) {
        return;
    }
    [self.view endEditing:YES];
    //必须键盘完全收起
    [self performSelector:@selector(showFeedBack:) withObject:nil afterDelay:0.68];
}

- (void)sendFeedbackWithLogger:(BOOL)log {
    
    if (log) {
        [_attachments addObject:self.mailchatLogs];
    }
    //友盟统计
    [MCUmengManager addEventWithKey:mc_me_feedback];
    
    MCMailModel *mail = [MCMailModel new];
    MCMailAddress *mailAddress = [MCMailAddress new];
    mailAddress.email = kMailChatHelper;
    mailAddress.name = @"邮洽小助手";
    mail.to = @[mailAddress];
    mail.messageContentHtml = _feedBackTextView.text;
    mail.attachments = _attachments;
    mail.subject = @"feedback";
    
    [MCStatusBarOverlay setAnimation:MCStatusBarOverlayAnimationTypeFromTop];
    [MCStatusBarOverlay showWithMessage:@"" loading:NO animated:YES];
    [MCStatusBarOverlay setProgress:0 animated:NO];
    
    MCMailManager *mailManager = [[MCMailManager alloc] initWithAccount:AppStatus.currentUser];
    [mailManager sendEmailWithMail:mail success:^(id response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MCStatusBarOverlay showSuccessWithMessage:PMLocalizedStringWithKey(@"PM_Mine_FeedBackSuccess") duration:1 animated:YES];
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MCStatusBarOverlay showErrorWithMessage:PMLocalizedStringWithKey(@"PM_Mine_FeedBackFailed") duration:1 animated:YES];
        });
    } progress:^(NSInteger currentProgress, NSInteger maximumProgress) {
        
        CGFloat progress = currentProgress/(CGFloat)maximumProgress;
        progress = progress < 0.3?0.3:progress;
        dispatch_async(dispatch_get_main_queue(), ^{
            [MCStatusBarOverlay setProgress:progress animated:NO];
        });
    }];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)showFeedBack:(id)sender
{
    RIButtonItem *item = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Mail_OptionYes") action:^{
        [self sendFeedbackWithLogger:YES];
    }];
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Mail_OptionNo") action:^{
         [self sendFeedbackWithLogger:NO];
    }];
    
    NSString *fileSize = [[MCTool shared] getFileSizeWithLength:self.mailchatLogs.size];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:PMLocalizedStringWithKey(@"PM_Common_Notice") message:[NSString stringWithFormat:@"%@?\n%@:%@",PMLocalizedStringWithKey(@"PM_Mine_sendFeedBackFile"), PMLocalizedStringWithKey(@"PM_Mine_FileSize"), fileSize]cancelButtonItem:cancelItem otherButtonItems:item, nil];
    [alertView show];
}

//TODO:获取日志
- (MCMailAttachment*)mailchatLogs {
    
    if (!_mailchatLogs) {
       _mailchatLogs = [MCMailAttachment new];
        //写入信息
        [self writeInfoAboutNotifyAndVersion];
        NSArray *array =  [DDLog allLoggers];
        for (id obj in array) {
            if ([obj isKindOfClass:[DDFileLogger class]]) {
                DDFileLogger *fileLogger = (DDFileLogger*)obj;
                DDLogFileInfo *fileInfo = [fileLogger currentLogFileInfo];
                _mailchatLogs.data = [NSData dataWithContentsOfFile:fileInfo.filePath];
                _mailchatLogs.size = _mailchatLogs.data.length;
                _mailchatLogs.name = @"mailchatLog.txt";
                _mailchatLogs.fileExtension = @"txt";
                _mailchatLogs.mimeType = @"text/plain";
                return _mailchatLogs;
            }
        }
    }
    return _mailchatLogs;
}

//TODO:写入版本信息
- (void)writeInfoAboutNotifyAndVersion {
    NSString*versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *notifyInfo ;
    if (EGOVersion_iOS8) {
        if ([[[UIApplication sharedApplication] currentUserNotificationSettings] types] == UIUserNotificationTypeNone) {
            notifyInfo = @"手机设置中消息提醒已关闭";
        } else {
            notifyInfo = @"手机设置中消息提醒已开启";
        }
    }else {
        if (![[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
            notifyInfo = @"手机设置中消息提醒已关闭";
        } else {
            notifyInfo = @"手机设置中消息提醒已开启";
        }
    }
    NSString *systemVersion = [NSString stringWithFormat:@"系统版本号:%@", [UIDevice currentDevice].systemVersion];
    NSString *iphoneModel = [NSString stringWithFormat:@"手机型号:%@", [MCDeviceHelper deviceModelName]];
    NSArray *accounts = [[MCAccountManager shared] getAllAccounts];
    NSString *accountsConfigInfo = @"邮箱账号登录配置:";
    for (MCAccount *account in accounts) {
        if (account.config) {
            accountsConfigInfo = [accountsConfigInfo stringByAppendingFormat:@"\n账号%@\n%@\n", account.email, [account.config toDictionary] ];
        }
    }
    NSString *logInfo = [NSString stringWithFormat:@"当前版本:%@\n通知开启状态:%@\n%@\n%@\n%@",versionString,notifyInfo, systemVersion, iphoneModel, accountsConfigInfo];
    DDLogError(@"%@",logInfo);
}

//private
- (void)changeSelectActionViewFrame{
    [_selectActionView setFrame:CGRectMake(_attachments.count * 45, 0, _imageCollectinView.frame.size.width - _attachments.count * 45, _imageCollectinView.frame.size.height)];
}
@end
