//
//  MCIMChatNoticeCell.h
//  NPushMail
//
//  Created by swhl on 16/4/22.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCIMMessageModel.h"

static const CGFloat padding = 5;//label与背景的间距
static const CGFloat paddingY = 3;//时间label与背景的间距
static const CGFloat fontSize = 14.0f;//字体大小
static const CGFloat timeLabelHeight = 18;//时间label高度

@interface MCIMChatNoticeCell : UITableViewCell
@property (nonatomic,strong)UILabel *contentLabel;
@property (nonatomic, retain)MCIMMessageModel *model;

+(CGFloat) cellHeightWithMessageModel:(MCIMMessageModel *)model showTime:(BOOL)showTime;

@end


@interface UILabel (Common)
typedef enum {
    UILabelResizeType_constantHeight = 1,
    UILabelResizeType_constantWidth,
} UILabelResizeType;

// 调整UILabel尺寸
- (void)resize:(UILabelResizeType)type;

// 返回估计的尺寸
- (CGSize)estimateUISizeByHeight:(CGFloat)height;
- (CGSize)estimateUISizeByWidth:(CGFloat)width;
@end