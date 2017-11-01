//
//  MCChatTextView.h
//  NPushMail
//
//  Created by swhl on 16/2/26.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, IMTextViewInputViewType) {
    IMTextViewNormalInputType = 0,
    IMTextViewTextInputType,
    IMTextViewFaceInputType,
    IMTextViewShareMenuInputType,
};

@protocol keyInputTextFieldDelegate <NSObject>

 - (void)deleteBackward;

@end


@interface MCChatTextView : UITextView

@property (nonatomic, copy) NSString *placeHolder;
@property (nonatomic, strong) UIColor *placeHolderTextColor;
@property (nonatomic, weak) id<keyInputTextFieldDelegate> keyInputDelegate;

/**
 *  获取自身文本占据有多少行
 *
 *  @return 返回行数
 */
- (NSUInteger)numberOfLinesOfText;
/**
 *  获取每行的高度
 *
 *  @return 根据iPhone或者iPad来获取每行字体的高度
 */
+ (NSUInteger)maxCharactersPerLine;
/**
 *  获取某个文本占据自身适应宽带的行数
 *
 *  @param text 目标文本
 *
 *  @return 返回占据行数
 */
+ (NSUInteger)numberOfLinesForMessage:(NSString *)text;

@end
