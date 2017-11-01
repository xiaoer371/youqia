//
//  MCOALoginViewController.h
//  NPushMail
//
//  Created by wuwenyu on 16/5/31.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseSubViewController.h"

typedef enum {
    KeyboardSlideMode_Nothing   = 0,
    KeyboardSlideMode_ResizeFrame,
    KeyboardSlideMode_FitToFirstResponder
} KeyboardSlideMode;

//从哪个页面进入
typedef enum {
    fromMessageListCtrlType   = 0,//消息列表
    fromWorkSpaceType//工作台
} controllerSourceType;

@interface MCOALoginViewController : MCBaseSubViewController

@property (weak, nonatomic) IBOutlet UILabel *loginInfoLabel;
- (id)initWithOaUserName:(NSString *)oaName domin:(NSString *)domin controllerSourceType:(controllerSourceType)ctrlType;

@end
