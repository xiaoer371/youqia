//
//  MCIMChatVoicePlayer.h
//  NPushMail
//
//  Created by swhl on 16/4/29.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MCIMChatVoicePlayerDelegate <NSObject>

- (void)voicePlayerBeiginLoadVoice;
- (void)voicePlayerBeiginPlay;
- (void)voicePlayerDidFinishPlay;

@end

@interface MCIMChatVoicePlayer : NSObject

@property (nonatomic, weak)id <MCIMChatVoicePlayerDelegate> delegate;

+ (MCIMChatVoicePlayer *)sharedInstance;

-(void)playSongWithData:(NSData *)songData;

- (void)stopSound;

@end
