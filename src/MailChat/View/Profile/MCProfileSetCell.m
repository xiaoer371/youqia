//
//  MCProfileSetCell.m
//  NPushMail
//
//  Created by zhang on 16/4/12.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCProfileSetCell.h"

@implementation MCProfileSetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _mCSetLable.textColor = AppStatus.theme.titleTextColor;
    _mcCacheFileSize.textColor = AppStatus.theme.fontTintColor;
    _mCAddAccountImage.image = AppStatus.theme.profileStyle.mCAddAccountImage;
    _updateBadge.layer.cornerRadius = 5.0f;
}

- (void)setMcSettingTitle:(NSString *)mcSettingTitle {
    _mCSetLable.text = mcSettingTitle;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)mcLoadAvatarSweich:(UISwitch *)sender {
    
    if (_loadAvatarChangeValueCallback) {
        _loadAvatarChangeValueCallback(sender.on);
    }
}
@end
