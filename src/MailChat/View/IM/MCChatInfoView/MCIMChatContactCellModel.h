//
//  MCIMChatContactCellModel.h
//  NPushMail
//
//  Created by swhl on 16/3/1.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MCIMConversationModel.h"
#import "MCIMGroupModel.h"

typedef enum : NSUInteger {
    MCModelStateNormal = 0,
    MCModelStateAdd = 1,
    MCModelStateDel = 2,
} MCModelState;

@interface MCIMChatContactCellModel : NSObject

@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *headerUrl;
@property (nonatomic, strong) UIImage  *headerDefaule;
@property (nonatomic) MCModelState state;
@property (nonatomic) MCModelType  type;

+(MCIMChatContactCellModel*)contactModelWithConversationModel:(MCIMConversationModel *)conversation;

+(NSArray*)contactModelWithMembers:(NSArray *)members;

+(NSArray *)contactModelWithContactModels:(NSArray *)contacts;

@end
