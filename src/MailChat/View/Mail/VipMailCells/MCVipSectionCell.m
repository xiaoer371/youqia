//
//  MCVipSectionCell.m
//  NPushMail
//
//  Created by zhang on 2017/2/14.
//  Copyright © 2017年 sprite. All rights reserved.
//

#import "MCVipSectionCell.h"

@interface MCVipSectionCell ()<UITableViewDelegate,UITableViewDataSource,MGSwipeTableCellDelegate>

@property (nonatomic,strong)UIView *tableViewFooterView;
@property (nonatomic,strong)UIView *tableViewFooterView2;
@property (nonatomic,strong)UIButton *totalButton;

@property (nonatomic,assign)long totalMails;
@end

const static CGFloat kMCVIPMailViewCellButtonWidth = 85.0;
const static CGFloat kMCMailListViewCellThresholdForOther = 1.0;
const static CGFloat kMCMailListViewCellPadding = 15.0;

@implementation MCVipSectionCell

+ (UINib*)registNib {
    return [UINib nibWithNibName:@"MCVipSectionCell" bundle:nil];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.vipSectionTableView.delegate = self;
    self.vipSectionTableView.dataSource = self;
    self.vipSectionTableView.scrollEnabled = NO;
    [self.vipSectionTableView registerNib:[MCVIPMailListCell mailCellNib] forCellReuseIdentifier:kMCVipMailCellIdentity];
    [self.vipSectionTableView registerNib:[MCVIPMailListCell avatarMailCellNib] forCellReuseIdentifier:kMCVipAvatarMailCellIdentity];
}
- (void)reloadData {
    [self.vipSectionTableView reloadData];
}

- (UIView*)tableViewFooterView {
    if (_tableViewFooterView == nil) {
        _tableViewFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 12)];
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.5)];
        line.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
        [_tableViewFooterView addSubview:line];
        _tableViewFooterView.backgroundColor = [UIColor colorWithHexString:@"f7f7f9"];
    }
    return _tableViewFooterView;
}

- (UIView*)tableViewFooterView2 {
    if (_tableViewFooterView2 == nil) {
        _tableViewFooterView2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 56)];
        _tableViewFooterView2.backgroundColor = [UIColor whiteColor];
        _totalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _totalButton.frame = CGRectMake(0, 12, ScreenWidth, 44);
        [_totalButton addTarget:self action:@selector(showMoreMails:) forControlEvents:UIControlEventTouchUpInside];
        [_totalButton setTitleColor:AppStatus.theme.tintColor forState:UIControlStateNormal];
        [_tableViewFooterView2 addSubview:_totalButton];
        [_tableViewFooterView2 addSubview:self.tableViewFooterView];
    }
    self.totalMails = self.mails.count;
    return _tableViewFooterView2;
}

- (void)setTotalMails:(long)totalMails {
    [self.totalButton setTitle:[NSString stringWithFormat:@"%@(%lu)",PMLocalizedStringWithKey(@"PM_Mail_ShowAllMails"),totalMails] forState:UIControlStateNormal];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mails.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCVIPMailListCell *cell = [tableView dequeueReusableCellWithIdentifier:self.isAvatarShow?kMCVipAvatarMailCellIdentity:kMCVipMailCellIdentity forIndexPath:indexPath];
    cell.loadAvatar = self.isAvatarShow;
    cell.delegate = self;
    cell.model = self.mails[indexPath.row];
    if (!cell.model.messageContentHtml) {
        if (self.loadMailCotentCallback) {
            self.loadMailCotentCallback(cell.model);
        }
    }
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (self.mails.count > 3) {
        return self.tableViewFooterView2;
    }
    return self.tableViewFooterView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 84;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.mails.count > 3) {
        return 56;
    }
    return 12;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MCVIPMailListCell *cell = (MCVIPMailListCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (self.didSelectedMailCallback) {
        self.didSelectedMailCallback (cell.model);
    }
}

//TODO:cell左右滑动 已读未读、收藏、删除、移动操作
-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell
  swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings
         expansionSettings:(MGSwipeExpansionSettings*) expansionSettings {
    
    MCVIPMailListCell *listCell = (MCVIPMailListCell*)cell;
    MCMailModel *mail = listCell.model;
    //已读未读
    if (direction == MGSwipeDirectionLeftToRight) {
        
        swipeSettings.transition = MGSwipeTransitionBorder;
        cell.leftExpansion.buttonIndex = 0;
        cell.leftExpansion.fillOnTrigger = NO;
        cell.leftExpansion.threshold = 0.8;
        
        NSString *rightButttonTitle = mail.isRead?PMLocalizedStringWithKey(@"PM_Mail_SetUnRead"):PMLocalizedStringWithKey(@"PM_Mail_SetRead");
        MGSwipeButton*rightButtton = [MGSwipeButton buttonWithTitle:rightButttonTitle backgroundColor:[UIColor colorWithHexString:@"52b2ea"] padding:kMCMailListViewCellPadding callback:^BOOL(MGSwipeTableCell *sender) {
            //友盟事件统计
            [MCUmengManager addEventWithKey:mc_mail_list_read];
            [sender  refreshButtons:YES];
            
            NSString *event = mail.isRead ? mc_mail_important_read : mc_mail_important_unread;
            [MCUmengManager importantEvent:event];
            if (self.readMailCallBack) {
                self.readMailCallBack (mail);
            }
            
            return YES;
        }];
        
        rightButtton.buttonWidth = kMCVIPMailViewCellButtonWidth + 20;
        return @[rightButtton];
        
    } else if (self.isBacklogMail){
        cell.rightExpansion.buttonIndex = 0;
        cell.rightExpansion.fillOnTrigger = YES;
        cell.rightExpansion.threshold = 1.1;
        CGFloat padding = kMCMailListViewCellPadding;
        MGSwipeButton * finish = [MGSwipeButton buttonWithTitle:PMLocalizedStringWithKey(@"PM_Common_Complite") backgroundColor:[UIColor colorWithHexString:@"4cd964"] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            [MCUmengManager backlogEvent:mc_mail_backlog_vipListUnBacklog];
            if (self.mails.count > 1) {
               [self deleteMail:mail indexPath:[self.vipSectionTableView indexPathForCell:listCell]];
            }
            if (self.backlogCallBack) {
                self.backlogCallBack(mail);
            }
            return YES;
        }];
        return @[finish];
    } else {
        cell.rightExpansion.buttonIndex = -1;
        cell.rightExpansion.fillOnTrigger = YES;
        cell.rightExpansion.threshold = kMCMailListViewCellThresholdForOther;
        CGFloat padding = kMCMailListViewCellPadding;
        //删除
        MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:PMLocalizedStringWithKey(@"PM_Mail_DeleteMail") backgroundColor:[UIColor colorWithHexString:@"f54e46"] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            //友盟事件统计
            [MCUmengManager addEventWithKey:mc_mail_list_delete];
            if (mail.tags & MCMailTagImportant) {
                [MCUmengManager importantEvent:mc_mail_important_delete];
            }
            [self deleteMail:mail indexPath:[self.vipSectionTableView indexPathForCell:listCell]];
            if (self.deleteMailCallBack) {
                self.deleteMailCallBack(mail);
            }
            [sender refreshContentView];
            [sender refreshButtons:YES];
            return YES;
        }];
        trash.buttonWidth = kMCVIPMailViewCellButtonWidth;
        MGSwipeButton * flag = [MGSwipeButton buttonWithTitle:mail.tags& MCMailTagImportant? PMLocalizedStringWithKey(@"PM_Mail_UnMarkVIPMail"):PMLocalizedStringWithKey(@"PM_Mail_MrakVIPMail") backgroundColor:[UIColor colorWithHexString:@"f5b146"] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            [sender refreshContentView];
            [self deleteMail:mail indexPath:[self.vipSectionTableView indexPathForCell:cell]];
            if (self.vipMailDesMarkCallBack) {
                self.vipMailDesMarkCallBack (mail);
            }
            return YES;
        }];
        flag.buttonWidth = kMCVIPMailViewCellButtonWidth;
        //待办
        MGSwipeButton * backlog = [MGSwipeButton buttonWithTitle:PMLocalizedStringWithKey(@"PM_Mail_backlogMails") backgroundColor:[UIColor colorWithHexString:@"c7c7cc"] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            [MCUmengManager backlogEvent:mc_mail_backlog_vipListBacklog];
            [self deleteMail:mail indexPath:[self.vipSectionTableView indexPathForCell:cell]];
            if (self.backlogCallBack) {
                self.backlogCallBack (mail);
            }
            return YES;
        }];
        backlog.buttonWidth = kMCVIPMailViewCellButtonWidth;
        return @[trash, flag, backlog];
    }
    return nil;
}

- (void)deleteMail:(MCMailModel*)mail indexPath:(NSIndexPath*)indexPath {
    [self.mails removeObject:mail];
    [self.vipSectionTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    self.totalMails = self.mails.count;
}
//action
- (void)showMoreMails:(UIButton*)sender {
    if (self.showMoreMailsCallback) {
        self.showMoreMailsCallback (self.isBacklogMail);
    }
}

- (void)insertMail:(MCMailModel *)mail inIndexPath:(NSIndexPath *)indexPath {
    [self.mails insertObject:mail atIndex:indexPath.row];
    [self.vipSectionTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}


@end
