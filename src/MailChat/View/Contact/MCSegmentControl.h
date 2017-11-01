//
//  MCSegmentControl.h
//  NPushMail
//
//  Created by wuwenyu on 16/4/26.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MCSegmentControlBlock)(NSInteger index);

@class MCSegmentControl;

@protocol MCSegmentControlDelegate <NSObject>

- (void)segmentControl:(MCSegmentControl *)control selectedIndex:(NSInteger)index;

@end

@interface MCSegmentControl : UIView

- (instancetype)initWithFrame:(CGRect)frame Items:(NSArray *)titleItem delegate:(id <MCSegmentControlDelegate>)delegate;

- (instancetype)initWithFrame:(CGRect)frame Items:(NSArray *)titleItem selectedBlock:(MCSegmentControlBlock)selectedHandle;

- (void)selectIndex:(NSInteger)index;

- (void)moveIndexWithProgress:(float)progress;

- (void)endMoveIndex:(NSInteger)index;

- (void)setCurrentIndex:(NSInteger)currentIndex;

@end
