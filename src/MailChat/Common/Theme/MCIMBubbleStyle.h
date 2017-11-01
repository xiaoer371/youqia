//
//  MCIMBubbleStyle.h
//  NPushMail
//
//  Created by swhl on 16/2/26.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCIMBubbleStyle : NSObject

/**
 *  bubbleWithSenderText  === text  voice 图片 气泡
 *  bubbleWithSenderFile  === 文件 气泡
 */
@property (nonatomic, strong) UIImage  *bubbleWithText;
@property (nonatomic, strong) UIImage  *bubbleWithFile;


/**
 *  语音对应气泡
 */
@property (nonatomic, strong) UIImage  *voiceMini1;
@property (nonatomic, strong) UIImage  *voiceMini2;
@property (nonatomic, strong) UIImage  *voiceMini3;
@property (nonatomic, strong) UIImage  *voiceDefaul;


/**
 *  背景图伸参数  2 参数拉伸
 */
@property (nonatomic) NSInteger capInsetWidth;
@property (nonatomic) NSInteger capInsetHeight;


/**
 *  时间背景颜色
 */
@property (nonatomic, strong) UIColor  *timeCellColor;

/**
 *  时间文本颜色
 */
@property (nonatomic, strong) UIColor  *timeTextColor;


/**
 *  背景图伸参数  4 参数拉伸
 */
@property (nonatomic)NSInteger capInsetLeft;
@property (nonatomic)NSInteger capInsetRight;
@property (nonatomic)NSInteger capInsetTop;
@property (nonatomic)NSInteger capInsetBobbom;

/**
 *  bubbleView中，箭头的宽度
 */
@property (nonatomic) NSInteger  arrowWidth;

/**
 *  bubbleView 与 在其中的控件内边距
 */
@property (nonatomic) NSInteger  viewPadding;

/**
 *  文字,bubble用于拉伸点的X坐标
 */
@property (nonatomic) NSInteger  textCapWidth;
/**
 *  文字,bubble用于拉伸点的Y坐标
 */
@property (nonatomic) NSInteger  textCapHeight;

/**
 *  文本框最大宽度
 */
@property (nonatomic) NSInteger  textLabelWidth;

/**
 *  文本框文字大小
 */
@property (nonatomic) NSInteger  textFontSize;

/**
 *  文本框 行间距
 */
@property (nonatomic) NSInteger  textLineSpace;

/**
 *  时间label宽度
 */
@property (nonatomic) NSInteger  timeLableWidth;

/**
 *  时间label 高度
 */
@property (nonatomic) NSInteger  timeLableWHeight;

/**
 *  时间label 字体
 */
@property (nonatomic) NSInteger  timeLableFont;









@end
