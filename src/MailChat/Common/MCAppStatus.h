//
//  MCAppStatus.h
//  NPushMail
//
//  Created by admin on 12/24/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "MCAccount.h"
#import "MCThemeManager.h"
#import "MCAccountData.h"
#import "MCTouchIdWindow.h"
#import "MCGestureWindow.h"

#define AppStatus [MCAppStatus shared]

@protocol OIDAuthorizationFlowSession;

@interface MCAppStatus : NSObject

+ (instancetype)shared;

/**
 *  当前网络状态
 */
@property (nonatomic,assign) NetworkStatus networkStatus;

/**
 *  当前登录用户
 */
@property (nonatomic,strong) MCAccount *currentUser;

/**
 *  当前登录用户的数据
 */
@property (nonatomic,strong) MCAccountData *accountData;
@property (nonatomic,strong) MCTouchIdWindow *touchIdWindow;
@property (nonatomic,strong) MCGestureWindow *gestureWindow;
/**
 *  文档文件夹路径
 */
@property (nonatomic,strong,readonly) NSString *documentDir;

@property (nonatomic,strong) MCTheme *theme;

@property(nonatomic, strong, nullable) id<OIDAuthorizationFlowSession> currentAuthorizationFlow;


@end
