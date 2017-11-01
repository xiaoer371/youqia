//
//  MCIMFileModel.m
//  NPushMail
//
//  Created by swhl on 16/1/27.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMFileModel.h"
#import "NSString+JSON.h"
#import "MCAppSetting.h"

@implementation MCIMFileModel

- (IMMessageType)type
{
    return IMMessageTypeFile;
}

- (NSString *)shortDescription
{
    return PMLocalizedStringWithKey(@"PM_Msg_Type_File");
}

- (NSString *)content
{
    NSDictionary *json = @{@"name" : self.name,
                           @"checksum" : self.checksum,
                           @"size" : @(self.size),
                           @"downloadState" : @(self.downloadState),
                           @"fileId" : self.fileId?:self.messageId,
                           @"localPath" : self.localPath ?: @""
                           };
    return [NSString jsonStringWithObject:json];
}

- (void)setContent:(NSString *)content
{
    [super setContent:content];
    
    if (content) {
        NSDictionary *json = [content toJson];
        self.name = [json objectForKey:@"name"];
        self.checksum = [json objectForKey:@"checksum"];
        self.size = [[json objectForKey:@"size"] integerValue];
        self.downloadState = [[json objectForKey:@"downloadState"] integerValue];
        self.fileId = [json objectForKey:@"fileId"];
        self.localPath = [json objectForKey:@"localPath"];
    }
}

- (NSString *)path
{
    if (!_path) {
        NSString *filePath = [NSString stringWithFormat:@"file/%@/%@",self.checksum,self.name];
        filePath = [filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        _path = [AppSettings.apiBaseUrl stringByAppendingPathComponent:filePath];
    }
    
    return _path;
}


@end
