//
//  MCMailAttachmentManager.m
//  NPushMail
//
//  Created by zhang on 16/2/26.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCMailAttachmentManager.h"
#import "MCMailAttachmentTable.h"
#import "MCCallbackUtils.h"
#import "MCFileCore.h"
#import "MCFileManager.h"
@interface MCMailAttachmentManager ()

@property (nonatomic,strong) MCMailAttachmentTable *db;
@property (nonatomic,strong) id<MCMailProviderProtocol>provider;
@property (nonatomic,strong) MCFileManager * fileManager;
@end

@implementation MCMailAttachmentManager

- (instancetype)initWithProvider:(id<MCMailProviderProtocol>)provider {
    if (self = [super init]) {
    
        _db = [MCMailAttachmentTable new];
        _provider = provider;
        _fileManager = [MCFileCore sharedInstance].getFileModule;
    }
    return self;
}

- (NSArray*)getAttachmentsWithMail:(NSInteger)mailId {
    
    return [_db getAttachementsForMail:mailId];
}

- (NSArray*)getInlineAttachmemtWithMail:(NSInteger)mailId {
    return [_db getInlineAttachmentForMail:mailId];
}

- (void)updataAttachmentInfoWithAttachment:(MCMailAttachment *)attachment {
    [_db updateModel:attachment];
}

- (BOOL)getAttachmentDataWith:(MCMailAttachment*)attachment  progress:(ProgressBlock)progress success:(SuccessBlock)success failure:(FailureBlock)failure {
    
    if (attachment.isDownload && attachment.localPath && [self.fileManager fileIsExistsAtPath:attachment.localPath]) {
        //TODO:本地获取
        NSData *data = [self.fileManager getFileDataWithShortPath:attachment.localPath];
        attachment.data = data;
        success(attachment);
        return NO;
    } else {
        
        __weak typeof(self) weakSelf = self;
        [self.provider getAttachmentData:attachment progress:progress success:^(id response) {
            attachment.data = (NSData*)response;
            [weakSelf saveAttachmentInfo:attachment];
            success(attachment);
        } failure:failure];
        return YES;
    }
}

- (void)saveAttachmentInfo:(MCMailAttachment*)attachment {
    
    //TODO:写入本地 返回路径
    NSString *path;
    
    if (!attachment.cid) {
        path =[_fileManager saveFileWithData:attachment.data folder:mailFileDirectory fileName:attachment.name];
        attachment.localPath = path;
        [[MCFileCore sharedInstance] saveFileInDbWithModel:attachment];
    } else {
        path = [_fileManager saveInlineFileWithData:attachment.data fileName:attachment.name];
        attachment.localPath = path;
    }
    if (path) {
        attachment.isDownload = YES;
    }
    [self updataAttachmentInfoWithAttachment:attachment];
}
//TODO:加载内嵌图片
- (void)toLoadInlineAttachment:(NSArray*)inlineAttachments success:(SuccessBlock)success failure:(FailureBlock)failuer {
    for (MCMailAttachment *inlineAttachment in inlineAttachments) {
        if (!inlineAttachment.cid) {
            continue;
        }
        
        __weak typeof(self) weakSelf = self;
        [self getAttachmentDataWith:inlineAttachment progress:nil success:^(id response) {
            
          [weakSelf getImapPathWith:inlineAttachment success:success failure:failuer];
            
        } failure:nil];
    }
}
- (void)getImapPathWith:(MCMailAttachment*)attachment success:(SuccessBlock)success failure:(FailureBlock)failure {
    
    NSString*fullPath = [[[MCFileCore sharedInstance] getFileModule] getFileFullPathWithShortPath:attachment.localPath];
    NSString* path = [NSString stringWithFormat:@"file://%@",fullPath];
    NSString*urlString = [NSString stringWithFormat:@"cid:%@",attachment.cid];
    NSDictionary * args = @{@"URLKey": urlString, @"LocalPathKey": path};
    NSString * jsonString = [self _jsonEscapedStringFromDictionary:args];
    NSString * replaceScript = [NSString stringWithFormat:@"replaceImageSrc(%@)", jsonString];
    if (jsonString) {
        [MCCallbackUtils reportSuccessOnMainThread:success withResponse:replaceScript];
    } else {
        [MCCallbackUtils reportSuccessOnMainThread:failure withResponse:nil];
    }
}
//拼接HTML可识别标签
- (NSString *) _jsonEscapedStringFromDictionary:(NSDictionary *)dictionary
{
    NSData * json = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString * jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    return jsonString;
}


- (void)deleteAttachmentLocalFielWithUid:(NSInteger)uid {
    [_db deleteAttachmentLocalFileWithUid:uid];
}

@end
