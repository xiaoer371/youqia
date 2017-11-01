//
//  MCModelConversion.m
//  NPushMail
//
//  Created by zhang on 16/5/27.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCModelConversion.h"
#import "MCFileCore.h"
#import "MCFileManager.h"
@implementation MCModelConversion


+ (MCMailAddress*)mailAddressWithMCContactModel:(MCContactModel*)contactModel {
    MCMailAddress *mailAddress = [MCMailAddress new];
    mailAddress.email = contactModel.account;
    mailAddress.name = contactModel.displayName;
    return mailAddress;
}
//MCMailAddress to MCContactModel
+ (MCContactModel*)contactModelWithMailAddress:(MCMailAddress*)mailAddress {
    MCContactModel *contactModel = [[MCContactManager sharedInstance] getOrCreateContactWithEmail:mailAddress.email name:mailAddress.name];
    return contactModel;
}
//MCFileBaseModel to MCMailAttachment
+ (MCMailAttachment*)mailAttachmentWithFileBaseModel:(MCFileBaseModel*)fileBaseModel {
    MCMailAttachment *mailAttachment = [MCMailAttachment new];
    
    NSData*data = [[[MCFileCore sharedInstance] getFileModule] getFileDataWithShortPath:fileBaseModel.location];
    BOOL isImage = [fileBaseModel.format isEqualToString:@"jpg"]|[fileBaseModel.format isEqualToString:@"png"];
    mailAttachment.thumbImage = nil;
    mailAttachment.mimeType = fileBaseModel.sourceName.pathExtension;
    mailAttachment.fileExtension = fileBaseModel.sourceName.pathExtension;
    mailAttachment.name = fileBaseModel.sourceName;
    mailAttachment.data = data;
    mailAttachment.size = fileBaseModel.size;
    mailAttachment.localPath = fileBaseModel.location;
    mailAttachment.isDownload = YES;
    mailAttachment.isImage = isImage;
    return mailAttachment;
}
//MCMailAttachment to MCFileBaseModel
+ (MCFileBaseModel*)fileBaseModelWithMailAttachment:(MCMailAttachment*)mailAttachment {
    MCFileBaseModel *fileBaseModel = [MCFileBaseModel new];
    return fileBaseModel;
}
//MCIMFileModel to MCMailAttachment;
+ (MCMailAttachment*)mailAttachmentWithIMFileModel:(MCIMFileModel*)imFileModel {
    MCMailAttachment *mailAttachment = [MCMailAttachment new];
    
    BOOL isImage = [imFileModel.name.pathExtension isEqualToString:@"jpg"] || [imFileModel.name.pathExtension isEqualToString:@"png"] || [imFileModel.name.pathExtension isEqualToString:@"bmp"];
    NSData*data = [[[MCFileCore sharedInstance] getFileModule] getFileDataWithShortPath:imFileModel.localPath];
    mailAttachment.mimeType = imFileModel.name.pathExtension;
    mailAttachment.fileExtension = imFileModel.name.pathExtension;
    mailAttachment.name = imFileModel.name;
    mailAttachment.data = data;
    mailAttachment.size = imFileModel.size;
    mailAttachment.localPath = imFileModel.localPath;
    mailAttachment.isDownload = YES;
    mailAttachment.isImage = isImage;
    return mailAttachment;
}

+ (MCMailAttachment *)mailAttachmentWithIMImageModel:(MCIMImageModel*)imImageModel {
    
    MCMailAttachment *attachment = [MCMailAttachment new];
    NSData*data = [[[MCFileCore sharedInstance] getFileModule] getFileDataWithShortPath:imImageModel.localPath];
    attachment.thumbImage = imImageModel.thumbnailImg;
    attachment.mimeType = imImageModel.name.pathExtension;
    attachment.fileExtension = imImageModel.name.pathExtension;
    attachment.name = imImageModel.name;
    attachment.data = data;
    attachment.size = imImageModel.size;
    attachment.localPath = imImageModel.localPath;
    attachment.isDownload = YES;
    attachment.isImage = YES;
    return attachment;
}

//MailAddress to string
+ (NSString*)stringWithMailAddresses:(NSArray*)adddresses {
    
    NSMutableArray *nameArray = [NSMutableArray new];
    for (MCMailAddress *ad in adddresses) {
         if (ad.email){
            [nameArray addObject:[self emailUrlWithEmail:ad]];
        } else {
            continue;
        }
    }
    return [nameArray componentsJoinedByString:@"、"];
}

+ (NSString*)emailUrlWithEmail:(MCMailAddress*)ad {
    NSString *emailAddress = [NSString stringWithFormat:@"<a href=\"mailto:%@\" style=\"color:#4284d9;\">%@</a>",ad.email,ad.name?ad.name:ad.email];
    return emailAddress;
}

//MCMailAttachment With File URL
+ (MCMailAttachment*)mailattachmentWithUrl:(NSURL*)url{
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (!data) {
        return nil;
    }
    MCMailAttachment *attachment = [MCMailAttachment new];
    NSString *urlString = [url absoluteString];
    NSString *fileName = [urlString.lastPathComponent stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *extension = fileName.pathExtension;
    attachment.data = data;
    attachment.name = fileName;
    attachment.size = data.length;
    attachment.mimeType = extension;
    attachment.fileExtension = extension;
    return attachment;
}

@end
