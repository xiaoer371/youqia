//
//  UITabBar+badge.m
//  NPushMail
//
//  Created by swhl on 16/11/21.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "UITabBar+badge.h"
#import <objc/runtime.h>
static NSString* const kmHaveWorkSpace = @"haveWorkSpace";


@implementation UITabBar (badge)

- (void)showBadgeOnItemIndex:(int)index itemNumber:(NSInteger)itemNum{
    
    //移除之前的小红点
    [self removeBadgeOnItemIndex:index];
    
    //新建小红点
    UIView *badgeView = [[UIView alloc]init];
    badgeView.tag = 888 + index;
    badgeView.layer.cornerRadius = 5;
    badgeView.backgroundColor = [UIColor redColor];
    CGRect tabFrame = self.frame;
    
    //确定小红点的位置
    float percentX = (index +0.6) / itemNum;
    CGFloat x = ceilf(percentX * tabFrame.size.width);
    CGFloat y = ceilf(0.1 * tabFrame.size.height);
    badgeView.frame = CGRectMake(x, y, 10, 10);
    [self addSubview:badgeView];
    
}

- (void)hideBadgeOnItemIndex:(int)index{
    //移除小红点
    [self removeBadgeOnItemIndex:index];
}

- (void)removeBadgeOnItemIndex:(int)index{
    //按照tag值进行移除
    for (UIView *subView in self.subviews) {
        if (subView.tag == 888+index) {
            [subView removeFromSuperview];
        }
    }
}

- (void)showBadgeForItem:(NSInteger)index workSpace:(BOOL)workSpace {
    
    NSString *flg = objc_getAssociatedObject(self, &kmHaveWorkSpace);
    BOOL oldFlg = NO;
    if (flg) {
        oldFlg = [flg boolValue];
    }
    if (index > 2) {
        
        if (workSpace && !oldFlg) {
            [self removeBadgeOnItemIndex:(int)index - 1];
        } else if (!workSpace && oldFlg){
            [self removeBadgeOnItemIndex:(int)index + 1];
        } else {
            [self removeBadgeOnItemIndex:(int)index];
        }
        
    } else {
        [self removeBadgeOnItemIndex:(int)index];
    }
    objc_setAssociatedObject(self, &kmHaveWorkSpace, @(workSpace), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    //新建小红点
    UIView *badgeView = [[UIView alloc]init];
    badgeView.tag = 888 + index;
    badgeView.layer.cornerRadius = 5;
    badgeView.backgroundColor = [UIColor redColor];
    CGRect tabFrame = self.frame;
    
    //确定小红点的位置
    float percentX = (index +0.6) / (workSpace?5:4);
    CGFloat x = ceilf(percentX * tabFrame.size.width);
    CGFloat y = ceilf(0.1 * tabFrame.size.height);
    badgeView.frame = CGRectMake(x, y, 10, 10);
    [self addSubview:badgeView];
}

@end

