//
//  MCIMChatVoiceBubbleView.h
//  NPushMail
//
//  Created by swhl on 16/2/23.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMChatBaseBubbleView.h"

#define ANIMATION_IMAGEVIEW_SIZEW 12 // 小喇叭图片 width
#define ANIMATION_IMAGEVIEW_SIZEH 16 // 小喇叭图片 height
#define ANIMATION_IMAGEVIEW_SPEED 1 // 小喇叭动画播放速度
#define ANIMATION_TIME_LABEL_WIDHT 30 // 时间宽度
#define ANIMATION_TIME_LABEL_HEIGHT 15 // 时间高度
#define ANIMATION_TIME_LABEL_FONT_SIZE 14 // 时间字体

extern NSString *const kRouterEventAudioBubbleTapEventName;
extern NSString *const kRouterEventAudioBubblePlayNext;

@interface MCIMChatVoiceBubbleView : MCIMChatBaseBubbleView
{
    UIImageView *_animationImageView; // 动画的ImageView
    UILabel *_timeLabel; // 时间label
}

- (void)startAudioAnimation;
- (void)stopAudioAnimation;
- (void)bubbleViewPressed:(id)sender;

@end

