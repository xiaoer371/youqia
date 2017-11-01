//
//  MCIMChatForwordViewController.h
//  NPushMail
//
//  Created by swhl on 16/5/4.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseViewController.h"

@class MCIMMessageModel;

@interface MCIMChatForwordViewController : MCBaseViewController

- (instancetype)initWithMessageModel:(MCIMMessageModel *)messageModel;

- (instancetype)initWithFiles:(NSArray *)files;

@end
