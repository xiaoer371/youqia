//
//  MCChatViewCell.h
//  NPushMail
//
//  Created by swhl on 16/2/23.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMChatBaseCell.h"

#import "MCIMChatTextBubbleView.h"
#import "MCIMChatImageBubbleView.h"
#import "MCIMChatVoiceBubbleView.h"
#import "MCIMChatFileBubbleView.h"

#define SEND_STATUS_SIZE 20 // 发送状态View的Size
#define ACTIVTIYVIEW_BUBBLE_PADDING 5 // 菊花和bubbleView之间的间距

extern NSString *const kResendButtonTapEventName;
extern NSString *const kShouldResendCell;


@interface MCChatViewCell : MCIMChatBaseCell

//sender
@property (nonatomic, strong) UIActivityIndicatorView *activtiy;
@property (nonatomic, strong) UIView *activityView;
@property (nonatomic, strong) UIButton *retryButton;


@end
