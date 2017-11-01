//
//  MCSegmentHeadView.h
//  NPushMail
//
//  Created by wuwenyu on 15/12/30.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SegmentTapViewDelegate <NSObject>
@optional
/**
 *  选择index回调
 *
 *  @param index
 */
- (void)selectedIndex:(NSInteger)index;
- (void)searchAction;

@end

@interface MCSegmentHeadView : UIView

@property(nonatomic, assign) id<SegmentTapViewDelegate> delegate;
/**
 *  数据源
 */
@property(nonatomic, strong) NSArray *dataArray;
/**
 *  字体非选中时颜色
 */
@property(nonatomic, strong) UIColor *textNomalColor;
/**
 *  view的背景颜色
 */
@property(nonatomic, strong) UIColor *bgColor;
/**
 *  字体选中时颜色
 */
@property(nonatomic, strong) UIColor *textSelectedColor;
/**
 *  横线颜色
 */
@property(nonatomic, strong) UIColor *lineColor;
/**
 *  字体大小
 */
@property(nonatomic, assign) CGFloat titleFont;
/**
 *  手动选择
 *
 *  @param index 从1开始
 */
- (void)selectIndex:(NSInteger)index;

@end
