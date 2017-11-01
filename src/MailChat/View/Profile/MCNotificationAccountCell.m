//
//  MCNotificationAccountCell.m
//  NPushMail
//
//  Created by swhl on 16/12/5.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCNotificationAccountCell.h"
#import "MCApnsPush.h"

@interface MCNotificationAccountCell ()

@property (weak, nonatomic) IBOutlet UILabel *accountLab;
@property (weak, nonatomic) IBOutlet UILabel *detailLab;

@end


@implementation MCNotificationAccountCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setMCAccount:(MCAccount *)mCAccount
{
    _mCAccount = mCAccount;
    
    _accountLab.text = _mCAccount.email;
    
    // TODO: 显示推送的设置 详情。
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MCPushSettingModel *pushSettingModel = [[MCApnsPush new] getPushSettingModelWithEmail:mCAccount.email];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *detailStr = @"提醒已关闭";
            if (pushSettingModel.msgPush == 1 && pushSettingModel.mailPush == 1 && pushSettingModel.appPush == 1) {
                detailStr = @"允许新消息/邮件提醒/OA提醒";
            }else if (pushSettingModel.msgPush == 1 && pushSettingModel.mailPush == 1) {
                detailStr = @"允许新消息/邮件提醒";
            }else if (pushSettingModel.msgPush == 1 && pushSettingModel.appPush == 1) {
                detailStr = @"允许新消息/OA提醒";
            }else if (pushSettingModel.mailPush == 1 && pushSettingModel.appPush == 1) {
                detailStr = @"允许新邮件/OA提醒";
            }else if (pushSettingModel.msgPush == 1) {
                detailStr = @"允许新消息提醒";
            }else if (pushSettingModel.mailPush == 1) {
                detailStr = @"允许新邮件提醒";
            }else if(pushSettingModel.appPush == 1) {
                detailStr = @"允许OA提醒";
            }
            
            weakSelf.detailLab.text = detailStr;
        });
    });
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
