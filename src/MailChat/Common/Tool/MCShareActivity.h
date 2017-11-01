//
//  MCShareActivity.h
//  NPushMail
//
//  Created by swhl on 16/12/15.
//  Copyright © 2016年 sprite. All rights reserved.
//


/**
 *   这个类用来，别的应用分享，显示我们的应用，要处理的信息。 ps：暂时没有用到
 *   定义要分享的属性，图片，标题，url，文本
 */
#import <UIKit/UIKit.h>

@interface MCShareActivity : UIActivity

@property (nonatomic) UIImage *shareImage;

@property (nonatomic, copy) NSURL *URL;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSArray *shareContentArray;

-(instancetype)initWithImage:(UIImage *)shareImage atURL:(NSURL *)URL atTitle:(NSString *)title atShareContentArray:(NSArray *)shareContentArray;

@end
