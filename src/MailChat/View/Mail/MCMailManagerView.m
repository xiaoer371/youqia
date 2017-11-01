//
//  MCMailManagerView.m
//  NPushMail
//
//  Created by zhang on 15/12/23.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import "MCMailManagerView.h"
#import "MCAppStatus.h"
#import "MCMailModel.h"
@interface MCMailManagerView ()
@property (nonatomic,strong)NSArray *itemNames;
@property (nonatomic,assign)MCMailManagerItemShowKind managerShowKind;
@end

const static NSInteger kMCMailManagerViewItemCount = 4 ;
const static CGFloat   kMCMailManagerViewItemButtonFontSize = 15.0;
const static CGFloat   kMCMailManagerViewHight     = 49.0;
@implementation MCMailManagerView

- (id)init{
    
    self = [super init];
    if (self) {
        
        self.frame = CGRectMake(0, kMCMailManagerViewHight, ScreenWidth, kMCMailManagerViewHight);
        self.backgroundColor = AppStatus.theme.toolBarBackgroundColor;
        UIView*lineView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.5)];
        lineView.backgroundColor = AppStatus.theme.toolBarSeparatorColor;
        [self addSubview:lineView];
        
        for (int q  = 0; q < kMCMailManagerViewItemCount; q ++) {
            
            UIButton*buttton = [UIButton buttonWithType:UIButtonTypeCustom];
            buttton.frame = CGRectMake(q*(ScreenWidth/kMCMailManagerViewItemCount), 0, ScreenWidth/kMCMailManagerViewItemCount, self.frame.size.height);
            buttton.tag = q + 1;
            [buttton addTarget:self action:@selector(mCMailManagerViewItemChoose:) forControlEvents:UIControlEventTouchUpInside];
            [buttton setTitle:self.itemNames[q] forState:UIControlStateNormal];
            buttton.titleLabel.font = [UIFont systemFontOfSize:kMCMailManagerViewItemButtonFontSize];
            [buttton setTitleColor:AppStatus.theme.fontTintColor forState:UIControlStateNormal];
            buttton.userInteractionEnabled = NO;
            [self addSubview:buttton];
        }
    }
    return self;
}

- (void)setShow:(BOOL)show{
    
    CGFloat y;
    y = show ?0:kMCMailManagerViewHight;
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = self.frame;
        rect.origin.y = y;
        self.frame = rect;
    }];
}

#pragma mark - npMailManagerSet
- (void)mCMailManagerViewItemChoose:(UIButton*)sender
{
    if ([_delegate respondsToSelector:@selector(mailManagerView:didSelectedProcessType:)]) {
        
        MCMailProcessType processType;
        
        switch (sender.tag) {
            case 1:
            {
               //友盟统计事件
                [MCUmengManager addEventWithKey:mc_mail_edit_read];
                if (_managerShowKind &MCMailManagerItemShowUnread) {
                    processType = MCMailProcessUnread;
                } else{
                    processType = MCMailProcessRead;
                }
            }
                break;
            case 2:
            {
                //友盟统计事件
                [MCUmengManager addEventWithKey:mc_mail_edit_star];
                if (_managerShowKind&MCMailManagerItemShowUnstar) {
                    processType = MCMailProcessUnstarred;
                } else{
                    processType = MCMailProcessStarred;
                }
            }
                break;
            case 3:
            {
                //友盟统计事件
                [MCUmengManager addEventWithKey:mc_mail_edit_move];
                processType = MCMailProcessMove;
            }
                break;
            case 4:
            {
                //友盟统计事件
                [MCUmengManager addEventWithKey:mc_mail_edit_delete];
                processType = MCMailProcessDelete;
            }
                break;
        }
        [_delegate mailManagerView:self didSelectedProcessType:(MCMailProcessType)processType];
    }
}

//TODO:reset
- (void)resetItemShowWithMaisl:(NSArray *)mails folder:(MCMailBox*)folder {
    
    if (folder.type == MCMailFolderTypeDrafts ||folder.type == MCMailFolderTypePending) {
        _managerShowKind = MCMailManagerItemShowTrash;
    } else if (folder.type == MCMailFolderTypeStarred){
        MCMailManagerItemShowKind showKind = [self managerShowKindWithMails:mails];
        _managerShowKind = showKind&(~MCMailManagerItemShowMove);
    } else {
         _managerShowKind = [self managerShowKindWithMails:mails];
    }
    BOOL canEdit = mails.count > 0?YES:NO;
    [self restItemShowKind:_managerShowKind edit:canEdit];
}

- (MCMailManagerItemShowKind)managerShowKindWithMails:(NSArray*)mails {
    
    if (mails.count == 0) {
        return MCMailManagerItemShowNormal;
    }
    MCMailManagerItemShowKind showKind = MCMailManagerItemShowAll;
    BOOL haveUnStarMail = NO;
    BOOL haveUnReadMail = NO;
    
    for (MCMailModel *model in mails) {
        if (!model.isRead) {
            haveUnReadMail = YES;
        }
        if (!model.isStar) {
            haveUnStarMail = YES;
        }
    }
    if (!haveUnReadMail && haveUnStarMail) {
        showKind = showKind|MCMailManagerItemShowUnread;
        showKind = showKind &(~MCMailManagerItemShowRead);
    } else if (!haveUnReadMail && !haveUnStarMail) {
        showKind = showKind|MCMailManagerItemShowUnread|MCMailManagerItemShowUnstar;
        showKind = showKind &(~MCMailManagerItemShowRead)&(~MCMailManagerItemShowStar);
    } else if (haveUnReadMail && !haveUnStarMail) {
        showKind = showKind|MCMailManagerItemShowUnstar;
        showKind = showKind &(~MCMailManagerItemShowStar);
    }
    return showKind;
}

- (void)restItemShowKind:(MCMailManagerItemShowKind)showKind edit:(BOOL)canEdit {
    UIButton *bt;
    if (showKind == MCMailManagerItemShowNormal) {
        for (int i = 1; i < 5; i ++) {
            bt = (UIButton*)[self viewWithTag:i];
            [bt setTitle:self.itemNames[i - 1] forState:UIControlStateNormal];
            [self button:bt title:self.itemNames[i - 1] enable:canEdit];
         }
    }
    if (showKind &MCMailManagerItemShowRead) {
        bt = (UIButton*)[self viewWithTag:1];
        [self button:bt title:PMLocalizedStringWithKey(@"PM_Mail_Set_Read") enable:canEdit];
    }
    if (showKind &MCMailManagerItemShowUnread) {
        bt = (UIButton*)[self viewWithTag:1];
        [self button:bt title:PMLocalizedStringWithKey(@"PM_Mail_Set_UnRead") enable:canEdit];
    }
    if (showKind &MCMailManagerItemShowUnstar) {
        bt = (UIButton*)[self viewWithTag:2];
        [self button:bt title:PMLocalizedStringWithKey(@"PM_Mail_UnCollection") enable:canEdit];
    }
    if (showKind &MCMailManagerItemShowStar) {
        bt = (UIButton*)[self viewWithTag:2];
        [self button:bt title:PMLocalizedStringWithKey(@"PM_Mail_Collection") enable:canEdit];
    }
    if (showKind &MCMailManagerItemShowMove) {
        bt = (UIButton*)[self viewWithTag:3];
        [self button:bt title:PMLocalizedStringWithKey(@"PM_Mail_MoveMail") enable:canEdit];
    }
    if (showKind &MCMailManagerItemShowTrash) {
        bt = (UIButton*)[self viewWithTag:4];
        [self button:bt title:PMLocalizedStringWithKey(@"PM_Mail_DeleteMail") enable:canEdit];
    }
}

//private
- (void)button:(UIButton*)bt title:(NSString*)title enable:(BOOL)enable {
    [bt setTitle:title forState:UIControlStateNormal];
    [bt setTitleColor:enable?AppStatus.theme.tintColor:AppStatus.theme.fontTintColor forState:UIControlStateNormal];
    bt.userInteractionEnabled = enable;
}

- (NSArray*)itemNames{
    if (_itemNames == nil) {
        _itemNames = [NSArray arrayWithObjects:PMLocalizedStringWithKey(@"PM_Mail_Set_Read"),PMLocalizedStringWithKey(@"PM_Mail_Collection"),PMLocalizedStringWithKey(@"PM_Mail_MoveMail"),PMLocalizedStringWithKey(@"PM_Mail_DeleteMail"), nil];
    }
    return _itemNames;
}

@end
