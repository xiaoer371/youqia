//
//  MCIFlyWaverView.h
//  NPushMail
//
//  Created by wuwenyu on 16/11/8.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Waver.h"

typedef void (^speechEnd)(void);

@interface MCIFlyWaverView : UIView

@property (nonatomic, assign) CGFloat volume;
@property (nonatomic, copy) speechEnd speechEndBlock;
@property (nonatomic, strong) UIButton *speechEndBtn;

- (void)startUpdate;
- (void)pauseUpdate;
- (void)stopUpdate;

@end
