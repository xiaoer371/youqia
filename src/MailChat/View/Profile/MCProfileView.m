//
//  MCProfileView.m
//  NPushMail
//
//  Created by zhang on 16/4/12.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCProfileView.h"
#import "MCProfileAccountCell.h"
#import "MCProfileSetCell.h"
#import "MCFileCore.h"
#import "MCFileManager.h"
#import "MCAppSetting.h"
#import "MCWorkSpaceManager.h"
#import "MCAccountConfig.h"
#import "UIView+MCExpand.h"

@interface MCProfileView () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,weak)id <MCProfileViewDelegate> delegate;

@property (nonatomic,strong)UITableView *profileTablView;
//item标题
@property (nonatomic,strong)NSArray *titles;
//区头标题
@property (nonatomic,strong)NSArray *sectionTitles;
@property (nonatomic,strong)NSString *mcCacheFileSize;
@property (nonatomic,assign)NSTimeInterval updateTimeInterval;
@end

NSString *const kMCProfileAccountCellId = @"kMCProfileAccountCellId";
NSString *const kMCProfileSetCellId = @"profileSetNormalCellId";
NSString *const kMCPrefileSetAddCellId = @"prefileSetAddCellId";
NSString *const kMCPrefileSetShowAvatarCellId = @"prefileSetShowAvatarCellId";

const CGFloat kMCProfileTablViewSectionHight = 27.0;
const CGFloat kMCProfileTablViewAccountCellHight = 55.0;
const CGFloat kMCProfileTablViewSetCellHight = 44.0;

@implementation MCProfileView

- (id)initWithDelegate:(id<MCProfileViewDelegate>)delegate
{
    if (self = [super init]) {
        _delegate = delegate;
        [self mcCacheFileSize];
        [self setUp];
    }
    return self;
}

- (void)setUp {
    self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeigth - NAVIGATIONBARHIGHT - TOOLBAR_HEIGHT);
    _profileTablView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,self.frame.size.width,self.frame.size.height)];
    _profileTablView.delegate = self;
    _profileTablView.dataSource = self;
    _profileTablView.tableFooterView = [[UIView alloc] init];
    _profileTablView.separatorColor = AppStatus.theme.tableViewSeparatorColor;
    _profileTablView.backgroundColor = [UIColor clearColor];
    [self addSubview:_profileTablView];
}
#pragma  mark UITableViewDelegate DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _titles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray*dataSource = _titles[section];
    return dataSource.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
   
    NSArray*dataSource = _titles [indexPath.section];
    id object = dataSource[indexPath.row];
    if ([object isKindOfClass:[MCAccount class]]) {
        MCProfileAccountCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:kMCProfileAccountCellId];
        if (!cell) {
            NSArray*array = [[NSBundle mainBundle] loadNibNamed:@"MCProfileAccountCell" owner:nil options:nil];
            cell = [array firstObject];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.mCAccount = (MCAccount*)object;
        
        cell.accountInfoComplete = ^{
            if ([_delegate respondsToSelector:@selector(profileView:didSelectAccountInfo:)]) {
                [_delegate profileView:self didSelectAccountInfo:(MCAccount*)object];
            }
        };
        cell.separatorInset = UIEdgeInsetsMake(0, 64.0, 0, 0);
        return cell;
        
    } else {
        
        MCProfileSetCell *cell;
        NSString *cellid;
        NSInteger nibIndex;
        if (indexPath.section == 0) {
            cellid = kMCPrefileSetAddCellId;
            nibIndex = 0;
        } else if (indexPath.row == 3 &indexPath.section == 1) {
            cellid = kMCPrefileSetShowAvatarCellId ;
            nibIndex = 1;
        }else if (indexPath.row == 4 &indexPath.section == 1) {
            cellid = kMCPrefileSetShowAvatarCellId ;
            nibIndex = 1;
        } else {
            cellid = kMCProfileSetCellId;
            nibIndex = 2;
        }
        
        cell = [tableView dequeueReusableCellWithIdentifier:cellid];
        if (!cell) {
           NSArray*array = [[NSBundle mainBundle] loadNibNamed:@"MCProfileSetCell" owner:nil options:nil];
            cell = array[nibIndex];
        }
        switch (nibIndex) {
            case 0:
            {
                cell.mCSetLable.textColor = AppStatus.theme.tintColor;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            }
                break;
            case 1:
            {
               cell.accessoryType = UITableViewCellAccessoryNone;
               cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
                break;
            case 2:
            {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            }
                break;
                
            default:
                break;
        }
        NSString *title = (NSString*)object;
        cell.mcSettingTitle = title;
        if ([title isEqualToString:PMLocalizedStringWithKey(@"PM_WorkSpace_Item_Setup")]) {
            //设置工作台
            cell.mcShowAvatarSwitch.on = AppSettings.isShowWorkspace;
            cell.loadAvatarChangeValueCallback = ^(BOOL on) {
                [AppSettings setIsShowWorkspace:on];
                [MCWorkSpaceManager workSpaceUserCheck];
            };
        }else {
            cell.mcShowAvatarSwitch.on = AppSettings.loadAvatarCellForMailList;
            cell.loadAvatarChangeValueCallback = ^(BOOL on) {
                //友盟统计
                [MCUmengManager addEventWithKey:mc_me_mailhead];
                AppSettings.loadAvatarCellForMailList = on;
            };
        }
        if (indexPath.row == 2 && indexPath.section == 2) {
            cell.mcCacheFileSize.text = self.mcCacheFileSize;
        } else {
            cell.mcCacheFileSize.text = @"";
        }
        //设置提示红点
        if (indexPath.row == 0 && indexPath.section == 2) {
            if (AppSettings.isQuestionnaireNote){
                CGSize size = [title boundingRectWithSize:CGSizeMake(200, 20) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0f]} context:nil].size;
                [cell.updateBadge moveToX:size.width + 12];
                cell.updateBadge.hidden = NO;
            }else  cell.updateBadge.hidden = YES;
        } else {
            cell.updateBadge.hidden = YES;
        }
        
        //配置分割线
        if (indexPath.row == 4 && indexPath.section == 2) {
            cell.separatorInset = UIEdgeInsetsMake(0, -12.0, 0, 0);
        } else {
            cell.separatorInset = UIEdgeInsetsMake(0, 12.0, 0, 0);
        }
        return cell;
    }
    return nil;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, kMCProfileTablViewSectionHight)];
    sectionView.backgroundColor = [UIColor colorWithHexString:@"f7f7f9"];
    //section标题
    UILabel *sectionTitle = [[UILabel alloc]initWithFrame:CGRectMake(12.0, 0, 200, kMCProfileTablViewSectionHight)];
    sectionTitle.backgroundColor = [UIColor clearColor];
    sectionTitle.text = self.sectionTitles[section];
    sectionTitle.font = [UIFont systemFontOfSize:12];
    sectionTitle.textColor = AppStatus.theme.fontTintColor;
    [sectionView addSubview:sectionTitle];
    //section分割线
    UIView *sectionLine = [[UIView alloc]initWithFrame:CGRectMake(0, kMCProfileTablViewSectionHight - 0.3, ScreenWidth, 0.3)];
    sectionLine.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
    [sectionView addSubview:sectionLine];
    
    //section分割线
    if (section != 0) {
        UIView *sectionLine2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.3)];
        sectionLine2.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
        [sectionView addSubview:sectionLine2];
    }
    return sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kMCProfileTablViewSectionHight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray*dataSource = _titles [indexPath.section];
    id object = dataSource[indexPath.row];
    if ([object isKindOfClass:[MCAccount class]]) {
        return kMCProfileTablViewAccountCellHight;
    }
    return kMCProfileTablViewSetCellHight;
}

//delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSArray*dataSource = _titles [indexPath.section];
    id object = dataSource[indexPath.row];
    if ([object isKindOfClass:[MCAccount class]]) {
        
        if ([_delegate respondsToSelector:@selector(profileView:didChangeAccount:)]) {
            [_delegate profileView:self didChangeAccount:(MCAccount*)object];
        }
    } else {
        
        if (indexPath.section == 0) {
            if ([_delegate respondsToSelector:@selector(profileViewAddNewAccount)]) {
                [_delegate profileViewAddNewAccount];
            }
        } else {
         
            if ([_delegate respondsToSelector:@selector(profileView:didSelectCellIndexPath:title:)]) {
                [_delegate profileView:self didSelectCellIndexPath:indexPath title:(NSString*)object];
            }
        }
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            if (AppSettings.isQuestionnaireNote) {
                AppSettings.isQuestionnaireNote = NO;
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

//prative
- (NSArray*)sectionTitles {
    if (!_sectionTitles) {
        
        _sectionTitles = @[PMLocalizedStringWithKey(@"PM_Contact_AccountTitle"),
                           PMLocalizedStringWithKey(@"PM_Mine_Setting"),
                           PMLocalizedStringWithKey(@"PM_Mail_More")];
    }
    return _sectionTitles;
}

- (void)setAccounts:(NSArray *)accounts {
    
    _accounts = accounts;
    
    if (_titles) {
        _titles = nil;
    }
    NSMutableArray *account = [NSMutableArray new];
    [account addObjectsFromArray:accounts];
    [account addObject:PMLocalizedStringWithKey(@"PM_Mine_AddEmailAccount")];
    DDLogInfo(@"当前用户%@", AppStatus.currentUser.email);
    NSArray *array = @[PMLocalizedStringWithKey(@"PM_Mine_AwardedQuestionnaire"),
                       PMLocalizedStringWithKey(@"PM_Mine_MyFiles"),
                       PMLocalizedStringWithKey(@"PM_Mine_ClearCache"),
                       PMLocalizedStringWithKey(@"PM_Mine_FeedBack"),
                       PMLocalizedStringWithKey(@"PM_Mine_AboutYouQia"),
                       PMLocalizedStringWithKey(@"PM_Main_inviteSomeUseYouQia")
                       ];

    
    if (AppStatus.accountData.accountConfig.hasWorkspace) {
        _titles = @[account, @[PMLocalizedStringWithKey(@"PM_Mine_NewMailAlert"),
                               PMLocalizedStringWithKey(@"PM_Mine_Signature"),
                               PMLocalizedStringWithKey(@"PM_Mine_PasswordProtect"),
                               PMLocalizedStringWithKey(@"PM_Main_MailListLoadAvatar"),
                               PMLocalizedStringWithKey(@"PM_WorkSpace_Item_Setup")
                               ],array];
    }else {
        _titles = @[account, @[PMLocalizedStringWithKey(@"PM_Mine_NewMailAlert"),
                               PMLocalizedStringWithKey(@"PM_Mine_Signature"),
                               PMLocalizedStringWithKey(@"PM_Mine_PasswordProtect"),
                               PMLocalizedStringWithKey(@"PM_Main_MailListLoadAvatar")
                               ],array];
    }
    [_profileTablView reloadData];
}

- (NSString*)mcCacheFileSize {
    
   NSTimeInterval nowInterval =  [[NSDate date] timeIntervalSince1970];
    //1000秒更新一次、切换账号时也会更新一次
    if (nowInterval - _updateTimeInterval > 1000) {
       _mcCacheFileSize = [[MCFileCore sharedInstance].getFileModule getAllCacheFilsSize];
    }
    _updateTimeInterval = nowInterval;
    return _mcCacheFileSize;
}


- (void)reloadData {
    _updateTimeInterval = 0;
    [_profileTablView reloadData];
}
@end
