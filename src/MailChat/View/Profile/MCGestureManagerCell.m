//
//  MCGestureManagerCell.m
//  NPushMail
//
//  Created by wuwenyu on 16/4/15.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCGestureManagerCell.h"
#import "MCAppSetting.h"
#import "MCAccountConfig.h"
#import "PCCircleViewConst.h"
#import "MCTouchIdHelper.h"
#import "UIView+MJExtension.h"
#import "UIAlertView+Blocks.h"
#import <LocalAuthentication/LAError.h>
#import "MCApnsPush.h"

@implementation MCGestureManagerCell {
    NSString *_title;
    BOOL _isGestureOn;
    BOOL _isTouchIdOn;
    NSIndexPath *_indexPath;
    settingType _settingType;
    MCApnsPush *_apnsPush;
    NSString *_pushSettingEmail;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _apnsPush = [[MCApnsPush alloc] initWithToken:AppSettings.apnsToken clientId:AppSettings.clientId];
    // Initialization code
}

- (void)configureGestureSettingCellWithTitle:(NSString *)title {
    _settingType = gestureSettingType;
    _title = title;
    self.settingSwitch.hidden = NO;
    self.accessoryType = UITableViewCellAccessoryNone;
    _isGestureOn = AppSettings.gesturePasswordFlag;
    _isTouchIdOn = AppSettings.touchIdFlag;
    self.titleLabel.text = PMLocalizedStringWithKey(title);
    if ([_title isEqualToString:@"PM_Mine_GesturePassword"]) {
        [self.settingSwitch setOn:_isGestureOn];
    }
    if ([_title isEqualToString:@"PM_Mine_SetingTouchId"]) {
        [self.settingSwitch setOn:_isTouchIdOn];
    }
    if ([title isEqualToString:@"PM_Mine_Modify_GesturePassword"]) {
        self.settingSwitch.hidden = YES;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}

- (void)configureApnsRemindCellWithTitle:(NSString *)title index:(NSIndexPath *)path email:(NSString *)email {
    if (path.section == 1) return;
    _pushSettingEmail = email;
    _settingType = apnsRemindType;
    _title = title;
    _indexPath = path;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.titleLabel.text = _title;
    BOOL isOn = YES;
    MCPushSettingModel *pushSettingModel = [[MCApnsPush new] getPushSettingModelWithEmail:email];
    if (path.section == 0) {
        if ([title isEqualToString:PMLocalizedStringWithKey(@"PM_Mine_msgPushTitle")]) {
            //消息设置
            if (pushSettingModel.msgPush != 1) {
                isOn = NO;
            }
            //AppSettings.msgPushFlag;
        }else if ([title isEqualToString:PMLocalizedStringWithKey(@"PM_Mine_mailPushTitle")]){
            //isOn = pushSettingModel.mailPush;//AppSettings.mailPushFlag;
            if (pushSettingModel.mailPush != 1) {
                isOn = NO;
            }
        }else if ([title isEqualToString:PMLocalizedStringWithKey(@"PM_Msg_SetOA_Notice")]){
            //isOn = pushSettingModel.mailPush;//AppSettings.oaPushFlag;
            if (pushSettingModel.appPush != 1) {
                isOn = NO;
            }
        }
    }
    else if (path.section == 2) {
        _title = PMLocalizedStringWithKey(@"PM_Mail_Push_Show_Detail");
        // isOn = AppSettings.pushDetailFlag;
        if (pushSettingModel.detailsPush != 1) {
            isOn = NO;
        }
    }
    [self.settingSwitch setOn:isOn animated:NO];
    
}

- (void)configureAddContactCellWithTitle:(NSString *)title importantFlag:(BOOL)importantFlag {
    _settingType = addContactSettingType;
    _title = title;
    self.settingSwitch.hidden = NO;
    self.titleLabel.text = _title;
    self.accessoryType = UITableViewCellAccessoryNone;
    [self.settingSwitch setOn:importantFlag];
}

- (void)configureCellWithSingleTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
    self.settingSwitch.hidden = YES;
    self.accessoryType = UITableViewCellAccessoryNone;
}

- (IBAction)switchValueChange:(id)sender {
    __weak MCGestureManagerCell *weakSelf = self;
    if (_settingType == gestureSettingType) {
        if ([_title isEqualToString:@"PM_Mine_GesturePassword"]) {
            //友盟统计
            [MCUmengManager addEventWithKey:mc_me_ps_fingerprint];
            //首先判断是否开启指纹密码，若是，则需先验证指纹锁，验证通过关闭指纹锁，然后开启手势密码，若指纹锁也关闭，则直接去设置手势密码。
            if (AppSettings.touchIdFlag) {
                //开启指纹解锁后开启手势
                RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Cancel") action:^{
                    if (weakSelf.gestureBlock) {
                        weakSelf.gestureBlock(NO, NO);
                    }
                }];
                RIButtonItem *sureItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Continue") action:^{
                    [[MCTouchIdHelper shared] verificationTouchIdWithOpenGesturePwd:YES title:PMLocalizedStringWithKey(@"PM_Mine_touchIdCloseVerificationTitle") reply:^(BOOL success, NSError *error) {
                        if (success) {
                            //去设置手势密码，设置成功后关闭指纹锁
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (weakSelf.gestureBlock) {
                                    weakSelf.gestureBlock(YES, NO);
                                }
                            });
                        }else {
                            DDLogWarn(@"指纹验证失败");
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (weakSelf.touchIdSetResultBlock) {
                                    weakSelf.touchIdSetResultBlock(success);
                                }
                            });
                        }
                    }];
                }] ;
                UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_Common_Notice") message:PMLocalizedStringWithKey(@"PM_Mine_signatureOpenNotice") cancelButtonItem:cancelItem otherButtonItems:sureItem, nil];
                [alertV show];
                
            }else {
                _isGestureOn = !_isGestureOn;
                if (_isGestureOn) {
                    //去设置手势密码
                    if (weakSelf.gestureBlock) {
                        weakSelf.gestureBlock(YES, NO);
                    }
                }else {
                    //先验证手势密码，验证完成后关闭并直接清空手势密码设置
                    if (weakSelf.gestureBlock) {
                        weakSelf.gestureBlock(NO, YES);
                    }
                }
            }
            return;
        }
        if ([_title isEqualToString:@"PM_Mine_SetingTouchId"]) {
            //友盟统计
            [MCUmengManager addEventWithKey:mc_me_ps_gestures];
            if (AppSettings.gesturePasswordFlag) {
                //开启手势密码后再开启指纹,给个提示。
                RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Cancel") action:^{
                    if (weakSelf.touchIdSetResultBlock) {
                        weakSelf.touchIdSetResultBlock(NO);
                    }
                }];
                
                RIButtonItem *continueItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Continue") action:^{
                    //点击继续则去验证指纹
                    [weakSelf verificationTouchId];
                }];
                
                UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_Common_Notice") message:PMLocalizedStringWithKey(@"PM_Mine_touchIdOpenNotice") cancelButtonItem:cancelItem otherButtonItems:continueItem, nil];
                [alertV show];
            }else {
                //当前手势密码关闭，直接验证指纹
                [self verificationTouchId];
            }
            return;
        }
    }
    
    UISwitch *switchObj = (UISwitch *)sender;
    //当前状态
    BOOL status = [switchObj isOn];
    
    if (_settingType == apnsRemindType) {
        [SVProgressHUD showWithStatus:@"请稍候..."];
        if (_indexPath.section == 0) {
            if ([_title isEqualToString:PMLocalizedStringWithKey(@"PM_Mine_msgPushTitle")]) {
                [self pushOnRemindType:apnsMsgRemindType currentStatus:status];
            }else if ([_title isEqualToString:PMLocalizedStringWithKey(@"PM_Mine_mailPushTitle")]) {
                [self pushOnRemindType:apnsMailRemindType currentStatus:status];
            }else if ([_title isEqualToString:PMLocalizedStringWithKey(@"PM_Msg_SetOA_Notice")]) {
                [self pushOnRemindType:apnsOaRemindType currentStatus:status];
            }
        }else if(_indexPath.section == 2){
            [self pushOnRemindType:apnsDetailRemindType currentStatus:status];
        }
    }
    
    if (_settingType == addContactSettingType) {
        if (self.setAddContactSettingBlock) {
            self.setAddContactSettingBlock(status);
        }
    }
}

- (void)pushOnRemindType:(pushRemindType)type currentStatus:(BOOL)status {
    MCPushSettingModel *pushSettingModel = [_apnsPush getPushSettingModelWithEmail:_pushSettingEmail];
    pushSettingModel.email = _pushSettingEmail;
    switch (type) {
        case apnsMsgRemindType:
            pushSettingModel.msgPush = status;
            break;
        case apnsMailRemindType:
            pushSettingModel.mailPush = status;
            break;
        case apnsOaRemindType:
            pushSettingModel.appPush = status;
            break;
        case apnsDetailRemindType:
            pushSettingModel.detailsPush = status;
            break;
        default:
            break;
    }
    
    __weak MCGestureManagerCell *weakSelf = self;
    [_apnsPush updatePushSettingWithPushSettingModel:pushSettingModel success:^(id response) {
        __strong MCGestureManagerCell *sSelf = weakSelf;
        if (sSelf->_pushSettingEmail) {
            [[MCApnsPush new] setPushSettingConfigWithSettingModel:pushSettingModel];
        }else {
            AppSettings.msgPushFlag = pushSettingModel.msgPush;
            AppSettings.mailPushFlag = pushSettingModel.mailPush;
            AppSettings.oaPushFlag = pushSettingModel.appPush;
            AppSettings.pushDetailFlag = pushSettingModel.detailsPush;
        }
        [SVProgressHUD dismiss];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self.settingSwitch setOn:!status animated:NO];
    }];
}

- (void)verificationTouchId {
    __weak MCGestureManagerCell *weakSelf = self;
    _isTouchIdOn = !_isTouchIdOn;
    NSString *title = PMLocalizedStringWithKey(@"PM_Mine_touchIdOpenVerificationTitle");
    if (!_isTouchIdOn) {
        title = PMLocalizedStringWithKey(@"PM_Mine_touchIdCloseVerificationTitle");
    }
    [[MCTouchIdHelper shared] verificationTouchIdWithOpenGesturePwd:NO title:title reply:^(BOOL success, NSError *error) {
        if (success) {
            AppSettings.touchIdFlag = _isTouchIdOn;
            AppSettings.gesturePasswordFlag = NO;
        }else {
            switch (error.code) {
                case LAErrorUserCancel:{
                    break;
                }
                case LAErrorUserFallback: {
                    break;
                }
                case LAErrorTouchIDNotEnrolled: {
                    //设备没有进行Touch ID 指纹注册
                    [weakSelf touchIdCloseWaring];
                    break;
                }
                case LAErrorPasscodeNotSet: {
                    //用户没有在设备Settings中设定密码
                    [weakSelf touchIdCloseWaring];
                    break;
                }
                case LAErrorSystemCancel: {
                    // 系统终止了验证
                    break;
                }
                default:
                    [weakSelf touchIdCloseWaring];
                    break;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.touchIdSetResultBlock) {
                self.touchIdSetResultBlock(success);
            }
        });
    }];
}

- (void)touchIdCloseWaring {
    dispatch_async(dispatch_get_main_queue(), ^{
        DDLogWarn(@"指纹验证失败");
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_Common_Notice") message:PMLocalizedStringWithKey(@"PM_Mine_touchIdCloseWaring") delegate:nil cancelButtonTitle:PMLocalizedStringWithKey(@"PM_Common_Sure") otherButtonTitles:nil, nil];
        [alertV show];
    });
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
