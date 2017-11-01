//
//  MCProgressView.h
//  NPushMail
//
//  Created by zhang on 16/7/7.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCProgressView : UIView
//进度
@property (nonatomic,assign)CGFloat progress;
//进度条宽度
@property (nonatomic,assign)CGFloat progressWidth;
//进度条颜色
@property (nonatomic,strong)UIColor *progressColor;
//进度条背景色
@property (nonatomic,strong)UIColor *trackColor;
@end
