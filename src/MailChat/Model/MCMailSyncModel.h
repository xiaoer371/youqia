//
//  MailSyncModel.h
//  NPushMail
//
//  Created by admin on 12/14/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  邮件同步类型
 */
typedef NS_ENUM(NSInteger, MCMailSyncType) {
    /**
     *  同步已读未读状态
     */
    MCMailSyncRead = 0,
    /**
     *  同步收藏状态
     */
    MCMailSyncStar = 1 << 0,
    /**
     *  同步移动或删除状态
     */
    MCMailSyncDeleteOrMove = 1 << 1
};

@interface MCMailSyncModel : NSObject

@property (nonatomic,assign) NSInteger uid;
@property (nonatomic,assign) NSInteger accountId;
@property (nonatomic,assign) NSInteger mailId;
@property (nonatomic,assign) MCMailSyncType syncType;
@property (nonatomic,assign) NSInteger fromBoxId;
@property (nonatomic,assign) NSInteger toBoxId;

/**
 *  尝试同步的次数，即失败的次数
 */
@property (nonatomic,assign) NSInteger tryTimes;

@end