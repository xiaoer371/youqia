//
//  MCIMChatModifyGroupViewController.h
//  NPushMail
//
//  Created by swhl on 16/4/15.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseViewController.h"


typedef enum : NSUInteger {
    MCModifyInfoTypeGroupName = 0,
    MCModifyInfoTypeNickName  = 1,
    MCModifyInfoTypeRemark    = 2,
} MCModifyInfoType;

@class MCIMConversationModel;

@interface MCIMChatModifyGroupViewController : MCBaseViewController

@property (nonatomic , assign) MCModifyInfoType  modifyInfoType;

- (instancetype)initWithMCModifyInfoType:(MCModifyInfoType)modifyInfoType
                                 withObj:(id)obj;


@end
