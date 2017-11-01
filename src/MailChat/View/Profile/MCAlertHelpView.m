//
//  MCAlertHelpView.m
//  NPushMail
//
//  Created by wuwenyu on 16/4/22.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAlertHelpView.h"

static const CGFloat originX = 10;
static const CGFloat originY = 10;

@interface MCAlertHelpView ()

@property (nonatomic, strong)  UIButton *alertOnOffLabel;

@end

@implementation MCAlertHelpView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UILabel* newMailAlertLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, 150, 21)];
        newMailAlertLabel.backgroundColor = [UIColor clearColor];
        newMailAlertLabel.text = PMLocalizedStringWithKey(@"PM_Mine_NewMailAlert");
        newMailAlertLabel.textColor = AppStatus.theme.titleTextColor;
        newMailAlertLabel.font = [UIFont systemFontOfSize:17.0f];
        
        _alertOnOffLabel = [UIButton buttonWithType:UIButtonTypeCustom];
        _alertOnOffLabel.frame = CGRectMake(ScreenWidth - 80 - 10, originY, 80, 21);
        [_alertOnOffLabel setTitleColor:AppStatus.theme.tintColor forState:UIControlStateNormal];
        [_alertOnOffLabel setTitle:PMLocalizedStringWithKey(@"PM_Mine_AlreadyPushOn") forState:UIControlStateNormal];
        _alertOnOffLabel.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        _alertOnOffLabel.titleLabel.textAlignment = NSTextAlignmentRight;

        if ([[[UIApplication sharedApplication] currentUserNotificationSettings] types] == UIUserNotificationTypeNone) {
            
            UIImageView *lineImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 85.5, ScreenWidth, 0.5)];
            lineImage.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
            [self addSubview:lineImage];
            DDLogWarn(@"手机设置中消息提醒已关闭");
            [_alertOnOffLabel setTitle:PMLocalizedStringWithKey(@"PM_Mine_AlreadyPushOff") forState:UIControlStateNormal];
        }

        
        UIButton *setNotification = [UIButton buttonWithType:UIButtonTypeCustom];
        setNotification.frame = self.bounds;
        setNotification.backgroundColor = [UIColor clearColor];
        [setNotification addTarget:self action:@selector(setNotification:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:setNotification];
        
        
        UILabel *alertMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, _alertOnOffLabel.frame.origin.y + _alertOnOffLabel.frame.size.height + originY, ScreenWidth - originX*2, 32)];
        alertMsgLabel.backgroundColor = [UIColor clearColor];
        alertMsgLabel.textColor = AppStatus.theme.fontTintColor;
        alertMsgLabel.font = [UIFont systemFontOfSize:13.0f];
        alertMsgLabel.numberOfLines = 0;
        alertMsgLabel.text = PMLocalizedStringWithKey(@"PM_Mine_PushSettingGuide");
        
        [self addSubview:newMailAlertLabel];
        [self addSubview:_alertOnOffLabel];
        [self addSubview:alertMsgLabel];
    }
    return self;
}

- (void)setNotification:(UIButton *)sender
{
    if (EGOVersion_iOS10) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=NOTIFICATIONS_ID&path=com.c35.ptc.pushmail"]];
    }
}

- (void)refreshsubLabelText
{
    if ([[[UIApplication sharedApplication] currentUserNotificationSettings] types] == UIUserNotificationTypeNone) {
        [_alertOnOffLabel setTitle:PMLocalizedStringWithKey(@"PM_Mine_AlreadyPushOff") forState:UIControlStateNormal];

        return;
    }
    [_alertOnOffLabel setTitle:PMLocalizedStringWithKey(@"PM_Mine_AlreadyPushOn") forState:UIControlStateNormal];
}

@end
