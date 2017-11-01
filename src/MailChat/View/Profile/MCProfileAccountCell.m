//
//  MCProfileAccountCell.m
//  NPushMail
//
//  Created by zhang on 16/4/12.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCProfileAccountCell.h"
#import "UIImageView+WebCache.h"
#import "MCContactManager.h"
#import "UIImageView+MCCorner.h"
#import "MCAvatarHelper.h"
#import "FBKVOController.h"
#import "MCWorkSpaceManager.h"

@implementation MCProfileAccountCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_mCAccountImage cornerRadiusWithMask];
    _mCAccountImage.image = [UIImage imageNamed:@"youqiaIcon.png"];
    _oaAccountLabel.textColor = AppStatus.theme.fontTintColor;
    _mCAccountLabel.textColor = AppStatus.theme.titleTextColor;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.KVOController unobserveAll];
}

- (void)setMCAccount:(MCAccount *)mCAccount {
    
    [self.KVOController unobserveAll];
    _mCAccount = mCAccount;
    _mCAccountLabel.text = mCAccount.email;
    NSString *oaUserName = [MCOAWorkSpaceManager getOaUserNameWithAccount:mCAccount];
    if (oaUserName) {
        _oaAccountLabel.text = [NSString stringWithFormat:@"%@%@",PMLocalizedStringWithKey(@"PM_Login_OA_Account"),oaUserName];
        _oaAccountLabel.hidden = NO;
        _mCAccountLabelTopConstraints.constant = 10;
        
    }else {
        _oaAccountLabel.hidden = YES;
        _mCAccountLabelTopConstraints.constant = 18;
    }
    [_mCAccountImage sd_setImageWithURL:[NSURL URLWithString:_mCAccount.avatarUrl] placeholderImage:_mCAccount.avatarPlaceHolder options:SDWebImageAllowInvalidSSLCertificates];
//    _mCSelectImage.hidden = ![mCAccount.email isEqualToString:AppStatus.currentUser.email];
    
    __weak typeof(self) weakSelf = self;
    [self.KVOController observe:self.mCAccount keyPath:@"avatar" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        [weakSelf.mCAccountImage sd_setImageWithURL:[NSURL URLWithString:weakSelf.mCAccount.avatarUrl] placeholderImage:weakSelf.mCAccount.avatarPlaceHolder options:SDWebImageAllowInvalidSSLCertificates];
    }];
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

//Action
- (IBAction)mCAccountButtonToShowAccountDetail:(UIButton *)sender {
    
    if (_accountInfoComplete) {
        _accountInfoComplete();
    }
}

@end
