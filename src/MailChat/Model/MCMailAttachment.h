//
//  MailAttachment.h
//  NPushMail
//
//  Created by swhl on 14-10-8.
//  Copyright (c) 2014年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCMailAddress.h"
#import <AssetsLibrary/AssetsLibrary.h>

typedef NS_ENUM(NSInteger, MCAttachEncode) {
    MCAttachEncoding7Bit = 0,
    MCAttachEncode8Bit = 1,
    MCAttachEncodeBinary = 2,
    MCAttachEncodeBase64 = 3,
    MCAttachEncodeQuotedPrintable = 4,
    MCAttachEncodeOther = 5,
};

@interface MCMailAttachment : NSObject

//附件id
@property(nonatomic,assign) NSInteger uid;

//mailId
@property(nonatomic,assign) NSInteger mailId;

//邮件uid
@property(nonatomic,assign) NSInteger mailUid;

//partId
@property(nonatomic,strong) NSString *partId;

//附件名称
@property(nonatomic,strong)NSString *name;

//内嵌附件的 inline cid
@property(nonatomic,strong)NSString *cid;

//附件大小
@property(nonatomic,assign) NSUInteger size;

//MIME type of the part. For example application/data
@property(nonatomic,strong)NSString *mimeType;

//附件的编码格式
@property(nonatomic,assign)MCAttachEncode partEncode;

//附件本地短路径
@property(nonatomic,strong)NSString *localPath;

//附件文件夹
@property(nonatomic,strong)NSString *partFolder;

//接收的时间
@property(nonatomic,assign)int64_t   receiveDate;

//来源者
@property(nonatomic,strong)MCMailAddress *from;

//文件后缀
@property (nonatomic,strong) NSString *fileExtension;

//附件是否已经下载
@property(nonatomic,assign) BOOL isDownload;

//图片附件可预览
@property(nonatomic,assign)BOOL  isImage;
//原图
@property(nonatomic,assign) BOOL isOriginalImage;

//缩列图
@property(nonatomic,strong) UIImage *thumbImage;

//附件数据
@property(nonatomic,strong) NSData  *data;

@property(nonatomic,strong) UIImage *originalImage;
@end
