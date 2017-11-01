//
//  MCGestureManagerCell.h
//  NPushMail
//
//  Created by wuwenyu on 16/4/15.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  手势密码操作回调
 *
 *  @param isOn                    是否开启手势密码
 *  @param needVerificationGesture 是否需要验证手势密码
 */
typedef void(^setGesturePwdBlcok)(BOOL isOn, BOOL needVerificationGesture);
typedef void(^setTouchIdResult)(BOOL success);
typedef void(^setAddContactSettingResult)(BOOL flag);

/**
 设置的类型
 */
typedef enum : NSUInteger {
    apnsRemindType,         //消息提醒设置
    gestureSettingType,     //手势密码或者指纹设置
    addContactSettingType,  //添加联系人页面相关设置
} settingType;

typedef enum : NSUInteger {
    apnsMsgRemindType,         //消息提醒设置
    apnsMailRemindType,     //邮件提醒设置
    apnsOaRemindType,  //oa提醒设置
    apnsDetailRemindType,  //通知详情提醒设置
} pushRemindType;

@interface MCGestureManagerCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *settingSwitch;
@property (strong, nonatomic) setGesturePwdBlcok gestureBlock;
@property (strong, nonatomic) setTouchIdResult touchIdSetResultBlock;
@property (strong, nonatomic) setAddContactSettingResult setAddContactSettingBlock;
- (void)configureGestureSettingCellWithTitle:(NSString *)title;
- (void)configureApnsRemindCellWithTitle:(NSString *)title index:(NSIndexPath *)path email:(NSString *)email;
- (void)configureAddContactCellWithTitle:(NSString *)title importantFlag:(BOOL)importantFlag;
/**
 *  配置单独只有标题的
 *
 *  @param title
 */
- (void)configureCellWithSingleTitle:(NSString *)title;
- (IBAction)switchValueChange:(id)sender;

@end
