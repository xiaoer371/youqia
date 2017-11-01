//
//  MCMailBoxListCell.h
//  NPushMail
//
//  Created by zhang on 16/3/16.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDBadgedCell.h"
#import "MCMailBox.h"
const static CGFloat kMCMailBoxListViewBageFontSize   = 13.0;
const static CGFloat kMCMailBoxListViewShowSpaceWidth = 0;
const static CGFloat kMCMailBoxListViewCellFontSize   = 16.0;

@interface MCMailBoxListCell : UITableViewCell

@property (nonatomic,strong)MCMailBox *mailBoxModel;
@property (nonatomic,assign)BOOL loadVipMails;
@property (nonatomic,assign)NSInteger mailCount;

@property (weak, nonatomic) IBOutlet UIImageView *boxImageView;
@property (weak, nonatomic) IBOutlet UILabel *boxNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mcCellLeftConstraints;

@end
