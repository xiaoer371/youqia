//
//  MCMailManagerView.h
//  NPushMail
//
//  Created by zhang on 15/12/23.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCMailbox.h"
#import "MCMailModel.h"

typedef NS_OPTIONS(NSInteger, MCMailManagerItemShowKind) {
    MCMailManagerItemShowNormal = 0 ,
    MCMailManagerItemShowRead   = 1 << 0,
    MCMailManagerItemShowUnread = 1 << 1,
    MCMailManagerItemShowStar   = 1 << 2,
    MCMailManagerItemShowUnstar = 1 << 3,
    MCMailManagerItemShowMove   = 1 << 4,
    MCMailManagerItemShowTrash  = 1 << 5,
    MCMailManagerItemShowVip    = 1 << 6,
    MCMailManagerItemShowUnVip  = 1 << 7,
    MCMailManagerItemShowAll    = MCMailManagerItemShowRead|MCMailManagerItemShowStar|MCMailManagerItemShowMove|MCMailManagerItemShowTrash,
};

@class MCMailManagerView;


@protocol MCMailManagerViewDelegate <NSObject>

- (void)mailManagerView:(MCMailManagerView *)mailManagerView didSelectedProcessType:(MCMailProcessType)mailProcessType;
@end

@interface MCMailManagerView : UIView

@property (nonatomic,weak)id<MCMailManagerViewDelegate>delegate;

@property (nonatomic,assign)BOOL show;

- (id)init;
- (void)resetItemShowWithMaisl:(NSArray *)mails folder:(MCMailBox*)folder;

@end
