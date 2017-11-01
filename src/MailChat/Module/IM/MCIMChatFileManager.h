//
//  MCIMChatFileManager.h
//  NPushMail
//
//  Created by swhl on 16/4/28.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCIMChatFileManager : NSObject

+ (NSString *)saveVoiceData:(NSData *)data withFileName:(NSString *)fileName;
+ (void)deleteVoiceFileWithMessageId:(NSString *)messageId;
+ (NSString *)voicePathWithFileName:(NSString *)fileName;
+ (NSData *)amrDataWithFileName:(NSString *)fileName;
+ (NSData *)wavDataWithFileName:(NSString *)fileName;

@end
