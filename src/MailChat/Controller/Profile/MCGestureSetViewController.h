//
//  MCGestureSetViewController.h
//  NPushMail
//
//  Created by wuwenyu on 16/4/15.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseSubViewController.h"

typedef enum{
    GestureViewControllerTypeSetting = 1,
    GestureViewControllerTypeLogin,
    GestureViewControllerTypeModify,
    GestureViewControllerTypeVerify
}GestureViewControllerType;

typedef enum{
    buttonTagReset = 1,
    buttonTagManager,
    buttonTagForget
    
}buttonTag;

typedef void(^verifyGestrueBlock)(BOOL result);
typedef void(^loginGestureResult)(BOOL success, NSError * error);//手势密码登录结果

@interface MCGestureSetViewController : MCBaseSubViewController

- (id)initWithCtrlType:(GestureViewControllerType) type;

@property(nonatomic, strong) verifyGestrueBlock verifyBlock;
@property(nonatomic, strong) loginGestureResult resultBlock;

@end
