//
//  MCVIPMailListCell.h
//  NPushMail
//
//  Created by zhang on 16/8/25.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"
#import "MCMailModel.h"
#import "MCMailBox.h"
#import "MCContactModel.h"
static NSString* const kMCVipAvatarMailCellIdentity = @"MCVIPAvatarMailCell";
static NSString* const kMCVipMailCellIdentity = @"MCVIPMailCell";

@class MCVIPMailListCell;
@protocol MailListCellDelegate <NSObject>
@optional
//点击头像
- (void)tapAvatar:(MCVIPMailListCell*)cell contact:(MCContactModel*)contact;
@end


@interface MCVIPMailListCell : MGSwipeTableCell

@property (nonatomic,weak)IBOutlet UIImageView *avatarImageView;
@property (nonatomic,weak)IBOutlet UIImageView *unreadImageView;
@property (nonatomic,weak)IBOutlet UIImageView *vipImageView;
@property (nonatomic,weak)IBOutlet UIImageView *attachImageView;
@property (nonatomic,weak)IBOutlet UIImageView *starImageView;
@property (nonatomic,weak)IBOutlet UILabel *fromAdLabel;
@property (nonatomic,weak)IBOutlet UILabel *timeLabel;
@property (nonatomic,weak)IBOutlet UILabel *subjectLabel;
@property (nonatomic,weak)IBOutlet UILabel *contentLabel;
@property (nonatomic,weak)IBOutlet UIImageView *replyImageView;
@property (nonatomic,weak)IBOutlet UIImageView *failSentImageView;
//选中状态
@property (nonatomic,strong)UIImageView *mSelectedIndicator;


@property (nonatomic,weak)IBOutlet NSLayoutConstraint *vipImageLeftConstraint;
@property (nonatomic,weak)IBOutlet NSLayoutConstraint *fromAdLabelLeftConstraint;
@property (nonatomic,weak)IBOutlet NSLayoutConstraint *contentRightConstraint;
@property (nonatomic,weak)IBOutlet NSLayoutConstraint *timeLabelWidthConstraint;
@property (nonatomic,weak)IBOutlet NSLayoutConstraint *unreadLabelLeftConstraint;
@property (nonatomic,weak)IBOutlet NSLayoutConstraint *replyImageRightConstraint;
@property (nonatomic,weak)IBOutlet NSLayoutConstraint *attachLabelRightConstraint;
@property (nonatomic,weak)IBOutlet NSLayoutConstraint *leftContentConstraint;

@property (nonatomic,strong)MCMailModel *model;
@property (nonatomic,strong)MCMailBox *mailBox;
@property (nonatomic,assign)BOOL isSelected;
@property (nonatomic,assign)BOOL vipSection;
@property (nonatomic,assign)BOOL loadAvatar;
@property (nonatomic,weak)id <MailListCellDelegate> cellDelegate;

+ (UINib *)mailCellNib;
+ (UINib *)avatarMailCellNib;

- (void)changeMSelectedState;
@end
