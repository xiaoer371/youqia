//
//  MCCheckBoxView.h
//  NPushMail
//
//  Created by swhl on 16/12/9.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCCheckBoxView;
@protocol MCCheckBoxViewDelegate <NSObject>

- (void)didSelect:(MCCheckBoxView*)checkBoxView  index:(NSInteger)index;

@end

@interface MCCheckBoxView : UIView

@property (nonatomic,weak) id<MCCheckBoxViewDelegate> delegate;

@property (nonatomic, assign) NSInteger  selectIndex;

- (instancetype)initWithFrame:(CGRect)frame Titles:(NSArray *)titles;


@end

