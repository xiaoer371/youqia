//
//  MCIMVoiceModel.m
//  NPushMail
//
//  Created by swhl on 16/1/27.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMVoiceModel.h"
#import "NSString+Json.h"

@implementation MCIMVoiceModel

- (IMMessageType)type
{
    return IMMessageTypeVoice;
}

- (NSString *)shortDescription
{
    return PMLocalizedStringWithKey(@"PM_Msg_Type_Voice");
}

- (NSString *)content
{
    NSDictionary *jsonContent = @{@"seconds" : @(self.seconds),
                                  @"localPath" : self.localPath
                                  };
    
    return [NSString jsonStringWithObject:jsonContent];
}

- (void)setContent:(NSString *)content
{
    [super setContent:content];
    
    self.localPath = nil;
    self.seconds = 0;
    if (content) {
        NSDictionary *json = [content toJson];
        self.localPath = json[@"localPath"];
        self.seconds = [json[@"seconds"] floatValue];
    }
}

@end
