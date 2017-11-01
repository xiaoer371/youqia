//
//  MCAccountInfoBaseCell.m
//  NPushMail
//
//  Created by zhang on 16/4/25.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAccountInfoCell.h"
#import "MCContactManager.h"
#import "MCAccountManager.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+MCCorner.h"
#import "FBKVOController.h"
#import "MCAvatarHelper.h"
@implementation MCAccountInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _mcTitle.textColor = AppStatus.theme.titleTextColor;
    _mcName.textColor = AppStatus.theme.fontTintColor;
    [_mcAvatar cornerRadiusWithMask];
}

- (void)setTitle:(NSString *)title {
    _mcTitle.text = title;
}

- (void)setAccount:(MCAccount *)account {
    
    [self removeObserver];
    _account = account;
    if (!account.displayName||account.displayName.length == 0) {
        MCContactModel *contact = [[MCContactManager sharedInstance] getOrCreateContactWithEmail:account.email name:account.displayName];
        _mcName.text = contact.displayName;
        account.displayName = contact.displayName;
        
        [[MCAccountManager shared] updateAccount:account withNickName:account.displayName company:contact.company dept:contact.enterpriseDepartMent title:contact.position success:nil failure:nil];
        
    } else {
        _mcName.text = account.displayName;
    }
    
    [_mcAvatar sd_setImageWithURL:[NSURL URLWithString:account.avatarUrl] placeholderImage:account.avatarPlaceHolder options:SDWebImageAllowInvalidSSLCertificates];
    [self addObserver];
}

- (void)addObserver {
    
    __weak typeof(self) weakSelf = self;
    [self.KVOController observe:_account keyPath:@"displayName" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        NSString *displayName = change[NSKeyValueChangeNewKey];
        if (![displayName isKindOfClass:[NSNull class]]) {
            weakSelf.mcName.text = displayName;
            [weakSelf.mcAvatar sd_setImageWithURL:[NSURL URLWithString:weakSelf.account.avatarUrl] placeholderImage:weakSelf.account.avatarPlaceHolder options:SDWebImageAllowInvalidSSLCertificates];
        }
    }];
}

- (void)removeObserver{
    [self.KVOController unobserveAll];
}
//Switch action
- (IBAction)mcSwitchOn:(UISwitch*)sender {
    
    if (_mcSwitchONComplete) {
        _mcSwitchONComplete(sender.on);
    }
}

@end
