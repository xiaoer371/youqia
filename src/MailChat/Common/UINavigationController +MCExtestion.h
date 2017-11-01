//
//  UINavigationController +MCExtestion.h
//  SGNavigationProgress
//
//  Created by zhang on 2016/10/31.
//  Copyright © 2016年 Shawn Gryschuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController(MCExtestion)

//显示进度条
- (void)showMCProgress:(CGFloat)progress;
//进度条颜色
- (void)showMCProgress:(CGFloat)progress withProgressColor:(UIColor*)color;

- (void)dismissMCProgress;

//错误提示
- (void)showErrorNote;

- (void)dimissErrorNoteAnimate:(BOOL)animate;


@end
