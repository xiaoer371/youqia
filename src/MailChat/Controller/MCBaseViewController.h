//
//  MCBaseViewController.h
//  NPushMail
//
//  Created by zhang on 15/12/23.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCLoginManager.h"
#import "UITabBarItem+Badge.h"
#import "MCDownMenuView.h"
#import "UINavigationController +MCExtestion.h"
#import "UIView+MCExtension.m"
const static CGFloat kMCBaseViewNavBarTitleViewWidth   = 160.0;
const static CGFloat kMCBaseViewNavBarTitleViewHight   = 44.0;
const static CGFloat kMCBaseViewNavBarSearchButtonSize = 22.0;
const static CGFloat kMCBaseViewNavBarTitleFont        = 18.0;
const static CGFloat kMCBaseViewCurrentUserLableFont   = 11.0;
const static CGFloat kMCBaseViewIndicatorViewSize      = 28.0;
const static CGFloat kMCBaseViewCurrentUserLableHight  = 17.0;
const static CGFloat kMCBaseViewNavBarTitleHight       = 20.0;

@interface MCBaseViewController : UIViewController

@property (nonatomic,strong) UILabel  *navBarTitleLable;
@property (nonatomic,strong) UILabel  *currentUserLable;
@property (nonatomic,strong) UIActivityIndicatorView*indicatorView;

//导航栏左边按钮
@property (nonatomic,strong) UIBarButtonItem *leftNavigationBarButtonItem;
//导航栏右边按钮
@property (nonatomic,strong) UIBarButtonItem *rightNavigationBarButtonItem;
//搜索按钮
@property (nonatomic,strong) UIBarButtonItem *searchNavigationBarButtonItem;

@property (nonatomic,strong) UIButton       *searchButton;

//titleView
@property (nonatomic,strong) UIView *navigationBarTitleView;

@property (nonatomic,strong) MCLoginManager *loginManager;

- (void)addSearchNavigationBarButtonItem;

- (void)leftNavigationBarButtonItemAction:(id)sender;
- (void)rightNavigationBarButtonItemAction:(id)sender;
- (void)searchNavigationBarButtonItemAction:(id)sender;

- (void)startAnimationIndicatorView;
- (void)stopAnimationInducatorView;
//changeAccount
- (void)mcAccountDidChange:(NSNotification*)info;

//多账号页面相关调整
- (void)addRootViewSearchNavigationBarButtonItem;
- (void)setRootCtrlNavigationBarTitleView;
- (void)setCurrentUserLabelFrame;
@property(nonatomic, strong) UIButton *changeAccountBtn;
//下拉箭头
@property (nonatomic, strong) UIImageView *changeAccountArrow;
@property(nonatomic, strong) MCDownMenuView *changeAccountDownView;

@end
