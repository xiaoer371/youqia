//
//  MCTabBarController.h
//  NPushMail
//
//  Created by zhang on 16/1/18.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TabarItemDoubleClickBlock) (UIViewController*vc);
@interface MCTabBarController : UITabBarController

- (void)setTabbarWithWorkspaceFlag:(BOOL)flag;
@property (nonatomic, strong) UINavigationController *msgRootNav;
@property (nonatomic, strong) UINavigationController *mailRootNav;
@property (nonatomic, strong) UINavigationController *contactRootNav;
@property (nonatomic, strong) UINavigationController *profileRootNav;
@property (nonatomic, strong) UINavigationController *workSpaceNav;
@property (nonatomic, copy) TabarItemDoubleClickBlock mcTabarItemDoubleClickBlock;
@property (nonatomic, assign) BOOL needCheckWorkSpaceWhenAccountChange;
@end
