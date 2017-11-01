//
//  MCTheme.h
//  NPushMail
//
//  Created by admin on 1/27/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCMailBoxIconStyle.h"
#import "MCMailStyle.h"
#import "MCIMChatStyle.h"
#import "MCIMBubbleStyle.h"
#import "MCProfileStyle.h"
@interface MCTheme : NSObject

/**
 *  主题的名称
 */
@property (nonatomic, copy) NSString *name;

/**
 *  创建一个新的主题
 *
 *  @param themeName 主题的名字，必需有对应的主题文件
 *
 *  @return 新建的主题
 */
- (instancetype)initWithName:(NSString *)themeName;

/**
 *  主颜色(比如导航栏的)，可点击的按钮文字颜色，强调颜色等
 */
@property (nonatomic,strong) UIColor *tintColor;

/**
 *   主颜色，不可点击的按钮文字颜色，相对强颜色的弱颜色
 */
@property (nonatomic,strong) UIColor *tintWeakColor;

/**
 *  也是主色调，主要是针对于页面中的除标题以外的字体颜色（默认为灰色）,比如邮件摘要，副标题等
 */

@property (nonatomic,strong) UIColor *fontTintColor;
/**
 *  标题颜色，除去导航栏之外的标题，cell标题等等(默认为黑色)
 */

@property (nonatomic,strong) UIColor *titleTextColor;
/**
 *  导航栏字体颜色
 */
@property (nonatomic,strong) UIColor *navgationBarTitleTextColor;
/**
 *  tableview分割线颜色
 */
@property (nonatomic,strong) UIColor *tableViewSeparatorColor;
/**
 *  底部工具栏的背景色
 */
@property (nonatomic,strong) UIColor *toolBarBackgroundColor;
/**
 *  底部工具栏的分割线
 */
@property (nonatomic,strong) UIColor *toolBarSeparatorColor;
/**
 *  比较深的背景色，目前用于导航栏
 */

@property (nonatomic,strong) UIColor *darkBackgroundColor;

/**
 *  比较深的边框颜色，比如导航栏的边框
 */
@property (nonatomic,strong) UIColor *darkBorderColor;

/**
 *  页面背景色
 */
@property (nonatomic,strong) UIColor *backgroundColor;

/**
 *  页面边框颜色
 */
@property (nonatomic,strong) UIColor *borderColor;
/**
 *  进入编辑状态下的cell的可选样式
 *
 */
@property (nonatomic,strong) UIImage *selectStateImage;
@property (nonatomic,strong) UIImage *unselectStateImage;
@property (nonatomic,strong) UIImage *cantEditStateImage;
/**
 *  tabBar 样式
 *  @return UIImage array
 */
@property (nonatomic,strong) NSArray *tabBarImages;
@property (nonatomic,strong) NSArray *tabBarHightlightImages;
/**
 *  邮件样式
 */
@property (nonatomic,strong) MCMailStyle *mailStyle;
/**
 *  邮件文件夹的样式
 */
@property (nonatomic,strong) MCMailBoxIconStyle *mailBoxStyle;

/**
 *  接收消息气泡样式
 */
@property (nonatomic,strong) MCIMBubbleStyle *incomingBubbleStyle;

/**
 *  发送消息的气泡样式
 */
@property (nonatomic,strong) MCIMBubbleStyle *outgoingBubbleStyle;

/**
 *  聊天相关的样式
 */
@property (nonatomic,strong) MCIMChatStyle   *chatStyle;
/**
 *  设置界面样式
 */
@property (nonatomic,strong) MCProfileStyle  *profileStyle;


/**
 *  导航栏返回图片
 */
@property (nonatomic,strong) UIImage *commonBackImage;
@property (nonatomic,strong) UIImage *navbarBgImage;

/**
 *  登录界面图片
 */
@property (nonatomic, strong) UIImage  *accountImage;
@property (nonatomic, strong) UIImage  *passwordImage;
@property (nonatomic, strong) UIImage  *passwordHidImage;
@property (nonatomic, strong) UIImage  *passwordShowImage;
@property (nonatomic, strong) UIImage  *accountClearImage;

@end
