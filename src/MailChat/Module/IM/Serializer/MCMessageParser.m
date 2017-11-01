//
//  MCMessageParser.m
//  NPushMail
//
//  Created by swhl on 16/1/21.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCMessageParser.h"
#import "NSString+JSON.h"
#import "MCIMCommandModel.h"
#import "GTMBase64.h"
#import "MCAppSetting.h"
#import "MCUDID.h"

#import "MCFileCore.h"
#import "MCFileManager.h"
#import "VoiceConverter.h"
#import "MCIMChatFileManager.h"


@implementation MCMessageParser

+ (NSTimeInterval)parseTimeWithData:(NSData *)data
{
    NSData *timeData = [data subdataWithRange:NSMakeRange(0, 8)];
    UInt64 time = 0;
    [timeData getBytes:&time length:sizeof(time)];
    
    return time;
}

+ (id)parseContentWithData:(NSData *)data
{
    NSData *contentData = [data subdataWithRange:NSMakeRange(8, data.length - 8)];
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:contentData options:0 error:&error];
    if (error) {
        DDLogError(@"Parse message data error = %@",error);
        return nil;
    }
    
    DDLogVerbose(@"Receive message = %@",json);
    
    return json;
}

+ (MCIMDataModel *)createMesssageWithTopic:(NSString *)topic data:(NSData *)data
{
    //单聊
    if ([topic hasSuffix:@"/1"]) {
        MCIMMessageModel *msg = [MCMessageParser newMessageWithData:data];
        msg.serviceType = IMServiceTypeMsgData;
        msg.isSender = [msg.from isEqualToString:AppStatus.currentUser.email];
        msg.conversationType = MailChatConversationTypeSingle;
        return msg;
    }
    // 系统消息
    else if ([topic hasSuffix:@"/s"]) {
        
        id json = [MCMessageParser parseContentWithData:data];
        if (!json) {
            return nil;
        }
        
        //系统频道，有 type 字段的是推送消息，暂时先不用
        if (json[@"p"]) {
            NSInteger type = [json[@"p"] integerValue];
            // 邮件通知
            if (type == 1) {
                MCIMNewMailModel *msg = [[self class] createNewMailModelWithJson:json];
                return msg;
            }
            
            return nil;
        }
        else{
            MCIMCommandModel *cmd = [MCMessageParser createCommandWithJson:json];
            cmd.serviceType = IMServiceTypeGroupCmd;
            return cmd;
        }
    }
    // OA
    else if ([topic hasSuffix:@"/a"]) {
        id json = [MCMessageParser parseContentWithData:data];
        MCIMOAMessageModel *oaMsg = [[self class] createOAMessageModelWithJson:json];
        return oaMsg;
    }
    // 群聊
    else{
        MCIMMessageModel *msg = [MCMessageParser newMessageWithData:data];
        msg.serviceType = IMServiceTypeMsgData;
        msg.to = topic;
        msg.isSender = [msg.from isEqualToString:AppStatus.currentUser.email];
        msg.conversationType = MailChatConversationTypeGroup;
        return msg;
    }
    
    return nil;
}


+ (MCIMCommandModel *)newCommandWithData:(NSData *)data
{
    NSTimeInterval time = [[self class] parseTimeWithData:data];
    id contentJson = [[self class] parseContentWithData:data];
    if (!contentJson) {
        return nil;
    }
    
    MCIMCommandModel *cmdModel = [[self class] createCommandWithJson:contentJson];
    cmdModel.timeStamp = time;
    
    return cmdModel;
}

+ (MCIMMessageModel *)newMessageWithData:(NSData *)data
{
    NSTimeInterval time = [[self class] parseTimeWithData:data];
    id contentJson = [[self class] parseContentWithData:data];
    if (!contentJson) {
        return nil;
    }
    
    MCIMMessageModel *msg = [[self class] createMessageWithJson:contentJson];
    msg.timeStamp = time;
    msg.time = [NSDate dateWithTimeIntervalSince1970:time];
    
    return msg;
}

+ (MCIMCommandModel *)createCommandWithJson:(id)json
{
    MCIMCommandModel *msg = [MCIMCommandModel new];
    msg.from  = [json objectForKey:@"f"];
    id m = [json objectForKey:@"m"];
    msg.cmd = [[m objectForKey:@"t"] integerValue];
    
    NSArray *c = [m objectForKey:@"c"];
    if (msg.cmd == MCIMCmdJoinGroup ||
        msg.cmd == MCIMCmdDeleteGroup ||
        msg.cmd == MCIMCmdLeaveGroup ||
        msg.cmd == MCIMCmdBeKickefOff) {
        msg.messageId = c[1];
        msg.groupId = c[0];
    }
    else if (msg.cmd == MCIMCmdModifyGroupName){
        msg.messageId = c[2];
        msg.groupId = c[0];
        msg.groupName = c[1];
    }
    else if (msg.cmd == MCIMCmdOtherUserBeKickedOff){
        msg.messageId = c[2];
        msg.kickedOffUserId = c[1];
        msg.groupId = c[0];
    }
    else{
        DDLogError(@"Unknown message command = %@",json);
        return nil;
    }
    
    return msg;
}

+ (MCIMMessageModel *)createMessageWithJson:(id)json
{
    MCIMMessageModel *msg = nil;
    id m = [json objectForKey:@"m"];
    IMMessageType type = [[m objectForKey:@"t"] integerValue];
    NSArray *c = [m objectForKey:@"c"];
    switch (type) {
        case IMMessageTypeText:
        {
            msg = [MCIMMessageModel new];
            msg.content = c[0];
            msg.messageId = c[1];
            break;
        }
        case IMMessageTypeImage:{
            MCIMImageModel *imgModel = [MCIMImageModel new];
            NSString *fileName = c[0];
            NSString *folderName = c[1];
            imgModel.name = fileName;
            imgModel.checksum = folderName;
            imgModel.size = [c[2] integerValue];
            imgModel.messageId = c[3];
            if (c.count >= 5) {
                NSString *sizeStr = c[4];
                NSArray *sizeArray = [sizeStr componentsSeparatedByString:@"*"];
                NSInteger width = [sizeArray[0] integerValue];
                NSInteger height = [sizeArray[1] integerValue];
                imgModel.imageSize = CGSizeMake(width, height);
            }
            
            msg = imgModel;
            
            break;
        }
        case IMMessageTypeFile:{
            MCIMFileModel *fileModel = [MCIMFileModel new];
            NSString *fileName = c[0];
            NSString *folderName = c[1];
            fileModel.name = fileName;
            fileModel.checksum = folderName;
            fileModel.path = [NSString stringWithFormat:@"%@file/%@/%@", AppSettings.apiBaseUrl,folderName,fileName];
            fileModel.size = [c[2] integerValue];
            fileModel.messageId = c[3];
            
            msg = fileModel;
            break;
        }
        case IMMessageTypeVoice:{
            MCIMVoiceModel *voiceModel = [MCIMVoiceModel new];
            voiceModel.sendData = [GTMBase64 decodeString:c[0]];
            voiceModel.seconds = [c[1] floatValue];
            voiceModel.messageId = c[2];
            [MCMessageParser saveVoiceMessage:voiceModel];
            msg = voiceModel;
            break;
        }
        case IMMessageTypeNotice:
        {
            msg = [MCIMMessageModel new];
            msg.type = type;
            msg.content = c[0];
            msg.messageId = c[1];
            break;
        }
        default:
            break;
    }
    
    msg.from = [json objectForKey:@"f"];
    // 外层有to的字断，表示是多端同步的消息，t表示发给哪个用户
    NSString *to = [json objectForKey:@"t"];
    if (to.length > 0) {
        msg.to = to;
    }
    else{
        msg.to = AppStatus.currentUser.email;
    }
    msg.state = IMMessageStateSuccess;
    
    
    
    return msg;
}

+ (MCIMNewMailModel *)createNewMailModelWithJson:(id)json
{
    id m = [json objectForKey:@"m"];
    MCIMNewMailModel *model = [MCIMNewMailModel new];
    model.mailInfo = [[MCMailNotificationModel alloc] initModelWith:m];
    return model;
}

+ (MCIMOAMessageModel *)createOAMessageModelWithJson:(id)json
{
    id data = json[@"m"];
    if (data) {
        MCIMOAMessageModel *model = [MCIMOAMessageModel new];
        model.app = kMailChatOA;
        model.from = kMailChatOA;
        model.to = AppStatus.currentUser.email;
        model.toUser = data[@"u"];
        model.title = data[@"s"];
        model.sponsor = data[@"f"];
        model.oaType = [data[@"c"] integerValue];
        model.eventId = data[@"i"];
        model.url = data[@"w"];
        model.timeStamp = [data[@"t"] doubleValue];
        model.time = [NSDate dateWithTimeIntervalSince1970:model.timeStamp];
        
        model.messageId = model.eventId;
        
        return model;
    }
    
    return nil;
}

+ (void)saveVoiceMessage:(MCIMVoiceModel *)msg
{
    NSString *amrFileName = [msg.messageId stringByAppendingFormat:@".amr"];
    [MCIMChatFileManager saveVoiceData:msg.sendData withFileName:[msg.messageId stringByAppendingFormat:@".amr"]];
    msg.localPath = amrFileName;

}

@end
