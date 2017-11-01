//
//  MCMailSelectedViewController.m
//  NPushMail
//
//  Created by zhang on 16/8/26.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCMailSelectedViewController.h"
#import "MCMailMoveViewController.h"
#import "MCMailDetailViewController.h"
#import "MCBaseNavigationViewController.h"
#import "MCContactManager.h"
#import "MCVIPMailListCell.h"
#import "MCAppSetting.h"
#import "MCRepealView.h"
#import "MCContactInfoViewController.h"
#import "MCMailBoxManager.h"
const static CGFloat kMCVIPMailViewCellButtonWidth = 85.0;
const static CGFloat kMCMailListViewCellThresholdForOther = 1.0;
const static CGFloat kMCMailListViewCellPadding = 15.0;

@interface MCMailSelectedViewController ()<UITableViewDelegate,UITableViewDataSource,MCMailManagerViewDelegate,MGSwipeTableCellDelegate,MCMailDetailViewControllerDelegate,MailListCellDelegate>

@property (nonatomic,copy)MCMailProcessBlock mailProcessCallback;
@property (nonatomic,strong)NSMutableArray *mails;
@property (nonatomic,strong)NSMutableArray *undonMails;
@property (nonatomic,strong)NSMutableDictionary *selectedMails;
@property (nonatomic,assign)BOOL haveAvatar;
@property (nonatomic,strong)MCMailManagerView *managerView;
@property (nonatomic,assign)MCSelectType selectType;
@property (nonatomic,strong)MCRepealView *repealView;

@property (nonatomic,assign)BOOL isBacklogMails;


@end

@implementation MCMailSelectedViewController

- (id)initWithMails:(NSArray *)mails selectType:(MCSelectType)selectType didProcessMails:(MCMailProcessBlock)mailProcessCallback {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _mails = [mails mutableCopy];
        _haveAvatar = AppSettings.loadAvatarCellForMailList;
        _selectType = selectType;
        _selectedMails = [NSMutableDictionary new];
        self.mailProcessCallback = mailProcessCallback;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSubViews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_selectType == MCSelectDo && !_tableView.editing) {
      [self tableViewEidting:YES animationFinished:nil];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_repealView dismiss];
}
- (void)initSubViews {
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.multipleTouchEnabled = NO;
    _tableView.allowsSelectionDuringEditing = YES;
    _tableView.tableFooterView = [UIView new];
    [_tableView registerNib:[MCVIPMailListCell mailCellNib] forCellReuseIdentifier:kMCVipMailCellIdentity];
    [_tableView registerNib:[MCVIPMailListCell avatarMailCellNib] forCellReuseIdentifier:kMCVipAvatarMailCellIdentity];
    _tableView.rowHeight = 86.0;
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    longPressGesture.minimumPressDuration = 0.5;
    [self.tableView addGestureRecognizer:longPressGesture];
    
    [self.leftNavigationBarButtonItem setTitle:PMLocalizedStringWithKey(@"PM_Common_Cancel")];
    [self.leftNavigationBarButtonItem setImage:nil];
    
    _managerView = [[MCMailManagerView alloc]init];
    _managerView.frame = CGRectMake(0, ScreenHeigth - NAVIGATIONBARHIGHT, CGRectGetWidth(_managerView.frame), CGRectGetHeight(_managerView.frame));
    _managerView.delegate = self;
    [self.view addSubview:_managerView];
    [self resetSelectedTitle];
    [self setRightItem];
    self.repealView = [MCRepealView shared];
}

- (void)tableViewEidting:(BOOL)editing animationFinished:(dispatch_block_t)finishCallback{
    [self.selectedMails removeAllObjects];
    [_managerView resetItemShowWithMaisl:[_selectedMails allValues] folder:nil];
    [self resetSelectedTitle];
    [_tableView setEditing:editing animated:YES];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = _managerView.frame;
        if (editing) {
            rect.origin.y -= rect.size.height;
            _managerView.frame = rect;
            _tableViewbottomConstrain.constant = CGRectGetHeight(_managerView.frame);
        } else {
            _tableViewbottomConstrain.constant = 0;
            rect.origin.y = CGRectGetHeight(self.view.frame);
            _managerView.frame = rect;
        }
    } completion:^(BOOL finished) {
        [_tableView reloadData];
        if (finishCallback) {
            finishCallback();
        }
    }];
}

#pragma mark UITableViewDelegate ,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _mails.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MCVIPMailListCell *cell = [tableView dequeueReusableCellWithIdentifier:_haveAvatar?kMCVipAvatarMailCellIdentity:kMCVipMailCellIdentity];
    cell.delegate = self;
    cell.cellDelegate = self;
    cell.loadAvatar = _haveAvatar;
    MCMailModel *mail =  _mails[indexPath.row];
    cell.model = mail;
    cell.isSelected = _selectedMails[@(mail.messageUid)]?YES:NO;
    if (!cell.model.messageContentString) {
        [self.mailManager loadMailContent:cell.model inFolder:self.folder urgent:NO success:nil failure:nil];
    }
    return cell;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  UITableViewCellEditingStyleNone;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MCVIPMailListCell *cell = (MCVIPMailListCell*)[tableView cellForRowAtIndexPath:indexPath];
    MCMailModel *mail = cell.model;
    
    if (tableView.editing) {
        if (![_selectedMails objectForKey:@(mail.messageUid)]) {
            [_selectedMails setObject:mail forKey:@(mail.messageUid)];
        } else {
            [_selectedMails removeObjectForKey:@(mail.messageUid)];
        }
        BOOL selectAll = _selectedMails.allValues.count == _mails.count;
        [UIView performWithoutAnimation:^{
          [self.rightNavigationBarButtonItem setTitle:selectAll?PMLocalizedStringWithKey(@"PM_Mail_UnSelectAll"):PMLocalizedStringWithKey(@"PM_Mail_SelectAll")];
        }];
        [cell changeMSelectedState];
        [self resetSelectedTitle];
        [_managerView resetItemShowWithMaisl:[_selectedMails allValues] folder:nil];
    } else {
        MCMailBoxManager*boxManager = [MCMailBoxManager new];
        MCMailBox *box = [boxManager getMailBoxWithAccount:self.folder.accountId path:cell.model.folder];
        MCMailDetailViewController *mailDetailViewController = [[MCMailDetailViewController alloc]initWithMail:mail manager:_mailManager delegate:self];
        mailDetailViewController.mailbox = box;
        [self.navigationController pushViewController:mailDetailViewController animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

#pragma mark Swipe Delegate
-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction
{
    [_repealView dismiss];
    [cell refreshButtons:YES];
    return YES;
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
            self.mailProcessCallback(@[mail],nil,mail.isRead?MCMailProcessUnread:MCMailProcessRead);
            [sender  refreshButtons:YES];
            return YES;
        }];
        rightButtton.buttonWidth = kMCVIPMailViewCellButtonWidth + 20;
        return @[rightButtton];
        
    } else {
        
        if (self.isBacklogMails) {
            cell.rightExpansion.buttonIndex = 0;
            cell.rightExpansion.fillOnTrigger = YES;
            cell.rightExpansion.threshold = 1.1;
            CGFloat padding = kMCMailListViewCellPadding;
            MGSwipeButton * finish = [MGSwipeButton buttonWithTitle:PMLocalizedStringWithKey(@"PM_Common_Complite") backgroundColor:[UIColor colorWithHexString:@"4cd964"] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
                [self markBacklogMail:mail mark:!(mail.tags&2) repeal:YES];
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
                [self moveMails:@[mail] toBox:nil processType:MCMailProcessDelete];
                [MCUmengManager addEventWithKey:mc_mail_list_delete];
                [sender refreshContentView];
                return YES;
            }];
            trash.buttonWidth = kMCVIPMailViewCellButtonWidth;
            MGSwipeButton * flag = [MGSwipeButton buttonWithTitle:mail.tags&1? PMLocalizedStringWithKey(@"PM_Mail_UnMarkVIPMail"):PMLocalizedStringWithKey(@"PM_Mail_MrakVIPMail") backgroundColor:[UIColor colorWithHexString:@"f5b146"] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
                BOOL markVip = mail.tags&MCMailTagImportant;
                [self markVipWithMail:mail markVip:!markVip];
                [sender hideSwipeAnimated:YES];
                [sender refreshButtons:YES];
                return YES;
            }];
            flag.buttonWidth = kMCVIPMailViewCellButtonWidth;
            //移动
            MGSwipeButton * move = [MGSwipeButton buttonWithTitle:PMLocalizedStringWithKey(@"PM_Mail_MoveMail") backgroundColor:[UIColor colorWithHexString:@"c7c7cc"] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
                //友盟事件统计
                [MCUmengManager addEventWithKey:mc_mail_list_move];
                MCMailMoveViewController *mailMoveViewController = [[MCMailMoveViewController alloc]initWithCurrentMailBox:_folder manager:_mailManager moveComplete:^(MCMailBox * toBox) {
                    [self moveMails:@[mail] toBox:toBox processType:MCMailProcessMove];
                }];
                MCBaseNavigationViewController *nav = [[MCBaseNavigationViewController alloc]initWithRootViewController:mailMoveViewController];
                [self presentViewController:nav animated:YES completion:nil];
                
                return YES;
            }];
            move.buttonWidth = kMCVIPMailViewCellButtonWidth;
            return @[trash, flag, move];
        }
        
    }
    return nil;
}

-(void) swipeTableCell:(MGSwipeTableCell*) cell didChangeSwipeState:(MGSwipeState) state gestureIsActive:(BOOL) gestureIsActive {
    if (state == MGSwipeStateSwipingLeftToRight||
        state == MGSwipeStateSwipingRightToLeft) {
        [self.repealView dismiss];
    }
}

- (void)tapAvatar:(MCVIPMailListCell *)cell contact:(MCContactModel *)contact {
    
    if (self.tableView.editing) {
        return;
    }
    MCContactInfoViewController *contactInfoViewController = [[MCContactInfoViewController alloc]initFromType:fromReadMail contactModel:contact canEditable:NO isEnterprise:contact.isCompanyUser];
    [self.navigationController pushViewController:contactInfoViewController animated:YES];
}


#pragma mark - MCMailDetailViewControllerDelegate
- (void)mailDetailViewHandleMail:(MCMailModel *)mail from:(MCMailBox *)fromBox moveTo:(MCMailBox *)mailBox {
    
    [self moveMails:@[mail] toBox:mailBox processType:MCMailProcessMove];
}

- (void)mailDetailViewHandleMail:(MCMailModel *)mail setRead:(BOOL)read {
    self.mailProcessCallback(@[mail],nil,read?MCMailProcessRead:MCMailProcessUnread);
}

- (void)mailDetailViewHandleMail:(MCMailModel *)mail tag:(MCMailTags)tags mark:(BOOL)mark {
    if (tags == MCMailTagBacklog) {
        [self markBacklogMail:mail mark:mark repeal:NO];
    } else {
        self.mailProcessCallback(@[mail],nil,mark?MCMailProcessVip:MCMailProcessUnVip);
    }
}

- (MCMailModel*)mailDetailViewReadOtherFromMail:(MCMailModel *)mail toNext:(BOOL)next {
    MCMailModel *nextMail = nil;
    NSInteger index = [self.mails indexOfObject:mail];
    if (index != NSNotFound) {
        index = next?index+1:index -1;
        if (index >=0 && index < self.mails.count) {
            nextMail = self.mails[index];
            return nextMail;
        }
    }
    return nil;
}
//TODO:action
- (void)rightNavigationBarButtonItemAction:(id)sender {
    [UIView performWithoutAnimation:^{
        if ([self.rightNavigationBarButtonItem.title isEqualToString:PMLocalizedStringWithKey(@"PM_Mail_SelectAll")]) {
            for (MCMailModel *mail in _mails) {
                [_selectedMails setObject:mail forKey:@(mail.messageUid)];
            }
            [self.rightNavigationBarButtonItem setTitle:PMLocalizedStringWithKey(@"PM_Mail_UnSelectAll")];
        } else {
            [_selectedMails removeAllObjects];
            [self.rightNavigationBarButtonItem setTitle:PMLocalizedStringWithKey(@"PM_Mail_SelectAll")];
        }
    }];
    [_tableView reloadData];
    [self resetSelectedTitle];
    [_managerView resetItemShowWithMaisl:[_selectedMails allValues] folder:nil];
}

- (void)leftNavigationBarButtonItemAction:(id)sender {
    
    if (_tableView.editing && _selectType == MCSelectNormal) {
        [_selectedMails removeAllObjects];
        [self tableViewEidting:NO animationFinished:nil];
    } else {
        [self tableViewEidting:NO animationFinished:^{
          [self dismissViewControllerAnimated:NO completion:nil];
        }];
    }
    [self resetSelectedTitle];
    [self setRightItem];
}

//reset Selected
- (void)resetSelectedTitle {
    NSString *title;
    if (_selectType == MCSelectDo ||_tableView.editing) {
        NSInteger count = _selectedMails.allValues.count;
        if (count > 0) {
            title = [NSString stringWithFormat:@"%@(%ld)",self.sectionTitle,(long)count];
        } else {
            title = self.sectionTitle;
        }
    } else {
        
        title = self.sectionTitle;
    }
    self.viewTitle = title;
}

- (void)setRightItem {
    
    [UIView performWithoutAnimation:^{
        if (_selectType == MCSelectDo ||_tableView.editing) {
            [self.rightNavigationBarButtonItem setTitle:PMLocalizedStringWithKey(@"PM_Mail_SelectAll")];
            self.rightNavigationBarButtonItem.enabled = YES;
        } else {
            [self.rightNavigationBarButtonItem setTitle:@""];
            self.rightNavigationBarButtonItem.enabled = NO;
        }
    }];
}

//loogPress
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (_tableView.editing || self.isBacklogMails) {
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath) {
        [self tableViewEidting:YES animationFinished:nil];
        [self resetSelectedTitle];
        [self setRightItem];
    }
}
#pragma mark - ManagerViewDelegate
- (void)mailManagerView:(MCMailManagerView *)mailManagerView didSelectedProcessType:(MCMailProcessType)mailProcessType{
    self.selectType = MCSelectNormal;
    if (mailProcessType == MCMailProcessMove) {
        MCMailMoveViewController *mailMoveViewController = [[MCMailMoveViewController alloc] initWithCurrentMailBox:_folder manager:nil moveComplete:^(MCMailBox * toBox) {
            NSArray*mails = [[_selectedMails allValues] copy];
            [self tableViewEidting:NO animationFinished:^{
               [self moveMails:mails toBox:toBox processType:mailProcessType];
            }];
            [self setRightItem];
        }];
        MCBaseNavigationViewController *nav = [[MCBaseNavigationViewController alloc]initWithRootViewController:mailMoveViewController];
       [self presentViewController:nav animated:YES completion:nil];
       return;
    } else if (mailProcessType == MCMailProcessDelete){
        NSArray*mails = [[_selectedMails allValues] copy];
        [self tableViewEidting:NO animationFinished:^{
            [self moveMails:mails toBox:nil processType:mailProcessType];
        }];
    } else {
        NSArray*mails = [[_selectedMails allValues] copy];
        [self tableViewEidting:NO animationFinished:^{
            self.mailProcessCallback(mails,nil,mailProcessType);
        }];
    }
    [self setRightItem];
}

- (void)moveMails:(NSArray*)mails toBox:(MCMailBox*)box processType:(MCMailProcessType)processType{
    if (_selectType == MCSelectNormal) {
        _undonMails = [_mails mutableCopy];
        NSMutableArray *indexPaths = [NSMutableArray new];
        for (MCMailModel *mail in  mails) {
            NSInteger index = [_mails indexOfObject:mail];
            [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }
        [_mails removeObjectsInArray:mails];
        [_tableView beginUpdates];
        [_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [_tableView endUpdates];
        
        __weak typeof(self)weak = self;
        self.repealView.message = box?PMLocalizedStringWithKey(@"PM_Mail_DidMoveMails"):PMLocalizedStringWithKey(@"PM_Mail_DidDeleteMails");
        self.repealView.doItemTitle = PMLocalizedStringWithKey(@"PM_Mail_RepealMails");
        [self.repealView showWithUndoBlock:^{
            _mails = [_undonMails mutableCopy];
            [_tableView reloadData];
        } commitBlock:^{
            weak.mailProcessCallback(mails,box,processType);
        }];
        
        
    } else {
        self.mailProcessCallback(mails,box,processType);
    }
}

- (void)markVipWithMail:(MCMailModel*)mail markVip:(BOOL)markVip{
    
    self.mailProcessCallback(@[mail],nil,markVip?MCMailProcessVip:MCMailProcessUnVip);
    self.repealView.message = markVip?PMLocalizedStringWithKey(@"PM_Mail_DidMarkVip"):PMLocalizedStringWithKey(@"PM_Mail_DidUnMarkVip");
    self.repealView.doItemTitle = PMLocalizedStringWithKey(@"PM_Mail_RepealMails");
    
    __weak typeof(self)weak = self;
    [self.repealView showWithUndoBlock:^{
        weak.mailProcessCallback(@[mail],nil,markVip?MCMailProcessUnVip:MCMailProcessVip);
    } commitBlock:^{}];
}

- (void)markBacklogMail:(MCMailModel*)mail mark:(BOOL)mark repeal:(BOOL)showRepeal{
    
    self.mailProcessCallback(@[mail],nil,mark?MCMailProcessBacklog:MCMailProcessUnBackLog);
    if (_undonMails && [_undonMails containsObject:mail] && mark) {
        _mails = [_undonMails mutableCopy];
        [self.tableView reloadData];
    } else {
        _undonMails = [_mails mutableCopy];
        NSInteger index = [self.mails indexOfObject:mail];
        if (index != NSNotFound) {
            [self.mails removeObject:mail];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    
    if (!showRepeal) {
        return;
    }
    self.repealView.message = PMLocalizedStringWithKey(@"PM_Mail_BacklogFinishNote");
    self.repealView.doItemTitle = PMLocalizedStringWithKey(@"PM_Mail_RepealMails");
    __weak typeof(self)weak = self;
    [self.repealView showWithUndoBlock:^{
        weak.mailProcessCallback(@[mail],nil,mark?MCMailProcessUnBackLog:MCMailProcessBacklog);
        _mails = [_undonMails mutableCopy];
        [_tableView reloadData];
    } commitBlock:^{}];
}

//dismis
- (void)dismiss {
    [_selectedMails removeAllObjects];
    if (_selectType == MCSelectDo) {
        [self tableViewEidting:NO animationFinished:^{
          [self dismissViewControllerAnimated:NO completion:nil];
        }];
    }else {
        [self tableViewEidting:NO animationFinished:nil];
    }
}

//private
- (BOOL)isBacklogMails {
    return [self.sectionTitle isEqualToString:PMLocalizedStringWithKey(@"PM_Mail_backlogMails")];
}
@end
