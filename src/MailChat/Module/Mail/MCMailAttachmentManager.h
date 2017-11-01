//
//  MCMailAttachmentManager.h
//  NPushMail
//
//  Created by zhang on 16/2/26.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCMailProviderProtocol.h"
@interface MCMailAttachmentManager : NSObject

- (instancetype)initWithProvider:(id<MCMailProviderProtocol>)provider;

/**
 *  获取附件信息
 */
- (NSArray*)getAttachmentsWithMail:(NSInteger)mailId;

- (NSArray*)getInlineAttachmemtWithMail:(NSInteger)mailId;
//更新附件信息
- (void)updataAttachmentInfoWithAttachment:(MCMailAttachment *)attachment;
/** 获取附件内容 首先本地获取是否存在
 *  下载附件
 *  current  下载当前进度
 *  maximum  总进度
 *  success  返回  MCMailAttachment
 */

- (BOOL)getAttachmentDataWith:(MCMailAttachment*)attachment progress:(ProgressBlock)progress success:(SuccessBlock)success failure:(FailureBlock)failure;
/**
 *  加载内嵌图片
 *
 *  @param inlineAttachments MCMailAttachment
 *  @param success           NSString  replaceScript for webView
 *  @param failuer           error
 */
- (void)toLoadInlineAttachment:(NSArray*)inlineAttachments success:(SuccessBlock)success failure:(FailureBlock)failuer;
/**
 *  删除本地文件 更新附件信息
 *
 *  @param uid attachment uid
 */
- (void)deleteAttachmentLocalFielWithUid:(NSInteger)uid;

/**
 *  保存附件
 *
 *  @param attachment MCMailAttachment
 */
- (void)saveAttachmentInfo:(MCMailAttachment*)attachment;
@end
