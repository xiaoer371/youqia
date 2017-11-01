//
//  MCIMChatInputView.h
//  NPushMail
//
//  Created by swhl on 16/2/26.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCChatTextView.h"

@class MCIMChatInputView;
@protocol MCIMChatInputViewDelegate <NSObject>

/**
 *   发送文本消息
 */
-(void)chatInputView:(MCIMChatInputView*)chatInputView
         sendMessage:(NSString *)messageStr;

/**
 *  发送图片
 *
 *  @param images
 */
- (void)chatInputView:(MCIMChatInputView *)chatInputView
               sendPictures:(NSArray *)images;

/**
 *  文件
 *
 *  @param images
 */
- (void)chatInputView:(MCIMChatInputView *)chatInputView
         sendFiles:(NSArray *)files;

/**
 *  语音
 *
 *  @param voice
 */
- (void)chatInputView:(MCIMChatInputView *)chatInputView
            sendVoice:(NSData *)voice
                 time:(NSInteger)second
                 name:(NSString*)voiceName;


- (void)layoutAndAnimateMessageInputTextView:(id)object;

- (void)inputTextViewDidBeginEditing:(MCChatTextView *)inputTextView;

//小助手账号的话，添加一键发送日志。
- (BOOL)iSHelperAccount;

- (void)sendLogToHelper;


- (void)didSelectMoreButtonActtion:(BOOL)isShow;


- (void)inputTextHiddenKeyboard:(MCChatTextView *)inputTextView;


@end

@interface MCIMChatInputView : UIView

@property (nonatomic, weak)id <MCIMChatInputViewDelegate> delegate;

@property (nonatomic, strong) MCChatTextView *inputTextView;


- (instancetype)initWithViewControll:(UIViewController *)viewController;

//动态改变高度,changeInHeight 目标变化的高度
- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight;

//获取根据最大行数和每行高度计算出来的最大显示高度
+ (CGFloat)maxHeight;

- (void)dismissKeyboardWithscrollSelectItem;

- (void)recordButtonTouchUpOutside;

@end
