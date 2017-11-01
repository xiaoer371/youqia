//
//  MCMailToolBar.m
//  NPushMail
//
//  Created by zhang on 15/12/25.
//  Copyright © 2015年 sprite. All rights reserved.
//


#import "MCMailToolBar.h"
#import "MCPopoverView.h"
#import "UIActionSheet+Blocks.h"
@interface MCMailToolBar ()

@property (nonatomic,strong)NSArray * handelItemTitles;

@end

const static CGFloat   kMCMailToolBarHight             = 51.0;
const static CGFloat   kMCMailToolBarSpaceLineHight    = 0.5;
const static CGFloat   kMCMailToolBarItemLableHight    = 12.0;
const static CGFloat   kMCMailToolBarItemLableX        = 32.0;
const static CGFloat   kMCMailToolBarItemLableFontSize = 9.0;
const static NSInteger kMCMailToolBarItemCount         = 4;


@implementation MCMailToolBar


- (id)initWithDelegate:(id<MCMailToolBarDelegate>)delegate{
    
    if (self == [super init]) {
        self.delegate = delegate;
        [self setUp];
    }
    return self;
}

-(void)setUp {
    
    self.frame = CGRectMake(0, ScreenHeigth - kMCMailToolBarHight - NAVIGATIONBARHIGHT, ScreenWidth, kMCMailToolBarHight);
    [self setBackgroundColor:AppStatus.theme.toolBarBackgroundColor];
    UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, kMCMailToolBarSpaceLineHight)];
    line.backgroundColor = AppStatus.theme.toolBarSeparatorColor;
    [self addSubview:line];
    
    for (int i = 0; i < kMCMailToolBarItemCount; i++){
        UIButton *toolBarButton = [self itemWithIndex:i];
        [self addSubview:toolBarButton];
    }
    [self resetBacklogItemView];
}

- (UIButton*)itemWithIndex:(NSInteger)index{
    UIButton*toolBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    toolBarButton.frame = CGRectMake((ScreenWidth/kMCMailToolBarItemCount)*index, kMCMailToolBarSpaceLineHight, ScreenWidth/kMCMailToolBarItemCount, kMCMailToolBarHight);
    toolBarButton.tag   = index;
    [toolBarButton setExclusiveTouch:YES];
    [toolBarButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"mc_maildetailManager_%ld",(unsigned long)index]] forState:UIControlStateNormal];
    [toolBarButton addTarget:self action:@selector(buttonDidHandelSet:) forControlEvents:UIControlEventTouchUpInside];
    [toolBarButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 18, 0)];
    UILabel*toolBarItemLable = [[UILabel alloc]initWithFrame:CGRectMake(0, kMCMailToolBarItemLableX, ScreenWidth/kMCMailToolBarItemCount, kMCMailToolBarItemLableHight)];
    toolBarItemLable.textColor = [UIColor colorWithHexString:@"737373"];
    toolBarItemLable.font = [UIFont systemFontOfSize:kMCMailToolBarItemLableFontSize];
    toolBarItemLable.textAlignment = NSTextAlignmentCenter;
    toolBarItemLable.text = self.handelItemTitles[index];
    toolBarItemLable.tag = 10000+index;
    [toolBarButton addSubview:toolBarItemLable];
    
    return toolBarButton;
}

- (void)resetBacklogItemView {
    
    UIButton *button = (UIButton*)[self viewWithTag:2];
    UILabel *label = (UILabel*)[button viewWithTag:10002];
    MCMailTags tags = [self.delegate toMarkTags];
    if (tags&MCMailTagBacklog) {
        [button setImage:[UIImage imageNamed:@"mc_maildetailManager_h2.png"] forState:UIControlStateNormal];
        [label setTextColor:AppStatus.theme.tintColor];
    } else {
        [button setImage:[UIImage imageNamed:@"mc_maildetailManager_2.png"] forState:UIControlStateNormal];
        [label setTextColor:[UIColor colorWithHexString:@"737373"]];
    }
}

#pragma mark-buttonDidHandelSet

- (void)buttonDidHandelSet:(UIButton*)sender{
    
    if ((self.mailBox.type == MCMailFolderTypeSent||
        self.mailBox.type == MCMailFolderTypeSpam||
        self.mailBox.type == MCMailFolderTypeTrash) &&
        sender.tag == 2) {
        return;
    }
    
    switch (sender.tag) {
        case 0:
        {
            if ([_delegate respondsToSelector:@selector(mailToolBar:mCHandelMailSet:)]) {
                [_delegate mailToolBar:self mCHandelMailSet:MCHandelMailSetToMessage];
            }
        }
            break;
        case 1:
        {
            [self replyOrForwardAction];
        }
            break;
        case 2:
        {
            if ([_delegate respondsToSelector:@selector(mailToolBar:mCHandelMailSet:)]) {
                [_delegate mailToolBar:self mCHandelMailSet:MCHandelMailToMarkBacklog];
                [self resetBacklogItemView];
            }
        }
            break;
        case 3:
        {
            [self moreAction];
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark -private

- (void)replyOrForwardAction {
    RIButtonItem *reActionItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Mail_EditOptionrReply") action:^{
        if ([_delegate respondsToSelector:@selector(mailToolBar:mCHandelMailSet:)]) {
            [_delegate mailToolBar:self mCHandelMailSet:MCHandelMailSetToReSingle];
        }
    }];
    RIButtonItem *reAllActionItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Mail_EditOptionReplyAll") action:^{
        if ([_delegate respondsToSelector:@selector(mailToolBar:mCHandelMailSet:)]) {
            [_delegate mailToolBar:self mCHandelMailSet:MCHandelMailSetToReAll];
        }
    }];
    RIButtonItem *fwdActionItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Mail_EditOptionForward") action:^{
        if ([_delegate respondsToSelector:@selector(mailToolBar:mCHandelMailSet:)]) {
            [_delegate mailToolBar:self mCHandelMailSet:MCHandelMailSetToForward];
        }
    }];
    
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Cancel")];
    NSString *title = [NSString stringWithFormat:@"%@/%@",PMLocalizedStringWithKey(@"PM_Mail_EditOptionrReply"),PMLocalizedStringWithKey(@"PM_Mail_EditOptionForward")];
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:title cancelButtonItem:cancelItem destructiveButtonItem:nil otherButtonItems:reActionItem,reAllActionItem,fwdActionItem ,nil];
    [actionSheet showInView:self];
}

- (void)moreAction {
   
    RIButtonItem *moveActionItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Mail_MoveMail") action:^{
        if ([_delegate respondsToSelector:@selector(mailToolBar:mCHandelMailSet:)]) {
            [_delegate mailToolBar:self mCHandelMailSet:MCHandelMailSetMove];
        }
    }];
    RIButtonItem *deleteActionItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Mail_DeleteMail") action:^{
        if ([_delegate respondsToSelector:@selector(mailToolBar:mCHandelMailSet:)]) {
            [_delegate mailToolBar:self mCHandelMailSet:MCHandelMailSetDelete];
        }
    }];
    RIButtonItem *readActionItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Mail_Set_UnRead") action:^{
        if ([_delegate respondsToSelector:@selector(mailToolBar:mCHandelMailSet:)]) {
            [_delegate mailToolBar:self mCHandelMailSet:MCHandelMailSetUnRead];
        }
    }];
    
    RIButtonItem *editAgainItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Mail_EditAgain") action:^{
        if ([_delegate respondsToSelector:@selector(mailToolBar:mCHandelMailSet:)]) {
            [_delegate mailToolBar:self mCHandelMailSet:MCHandelMailToEditAgain];
        }
    }];
    
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Cancel")];
    MCMailTags tags = [_delegate toMarkTags];
    RIButtonItem *markVipItem = [RIButtonItem itemWithLabel:tags&MCMailTagImportant?PMLocalizedStringWithKey(@"PM_Mail_UnMarkVIPMail"):PMLocalizedStringWithKey(@"PM_Mail_MrakVIPMail") action:^{
        if ([_delegate respondsToSelector:@selector(mailToolBar:mCHandelMailSet:)]) {
            [_delegate mailToolBar:self mCHandelMailSet:MCHandelMailToMarkVip];
        }
    }];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:PMLocalizedStringWithKey(@"PM_Mail_More") cancelButtonItem:cancelItem destructiveButtonItem:nil otherButtonItems:moveActionItem,deleteActionItem,readActionItem, nil];
    if (_mailBox.type == MCMailFolderTypeSent) {
        [actionSheet addButtonItem:editAgainItem];
    } else if (_mailBox.type == MCMailFolderTypeInbox) {
        [actionSheet addButtonItem:markVipItem];
    }
    RIButtonItem *adjustFont = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Mail_AdjustFont_Set") action:^{
        if ([_delegate respondsToSelector:@selector(mailToolBar:mCHandelMailSet:)]) {
            [_delegate mailToolBar:self mCHandelMailSet:MCHandelMailAdjustFont];
        }
    }];
    [actionSheet addButtonItem:adjustFont];
    actionSheet.destructiveButtonIndex = 1;
    [actionSheet showInView:self];
}

#pragma mark-
- (NSArray*)handelItemTitles{
    return @[PMLocalizedStringWithKey(@"PM_Msg_AddChats"),
             [NSString stringWithFormat:@"%@/%@",PMLocalizedStringWithKey(@"PM_Mail_EditOptionrReply"),PMLocalizedStringWithKey(@"PM_Mail_EditOptionForward")],
             PMLocalizedStringWithKey(@"PM_Mail_backlogMails"),
             PMLocalizedStringWithKey(@"PM_Mail_More")];
    
}

@end
