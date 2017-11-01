//
//  MCAdjustFontSizeView.h
//  NPushMail
//
//  Created by swhl on 16/12/7.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCAppSetting.h"

typedef void(^adjustFont)(NSString * fontSize); // fontSize eg: @"20%"

@protocol MCAdjustFontSizeViewDelegate <NSObject>

- (void)adjustFontSizeView:(NSString *)fontSize;

@end

@interface MCAdjustFontSizeView : UIView

@property (nonatomic, copy) adjustFont  adjustFont;
@property (nonatomic,weak) id<MCAdjustFontSizeViewDelegate> delegate;


+ (MCAdjustFontSizeView *)ShowWithValue:(CGFloat )value adjustFontBlock:(adjustFont)adjustFont;


@end
