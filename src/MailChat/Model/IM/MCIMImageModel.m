//
//  MCIMImageModel.m
//  NPushMail
//
//  Created by swhl on 16/1/27.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMImageModel.h"
#import "NSString+JSON.h"
#import "MCAppSetting.h"

@implementation MCIMImageModel

- (IMMessageType)type
{
    return IMMessageTypeImage;
}

- (NSString *)shortDescription
{
    return PMLocalizedStringWithKey(@"PM_Msg_Type_Pic");
}

- (NSString *)content
{
    NSDictionary *json = @{@"name" : self.name,
                           @"checksum" : self.checksum,
                           @"size" : @(self.size),
                           @"width" : @(self.imageSize.width),
                           @"height" : @(self.imageSize.height)
                           };
    return [NSString jsonStringWithObject:json];
}

- (void)setContent:(NSString *)content
{
    [super setContent:content];
    
    if (content) {
        NSDictionary *json = [content toJson];
        NSInteger width = [[json objectForKey:@"width"] integerValue];
        NSInteger height = [[json objectForKey:@"height"] integerValue];
        self.imageSize = CGSizeMake(width, height);
        self.name = [json objectForKey:@"name"];
        self.size = [[json objectForKey:@"size"] integerValue];
        self.checksum = [json objectForKey:@"checksum"];
    }
}

- (NSString *)localPath
{
    return [NSString stringWithFormat:@"http://localhost/image/%@_picture",self.messageId];
}

- (NSString *)thumbnailPath
{
    NSString *extension = [NSString stringWithFormat:@"file/%@_s/%@",self.checksum,self.name];
    NSString *fullPath = [AppSettings.apiBaseUrl stringByAppendingString:extension];
    return [fullPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)path
{
    NSString *extension = [NSString stringWithFormat:@"file/%@/%@",self.checksum,self.name];
    NSString *fullPath = [AppSettings.apiBaseUrl stringByAppendingString:extension];
    return [fullPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}



@end
