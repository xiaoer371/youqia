//
//  MCIMAuthView.h
//  NPushMail
//
//  Created by swhl on 16/4/6.
//  Copyright © 2016年 sprite. All rights reserved.
//


// 自动认证用户失败显示的界面

#import <UIKit/UIKit.h>

@protocol MCIMAuthViewDelegate <NSObject>

-(void)reAuth;

@end

@interface MCIMAuthView : UIView

@property (nonatomic ,weak) id<MCIMAuthViewDelegate> delegate;

@end
