//
//  MCMailNotificationModel.h
//  NPushMail
//
//  Created by admin on 5/19/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCMailAddress.h"

/**
 *  邮件消息通知实体
 */
@interface MCMailNotificationModel : NSObject

/**
 *  邮箱uid
 */
@property (nonatomic, assign) NSInteger mailUid;

/**
 *  收件人邮箱地址
 */
@property (nonatomic, copy) NSString *toMail;

/**
 *  标题
 */
@property (nonatomic, copy) NSString *subject;

/**
 *  发件人信息
 */
@property (nonatomic, strong) MCMailAddress *from;

/**
 *  时间戳（毫秒）
 */
@property (nonatomic, assign) NSTimeInterval time;

/**
 *  文件夹
 */
@property (nonatomic, copy) NSString *folder;
/**
 *  文件夹名称
 */
@property (nonatomic, copy) NSString *folderName;
/**
 *  文件夹级别
 */
@property (nonatomic,assign)NSInteger level;
/**
 *  邮件摘要
 */
@property (nonatomic, copy) NSString *briefContent;
/**
 *  附件数量
 */
@property (nonatomic,assign)NSInteger *attachCount;

- (id)initModelWith:(NSDictionary*)notifyInfo;

@end
