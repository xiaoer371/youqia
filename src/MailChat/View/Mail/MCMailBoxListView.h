//
//  MCMailBoxListView.h
//  NPushMail
//
//  Created by zhang on 15/12/23.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCMailBox.h"
@class MCMailBoxListView;

@protocol MCMailBoxListViewDelegate <NSObject>

- (void)mailBoxListView:(MCMailBoxListView*)mailBoxListView didSelectMailBox:(MCMailBox*)mailBoxModel smartBox:(BOOL)smartBox;

@end

@interface MCMailBoxListView : UIView

@property (nonatomic,weak)id <MCMailBoxListViewDelegate> delegate;
//文件夹
@property(nonatomic,strong)NSArray *folders;
//是否显示文件夹列表
@property (nonatomic,assign)BOOL  change;

@property (nonatomic,assign)BOOL smartBoxSelectEnable;
//显示文件夹列表
- (void)show;

- (void)resetSelectedBox:(MCMailBox*)box;
@end
