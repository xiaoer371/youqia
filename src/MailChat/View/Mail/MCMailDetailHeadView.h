//
//  MCMailDetailHeadView.h
//  NPushMail
//
//  Created by zhang on 15/12/25.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCContactManager.h"
#import "MCMailModel.h"


@interface MCMailAddressButton : UIButton

@end


@class MCMailDetailHeadView;

@protocol MCMailDetailHeadViewDelegate <NSObject>

- (void)mailDetailHeadView:(MCMailDetailHeadView*)mailDetailHeadView didSelectContact:(MCContactModel*)contactModel;

- (void)maildetailHeadView:(MCMailDetailHeadView*)mailDetailHeadView didChangeFrame :(CGFloat)hight;

- (void)maildetailHeadView:(MCMailDetailHeadView *)mailDetailHeadView contactDataFrom:(NSArray*)from to:(NSArray*)to cc:(NSArray*)cc;

@end

@interface MCMailDetailHeadView : UIView

@property (nonatomic,strong)MCMailModel *mail;

@property (nonatomic,weak)id <MCMailDetailHeadViewDelegate> delegate;
- (id)initWithMail:(MCMailModel*)mailModel setDelegate:(id)delegate;
- (void)reloadView;
@end
