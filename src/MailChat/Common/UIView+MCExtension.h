//
//  UIView+MCExtension.h
//  NPushMail
//
//  Created by wuwenyu on 16/3/10.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MCExtension)

/**
 *  得到圆形的view
 */
- (void)roundView;

//加载错误信息tiao

//错误提示
- (void)showErrorNote;

- (void)dimissErrorNoteAnimate:(BOOL)animate;


@end
