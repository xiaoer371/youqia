//
//  MCContactWeights.h
//  NPushMail
//
//  Created by admin on 9/1/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSInteger const kMailChatContactWeightStar = 10;
static NSInteger const kMailChatContactWeightReply = 3;
static NSInteger const kMailChatContactWeightCc = 5;
static NSInteger const kMailChatContactWeightBcc = 10;
static NSInteger const kMailChatContactWeightForward = 3;
static NSInteger const kMailChatContactWeightNewMail = 5;
static NSInteger const kMailChatContactWeightSetImportant = 10;
static NSInteger const kMailChatContactWeightChat = 1;

@interface MCContactWeights : NSObject

@end
