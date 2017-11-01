//
//  MCIMChatViewController.h
//  NPushMail
//
//  Created by swhl on 16/2/24.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseSubViewController.h"
@class MCIMConversationModel;

@interface MCIMChatViewController : MCBaseViewController
//是否当前vc 键盘通知
@property (nonatomic, assign) BOOL  isCurrentVC;

- (instancetype)initWithConversationModel:(MCIMConversationModel*)conversationModel;

- (void) clearMessagesAche;

- (void) stopRecording;

-(void) resignResponderModifyFrame;

@end
