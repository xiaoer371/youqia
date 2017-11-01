//
//  MCTool.h
//  NPushMail
//
//  Created by wuwenyu on 16/2/18.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCAppDelegate.h"
#import <UserNotifications/UserNotifications.h>

static NSString *const kMCNotificationDeleteActionIdentity = @"cn.mailchat.deleteActionIdentity-apns";
static NSString *const kMCNotificationReadActionIdentity = @"cn.mailchat.readActionIdentity-apns";
static NSString *const kMCNotificationCategoryIdentity = @"cn.mailchat.notificationCatoegory-apns";

@interface MCTool : NSObject

+ (instancetype)shared;

/**
 *  根据文件名得到对应的文件icon图片
 *
 *  @param extension
 *
 *  @return
 */
- (UIImage *)fileImageIconWithFileName:(NSString *)fileName;
/**
 *  获取文件大小（换算后）
 *
 *  @param length 文件字节长度
 *
 *  @return 
 */
- (NSString *)getFileSizeWithLength:(long)length;
/**
 *  int 转日期
 *
 *  @param timeMills 毫秒
 *
 *  @return
 */
- (NSDate *)getDateFromTimeMills:(int64_t)timeMills;
/**
 *  int 转日期
 *
 *  @param seconds 秒
 *
 *  @return
 */
- (NSDate *)getDateFromTimeSeconds:(int64_t)seconds;
/**
 *  获取设备IP地址
 */
- (NSString *)deviceIPAdress;
/**
 *  注册APNS
 */
- (void) registerRemoteNoticationsWithAppDelegate:(id<UNUserNotificationCenterDelegate>)appDelegate;
/**
 * 替换china-channel.com域名为35.cn
 *
 *  @param email
 *
 *  @return
 */
- (NSString *)replaceDominWith35cn:(NSString *)email;


/**
 获取启动页背景图片

 @return 获取启动页背景图片
 */
- (UIImage *)getBackgroundImage;


/**
 *  分享邮洽
 */
- (void)shareYouqia;
@end
