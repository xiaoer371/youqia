//
//  MCIMChatTextBubbleView.h
//  NPushMail
//
//  Created by swhl on 16/2/23.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMChatBaseBubbleView.h"
#import "TYAttributedLabel.h"

extern NSString *const kRouterEventTextURLTapEventName;
extern NSString *const kRouterEventTextNumTapEventName;

@interface MCIMChatTextBubbleView : MCIMChatBaseBubbleView

@property (nonatomic, strong) TYAttributedLabel *textLabel;

@end
