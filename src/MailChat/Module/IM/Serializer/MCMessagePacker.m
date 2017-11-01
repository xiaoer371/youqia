//
//  MCMessagePacker.m
//  NPushMail
//
//  Created by swhl on 16/1/21.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCMessagePacker.h"
#import "GTMBase64.h"  //语音

@implementation MCMessagePacker

+ (NSDictionary *)dictionaryWithCommand:(MCIMCommandModel *)cmd
{
    if (cmd.cmd == MCIMCmdModifyGroupName) {
        return @{@"f" : [cmd.from copy],
                 @"m" : @{
                         @"c" : @[cmd.groupId,cmd.groupName, cmd.messageId],
                         @"t" : @(cmd.cmd)
                         }
                 };
    }
    else if (cmd.cmd == MCIMCmdOtherUserBeKickedOff){
        return @{@"f" : [cmd.from copy],
                 @"m" : @{
                         @"c" : @[cmd.groupId,cmd.kickedOffUserId, cmd.messageId],
                         @"t" : @(cmd.cmd)
                         }
                 };
    }
    else{
        return @{@"f" : [cmd.from copy],
                 @"m" : @{
                         @"c" : @[cmd.groupId, cmd.messageId],
                         @"t" : @(cmd.cmd)
                         }
                 };
    }
}

+ (NSDictionary *)dictionaryWithMessage:(MCIMMessageModel *)msg
{
    if (msg.type == IMMessageTypeText || msg.type == IMMessageTypeNotice) {
        return @{@"f" : [msg.from copy],
                 @"m" : @{
                         @"c" : @[msg.content,msg.messageId],
                         @"t" : @(msg.type)
                         }
                 };
    }
    else if (msg.type == IMMessageTypeImage) {
        
        MCIMImageModel *imgModel = (MCIMImageModel *)msg;
        NSString *sizeSr = [NSString stringWithFormat:@"%ld*%ld",(long)imgModel.imageSize.width,(long)imgModel.imageSize.height];
        return @{@"f" : [msg.from copy],
                 @"m" : @{
                         @"c" : @[imgModel.name,imgModel.checksum,@(imgModel.size),msg.messageId,sizeSr],
                         @"t" : @(msg.type)
                         }
                 };
    }
    else if (msg.type == IMMessageTypeVoice) {
        MCIMVoiceModel *voiceModel = (MCIMVoiceModel *)msg;
        NSString *voiceStr = [GTMBase64 stringByEncodingData:voiceModel.sendData];
        return @{@"f" : [msg.from copy],
                 @"m" : @{
                         @"c" : @[voiceStr,@(voiceModel.seconds),msg.messageId],
                         @"t" : @(msg.type)
                         }
                 };
    }
    else if (msg.type == IMMessageTypeFile){
        MCIMFileModel *fileModel = (MCIMFileModel *)msg;
        return @{@"f" : [msg.from copy],
                 @"m" : @{
                         @"c" : @[fileModel.name,fileModel.checksum,@(fileModel.size),msg.messageId],
                         @"t" : @(msg.type)
                         }
                 };
    }
    
    return nil;
}

@end
