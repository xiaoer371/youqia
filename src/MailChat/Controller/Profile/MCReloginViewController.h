//
//  MCReloginViewController.h
//  NPushMail
//
//  Created by wuwenyu on 16/5/24.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseSubViewController.h"

typedef void(^loginSuccess)();
typedef enum {
    KeyboardSlideMode_Nothing   = 0,
    KeyboardSlideMode_ResizeFrame,
    KeyboardSlideMode_FitToFirstResponder
} KeyboardSlideMode;

@interface MCReloginViewController : MCBaseSubViewController

@property(nonatomic, strong) loginSuccess touchIdLoginSuccess;
@property(nonatomic, strong) loginSuccess gestureLoginSuccess;

@end
