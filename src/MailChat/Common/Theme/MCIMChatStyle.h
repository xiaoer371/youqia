//
//  MCIMChatStyle.h
//  NPushMail
//
//  Created by swhl on 16/2/26.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCIMChatStyle : NSObject



/**
 *  消息列表导航右边图片
 */
@property (nonatomic, strong) UIImage  *messageNavRightImage;

/**
 *  聊天界面导航右边图片
 */
@property (nonatomic, strong) UIImage  *chatNavRightImage;

/**
 *  消息会话列表  背景图
 */
@property (nonatomic, strong) UIImage  *chatListBackGroundImage;


@property (nonatomic, strong) UIImage  *chatInfoContactAddImage;

@property (nonatomic, strong) UIImage  *chatInfoContactdelImage;


/**
 *  消息列表  背景图
 */
@property (nonatomic, strong) UIImage  *chatTableViewBackGroundImage;

/**
 *  聊天输入框 背景图片
 */
@property (nonatomic, strong) UIImage  *chatToolBarBackGroundImage;

/**
 *  聊天输入框 背景颜色
 */
@property (nonatomic, strong) UIColor *chatToolBarBackColor;

/**
 *  更多选项 的背景颜色
 */
@property (nonatomic, strong) UIColor  *moreViewBackGroundColor;

/**
 *  表情界面 的背景颜色
 */
@property (nonatomic, strong) UIColor  *faceViewBackGroundColor;

/**
 *  语音按钮
 */
@property (nonatomic, strong) UIImage  *voiceImage;

/**
 *  表情按钮
 */
@property (nonatomic, strong) UIImage  *faceImage;

/**
 *  文本按钮
 */
@property (nonatomic, strong) UIImage  *textImage;

/**
 *  更多按钮
 */
@property (nonatomic, strong) UIImage  *moreImage;
/**
 *  更多选项 照片图片
 */
@property (nonatomic, strong) UIImage  *morePhothImage;
/**
 *  更多选项 拍照图片
 */
@property (nonatomic, strong) UIImage  *moreTakeImage;
/**
 *  更多选项 文件图片
 */
@property (nonatomic, strong) UIImage  *moreFileImage;


/**
 *  录音按钮图片
 */
@property (nonatomic, strong) UIImage  *recordImage;

/**
 *  录音字体颜色
 */
@property (nonatomic, strong) UIColor  *recordTextColor;








@end
