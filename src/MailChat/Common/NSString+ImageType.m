//
//  NSString+imageType.m
//  NPushMail
//
//  Created by zhang on 15/7/22.
//  Copyright (c) 2015年 sprite. All rights reserved.
//

#import "NSString+ImageType.h"
#import "NSString+Extension.h"

@implementation NSString (ImageType)

//image
//大图（附件图标）
- (NSString*)attachmentBigItemImageName
{
    if ([self hasExtension:@"doc"]|[self hasExtension:@"docx"])
        return @"doc_bigFile.png";
    else if ([self hasExtension:@"txt"])
        return @"txt_bigFile.png";
    else if ([self hasExtension:@"xls"]|[self hasExtension:@"xlsx"])
        return @"xls_bigFile.png";
    else if ([self hasExtension:@"pdf"])
        return @"pdf_bigFile.png";
    else if ([self hasExtension:@"html"])
        return @"html_bigFile.png";
    else if ([self hasExtension:@"zip"]|[self hasExtension:@"rar"])
        return @"rar_bigFile.png";
    else if ([self hasExtension:@"apk"])
        return @"apk_bigFile.png";
    else if ([self hasExtension:@"eml"])
        return @"eml_bigFile.png";
    else if ([self.lowercaseString hasExtension:@"jpg"]||[self.lowercaseString hasExtension:@"png"])
        return @"pic_bigFile.png";
    else if ([self hasExtension:@"ppt"])
        return @"ppt_bigFile.png";
    else if ([self hasExtension:@"psd"])
        return @"psd_bigFile.png";
    else if ([self hasExtension:@"mov"])
        return @"video_bigFile.png";
    else if ([self hasExtension:@"swf"])
        return @"swf_bigFile.png";
    else if ([self hasExtension:@"mp3"])
        return @"mus_bigFile.png";
    else if ([self hasExtension:@"ai"])
        return @"ai_bigFile.png";
    return @"unknown_bigFile.png";
}

- (NSString*)chatFileItemImageName{
    if ([self hasExtension:@"doc"]|[self hasExtension:@"docx"])
        return @"doc_file.png";
    else if ([self hasExtension:@"txt"])
        return @"txt_file.png";
    else if ([self hasExtension:@"xls"]|[self hasExtension:@"xlsx"])
        return @"xls_file.png";
    else if ([self hasExtension:@"pdf"])
        return @"pdf_file.png";
    else if ([self hasExtension:@"html"])
        return @"html_file.png";
    else if ([self hasExtension:@"zip"]|[self hasExtension:@"rar"])
        return @"rar_file.png";
    else if ([self hasExtension:@"apk"])
        return @"apk_file.png";
    else if ([self hasExtension:@"eml"])
        return @"eml_file.png";
    else if ([self.lowercaseString hasExtension:@"jpg"]|[self.lowercaseString hasExtension:@"png"])
        return @"pic_file.png";
    else if ([self hasExtension:@"eml"])
        return @"eml_file.png";
    else if ([self hasExtension:@"ppt"]||[self hasExtension:@"pptx"])
        return @"ppt_file.png";
    else if ([self hasExtension:@"psd"])
        return @"psd_file.png";
    else if ([self hasExtension:@"MOV"]||[self hasExtension:@"mp3"] )
        return @"video_file.png";
    else if ([self hasExtension:@"ai"])
        return @"ai_file.png";
    return @"unknown_file.png";
}


@end
