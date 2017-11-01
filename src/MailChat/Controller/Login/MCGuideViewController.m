//
//  MCGuideViewController.m
//  NPushMail
//
//  Created by zhang on 2016/10/19.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCGuideViewController.h"
#import "UIImage+VJDeviceSpecialMedia.h"
#import "MCAppSetting.h"
@interface MCGuideViewController ()

@end

@implementation MCGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setViews];
}

- (void)setViews {
    self.guideImageView.image = [UIImage vj_imageForDeviceWithName:@"userGuide" type:@"jpg"];
    self.goOnLoginGmail.layer.cornerRadius = 22.5f;
    self.goOnLoginGmail.backgroundColor = AppStatus.theme.tintColor;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:PMLocalizedStringWithKey(@"PM_Login_MailChat")];
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [str length])];
    [self.goOnMailChat setAttributedTitle:str forState:UIControlStateNormal];
    if (AppSettings.lastAccountId > 0) {
        [self.goOnLoginGmail setTitle:PMLocalizedStringWithKey(@"PM_Login_Gmail") forState:UIControlStateNormal];
    } else {
        self.goOnMailChat.hidden = YES;
        [self.goOnLoginGmail setTitle:PMLocalizedStringWithKey(@"PM_Login_MailChat") forState:UIControlStateNormal];
        _goOnGmailBottomConstraint.constant -= 30;
    }
}

- (IBAction)getGoOnLoginGmailAction:(id)sender {
    
    [UIView animateWithDuration:0.3 animations:^{
//        self.view.alpha = 0.3;
    } completion:^(BOOL finished) {
        if (_goOnLoginGmailAction) {
            _goOnLoginGmailAction(AppSettings.lastAccountId > 0? YES:NO);
        }
    }];
}

- (IBAction)getGoOnMailChatAction:(id)sender {

    [UIView animateWithDuration:0.3 animations:^{
//        self.view.alpha = 0.3;
    } completion:^(BOOL finished) {
        if (_goOnLoginGmailAction) {
            _goOnLoginGmailAction(NO);
        }
    }];
}
@end
