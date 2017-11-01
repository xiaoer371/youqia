//
//  MCViewDisplay.h
//  NPushMail
//
//  Created by zhang on 2016/11/1.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCAppDelegate.h"
@interface MCViewDisplay : NSObject

+ (MCTabBarController*)gotoRootViewController;
+ (void)gotoMailListViewController;
+ (UIViewController *)getCurrentViewController;
+ (UIViewController *)getRootViewController;

@end
