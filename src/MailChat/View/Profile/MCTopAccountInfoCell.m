//
//  MCTopAccountInfoCell.m
//  NPushMail
//
//  Created by wuwenyu on 16/8/22.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCTopAccountInfoCell.h"
#import "MCContactModel.h"
#import "UIImageView+WebCache.h"
#import "MCAvatarHelper.h"
#import "UIImageView+MCCorner.h"

@implementation MCTopAccountInfoCell {
    MCAccount *_curAccount;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _currentAccountImgView.hidden = YES;
    // Initialization code
}

- (void)configureCellWithModel:(id)model {
    MCAccount *act = (MCAccount *)model;
    _curAccount = act;
    _currentAccountImgView.hidden = YES;
    if ([_curAccount.email isEqualToString:AppStatus.currentUser.email]) {
        _currentAccountImgView.hidden = NO;
    }
    [self.avatorImgView cornerRadiusWithMask];
    [self.avatorImgView sd_setImageWithURL:[NSURL URLWithString:act.avatarUrl] placeholderImage:act.avatarPlaceHolder options:SDWebImageAllowInvalidSSLCertificates];
    self.accountLabel.text = act.email;
    [self.editBtn setBackgroundImage:[UIImage imageNamed:@"deleteAccountIcon.png"] forState:UIControlStateNormal];
}

- (IBAction)deleteAccountAction:(id)sender {
    if (self.delAccountBlock) {
        self.delAccountBlock(_curAccount);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
