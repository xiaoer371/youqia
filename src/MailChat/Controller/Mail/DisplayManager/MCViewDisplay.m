//
//  MCViewDisplay.m
//  NPushMail
//
//  Created by zhang on 2016/11/1.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCViewDisplay.h"
@implementation MCViewDisplay

+ (MCTabBarController*)taBarVC {
    MCAppDelegate *mcAppDelegate = (MCAppDelegate*)[UIApplication sharedApplication].delegate;
    return mcAppDelegate.tabBarController;
}

+ (MCTabBarController*)gotoRootViewController {
    MCTabBarController *tabVC = [self taBarVC];
    NSInteger index = [tabVC selectedIndex];
    UINavigationController *nav = tabVC.viewControllers[index];
    NSInteger count = nav.viewControllers.count;
    
    if (count > 1) {
        [nav popToRootViewControllerAnimated:NO];
    }
    return tabVC;
}

+ (void)gotoMailListViewController {
   MCTabBarController *tabVC =  [self gotoRootViewController];
    if (tabVC.selectedIndex != 0) {
        tabVC.selectedIndex = 0;
    }
}

+ (UIViewController *)getCurrentViewController {
    MCTabBarController *tabVC = [self taBarVC];
    NSInteger index = [tabVC selectedIndex];
    UINavigationController *nav = [tabVC.viewControllers objectAtIndex:index];
    NSInteger count = nav.viewControllers.count;
    if (count > 1) {
        UIViewController *vc = [nav.viewControllers objectAtIndex:count -1];
        return vc;
    }
    return nav.viewControllers[0];
}

+ (UIViewController *)getRootViewController {
    MCTabBarController *tabVC = [self taBarVC];
    NSInteger index = [tabVC selectedIndex];
    UINavigationController *nav = tabVC.viewControllers[index];
    return nav.viewControllers[0];
}
@end
