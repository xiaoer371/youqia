//
//  MCFileCore.m
//  NPushMail
//
//  Created by wuwenyu on 15/12/29.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import "MCFileCore.h"
#import "MCFileManager.h"
#import "MCFileTable.h"
#import "MCFileBaseModel.h"
#import "MCMailAttachment.h"
#import "MCIMFileModel.h"
#import "MCMailManager.h"
#import "MCIMMessageManager.h"
#import "MCUDID.h"
#import "MCMailAttachmentTable.h"

@implementation MCFileCore {
    MCFileManager *_fileManagerModule;
    MCFileTable *_fileDbModule;
}

- (id)init {
    self = [super init];
    if (self) {
        _fileManagerModule = [[MCFileManager alloc] initWithFileCore:self];
        _fileDbModule = [[MCFileTable alloc] init];
    }
    return self;
}

+ (MCFileCore *)sharedInstance {
    static dispatch_once_t pred;
    static MCFileCore *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[MCFileCore alloc] init];
    });
    return _sharedObject;
}

- (MCFileManager *)getFileModule {
    return _fileManagerModule;
}

- (MCFileBaseModel *)getFileModelWithId:(NSInteger)uid
{
    return [_fileDbModule getModelById:uid];
}

- (MCFileBaseModel *)getFileModelWithFileId:(NSString *)fileId
{
    return [_fileDbModule getModelByfileId:fileId];
}

- (MCFileBaseModel *)saveFileInDbWithModel:(id)model {
    MCFileBaseModel *baseModel = [self createFileBaseModelWithModel:model];
    [_fileDbModule insertModel:baseModel];
    return baseModel;
}

- (NSMutableArray *)getAllFiles {
    return [_fileDbModule getAllFiles];
}

- (BOOL)deleteFileWithModel:(id)model {
    BOOL success = NO;
    if ([model isMemberOfClass:[MCFileBaseModel class]]) {
        MCFileBaseModel *fileModel = (MCFileBaseModel *)model;
        //删除文件数据
        success = [_fileManagerModule deleteFileWithPath:[_fileManagerModule getFileFullPathWithShortPath:fileModel.location]];
        //删除基础文件数据库中的文件信息
        success = [_fileDbModule deleteFileWithFileName:fileModel.displayName];
        //TODO 更新邮件或者消息中的附近信息
        if (fileModel.source == FromMail) {
            if (fileModel.fileId) {
                MCMailAttachmentTable *attachmentTable = [MCMailAttachmentTable new];
                [attachmentTable deleteAttachmentLocalFileWithUid:[fileModel.fileId integerValue]];
            }
        }
        if (fileModel.source == FromMesssage) {
            if (fileModel.fileId) {
                MCIMMessageManager *manager = [[MCIMMessageManager alloc] init];
                [manager updateFileMessageWithFileId:fileModel.fileId];
            }
        }
    }
    return success;
}


/**
 *  通过消息或者邮件传过来的model得到基础的baseModel
 *
 *  @param model
 *
 *  @return
 */
- (MCFileBaseModel *)createFileBaseModelWithModel:(id)model {
    MCFileBaseModel *fileBaseModel = [[MCFileBaseModel alloc] init];
    if ([model isMemberOfClass:[MCMailAttachment class]]) {
        MCMailAttachment *attachment = (MCMailAttachment *)model;
        fileBaseModel.fileId = [NSString stringWithFormat:@"%d", attachment.uid];
        fileBaseModel.sourceName = attachment.name;
        /**
         *  文件重名处理
         */
        fileBaseModel.displayName = [self getFileDisplayNameWithSourceName:attachment.name];
        fileBaseModel.size = attachment.size;
        fileBaseModel.format = attachment.fileExtension;
        fileBaseModel.location = attachment.localPath;
        fileBaseModel.receiveDate = attachment.receiveDate;
        fileBaseModel.source = FromMail;
    }
    if ([model isMemberOfClass:[MCIMFileModel class]]) {
        
        MCIMFileModel *fileModel = (MCIMFileModel *)model;
        fileBaseModel.fileId = fileModel.messageId;
        fileBaseModel.sourceName = fileModel.name;
        /**
         *  文件重名处理
         */
        fileBaseModel.displayName = [self getFileDisplayNameWithSourceName:fileModel.name];
        fileBaseModel.size = fileModel.size;
        NSArray *fileExtensions =[fileModel.name componentsSeparatedByString:@"."];
        fileBaseModel.format = [fileExtensions lastObject]?:@"";
        fileBaseModel.location = fileModel.localPath;
        fileBaseModel.receiveDate = [fileModel.time timeIntervalSince1970];
        fileBaseModel.source = FromMesssage;
        
    }
    //小助手日志
    if ([model isKindOfClass:[NSString class]]) {
        fileBaseModel.fileId = [MCUDID newUUID];
        fileBaseModel.sourceName = @"mailchatLog.txt";
        /**
         *  文件重名处理
         */
        fileBaseModel.displayName = [self getFileDisplayNameWithSourceName:@"mailchatLog.txt"];
        fileBaseModel.source = FromMesssage;
        fileBaseModel.format = @"txt";
        
        [self writeInfoAboutNotifyAndVersion];
        NSArray *array =  [DDLog allLoggers];
        for (id obj in array) {
            if ([obj isKindOfClass:[DDFileLogger class]]) {
                DDFileLogger *fileLogger = (DDFileLogger*)obj;
                DDLogFileInfo *fileInfo = [fileLogger currentLogFileInfo];
                NSData *data = [NSData dataWithContentsOfFile:fileInfo.filePath];
                fileBaseModel.size = data.length;
                MCFileManager *fileManager =[[MCFileCore sharedInstance] getFileModule];
                NSString *shortPath = [fileManager saveFileWithData:data folder:msgFileDirectory fileName:fileBaseModel.displayName];
                fileBaseModel.location = shortPath;
                break;
            }
        }
        fileBaseModel.receiveDate = [[NSDate date] timeIntervalSince1970];
    }
    fileBaseModel.downLoadDate = [[NSDate date] timeIntervalSince1970];
    return fileBaseModel;
}

- (NSString *)getFileDisplayNameWithSourceName:(NSString *)sourceName {
    NSString *name = sourceName;
    int i = 0;
    NSMutableArray *files = [self getAllFiles];
    if (files) {
        for (MCFileBaseModel *obj in files) {
            if ([obj.sourceName isEqualToString:sourceName]) {
                i ++;
            }
        }
    }
    if (i > 0) {
        NSRange range = [sourceName rangeOfString:@"." options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            NSString *rangeStr = [sourceName substringToIndex:range.location];
            NSString *extension = [sourceName substringFromIndex:range.location];
            name = [NSString stringWithFormat:@"%@(%d)%@", rangeStr, i, extension];
        } else {
            name = [NSString stringWithFormat:@"%@(%d)", sourceName, i];
        }
        
    }
    return name;
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
        if (![[UIApplication sharedApplication] enabledRemoteNotificationTypes]) {
            notifyInfo = @"手机设置中消息提醒已关闭";
        } else {
            notifyInfo = @"手机设置中消息提醒已开启";
        }
    }
    NSString *logInfo = [NSString stringWithFormat:@"当前版本==%@\n通知开启状态 == %@",versionString,notifyInfo];
    DDLogError(@"%@",logInfo);
}


@end
