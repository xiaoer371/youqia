//
//  UITextView+ExtentRange.h
//  NPushMail
//
//  Created by swhl on 15/9/24.
//  Copyright (c) 2015年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

//也适用于 UITextField 直接改类别名 就行

@interface UITextView (ExtentRange)
/**
 *  获取UITextView 的光标NSRange
 *
 *  @return 光标 NSRange；
 */
- (NSRange) selectedRange;

/**
 *  设置UITextView 的光标位置
 *
 *  @param range 光标的NSRange
 */
- (void) setSelectedRange:(NSRange) range;
@end
