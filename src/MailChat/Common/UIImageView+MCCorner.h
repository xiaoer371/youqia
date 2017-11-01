//
//  UIImageView+MCCorner.h
//  NPushMail
//
//  Created by zhang on 16/4/28.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView(MCCorner)
//覆盖view 实现切圆
- (void)cornerRadius;
//使用mask属性实现圆角
- (void)cornerRadiusWithMask;
@end
