//
//  MCIMMessageSender.m
//  NPushMail
//
//  Created by admin on 4/8/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCIMMessageSender.h"
#import "MCIMClient.h"
#import "MCIMMessageManager.h"
#import "MCNotificationCenter.h"
#import "MCMessagePacker.h"
#import "NSString+JSON.h"
#import "MCIMConversationManager.h"
#import "MCUDID.h"
#import "MCIMImageModel.h"
#import "MCIMFileModel.h"
#import "MCIMVoiceModel.h"
#import "MCServerAPI+File.h"
#import "SDWebImageManager.h"
#import "MCFileManager.h"
#import "MCIMChatFileManager.h"
#import "UIImage+Utility.h"

typedef void(^SendMessageDataCompleteBlock)(NSInteger msgId, NSError *error);

@implementation MCIMMsgData
@end

@interface MCIMMessageSender () <MCIMClientDelegate>

@property (nonatomic,strong) NSMutableDictionary *handlers;
@property (nonatomic,strong) NSMutableDictionary *failureMessages;
@property (nonatomic,strong) MCIMMessageManager *messageMgr;

@end

@implementation MCIMMessageSender

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _timeout = 20;
        _handlers = [NSMutableDictionary new];
        _failureMessages = [NSMutableDictionary new];
        _messageMgr = [MCIMMessageManager new];
        MCWeakProxy *proxy = [[MCWeakProxy alloc] initWithTarget:self];
        [[MCIMClient shared] addDelegate:proxy];
    }
    return self;
}

+ (instancetype)shared
{
    return AppStatus.accountData.imMessageSender;
}

#pragma mark - Public

- (void)sendFakeMessageWithText:(NSString *)text toConversation:(MCIMConversationModel *)conversation
{
    [self sendFakeMessageWithText:text from:AppStatus.currentUser.email conversation:conversation messageType:IMMessageTypeNotice];
}

- (void)sendFakeMessageWithText:(NSString *)text from:(NSString *)from conversation:(MCIMConversationModel *)conversation messageType:(IMMessageType)msgType
{
    MCIMMessageModel *msg = [MCIMMessageModel new];
    msg.from = from;
    msg.conversationType = conversation.type;
    msg.to = conversation.peerId;
    msg.type = msgType;
    msg.content = text;
    msg.messageId = [MCUDID newUUID];
    msg.time = [NSDate new];
    msg.state = IMMessageStateSuccess;
    [[MCIMConversationManager shared] updateConversation:conversation withMessage:msg];
    [self.messageMgr insertMessage:msg];
    [MCNotificationCenter postNotification:MCNotificationDidReceiveMessage object:msg];
}

- (void)sendCommand:(MCIMCommandModel *)cmd toTopic:(NSString *)topic success:(ActionBlock)success failure:(FailureBlock)failure
{
    NSDictionary *msgDict = [MCMessagePacker dictionaryWithCommand:cmd];
    MCIMMsgData *msg = [[self class] msgDataWithDictionary:msgDict];
    [self sendMessageData:msg toTopic:topic completion:^(NSInteger msgId,NSError *error) {
        if (error) {
            DDLogError(@"Send command error = %@",error);
            if (failure) {
                failure(error);
            }
        }
        else{
            if (success) {
                success();
            }
        }
    }];
}

- (MCIMMessageModel *)sendNotice:(NSString *)notice toConversation:(MCIMConversationModel *)conversation success:(ActionBlock)success failure:(FailureBlock)failure
{
    MCIMMessageModel *msg = [MCIMMessageModel new];
    msg.from = AppStatus.currentUser.email;
    msg.conversationType = conversation.type;
    msg.to = conversation.peerId;
    msg.type = IMMessageTypeNotice;
    msg.content = notice;
    msg.time =[NSDate new];
    msg.messageId = [MCUDID newUUID];
    
    [[MCIMConversationManager shared] updateConversation:conversation withMessage:msg];
    [self.messageMgr insertMessage:msg];
    [MCNotificationCenter postNotification:MCNotificationDidReceiveMessage object:msg];
    
    [self sendMessage:msg toConversation:conversation success:success failure:failure];
    return msg;
    
}

- (MCIMMessageModel *)sendText:(NSString *)text toConversation:(MCIMConversationModel *)conversation success:(ActionBlock)success failure:(FailureBlock)failure
{
    MCIMMessageModel *msg = [MCIMMessageModel new];
    msg.from = AppStatus.currentUser.email;
    msg.conversationType = conversation.type;
    msg.to = conversation.peerId;
    msg.type = IMMessageTypeText;
    msg.content = text;
    msg.messageId = [MCUDID newUUID];
    msg.time = [NSDate new];
    
    [[MCIMConversationManager shared] updateConversation:conversation withMessage:msg];
    [self.messageMgr insertMessage:msg];
    [MCNotificationCenter postNotification:MCNotificationDidReceiveMessage object:msg];
    
    [self sendMessage:msg toConversation:conversation success:success failure:failure];
    return msg;
}

- (MCIMMessageModel *)sendImage:(UIImage *)imageToSend toConversation:(MCIMConversationModel *)conversation success:(ActionBlock)success failure:(FailureBlock)failure
{
    
    UIImage *image = [imageToSend fixOrientation];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.75);
    
    MCIMImageModel *msg = [MCIMImageModel new];
    msg.from = AppStatus.currentUser.email;
    msg.conversationType = conversation.type;
    msg.to = conversation.peerId;
    msg.type = IMMessageTypeImage;
    msg.messageId = [MCUDID newUUID];
    msg.time = [NSDate new];
    msg.imageSize = image.size;
    msg.size = imageData.length;
    msg.checksum = @"image";
    msg.name = [NSString stringWithFormat:@"%@_picture.jpg",msg.messageId];
    
    [[SDWebImageManager sharedManager] saveImageToCache:image forURL:[NSURL URLWithString:msg.localPath]];
    // 先显示发送状态
    [[MCIMConversationManager shared] updateConversation:conversation withMessage:msg];
    [self.messageMgr insertMessage:msg];
    [MCNotificationCenter postNotification:MCNotificationDidReceiveMessage object:msg];
    
    [ServerAPI uploadImage:imageData name:msg.name success:^(id responseObj) {
        
        // 上传成功后，用服务器的地址替换掉本地的地址
        msg.checksum = responseObj[@"checksum"];
        [self.messageMgr updateMessage:msg];
        
        [self sendMessage:msg toConversation:conversation success:^{
            if (success) {
                success();
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
        
    } failure:^(NSError *error) {
        msg.state = IMMessageStateFailure;
        [self.messageMgr updateMessageState:msg];
        if (failure) {
            failure(error);
        }
    }];
    
    return msg;
}

- (MCIMMessageModel *)sendFileWithModel:(MCFileBaseModel *)fileModel fileName:(NSString *)fileName toConversation:(MCIMConversationModel *)conversation success:(ActionBlock)success failure:(FailureBlock)failure
{
    MCIMFileModel *msg = [MCIMFileModel new];
    msg.from = AppStatus.currentUser.email;
    msg.conversationType = conversation.type;
    msg.to = conversation.peerId;
    msg.type = IMMessageTypeFile;
    msg.messageId = [MCUDID newUUID];
    msg.downloadState = IMFileDownloaded;
    msg.time = [NSDate new];
    msg.checksum = @"file";
    msg.size = fileModel.size;
    msg.name = fileName;
    msg.fileId = fileModel.fileId;
    msg.localPath = fileModel.location;
    msg.path = fileModel.fullPath;
    
    // 先显示发送状态
    [[MCIMConversationManager shared] updateConversation:conversation withMessage:msg];
    [self.messageMgr insertMessage:msg];
    [MCNotificationCenter postNotification:MCNotificationDidReceiveMessage object:msg];
    
    [ServerAPI uploadFileWithUrl:[NSURL fileURLWithPath:fileModel.fullPath] name:msg.name success:^(id response) {
        // 上传成功后，用服务器的地址替换掉本地的地址
        msg.checksum = response[@"checksum"];
        msg.path = response[@"url"];
        [self.messageMgr updateMessage:msg];
        
        [self sendMessage:msg toConversation:conversation success:^{
            if (success) {
                success();
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    } failure:^(NSError *error) {
        msg.state = IMMessageStateFailure;
        [self.messageMgr updateMessageState:msg];
        if (failure) {
            failure(error);
        }
    }];
    
    return msg;
}

- (MCIMMessageModel *)sendVoiceWithData:(NSData *)voiceData seconds:(CGFloat)seconds name:(NSString *)voiceName toConversation:(MCIMConversationModel *)conversation success:(ActionBlock)success failure:(FailureBlock)failure
{
    // 去掉后缀，必须用文件名当messageId才会跟接收的消息一致
    NSString *messageId = [voiceName substringToIndex:voiceName.length - 4];
    
    MCIMVoiceModel *msg = [MCIMVoiceModel new];
    msg.from = AppStatus.currentUser.email;
    msg.conversationType = conversation.type;
    msg.to = conversation.peerId;
    msg.type = IMMessageTypeVoice;
    msg.messageId = messageId;
    msg.time = [NSDate new];
    msg.sendData = voiceData;
    msg.seconds = seconds;
    msg.localPath = voiceName;
    
    // 先显示发送状态
    [[MCIMConversationManager shared] updateConversation:conversation withMessage:msg];
    [self.messageMgr insertMessage:msg];
    [MCNotificationCenter postNotification:MCNotificationDidReceiveMessage object:msg];
    
    [self sendMessage:msg toConversation:conversation success:success failure:failure];
    
    return msg;
}

- (MCIMMessageModel *)forwardMessage:(MCIMMessageModel *)msg toConversation:(MCIMConversationModel *)conversation success:(ActionBlock)success failure:(FailureBlock)failure
{
    switch (msg.type) {
        case IMMessageTypeText:{
            return [self sendText:msg.content toConversation:conversation success:success failure:failure];
            break;
        }
        case IMMessageTypeNotice:{
            return [self sendText:msg.content toConversation:conversation success:success failure:failure];
            break;
        }
        case IMMessageTypeVoice:{
            MCIMVoiceModel *voiceMsg = (MCIMVoiceModel *)msg;
            return [self sendVoiceWithData:voiceMsg.sendData seconds:voiceMsg.seconds name:voiceMsg.localPath toConversation:conversation success:success failure:failure];
            break;
        }
        case IMMessageTypeImage:{
            return [self forwardImageMessage:msg toConversation:conversation success:success failure:failure];
            break;
        }
        case IMMessageTypeFile:{
            return [self forwardFileMessage:msg toConversation:conversation success:success failure:failure];
            break;
        }
            
        default:
            break;
    }
    
    return nil;
}

- (MCIMMessageModel *)forwardImageMessage:(MCIMMessageModel *)msg toConversation:(MCIMConversationModel *)conversation success:(ActionBlock)success failure:(FailureBlock)failure
{
    MCIMImageModel *imgMsg = (MCIMImageModel *)msg;
    // 消息没有发送成功，图片还未上传，要先上传图片再发送
    if (msg.state != IMMessageStateSuccess) {
        SDWebImageManager *imageMgr = [SDWebImageManager sharedManager];
        NSURL *localUrl = [NSURL URLWithString:imgMsg.localPath];
        if ([imageMgr cachedImageExistsForURL:localUrl]) {
            NSString *cachedKey = [imageMgr cacheKeyForURL:localUrl];
            UIImage *image = [imageMgr.imageCache imageFromDiskCacheForKey:cachedKey];
            return [self sendImage:image toConversation:conversation success:success failure:failure];
        }
        else{
            DDLogError(@"No local image for forwarding");
            if (failure) {
                NSError *error = [NSError errorWithDomain:@"com.mailchat.error.msg" code:0 userInfo:@{@"error" : @"No local image found for forwarding"}];
                failure(error);
            }
            return nil;
        }
    }
    else{
        
        // 成功上传的图片，转发的时候只要转发地址
        MCIMImageModel *forwardMsg = [MCIMImageModel new];
        forwardMsg.from = AppStatus.currentUser.email;
        forwardMsg.conversationType = conversation.type;
        forwardMsg.to = conversation.peerId;
        forwardMsg.type = IMMessageTypeImage;
        forwardMsg.messageId = [MCUDID newUUID];
        forwardMsg.time = [NSDate new];
        forwardMsg.imageSize = imgMsg.imageSize;
        forwardMsg.size = imgMsg.size;
        forwardMsg.checksum = imgMsg.checksum;
        forwardMsg.name = imgMsg.name;
        
        // 先显示发送状态
        [[MCIMConversationManager shared] updateConversation:conversation withMessage:forwardMsg];
        [self.messageMgr insertMessage:forwardMsg];
        [MCNotificationCenter postNotification:MCNotificationDidReceiveMessage object:forwardMsg];
        [self sendMessage:forwardMsg toConversation:conversation success:success failure:failure];
        
        return forwardMsg;
    }
}

- (MCIMMessageModel *)forwardFileMessage:(MCIMMessageModel *)msg toConversation:(MCIMConversationModel *)conversation success:(ActionBlock)success failure:(FailureBlock)failure
{
    MCIMFileModel *fileMsg = (MCIMFileModel *)msg;
    // 消息没有发送成功，图片还未上传，要先上传图片再发送
    if (msg.state != IMMessageStateSuccess) {
        MCFileBaseModel *fileModel = [[MCFileCore sharedInstance] getFileModelWithFileId:fileMsg.fileId];
        return [self sendFileWithModel:fileModel fileName:fileModel.displayName toConversation:conversation success:success failure:failure];
    }
    else{
        
        // 成功上传的文件，只需要转发地址
        MCIMFileModel *forwardMsg = [MCIMFileModel new];
        forwardMsg.from = AppStatus.currentUser.email;
        forwardMsg.conversationType = conversation.type;
        forwardMsg.to = conversation.peerId;
        forwardMsg.type = IMMessageTypeFile;
        forwardMsg.messageId = [MCUDID newUUID];
        forwardMsg.time = [NSDate new];
        forwardMsg.size = fileMsg.size;
        forwardMsg.checksum = fileMsg.checksum;
        forwardMsg.name = fileMsg.name;
        forwardMsg.localPath = fileMsg.localPath;
        forwardMsg.path = fileMsg.path;
        forwardMsg.downloadState = IMFileDownloaded;
        
        // 先显示发送状态
        [[MCIMConversationManager shared] updateConversation:conversation withMessage:forwardMsg];
        [self.messageMgr insertMessage:forwardMsg];
        [MCNotificationCenter postNotification:MCNotificationDidReceiveMessage object:forwardMsg];
        
        [self sendMessage:forwardMsg toConversation:conversation success:success failure:failure];
        
        return forwardMsg;
    }
}

- (MCIMMessageModel *)resendMessage:(MCIMMessageModel *)msg toConversation:(MCIMConversationModel *)conversation success:(ActionBlock)success failure:(FailureBlock)failure
{
    switch (msg.type) {
        case IMMessageTypeText:
        case IMMessageTypeNotice: {
            
            msg.uid = 0;
            msg.time = [NSDate new];
            //消息存在是否显示时间， 把此消息时间先置0。
            msg.cellHeight = 0;
            msg.state = IMMessageStateSending;
            [[MCIMConversationManager shared] updateConversation:conversation withMessage:msg];
            [self.messageMgr insertMessage:msg];
            [MCNotificationCenter postNotification:MCNotificationDidReceiveMessage object:msg];
            
            [self sendMessage:msg toConversation:conversation success:success failure:failure];
            return msg;
            break;
        }
        case IMMessageTypeVoice:{
            
            MCIMVoiceModel *voiceMsg = (MCIMVoiceModel *)msg;
            
            msg.uid = 0;
            msg.time = [NSDate new];
            //消息存在是否显示时间， 把此消息时间先置0。
            msg.cellHeight = 0;
            msg.state = IMMessageStateSending;
            if (!voiceMsg.sendData) {
                voiceMsg.sendData = [MCIMChatFileManager amrDataWithFileName:voiceMsg.localPath];
            }
            
            [[MCIMConversationManager shared] updateConversation:conversation withMessage:msg];
            [self.messageMgr insertMessage:msg];
            [MCNotificationCenter postNotification:MCNotificationDidReceiveMessage object:msg];
            
            [self sendMessage:msg toConversation:conversation success:success failure:failure];
            return msg;
            break;
        }
        case IMMessageTypeImage:{
            return [self forwardImageMessage:msg toConversation:conversation success:success failure:failure];
            break;
        }
        case IMMessageTypeFile:{
            return [self forwardFileMessage:msg toConversation:conversation success:success failure:failure];
            break;
        }
            
        default:
            break;
    }
    
    return nil;
    
}


- (void)sendMessage:(MCIMMessageModel *)msg toConversation:(MCIMConversationModel *)conversation success:(ActionBlock)success failure:(FailureBlock)failure
{
    NSDictionary *msgDict = [MCMessagePacker dictionaryWithMessage:msg];
    MCIMMsgData *msgData = [[self class] msgDataWithDictionary:msgDict];
    
    NSString *topic = conversation.peerId;
    if (conversation.type == MailChatConversationTypeSingle){
        topic = [NSString stringWithFormat:@"%@/1",topic];
        // 单聊要给自己发送一条消息，进行多设备同步
        NSString *selfTopic = [NSString stringWithFormat:@"%@/1",msg.from];
        NSMutableDictionary *syncDict = [msgDict mutableCopy];
        syncDict[@"t"] = conversation.peerId;
        MCIMMsgData *syncData = [[self class] msgDataWithDictionary:syncDict];
        DDLogVerbose(@"Send message to self = %@", syncDict);
        [self sendMessageData:syncData toTopic:selfTopic completion:nil];
        
    }
    
    DDLogVerbose(@"Send message = %@ to topic = %@",msgDict,topic);
    __weak typeof(self) weakSelf = self;
    [self sendMessageData:msgData toTopic:topic completion:^(NSInteger msgId, NSError *error) {
        if (error) {
            msg.sendMsgId = msgId;
            msg.state = IMMessageStateFailure;
            [weakSelf.messageMgr updateMessageState:msg];
            [self.failureMessages setObject:msg forKey:@(msg.sendMsgId)];
            if (failure) {
                failure(error);
            }
        }
        else{
            msg.sendMsgId = msgId;
            msg.state = IMMessageStateSuccess;
            [weakSelf.messageMgr updateMessageState:msg];
            if (success) {
                success();
            }
        }
    }];
}

- (void)sendMessageData:(MCIMMsgData *)msg toTopic:(NSString *)topic completion:(SendMessageDataCompleteBlock)completionHanlder
{
    NSInteger msgId =  [[MCIMClient shared] sendData:msg.data topic:topic qos:msg.qos];
    msg.msgId =msgId;
    DDLogVerbose(@"Send msg (%ld) to topic = %@",(long)msgId, topic);
    if (completionHanlder) {
        [self.handlers setObject:[completionHanlder copy] forKey:@(msgId)];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            SendMessageDataCompleteBlock handler = [self getHandlerWithMsgId:msgId];
            if (handler) {
                DDLogError(@"Send message (%ld) timeout",(long)msgId);
                handler(msgId, [self timeoutError]);
            }
        });
    }
    else{
        [self.handlers removeObjectForKey:@(msgId)];
    }
}

#pragma mark - IMClient Delegate

- (void)imclient:(MCIMClient *)client messageDelevied:(NSInteger)msgId;
{
    DDLogVerbose(@"Message (%ld) delevied",(long)msgId);
    SendMessageDataCompleteBlock handler = [self getHandlerWithMsgId:msgId];
    if (handler) {
        handler(msgId, nil);
    }
    else{
        MCIMMessageModel *msg = self.failureMessages[@(msgId)];
        if (msg) {
            msg.state = IMMessageStateSuccess;
            [self.failureMessages removeObjectForKey:@(msgId)];
        }
        // 更新本地数据库消息的状态
        [self.messageMgr updateState:IMMessageStateSuccess withMqttMsgId:msgId];
    }
}

#pragma mark - Private
//TODO:写入版本信息
- (void)writeInfoAboutNotifyAndVersion {
    NSString*versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *notifyInfo ;
    if (EGOVersion_iOS8) {
        if ([[[UIApplication sharedApplication] currentUserNotificationSettings] types] == UIUserNotificationTypeNone) {
            notifyInfo = @"手机设置中消息提醒已关闭";
        } else {
            notifyInfo = @"手机设置中消息提醒已开启";
        }
    }else {
        if (![[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
            notifyInfo = @"手机设置中消息提醒已关闭";
        } else {
            notifyInfo = @"手机设置中消息提醒已开启";
        }
    }
    NSString *logInfo = [NSString stringWithFormat:@"当前版本==%@\n通知开启状态 == %@",versionString,notifyInfo];
    DDLogError(@"%@",logInfo);
}

- (SendMessageDataCompleteBlock)getHandlerWithMsgId:(NSInteger)msgId
{
    @synchronized (self.handlers) {
        SendMessageDataCompleteBlock handler = [self.handlers objectForKey:@(msgId)];
        [self.handlers removeObjectForKey:@(msgId)];
        return handler;
    }
}

- (NSError *)timeoutError
{
    return [NSError errorWithDomain:@"com.35.mailchat.mqtt" code:0 userInfo:@{@"error" : @"Send message time out"}];
}

+ (MCIMMsgData *)msgDataWithDictionary:(NSDictionary *)dict
{
    NSString *dictStr = [NSString jsonStringWithObject:dict];
    NSData *data = [dictStr dataUsingEncoding:NSUTF8StringEncoding];
    MCIMMsgData *msg = [[MCIMMsgData alloc] init];
    msg.data = data;
    msg.qos = 2;
    
    return  msg;
}

+ (NSUInteger)fileSizeWithPath:(NSString *)path
{
    NSError *error = nil;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:path error:&error];
    if (error) {
        DDLogError(@"Get file size error = %@",error);
        return 0;
    }
    
    return [attributes[NSFileSize] unsignedIntegerValue];
}

@end
