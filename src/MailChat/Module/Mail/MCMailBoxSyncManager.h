//
//  MCMailBoxSyncManager.h
//  NPushMail
//
//  Created by admin on 8/24/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCMailBox.h"
#import "MCMailManager.h"


@interface MCMailBoxSyncManager : NSObject

@property (nonatomic,strong,readonly) MCMailBox *folder;

/**
 *  请不要直接创建，调用 MCMailBoxSyncPool 来获取相应的 manager
 */
- (instancetype)initWithMailBox:(MCMailBox *)mailBox;

/**
 * 获取本地邮件
 */
- (NSArray *)getLocalMailsWithWindowSize:(NSInteger)windowSize;

/**
 * 获取本地重要邮件
 */
- (NSArray *)getLocalImportantMails;

/**
 * 获取本地代办邮件
 */
- (NSArray *)getLocalBackLogMails;
/**
 * 获取本地收藏邮件
 */
- (NSArray*)getAllStarMails;
/**
 * 获取本地往来邮件
 */
- (NSArray*)getContactMailsWithContact:(NSString*)email fromIndex:(NSInteger)index;
/**
 * 获取待发送邮件
 */
- (NSArray*)getPendingMails;
/**
 *  获取最新的N封邮件，返回按uid从大到小排序的邮件列表和状态
 *
 *  @param windowSize       要获取的邮件数量
 *  @param success          成功回调，返回按uid从大到小排序的邮件列表，会 copy 此block，避免循环引用
 *  @param failure          失败回调，返回错误信息, 会 copy 此block，避免循环引用
 */
- (void)getLatestMailsWithWindowSize:(NSInteger)windowSize
                             success:(SuccessBlock)success
                             failure:(FailureBlock)failure;


@end
