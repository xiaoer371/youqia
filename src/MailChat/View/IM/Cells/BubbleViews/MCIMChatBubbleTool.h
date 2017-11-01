//
//  MCIMChatBubbleTool.h
//  NPushMail
//
//  Created by swhl on 16/7/11.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCIMChatBubbleTool : NSObject

@property (nonatomic,strong) NSDictionary *mapper;

@property (nonatomic,strong) NSMutableDictionary *emojiMatches;
@property (nonatomic,strong) NSMutableDictionary *PhoneMatches;


+ (MCIMChatBubbleTool *)sharedInstance;

- (NSArray* )getEmojiMatchsWithContent:(NSString *)content;

- (NSArray *)getPhoneAndLinkMatchsWithContent:(NSString *)content;

@end
