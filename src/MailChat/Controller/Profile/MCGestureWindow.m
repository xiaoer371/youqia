//
//  MCGestureWindow.m
//  NPushMail
//
//  Created by wuwenyu on 16/10/19.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCGestureWindow.h"
#import "MCGestureSetViewController.h"
#import "MCBaseNavigationViewController.h"

@implementation MCGestureWindow

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame])
    {
        self.windowLevel = UIWindowLevelAlert;
        MCGestureSetViewController *gestureVc = [[MCGestureSetViewController alloc] initWithCtrlType:GestureViewControllerTypeLogin];
        __weak MCGestureWindow *weakSelf = self;
        gestureVc.resultBlock = ^(BOOL success, NSError *error){
            if (success) {
                [weakSelf dismiss];
            }
        };
        MCBaseNavigationViewController *nav = [[MCBaseNavigationViewController alloc] initWithRootViewController:gestureVc];
        self.rootViewController = nav;
    }
    
    return self;

}

- (BOOL)isIsShow {
    return _isShow;
}

- (void)show
{
    _isShow = YES;
    [self makeKeyAndVisible];
    self.hidden = NO;
}

- (void)dismiss
{
    [self resignKeyWindow];
    self.hidden = YES;
    _isShow = NO;
}


@end
