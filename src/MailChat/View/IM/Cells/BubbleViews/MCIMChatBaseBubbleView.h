//
//  MCIMChatBaseBubbleView.h
//  NPushMail
//
//  Created by swhl on 16/2/23.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MCIMModel.h"
#import "UIResponder+Router.h"
#import "UIView+MCExpand.h"

//extern NSString *const kRouterEventChatCellBubbleTapEventName;
extern NSString *const kRouterEventChatCellForwordEvent;
extern NSString *const kRouterEventChatCellDeleteEvent;


#define BUBBLE_ARROW_WIDTH 5 // bubbleView中，箭头的宽度
#define BUBBLE_VIEW_PADDING 5 // bubbleView 与 在其中的控件内边距 top
#define BUBBLE_VIEW_PADDINGX 7 // bubbleView 与 在其中的控件内边距 left

#define KMESSAGEKEY @"message"

@protocol MCIMChatBubbleDelegate <NSObject>

- (void)reSetFrameAutoSuperView;

@end


@interface MCIMChatBaseBubbleView : UIView

@property (nonatomic, strong) MCIMMessageModel* model;
@property (nonatomic, weak) id <MCIMChatBubbleDelegate> delegate;
@property (nonatomic, strong) UIImageView *backImageView;

- (void)bubbleViewPressed:(id)sender;

+ (CGFloat)heightForBubbleWithObject:(MCIMMessageModel *)object;


@end
