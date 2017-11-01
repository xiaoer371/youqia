//
//  MCIMOAToolBarView.h
//  NPushMail
//
//  Created by swhl on 16/3/22.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MCIMOAToolBarViewDelegate <NSObject>

/**
 *  代办
 */
-(void)commissionAction;

/**
 *  发起
 */
-(void)launchAction;

/**
 *  办过的oa 事务
 */
-(void)didOAAction;

@end



@interface MCIMOAToolBarView : UIView

@property(nonatomic, weak) id<MCIMOAToolBarViewDelegate> delegate;

@end
