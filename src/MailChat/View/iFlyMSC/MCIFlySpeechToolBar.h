//
//  MCIFlySpeechToolBar.h
//  NPushMail
//
//  Created by wuwenyu on 16/11/9.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^startRecBlock)(void);//识别完成回调

@interface MCIFlySpeechToolBar : UIView

@property(nonatomic, strong) UIButton *speechBtn;
@property(nonatomic, strong) startRecBlock startRecBlock;
@end
