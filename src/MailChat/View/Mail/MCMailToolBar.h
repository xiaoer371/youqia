//
//  MCMailToolBar.h
//  NPushMail
//
//  Created by zhang on 15/12/25.
//  Copyright © 2015年 sprite. All rights reserved.
//


typedef NS_ENUM(NSInteger,MCHandelMailSet) {
    MCHandelMailSetToMessage = 0,
    MCHandelMailSetToReAll,
    MCHandelMailSetToReSingle, 
    MCHandelMailSetToForward,
    MCHandelMailSetUnRead,
    MCHandelMailSetDelete,
    MCHandelMailSetMove,
    MCHandelMailToEditAgain,
    MCHandelMailToMarkVip,
    MCHandelMailToMarkBacklog,
    MCHandelMailAdjustFont
};


#import <UIKit/UIKit.h>
#import "MCMailBox.h"
#import "MCMailModel.h"
@class MCMailToolBar;
@protocol MCMailToolBarDelegate <NSObject>
- (void)mailToolBar:(MCMailToolBar*)mailToolBar mCHandelMailSet:(MCHandelMailSet)mCHandelMailSet;
- (MCMailTags)toMarkTags;
@end


@interface MCMailToolBar : UIView

@property (nonatomic,weak)id <MCMailToolBarDelegate> delegate;
@property (nonatomic,assign) BOOL isShowPop;
@property (nonatomic,strong)MCMailBox *mailBox;

- (id)initWithDelegate:(id<MCMailToolBarDelegate>)delegate;
- (void)resetBacklogItemView;

@end
