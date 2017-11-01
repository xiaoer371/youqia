//
//  MCIMChatMemberViewController.h
//  NPushMail
//
//  Created by swhl on 16/4/18.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseViewController.h"
#import "MCSelectedContactsBlock.h"

typedef enum : NSUInteger {
    
    ChatMemberTypeNormal = 0,
    ChatMemberTypeDelete  = 1,
    
} ChatMemberType;

@class MCIMConversationModel;

@interface MCIMChatMemberViewController : MCBaseViewController
@property (nonatomic, assign) ChatMemberType ChatMemberType;

- (instancetype)initWithConversation:(MCIMConversationModel*)conversationModel selectedModelsBlock:(SelectedModelsBlock)selectedModelsBlock ChatMemberType:(ChatMemberType)ChatMemberType;

@end
