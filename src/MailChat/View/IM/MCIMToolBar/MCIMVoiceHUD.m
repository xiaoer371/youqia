//
//  MCIMVoiceHUD.m
//  NPushMail
//
//  Created by swhl on 16/3/9.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMVoiceHUD.h"

@interface MCIMVoiceHUD ()
{
    NSTimer *myTimer;
    int timeCount;
}

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong, readonly) UIWindow *overlayWindow;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic,strong) UIImageView *voiceImg;

@end


@implementation MCIMVoiceHUD
@synthesize overlayWindow,timeLabel;



+ (MCIMVoiceHUD*)sharedView {
    static dispatch_once_t once;
    static MCIMVoiceHUD *sharedView;
    dispatch_once(&once, ^ {
        sharedView = [[MCIMVoiceHUD alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth/3+50, 140)/*[[UIScreen mainScreen] bounds]*/];
        sharedView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
        sharedView.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2,[[UIScreen mainScreen] bounds].size.height/2);
        sharedView.layer.cornerRadius = 12;
        sharedView.layer.masksToBounds = YES;
    });
    return sharedView;
}

+ (void)show {
    [[MCIMVoiceHUD sharedView] show];
}

- (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!self.superview)
            [self.overlayWindow addSubview:self];
        
        
        //语音图片
        if (!self.voiceImg) {
            self.voiceImg =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 42, 42)];
            self.voiceImg.image =[UIImage imageNamed:@"voice_pic.png"];
        }
        self.voiceImg.center = CGPointMake([self bounds].size.width/2,[self bounds].size.height/2-30);
        [self addSubview:self.voiceImg];
        
        //时间
        if (!self.timeLabel){
            self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 20)];
            self.timeLabel.backgroundColor = [UIColor clearColor];
        }
        self.timeLabel.center = CGPointMake([self bounds].size.width/2,[self bounds].size.height/2 +10);
        self.timeLabel.text = @"0:00";
        timeCount=0;
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        self.timeLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.timeLabel];
        
        //标题
        if (!self.titleLabel){
            self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 20)];
            self.titleLabel.backgroundColor = [UIColor clearColor];
        }
        self.titleLabel.center = CGPointMake([self bounds].size.width/2,[self bounds].size.height/2+40);
        self.titleLabel.text = @"手指上滑,取消发送";
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        self.titleLabel.textColor = [UIColor whiteColor];
        
        [self addSubview:self.titleLabel];
        
        if (myTimer)
            [myTimer invalidate];
        myTimer = nil;
        myTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                   target:self
                                                 selector:@selector(startAnimation)
                                                 userInfo:nil
                                                  repeats:YES];
        
      
        
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.alpha = 1;
                         }
                         completion:^(BOOL finished){
                         }];
        [self setNeedsDisplay];
    });
}

-(void) startAnimation
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    UIView.AnimationRepeatAutoreverses = YES;
    
    if (timeCount >=50) {
        self.timeLabel.textColor = [UIColor redColor];
    }else{
        self.timeLabel.textColor = [UIColor whiteColor];
    }
    timeCount+=1;
    if (timeCount<10) {
        self.timeLabel.text = [NSString stringWithFormat:@"0:0%d",timeCount];
    }else{
        self.timeLabel.text = [NSString stringWithFormat:@"0:%d",timeCount];
    }
    
    [UIView commitAnimations];
}

+ (void)changeSubTitle:(NSString *)str
{
    [[MCIMVoiceHUD sharedView] setState:str];
}

- (void)setState:(NSString *)str
{
    self.titleLabel.text = str;
    
    if ([str isEqualToString:@"手指上滑,取消发送"]) {
        self.voiceImg.image =[UIImage imageNamed:@"voice_pic.png"];
    }else{
        self.voiceImg.image =[UIImage imageNamed:@"voice_cancel.png"];
    }
}

+ (void)dismissWithSuccess:(NSString *)str {
    [[MCIMVoiceHUD sharedView] dismiss:str];
}

+ (void)dismissWithError:(NSString *)str {
    [[MCIMVoiceHUD sharedView] dismiss:str];
}

+ (void)refreshMeters:(double)lowPassResults
{
    
    MCIMVoiceHUD *imVoiceHUD =  [MCIMVoiceHUD sharedView];
    if (0<lowPassResults<=0.06) {
        [imVoiceHUD.voiceImg setImage:[UIImage imageNamed:@"record_animate_01.png"]];
    }else if (0.06<lowPassResults<=0.13) {
        [imVoiceHUD.voiceImg setImage:[UIImage imageNamed:@"record_animate_02.png"]];
    }else if (0.13<lowPassResults<=0.20) {
        [imVoiceHUD.voiceImg setImage:[UIImage imageNamed:@"record_animate_03.png"]];
    }else if (0.20<lowPassResults<=0.27) {
        [imVoiceHUD.voiceImg setImage:[UIImage imageNamed:@"record_animate_04.png"]];
    }else if (0.27<lowPassResults<=0.34) {
        [imVoiceHUD.voiceImg setImage:[UIImage imageNamed:@"record_animate_05.png"]];
    }else if (0.34<lowPassResults<=0.41) {
        [imVoiceHUD.voiceImg setImage:[UIImage imageNamed:@"record_animate_06.png"]];
    }else if (0.41<lowPassResults<=0.48) {
        [imVoiceHUD.voiceImg setImage:[UIImage imageNamed:@"record_animate_07.png"]];
    }else if (0.48<lowPassResults<=0.55) {
        [imVoiceHUD.voiceImg setImage:[UIImage imageNamed:@"record_animate_08.png"]];
    }else if (0.55<lowPassResults<=0.62) {
        [imVoiceHUD.voiceImg setImage:[UIImage imageNamed:@"record_animate_09.png"]];
    }else if (0.62<lowPassResults<=0.69) {
        [imVoiceHUD.voiceImg setImage:[UIImage imageNamed:@"record_animate_10.png"]];
    }else if (0.69<lowPassResults<=0.76) {
        [imVoiceHUD.voiceImg setImage:[UIImage imageNamed:@"record_animate_11.png"]];
    }else if (0.76<lowPassResults<=0.83) {
        [imVoiceHUD.voiceImg setImage:[UIImage imageNamed:@"record_animate_12.png"]];
    }else if (0.83<lowPassResults<=0.9) {
        [imVoiceHUD.voiceImg setImage:[UIImage imageNamed:@"record_animate_13.png"]];
    }else {
        [imVoiceHUD.voiceImg setImage:[UIImage imageNamed:@"record_animate_14.png"]];
    }

}


- (void)dismiss:(NSString *)state {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [myTimer invalidate];
        myTimer = nil;
        //        self.subTitleLabel.text = nil;
        self.timeLabel.text = nil;
        self.titleLabel.text = state;
        //        centerLabel.textColor = [UIColor whiteColor];
        
        CGFloat timeLonger;
        if ([state isEqualToString:@"Too Short"]) {
            timeLonger = 2;
        }else{
            timeLonger = 0.6;
        }
        [UIView animateWithDuration:timeLonger
                              delay:0
                            options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             if(self.alpha == 0) {
                                 [self.backView removeFromSuperview];
                                 self.backView = nil;
                                 [self.voiceImg removeFromSuperview];
                                 self.voiceImg = nil;
                                 [self.timeLabel removeFromSuperview];
                                 self.timeLabel = nil;
                                 
                                 NSMutableArray *windows = [[NSMutableArray alloc] initWithArray:[UIApplication sharedApplication].windows];
                                 [windows removeObject:overlayWindow];
                                 overlayWindow = nil;
                                 
                                 [windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIWindow *window, NSUInteger idx, BOOL *stop) {
                                     if([window isKindOfClass:[UIWindow class]] && window.windowLevel == UIWindowLevelNormal) {
                                         [window makeKeyWindow];
                                         *stop = YES;
                                     }
                                 }];
                             }
                         }];
    });
}

- (UIWindow *)overlayWindow {
    if(!overlayWindow) {
        
        overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        overlayWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        overlayWindow.userInteractionEnabled = NO;
        [overlayWindow makeKeyAndVisible];
        
        
    }
    return overlayWindow;
}


@end
