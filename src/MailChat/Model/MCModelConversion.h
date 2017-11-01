//
//  MCModelConversion.h
//  NPushMail
//
//  Created by zhang on 16/5/27.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCContactManager.h"
#import "MCMailAttachment.h"
#import "MCMailAddress.h"
#import "MCFileBaseModel.h"
#import "MCIMFileModel.h"
#import "MCIMImageModel.h"
@interface MCModelConversion : NSObject
//MCContactModel to MCMailAddress
+ (MCMailAddress*)mailAddressWithMCContactModel:(MCContactModel*)contactModel;
//MCMailAddress to MCContactModel
+ (MCContactModel*)contactModelWithMailAddress:(MCMailAddress*)mailAddress;
//MCFileBaseModel to MCMailAttachment
+ (MCMailAttachment*)mailAttachmentWithFileBaseModel:(MCFileBaseModel*)fileBaseModel;
//MCMailAttachment to MCFileBaseModel
+ (MCFileBaseModel*)fileBaseModelWithMailAttachment:(MCMailAttachment*)mailAttachment;
//MCIMFileModel to MCMailAttachment;
+ (MCMailAttachment*)mailAttachmentWithIMFileModel:(MCIMFileModel*)imFileModel;
//MCIMImageModel to MCMailAttachment;
+ (MCMailAttachment *)mailAttachmentWithIMImageModel:(MCIMImageModel*)imImageModel;
//MailAddress to string
+ (NSString*)stringWithMailAddresses:(NSArray*)adddresses;
//MCMailAttachment With File URL
+ (MCMailAttachment*)mailattachmentWithUrl:(NSURL*)url;

@end
