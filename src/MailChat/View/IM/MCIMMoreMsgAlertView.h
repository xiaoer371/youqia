//
//  MCIMMoreMsgAlertView.h
//  NPushMail
//
//  Created by swhl on 16/6/20.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MCIMMoreMsgAlertViewDelegate <NSObject>

- (void) lookNewMessages;

@end


@interface MCIMMoreMsgAlertView : UIView

@property (nonatomic ,assign) id<MCIMMoreMsgAlertViewDelegate> delegate;
@property (nonatomic ,assign) NSInteger newNum;  //新消息数据

- (instancetype)initWithNumString:(NSString *)numStr;

- (void)refreshData:(NSInteger )num;


@end
