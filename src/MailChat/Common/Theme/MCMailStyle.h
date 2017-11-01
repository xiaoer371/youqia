//
//  MCMailStyle.h
//  NPushMail
//
//  Created by zhang on 16/3/14.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCMailStyle : NSObject


//附件列表单元格背景色
@property (nonatomic,strong)UIColor *mailAttachCellBackgroundColor;

//邮件列表导航条左边图标
@property (nonatomic,strong)UIImage *mailListLeftImage;

//邮件列表导航搜索图标
@property (nonatomic,strong)UIImage *mailListSearchImage;

//邮件列表导航条右边图标
@property (nonatomic,strong)UIImage *mailListRightImage;

//邮件列表筛选表示图标
@property (nonatomic,strong)UIImage *classifyNoteImage;

//邮件附件图标
@property (nonatomic,strong)UIImage *mailAttachImage;

//邮件已读未读标示图标
@property (nonatomic,strong)UIImage *mailReadImage;

//邮件收藏与否图标
@property (nonatomic,strong)UIImage *mailStarImage;

//邮件详情右边导航条图标
@property (nonatomic,strong)UIImage *mailDetailRightSelectImage;
@property (nonatomic,strong)UIImage *mailDetailRightDeSelectImage;

//附件列表图标
@property (nonatomic,strong)UIImage *mailAttachDownLoadImage;
@property (nonatomic,strong)UIImage *mailAttachPreviewImage;
//分享附件
@property (nonatomic,strong)UIImage *attachmentShareImage;

//刷新图标集合
@property (nonatomic,strong)NSArray *mcRefreshImages;
@end
