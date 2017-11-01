//
//  MCMailBoxListView.m
//  NPushMail
//
//  Created by zhang on 15/12/23.
//  Copyright © 2015年 sprite. All rights reserved.
//


#import "MCMailBoxListView.h"
#import "MCMailBoxListCell.h"
#import "MCAppDelegate.h"
#import "MCAvatarHelper.h"
#import "UIImageView+WebCache.h"
#import "FBKVOController.h"
#import "MCAppSetting.h"
#import "MCMailManager.h"
@interface MCMailBoxListView ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>

@property(nonatomic,assign)CGFloat starX;
@property(nonatomic,assign)CGFloat selfStarX;
@property(nonatomic,strong)UITableView *boxListTableView;
@property(nonatomic,strong)MCMailBox   *selectMailBox;
@property(nonatomic,strong)UIView      *mcMaskView;

@property(nonatomic,strong)UILabel *mcNameLabel;
@property(nonatomic,strong)UILabel *mcEmailLabel;
@property(nonatomic,strong)UIImageView *mcAvatarView;

@property(nonatomic,strong)MCMailBox *smartBox;
@property(nonatomic,strong)UIView *sectionFooter;
@property(nonatomic,strong)UIView *sectionSeparator;
@property(nonatomic,assign)BOOL loadImportantMails;

@end

const static CGFloat kMCMailBoxListViewHeadForSection = 140;
const static CGFloat kMCMailBoxListViewCellHight = 49.0;
const static CGFloat kMCMailBoxListViewPand = 45.0;
static NSString *const kMCMailBoxListViewCellIndentifier = @"MCMailBoxListViewCellId";
static NSString *const kMCMailBoxListViewCell = @"MCMailBoxListCell";

@implementation MCMailBoxListView

- (id)init{
    
    if (self = [super init]) {
        [self setUp];
        _folders = [NSMutableArray new];
        _loadImportantMails = AppSettings.loadImportantMails;
    }
    return self;
}

- (void)setUp{
    
    self.frame = CGRectMake(-(ScreenWidth - kMCMailBoxListViewPand)-3 + kMCMailBoxListViewShowSpaceWidth, 0, ScreenWidth - kMCMailBoxListViewPand, ScreenHeigth);
    self.layer.shadowPath =[UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    self.layer.shadowColor = [UIColor grayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(2, 0);
    self.layer.shadowOpacity = 0.3;
    [self addSubview:[self listHeadView]];
    
    _boxListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kMCMailBoxListViewHeadForSection, self.frame.size.width, self.frame.size.height-kMCMailBoxListViewHeadForSection) style:UITableViewStylePlain];
    _boxListTableView.dataSource = self;
    _boxListTableView.delegate = self;
    _boxListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _boxListTableView.backgroundColor = [UIColor whiteColor];
    [_boxListTableView registerNib:[UINib nibWithNibName:kMCMailBoxListViewCell bundle:nil] forCellReuseIdentifier:kMCMailBoxListViewCellIndentifier];
    [self addSubview:_boxListTableView];
    
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self
                                                                                action:@selector(paningGestureReceive:)];
    [recognizer setDelegate:self];
    [recognizer delaysTouchesBegan];
    [self addGestureRecognizer:recognizer];
}

- (UIView*)listHeadView {
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth - 45, kMCMailBoxListViewHeadForSection)];
    view.backgroundColor = [UIColor whiteColor];
    UIImageView *backgroundView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth - 45, kMCMailBoxListViewHeadForSection )];
    backgroundView.image = AppStatus.theme.mailBoxStyle.backgroundImage;
    
    MCAccount *mcAccount = AppStatus.currentUser;
    _mcAvatarView = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenWidth == 320?25:36, 38, 63, 63)];
    _mcAvatarView.clipsToBounds = YES;
    _mcAvatarView.layer.cornerRadius = 63/2;
    _mcAvatarView.layer.borderWidth = 2;
    _mcAvatarView.layer.borderColor = [UIColor whiteColor].CGColor;
    [_mcAvatarView sd_setImageWithURL:[NSURL URLWithString:mcAccount.avatarUrl] placeholderImage:mcAccount.avatarPlaceHolder options:SDWebImageAllowInvalidSSLCertificates];
    
    _mcNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(_mcAvatarView.frame.size.width + _mcAvatarView.frame.origin.x + 11, 51, 120, 19)];
    _mcNameLabel.font = [UIFont systemFontOfSize:17.0];
    _mcNameLabel.textColor = [UIColor whiteColor];
    _mcNameLabel.text = mcAccount.displayName;
    _mcNameLabel.backgroundColor = [UIColor clearColor];
    
    _mcEmailLabel = [[UILabel alloc]initWithFrame:CGRectMake(_mcNameLabel.frame.origin.x, _mcNameLabel.frame.size.height+_mcNameLabel.frame.origin.y + 8, backgroundView.frame.size.width - _mcNameLabel.frame.origin.x - 10, 16)];
    _mcEmailLabel.textColor = [UIColor whiteColor];
    _mcEmailLabel.font = [UIFont systemFontOfSize:14];
    _mcEmailLabel.backgroundColor = [UIColor clearColor];
    _mcEmailLabel.text = mcAccount.email;
    
    [view addSubview:backgroundView];
    [view addSubview:_mcAvatarView];
    [view addSubview:_mcNameLabel];
    [view addSubview:_mcEmailLabel];
    return view;
}


#pragma mark - UITablViewDelegate UITablViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_folders.count == 0) {
        return 0;
    }
    return section == 0?1:_folders.count - 1;
    
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MCMailBoxListCell *cell = [tableView dequeueReusableCellWithIdentifier:kMCMailBoxListViewCellIndentifier];
    
    cell.loadVipMails = self.loadImportantMails;
    MCMailBox *boxModel = indexPath.section == 0?_folders[0]:_folders[indexPath.row +1];
    cell.mailBoxModel = boxModel;
    if (boxModel.selectable) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.loadImportantMails && indexPath.section == 0) {
        return 0;
    }
    return kMCMailBoxListViewCellHight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0 && self.loadImportantMails) {
        if (!_sectionFooter) {
            _sectionFooter = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 20)];
            UIView * sectionSeparator = [[UIView alloc]initWithFrame:CGRectMake(20, 10, CGRectGetWidth(_sectionFooter.frame)- 40, 0.5)];
            sectionSeparator.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
            [_sectionFooter addSubview:sectionSeparator];
        }
        return _sectionFooter;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.loadImportantMails) {
      return section == 0?20:0;
    }
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_delegate respondsToSelector:@selector(mailBoxListView:didSelectMailBox:smartBox:)]) {
        
        MCMailBox *mailbox = indexPath.section == 0?_folders[0]:_folders[indexPath.row +1];
        
        if (!mailbox.selectable) {
            if (indexPath.section == 0) {
                MCMailBox *inbox = _folders[1];
                self.smartBox.unreadCount = inbox.unreadCount;
                [_delegate mailBoxListView:self didSelectMailBox:inbox smartBox:YES];
            } else {
                [_delegate mailBoxListView:self didSelectMailBox:mailbox smartBox:NO];
            }
            _selectMailBox.selectable = NO;
        }
        mailbox.selectable = YES;
        
        //友盟事件添加
        if (indexPath.section == 0) {
            if (_selectMailBox.type == MCMailFolderTypeInbox) {
                [MCUmengManager folderChangeEvent:mc_mail_folder_InboxToSmart];
            } else{
                [MCUmengManager folderChangeEvent:mc_mail_folder_smart];
            }
        } else if (mailbox.type == MCMailFolderTypeInbox) {
            
            if (_selectMailBox.type == MCMailFolderTypeSmartBox) {
                [MCUmengManager folderChangeEvent:mc_mail_folder_SmartToInbox];
            } else {
                [MCUmengManager folderChangeEvent:mc_mail_folder_inbox];
            }
        } else {
            [MCUmengManager folderChangeEvent:mc_mail_folder_other];
        }
        _selectMailBox = mailbox;
        
    }
    self.change = NO;
}

- (void)resetSelectedBox:(MCMailBox*)box {
    box.selectable = YES;
    _selectMailBox.selectable = NO;
    _selectMailBox = box;
}

- (void)setFolders:(NSArray *)folders {
    
    if (!folders ||folders.count == 0) {
        _folders = folders;
        [self reset];
        return;
    }
    [self removeObserver];
    [self setBoxUnreadCountWith:folders];
    NSMutableArray *currentFolders = [folders mutableCopy];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.selectable = %@",@(YES)];
    NSArray * selectBoxArray =[folders filteredArrayUsingPredicate:predicate];
    //插入重要邮件文件夹
    [currentFolders insertObject:self.smartBox atIndex:0];
    if (selectBoxArray.count == 0) {
        MCMailBox *box;
        if (self.loadImportantMails) {
            BOOL selectEnable = AppSettings.smartBoxSelectEnable;
            box = selectEnable?currentFolders[0]:currentFolders[1];
            self.smartBoxSelectEnable = selectEnable;
        } else {
            box = currentFolders[1];
            self.smartBoxSelectEnable = NO;
        }
        box.selectable = YES;
        _selectMailBox = box;
        
    } else {
        _selectMailBox = selectBoxArray[0];
    }
    _folders = currentFolders;
    [self registObserver];
    [self reset];
}

#pragma mark UiGestureRecoginzerDelegate
//gesture
- (void)paningGestureReceive:(UIGestureRecognizer*)recoginzer
{
    CGPoint touchPoint = [recoginzer locationInView:self];
    if (recoginzer.state == UIGestureRecognizerStateBegan) {
        _starX = touchPoint.x;
        self.selfStarX = self.frame.origin.x;
        
    } else if (recoginzer.state == UIGestureRecognizerStateEnded || recoginzer.state == UIGestureRecognizerStateCancelled){
        __block BOOL change;
        __weak typeof(self)weekSelf = self;
        [UIView animateWithDuration:0.2 animations:^{
            CGRect rect = weekSelf.frame;
            if (weekSelf.frame.origin.x > self.selfStarX) {
                rect.origin.x = 0;
                change = YES;
            } else {
                rect.origin.x = - (self.frame.size.width - kMCMailBoxListViewShowSpaceWidth);
                change = NO;
            }
            self.frame = rect;
            [weekSelf showMaskView:change];
        } completion:^(BOOL finished) {
            _change = change;
        }];
        
    } else if (recoginzer.state == UIGestureRecognizerStateChanged) {
        
        CGFloat endX = touchPoint.x - _starX;
       [self showMaskView:YES];
        CGRect rect = self.frame;
        rect.origin.x += endX;
        if (rect.origin.x >= 0) {
            rect.origin.x = 0;
        } else if (rect.origin.x <= - (self.frame.size.width - kMCMailBoxListViewShowSpaceWidth)){
            rect.origin.x = - (self.frame.size.width - kMCMailBoxListViewShowSpaceWidth);
           [self showMaskView:NO];
            _change = NO;
        }
        self.frame = rect;
    }
}

- (void)setChange:(BOOL)change{
    
    CGFloat x;
    if (change) {
        x = 0;
    } else {
        x = - (ScreenWidth - kMCMailBoxListViewPand)-3 + kMCMailBoxListViewShowSpaceWidth;
    }
    __weak typeof(self)weekSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = weekSelf.frame;
        rect.origin.x = x;
        weekSelf.frame = rect;
        _mcMaskView.alpha = change?0.3:0;
    }];
    _change = change;
   
    [self reset];
}

- (void)reset{
    _mcNameLabel.text = AppStatus.currentUser.displayName;
    _mcEmailLabel.text = AppStatus.currentUser.email;
    [_mcAvatarView sd_setImageWithURL:[NSURL URLWithString:AppStatus.currentUser.avatarUrl] placeholderImage:AppStatus.currentUser.avatarPlaceHolder options:SDWebImageAllowInvalidSSLCertificates];
    [self.boxListTableView reloadData];
}

- (void)show {
   
    MCAppDelegate *mcAppdelegate = (MCAppDelegate*)[UIApplication sharedApplication].delegate;
    UIWindow *window = mcAppdelegate.window;
    _mcMaskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeigth)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissListView:)];
    [_mcMaskView addGestureRecognizer:tap];
    _mcMaskView.alpha = 0;
    _mcMaskView.backgroundColor = [UIColor grayColor];
    [window addSubview:_mcMaskView];
    [window addSubview:self];
}

- (void)dismissListView:(UIGestureRecognizer*)gesture {
    
    self.change = NO;
}

- (void)showMaskView:(BOOL)show {
    _mcMaskView.alpha = show?0.3:0;
}

//prative
- (void)setBoxUnreadCountWith:(NSArray*)boxes {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MCMailManager *mailManager = [[MCMailManager alloc]initWithAccount:AppStatus.currentUser];
        for (MCMailBox *box in boxes) {
            if (box.unreadCount == NSNotFound) {
                if (!box.showCount) {
                    box.showCount = 20;
                }
                box.unreadCount = [mailManager getUnreadMailCountWihtFolder:box limit:box.showCount];
            }
        }
    });
}

- (MCMailBox *)smartBox {
    if (_smartBox == nil) {
        _smartBox = [MCMailBox new];
        _smartBox.type = MCMailFolderTypeSmartBox;
        _smartBox.name = PMLocalizedStringWithKey(@"PM_Mail_SmartBox");
        _smartBox.path = @"INBOX";
    }
    return _smartBox;
}

//add kvo

- (void)registObserver
{
    MCMailBox *inbox = _folders[1];
    typeof(self)weak = self;
    [self.KVOController observe:inbox keyPath:@"unreadCount" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        if (self.loadImportantMails) {
            weak.smartBox.unreadCount = inbox.unreadCount;
        }
    }];
}

- (void)removeObserver{
    [self.KVOController unobserveAll];
}

@end
