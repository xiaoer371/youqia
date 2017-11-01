//
//  MCIMChatInfoViewController.h
//  NPushMail
//
//  Created by swhl on 16/3/1.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseViewController.h"

@class MCIMConversationModel;

@interface MCIMChatInfoViewController : MCBaseViewController

- (instancetype)initWithConversation:(MCIMConversationModel*)conversationModel;

@end
