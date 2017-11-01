//
//  MCBaseWorkSpaceManager.m
//  NPushMail
//
//  Created by wuwenyu on 2017/2/9.
//  Copyright © 2017年 sprite. All rights reserved.
//

#import "MCBaseWorkSpaceManager.h"
#import "MCAppDelegate.h"
#import "MCWorkspaceViewController.h"

@implementation MCBaseWorkSpaceManager

#pragma mark - 刷新工作台数据
+ (void)refreshWorkSpaceData {
    MCAppDelegate *del = (MCAppDelegate*)[UIApplication sharedApplication].delegate;
    UINavigationController *workSapceNav = del.tabBarController.workSpaceNav;
    MCWorkspaceViewController *v = (MCWorkspaceViewController *)[workSapceNav.viewControllers firstObject];
    [v refreshData];
}

@end
