//
//  MCIMVoiceHUD.h
//  NPushMail
//
//  Created by swhl on 16/3/9.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCIMVoiceHUD : UIView

@property (nonatomic, strong) UILabel *titleLabel;

+ (void)show;

+ (void)dismissWithSuccess:(NSString *)str;

+ (void)dismissWithError:(NSString *)str;

+ (void)changeSubTitle:(NSString *)str;

+ (void)refreshMeters:(double)lowPassResults;

@end
