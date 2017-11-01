//
//  MCIMChatFileManager.m
//  NPushMail
//
//  Created by swhl on 16/4/28.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMChatFileManager.h"
#import "VoiceConverter.h"

@implementation MCIMChatFileManager

+ (NSString *)saveVoiceData:(NSData *)data withFileName:(NSString *)fileName
{
    NSString *filePath = [self voicePathWithFileName:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return filePath;
    }
    
    if (data) {
        [data writeToFile:filePath atomically:NO];
        return filePath;
    }
    
    return nil;
}

+ (NSData *)amrDataWithFileName:(NSString *)fileName
{
    NSString *filePath = [self voicePathWithFileName:fileName];
    filePath = [filePath stringByReplacingOccurrencesOfString:@".wav" withString:@".amr"];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if ([fileMgr fileExistsAtPath:filePath]) {
        return [NSData dataWithContentsOfFile:filePath];
    }
    
    return nil;
}

+ (NSData *)wavDataWithFileName:(NSString *)fileName
{
    NSString *amrFileName = nil;
    NSString *wavFileName = nil;
    if ([fileName hasSuffix:@".amr"]) {
        amrFileName = fileName;
        wavFileName = [fileName stringByReplacingOccurrencesOfString:@".amr" withString:@".wav"];
    }
    else{
        wavFileName = fileName;
        amrFileName = [fileName stringByReplacingOccurrencesOfString:@".wav" withString:@".amr"];
    }
    
    NSString *wavFilePath = [self voicePathWithFileName:wavFileName];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if ([fileMgr fileExistsAtPath:wavFilePath]) {
        return [NSData dataWithContentsOfFile:wavFilePath];
    }
    
    NSString *amrFilePath = [self voicePathWithFileName:amrFileName];
    if ([fileMgr fileExistsAtPath:amrFilePath]) {
        [VoiceConverter amrToWav:amrFilePath wavSavePath:wavFilePath];
        return [NSData dataWithContentsOfFile:wavFilePath];
    }
    
    return nil;
}

+ (void)deleteVoiceFileWithMessageId:(NSString *)messageId
{
    NSString *amrName = [NSString stringWithFormat:@"%@.amr",messageId];
    NSString *wavName = [NSString stringWithFormat:@"%@.wav",messageId];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    [fileMgr removeItemAtPath:amrName error:nil];
    [fileMgr removeItemAtPath:wavName error:nil];
}

+ (NSString *)voicePathWithFileName:(NSString *)fileName
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *voiceFolderPath = [AppStatus.documentDir stringByAppendingPathComponent:@"voice"];
    if (![fileMgr fileExistsAtPath:voiceFolderPath]) {
        [fileMgr createDirectoryAtPath:voiceFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *filePath = [voiceFolderPath stringByAppendingPathComponent:fileName];
    return  filePath;
}

@end
