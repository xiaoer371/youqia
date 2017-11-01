//
//  UISearchBar+MCExtension.h
//  NPushMail
//
//  Created by wuwenyu on 16/3/17.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISearchBar (MCExtension)
/**
 *  设置激活时外观样式，包括边框颜色等
 */
- (void)settingActiveTintStyle;
/**
 *  设置正在状态下显示的样式
 */
- (void)settingPlainTintStyle;

@end
