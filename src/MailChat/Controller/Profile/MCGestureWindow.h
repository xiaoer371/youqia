//
//  MCGestureWindow.h
//  NPushMail
//
//  Created by wuwenyu on 16/10/19.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCGestureWindow : UIWindow

- (void)show;
- (void)dismiss;
@property (nonatomic, assign) BOOL isShow;

@end
