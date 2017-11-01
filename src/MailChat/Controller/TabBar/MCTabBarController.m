//
//  MCTabBarController.m
//  NPushMail
//
//  Created by zhang on 16/1/18.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCTabBarController.h"
#import "MCMailViewController.h"
#import "MCMessageViewController.h"
#import "MCContactRootViewController.h"
#import "MCProfileViewController.h"
#import "MCBaseNavigationViewController.h"
#import "MCWorkspaceViewController.h"
#import "MCTabBar.h"
#import "MCAccountConfig.h"
#import "UITabBarItem+Badge.h"
#import "MCAccountManager.h"
#import "MCWorkSpaceManager.h"
#import "MCAppSetting.h"
#import "UITabBar+badge.h"
#import "MCOrientationsNav.h"

typedef enum : NSUInteger {
    rememberWorkFlagN = 0,
    rememberWorkFlagY,
    rememberWorkFlagF,
} rememberWorkFlag;

@interface MCTabBarController () <UITabBarControllerDelegate>
{
    rememberWorkFlag _rememberWorkFlag;
}

@property(nonatomic,assign)BOOL selectCurrentIndex;

@end

@implementation MCTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBar.translucent = NO;
    self.delegate = self;
    _rememberWorkFlag = rememberWorkFlagF;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mcAccountDidChange:) name:MCNotificationDidChangeAccount object:nil];
    self.needCheckWorkSpaceWhenAccountChange = YES;
//    self.delegate = self;
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tabBarDoubleClockGesture:)];
//    [tap setNumberOfTapsRequired:2];
//    
//    [self.tabBar addGestureRecognizer:tap];
}

- (UINavigationController *)msgRootNav {
    if (!_msgRootNav) {
        //消息
        MCMessageViewController *mcMessageViewController = [[MCMessageViewController alloc]init];
        mcMessageViewController.leftNavigationBarButtonItem.image = nil;
        mcMessageViewController.navBarTitleLable.text = PMLocalizedStringWithKey(@"PM_Main_Tab_Message_Email");
        _msgRootNav = [self viewController:mcMessageViewController
                                     image:AppStatus.theme.tabBarImages[0]
                             selectedImage:AppStatus.theme.tabBarHightlightImages[0]
                                     title:PMLocalizedStringWithKey(@"PM_Main_Tab_Message_Email")];
    }
    return _msgRootNav;
}

- (UINavigationController *)mailRootNav {
    if (!_mailRootNav) {
        MCMailViewController *mcMailListViewController = [[MCMailViewController alloc]init];
        _mailRootNav = [self viewController:mcMailListViewController
                                      image:AppStatus.theme.tabBarImages[1]
                              selectedImage:AppStatus.theme.tabBarHightlightImages[1]
                                      title:PMLocalizedStringWithKey(@"PM_Main_Tab_Email")];
    }
    return _mailRootNav;
}

- (UINavigationController *)contactRootNav {
    if (!_contactRootNav) {
        //联系人
        MCContactRootViewController *mcContactRootViewController = [[MCContactRootViewController alloc]init];
        mcContactRootViewController.leftNavigationBarButtonItem.image = nil;
        mcContactRootViewController.navBarTitleLable.text = PMLocalizedStringWithKey(@"PM_Main_Tab_Contact_Email");
        _contactRootNav = [self viewController:mcContactRootViewController
                                         image:AppStatus.theme.tabBarImages[2]
                                 selectedImage:AppStatus.theme.tabBarHightlightImages[2]
                                         title:PMLocalizedStringWithKey(@"PM_Main_Tab_Contact_Email")];
    }
    return _contactRootNav;
}

- (UINavigationController *)profileRootNav {
    if (!_profileRootNav) {
        //我
        MCProfileViewController *mcProfileViewController = [[MCProfileViewController alloc]init];
        mcProfileViewController.leftNavigationBarButtonItem.image = nil;
        mcProfileViewController.navBarTitleLable.text = PMLocalizedStringWithKey(@"PM_Main_Tab_Mine_Email");
        _profileRootNav = [self viewController:mcProfileViewController
                                         image:AppStatus.theme.tabBarImages[3]
                                 selectedImage:AppStatus.theme.tabBarHightlightImages[3]
                                         title:PMLocalizedStringWithKey(@"PM_Main_Tab_Mine_Email")];
    }
    return _profileRootNav;
}

- (UINavigationController *)workSpaceNav {
    if (!_workSpaceNav) {
        //联系人
        MCWorkspaceViewController *mcWorkspaceRootViewController = [[MCWorkspaceViewController alloc]init];
        mcWorkspaceRootViewController.leftNavigationBarButtonItem.image = nil;
        mcWorkspaceRootViewController.navBarTitleLable.text = PMLocalizedStringWithKey(@"PM_WorkSpace_Item");
        _workSpaceNav = [self viewController:mcWorkspaceRootViewController
                                         image:AppStatus.theme.tabBarImages[4]
                                 selectedImage:AppStatus.theme.tabBarHightlightImages[4]
                                         title:PMLocalizedStringWithKey(@"PM_WorkSpace_Item")];
    }
    return _workSpaceNav;
}


- (void)setTabbarWithWorkspaceFlag:(BOOL)flag {

    if (flag) {
        NSArray *array = @[self.mailRootNav, self.msgRootNav, self.workSpaceNav, self.contactRootNav, self.profileRootNav];
        [self setViewControllers:array animated:NO];
    }else {
        NSArray *array = @[self.mailRootNav,self.msgRootNav, self.contactRootNav, self.profileRootNav];
        [self setViewControllers:array animated:NO];
    }
    if (_rememberWorkFlag != flag) {
        _rememberWorkFlag = flag ;
        MCMailViewController *mcMailListViewController = (MCMailViewController *)self.mailRootNav.viewControllers[0];
        [mcMailListViewController.tabBarItem rt_relayoutBadge:flag];
        MCMessageViewController *mcMessageViewController  = (MCMessageViewController *)self.msgRootNav.viewControllers[0];
        [mcMessageViewController.tabBarItem rt_relayoutBadge:flag];
    }
    if (AppSettings.isNewSettingUpdate) {
        NSInteger count = self.viewControllers.count;
        [self.tabBar showBadgeForItem:count - 1 workSpace:flag];
    }
}

- (UINavigationController*)viewController:(UIViewController *)viewController image:(UIImage *)image selectedImage:(UIImage *)selectedImage title:(NSString *)title {

    //标题
    viewController.title = title;
    //viewController.view.backgroundColor = [UIColor whiteColor];
    [viewController.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -2.0)];
    //tabBarItem图片
    viewController.tabBarItem.image = selectedImage;
    viewController.tabBarItem.title = title;
    //导航控制器
    MCBaseNavigationViewController *navigationController = [[MCBaseNavigationViewController alloc]initWithRootViewController:viewController];
    return navigationController;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
    UIViewController *tbSelectedController = tabBarController.selectedViewController;
    if ([tbSelectedController isEqual:viewController]) {
        return NO;
    }
    return YES;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSInteger index = [tabBar.items indexOfObject:item];
    if (index >= tabBar.items.count -1) {
        if (AppSettings.isNewSettingUpdate) {
            AppSettings.isNewSettingUpdate = NO;
            [tabBar hideBadgeOnItemIndex:(int)index];
        }
    }
}
//- (void)tabBarDoubleClockGesture:(UIGestureRecognizer*)gesture {
//    //获取当前tabarItem双击事件
//    if (_selectCurrentIndex) {
//        if (_mcTabarItemDoubleClickBlock) {
//            _mcTabarItemDoubleClickBlock(self.selectedViewController);
//        }
//    }
//}

- (void)mcAccountDidChange:(NSNotification*)info {
    if (!_needCheckWorkSpaceWhenAccountChange) {
        return;
    }
    [MCWorkSpaceManager workSpaceUserCheck];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MCNotificationDidChangeAccount object:nil];
}

@end
