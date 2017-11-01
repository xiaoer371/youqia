//
//  MCMailBoxListCell.m
//  NPushMail
//
//  Created by zhang on 16/3/16.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCMailBoxListCell.h"
#import "MCMailManager.h"
#import "CustomBadge.h"
#import "MCAppSetting.h"
@interface MCMailBoxListCell ()
@property (nonatomic,strong)CustomBadge *mcMailBadge;
@end

const CGFloat kMCBoxCellDefaultLeftConstrains = 39;
const CGFloat kMCBoxcellChangeFactorLeftConstrains = 16;

@implementation MCMailBoxListCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame] ;
    self.selectedBackgroundView.backgroundColor = [UIColor colorWithHexString:@"ecf4fb"];
    _boxNameLabel.textColor = [UIColor colorWithHexString:@"43505e"];
    self.backgroundColor = [UIColor whiteColor];
    
    _mcMailBadge = [CustomBadge customBadgeWithString:@"0" withScale:1];
    _mcMailBadge.badgeStyle.badgeInsetColor = [UIColor colorWithHexString:@"f74c31"];
    CGPoint centerPoint = CGPointMake(CGRectGetWidth(self.frame) - 34, CGRectGetHeight(self.frame)/2);
    _mcMailBadge.center = centerPoint;
    _mcMailBadge.clipsToBounds = YES;
    [self addSubview:_mcMailBadge];
}

- (void)setMailBoxModel:(MCMailBox *)mailBoxModel {
    
    if (mailBoxModel.type == MCMailFolderTypeSmartBox && !self.loadVipMails) {
        [_mcMailBadge autoBadgeSizeWithString:nil];
        _boxNameLabel.text = nil;
        _boxImageView.image = nil;
        return;
    }
    _mailBoxModel = mailBoxModel;
    _boxNameLabel.text = mailBoxModel.name;
    _boxImageView.image = mailBoxModel.boxIconIamge;
    _boxImageView.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
    NSInteger count = _mailBoxModel.unreadCount;
    NSString *badgeValue = (count <= 0||count == NSNotFound)? nil:[NSString stringWithFormat:@"%ld",(long)count];
    [_mcMailBadge autoBadgeSizeWithString:badgeValue];
    CGPoint centerPoint = CGPointMake(CGRectGetWidth(self.frame) - 34, CGRectGetHeight(self.frame)/2);
    _mcMailBadge.center = centerPoint;
    _mcCellLeftConstraints.constant = kMCBoxCellDefaultLeftConstrains + mailBoxModel.level*33;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
