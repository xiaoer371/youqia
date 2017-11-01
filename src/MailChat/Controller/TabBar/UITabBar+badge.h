//
//  UITabBar+badge.h
//  NPushMail
//
//  Created by swhl on 16/11/11.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBar (badge)

/**
 //显示小红点
 @param index
 */
- (void)showBadgeOnItemIndex:(int)index itemNumber:(NSInteger)itemNum;

- (void)showBadgeForItem:(NSInteger)index workSpace:(BOOL)workSpace;

/**
 //隐藏小红点
 @param index
 */
- (void)hideBadgeOnItemIndex:(int)index;

@end
