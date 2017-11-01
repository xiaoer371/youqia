//
//  MCAppDelegate.h
//  NPushMail
//
//  Created by zhang on 16/1/18.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCTabBarController.h"
#define BUGLY_APP_ID @"4b45bf6159"

@interface MCAppDelegate : UIResponder <UIApplicationDelegate>

@property(nonatomic, strong) UIWindow                   *window;
@property(nonatomic, strong) MCTabBarController         *tabBarController;
@property(strong, nonatomic) MCTouchIdWindow *touchWindow;
@property(strong, nonatomic) MCGestureWindow *gestureWindow;
@property(nonatomic,assign) NSInteger allowRotation;

//loadRootViewController
- (void)displayTabBarViewController;
- (void)displayLoginViewController;

- (void)setTabbarWithWorkspaceFlag:(BOOL)flag;


- (void)doLoginProcess;

@end
