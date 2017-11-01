//
//  MCMailEditingView.h
//  NPushMail
//
//  Created by zhang on 15/12/23.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCMailModel.h"
#import "MCMailBox.h"

@class MCMailEditingView;

@protocol MCMailEditingViewDelegate <NSObject>

- (void)mailEditingView:(MCMailEditingView*)mailEditingView intoEditing:(BOOL)edit;

- (void)mailEditingView:(MCMailEditingView *)mailEditingView classify:(MCMailFlags)classifyMailFlag;

- (MCMailBox*)mailEditingView:(MCMailEditingView*)mailEditingView canEditing:(BOOL)editable;

@end


@interface MCMailEditingView : UIView

@property(nonatomic,weak)id <MCMailEditingViewDelegate>delegate;

@property(nonatomic,assign)MCMailFlags  classfyMailFlag;

@property(nonatomic,strong)MCMailBox *boxModel;

- (void)reset;

@end
