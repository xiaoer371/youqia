//
//  MCIMChatImageBubbleView.h
//  NPushMail
//
//  Created by swhl on 16/2/23.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMChatBaseBubbleView.h"
#define MAX_SIZE 120.0f //　图片最大显示大小

extern NSString *const kRouterEventImageBubbleTapEventName;

@interface MCIMChatImageBubbleView : MCIMChatBaseBubbleView

@property (nonatomic, strong) UIImageView *imageView;

@end
