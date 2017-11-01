//
//
//  MCStatusBarOverlay.m
//  NPushMail
//
//  Created by zhang on 16/3/23.
//  Copyright © 2016年 sprite. All rights reserved.
//
#import "MCStatusBarOverlay.h"

#import <QuartzCore/QuartzCore.h>

#define ROTATION_ANIMATION_DURATION [UIApplication sharedApplication].statusBarOrientationAnimationDuration
#define STATUS_BAR_HEIGHT CGRectGetHeight([UIApplication sharedApplication].statusBarFrame)
#define STATUS_BAR_WIDTH CGRectGetWidth([UIApplication sharedApplication].statusBarFrame)
#define STATUS_BAR_ORIENTATION [UIApplication sharedApplication].statusBarOrientation
#define IS_IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

#define TEXT_LABEL_FONT [UIFont boldSystemFontOfSize:11]


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@interface MCStatusBarOverlay ()

- (void)animatateview:(UIView *)view show:(BOOL)show completion:(MCStatusBarBasicBlock)completion;

- (void)animatateview:(UIView *)view
    withAnimationType:(MCStatusBarOverlayAnimationType)animationType
                 show:(BOOL)show
           completion:(MCStatusBarBasicBlock)completion;

- (void)fromTopAnimatateview:(UIView *)view show:(BOOL)show completion:(MCStatusBarBasicBlock)completion;

- (void)fadeAnimatateview:(UIView *)view show:(BOOL)show completion:(MCStatusBarBasicBlock)completion;

- (void)initializeToDefaultState;

- (void)rotateStatusBarWithFrame:(NSValue *)frameValue;

- (void)rotateStatusBarAnimatedWithFrame:(NSValue *)frameValue;

- (void)showMessage:(NSString *)message
         withStatus:(MCStatusBarOverlayStatus)status
           duration:(NSTimeInterval)duration
           animated:(BOOL)animated;

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MCStatusBarOverlay

@synthesize progress     = _progress;
@synthesize activityView = _activityView;
@synthesize textLabel    = _textLabel;
@synthesize animation    = _animation;
@synthesize actionBlock  = _actionBlock;
@synthesize contentView  = _contentView;
@synthesize statusLabel  = _statusLabel;


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (MCStatusBarOverlay *)shared {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.windowLevel = UIWindowLevelStatusBar + 1;
        self.frame = [UIApplication sharedApplication].statusBarFrame;
        self.animation = MCStatusBarOverlayAnimationTypeFade;
         _contentView = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth - 100, 0, 100, 20)];
//        _contentView.alpha = 0.1;
        [self addSubview:_contentView];
        
        UIView*vi = [[UIView alloc]initWithFrame:CGRectMake(10, 0, 100, 20)];
        vi.backgroundColor = [UIColor clearColor];
        [_contentView addSubview:vi];
        
        UIView*bgView = [[UIView alloc]initWithFrame:CGRectMake(18, 7, 65, 6)];
        bgView.layer.cornerRadius = 3.0;
        bgView.clipsToBounds = YES;
        bgView.layer.borderColor = [UIColor whiteColor].CGColor;
        bgView.layer.borderWidth = 1.0;
        [vi addSubview:bgView];
        
        _progressView = [[UIView alloc] initWithFrame:self.frame];
        _progressView.frame = CGRectMake(18, 8, 6, 4);
        [vi addSubview:_progressView];
        
//        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//        self.activityView.frame = CGRectMake(4, 4, CGRectGetHeight(self.frame) - 4 * 2, CGRectGetHeight(self.frame) - 4 * 2);
//        self.activityView.hidesWhenStopped = YES;
//        
//        if ([self.activityView respondsToSelector:@selector(setColor:)]) { // IOS5 or greater
//            [self.activityView.layer setValue:[NSNumber numberWithFloat:0.7f] forKeyPath:@"transform.scale"];
//        }
//        
//        
//        [self.contentView addSubview:self.activityView];
        
        _sendStateItem = [[UIImageView alloc]initWithFrame:CGRectMake(10, 0, 20, 20)];
        _sendStateItem.image = [UIImage imageNamed:@"mc_sendMail.png"];
        [self.contentView addSubview:_sendStateItem];
        
        _statusLabel = [[UILabel alloc] initWithFrame:self.activityView.frame];
        self.statusLabel.backgroundColor = [UIColor clearColor];
        self.statusLabel.textAlignment = NSTextAlignmentCenter;
        self.statusLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.statusLabel];
        
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];

        self.textLabel.frame = CGRectMake(17,0,80,20);
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = TEXT_LABEL_FONT;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.textLabel];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressOnView:)];
        [self addGestureRecognizer:tapGestureRecognizer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willRotateScreen:)
                                                     name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
        
        self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self initializeToDefaultState];
    }
    
    return self;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showWithMessage:(NSString *)message animated:(BOOL)animated {
    [self showWithMessage:message loading:NO animated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showLoadingWithMessage:(NSString *)message animated:(BOOL)animated {
    [self showWithMessage:message loading:YES animated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showWithMessage:(NSString *)message loading:(BOOL)loading animated:(BOOL)animated {
    [self initializeToDefaultState];
    self.textLabel.text = message;
    self.hidden = NO;
    
    if (YES == loading) {
        [self.activityView startAnimating];
    } else {
        [self.activityView stopAnimating];
    }
    
    if (animated) {
        [self animatateview:self.contentView show:YES completion:nil];
    }
}

- (void)showStateBar
{
//    [self initializeToDefaultState];
    self.hidden = NO;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setMessage:(NSString *)message animated:(BOOL)animated {
    if (animated) {
        [self animatateview:self.textLabel show:NO completion:^{
            self.textLabel.text = message;
            self.sendStateItem.image = [UIImage imageNamed:@"mc_sentTrue.png"];
            [self animatateview:self.textLabel show:YES completion:nil];
        }];
    } else {
        self.textLabel.text = message;
        self.sendStateItem.image = [UIImage imageNamed:@"mc_sentTrue.png"];
    }
}

- (void)setErrorMessage:(NSString *)message animated:(BOOL)animated {
    if (animated) {
        [self animatateview:self.textLabel show:NO completion:^{
            self.textLabel.text = message;
            self.sendStateItem.image = [UIImage imageNamed:@"mc_sentFail.png"];
            [self animatateview:self.textLabel show:YES completion:nil];
        }];
    } else {
        self.textLabel.text = message;
        self.sendStateItem.image = [UIImage imageNamed:@"mc_sentFail.png"];
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setProgress:(float)progress animated:(BOOL)animated {
    _progress = progress;
    if (progress == 0) {
      _sendStateItem.image = [UIImage imageNamed:@"mc_sendMail.png"];
    }
    
    CGRect frame = _progressView.frame;
    CGFloat width = CGRectGetWidth(self.contentView.bounds) -38;
    frame.size.width = width * _progress;
    
    if (animated) {
        [UIView animateWithDuration:2 animations:^{
            _progressView.frame = frame;
        }];
    } else {
        _progressView.frame = frame;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showActivity:(BOOL)show animated:(BOOL)animated {
    if (show) {
        [self.activityView startAnimating];
    } else if (NO == animated) {
        [self.activityView stopAnimating];
    }
    
    if (animated) {
        [self animatateview:self.activityView show:show completion:^{
            if (NO == show) {
                [self.activityView stopAnimating];
            }
        }];
    } else {
        self.activityView.hidden = !show;
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showSuccessWithMessage:(NSString *)message duration:(NSTimeInterval)duration animated:(BOOL)animated {
    [self showMessage:message
           withStatus:MCStatusBarOverlayStatusSuccess
             duration:duration
             animated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showErrorWithMessage:(NSString *)message duration:(NSTimeInterval)duration animated:(BOOL)animated {
    [self showMessage:message
           withStatus:MCStatusBarOverlayStatusError
             duration:duration
             animated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dismissAnimated:(BOOL)animated {
    if (animated) {
        [self animatateview:self.contentView show:NO completion:^{
            self.hidden = YES;
        }];
    } else {
        self.hidden = YES;
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dismissAnimated {
    [self dismissAnimated:YES];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dismiss {
    [self dismissAnimated:NO];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.contentView.backgroundColor = AppStatus.theme.tintColor;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated {
    if (animated) {
        [self animatateview:self.contentView show:NO completion:^{
            [self setStatusBarStyle:statusBarStyle];
            [self animatateview:self.contentView show:YES completion:nil];
        }];
    } else {
        [self setStatusBarStyle:statusBarStyle];
    }
} 


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Getters and setters


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setProgressBackgroundColor:(UIColor *)progressBackgroundColor {
    _progressView.backgroundColor = [UIColor whiteColor];//[UIColor colorWithHexString:@"2ea8e5"];
    
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor *)progressBackgroundColor {
    return _progressView.backgroundColor;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setProgress:(float)progress {
    [self setProgress:progress animated:NO];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class methods


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)showWithMessage:(NSString *)message loading:(BOOL)loading animated:(BOOL)animated {
    [[MCStatusBarOverlay shared] showWithMessage:message loading:loading animated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)showWithMessage:(NSString *)message animated:(BOOL)animated {
    [[MCStatusBarOverlay shared] showWithMessage:message animated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)showLoadingWithMessage:(NSString *)message animated:(BOOL)animated {
    [[MCStatusBarOverlay shared] showLoadingWithMessage:message animated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)setMessage:(NSString *)message animated:(BOOL)animated {
    [[MCStatusBarOverlay shared] setMessage:message animated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)showSuccessWithMessage:(NSString *)message duration:(NSTimeInterval)duration animated:(BOOL)animated {
    [[MCStatusBarOverlay shared] showSuccessWithMessage:message duration:duration animated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)showErrorWithMessage:(NSString *)message duration:(NSTimeInterval)duration animated:(BOOL)animated {
    [[MCStatusBarOverlay shared] showErrorWithMessage:message duration:duration animated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)setAnimation:(MCStatusBarOverlayAnimationType)animation {
    [[MCStatusBarOverlay shared] setAnimation:animation];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)dismissAnimated:(BOOL)animated {
    [[MCStatusBarOverlay shared] dismissAnimated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)dismissAnimated {
    [[MCStatusBarOverlay shared] dismissAnimated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)dismiss {
    [[MCStatusBarOverlay shared] dismiss];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)setProgress:(float)progress animated:(BOOL)animated {
    [[MCStatusBarOverlay shared] setProgress:progress animated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)showActivity:(BOOL)show animated:(BOOL)animated {
    [[MCStatusBarOverlay shared] showActivity:show animated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)setBackgroundColor:(UIColor *)backgroundColor {
    [[MCStatusBarOverlay shared] setBackgroundColor:backgroundColor];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated {
    [[MCStatusBarOverlay shared] setStatusBarStyle:statusBarStyle animated:animated];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)setActionBlock:(MCStatusBarBasicBlock)actionBlock {
    [[MCStatusBarOverlay shared] setActionBlock:actionBlock];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)setProgressBackgroundColor:(UIColor *)backgroundColor {
    [[MCStatusBarOverlay shared] setProgressBackgroundColor:backgroundColor];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Gesture recognizer


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didPressOnView:(UIGestureRecognizer *)gestureRecognizer {
    if (nil != _actionBlock) {
        _actionBlock();
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Rotation


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willRotateScreen:(NSNotification *)notification {
    NSValue *frameValue = [notification.userInfo valueForKey:UIApplicationStatusBarFrameUserInfoKey];
    
    if (NO == self.hidden) {
        [self rotateStatusBarAnimatedWithFrame:frameValue];
    } else {
        [self rotateStatusBarWithFrame:frameValue];
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    if (UIStatusBarStyleLightContent == statusBarStyle ||
        IS_IPAD) {
        
        [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"status-bar-pattern-black.jpg"]]];
        self.textLabel.textColor = [UIColor whiteColor];
        [self setProgressBackgroundColor:[UIColor colorWithRed:48/255.0f green:159/255.0f blue:211/255.0f alpha:1]];
        [self.activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        
    } else {
        [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"status-bar-pattern-default.jpg"]]];
        self.textLabel.textColor = [UIColor colorWithRed:17/255.0f green:17/255.0f blue:17/255.0f alpha:1];
        [self setProgressBackgroundColor:[UIColor colorWithRed:48/255.0f green:159/255.0f blue:211/255.0f alpha:1]];
        [self.activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    }
    
    [self setProgressBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"status-bar-progress.png"]]];
    self.statusLabel.textColor = self.textLabel.textColor;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showMessage:(NSString *)message
         withStatus:(MCStatusBarOverlayStatus)status
           duration:(NSTimeInterval)duration
           animated:(BOOL)animated {
    
    if (YES == self.hidden) {
        if (status == MCStatusBarOverlayStatusError) {
            [self setErrorMessage:message animated:NO];
        }else
        {
            [self setMessage:message animated:NO];
        }
        
        [self initializeToDefaultState];
        [self.activityView stopAnimating];
        self.hidden = NO;
        
        if (animated) {
            [self animatateview:self.contentView show:YES completion:nil];
        }
    } else {
        [self fadeAnimatateview:_progressView show:NO completion:nil];
        if (status == MCStatusBarOverlayStatusError) {
            [self setErrorMessage:message animated:NO];
        }else
        {
            [self setMessage:message animated:NO];
        }
        [self showActivity:NO animated:animated];
        
    }
    
    [self performSelector:(animated) ? @selector(dismissAnimated) : @selector(hide)
               withObject:self.contentView
               afterDelay:duration];
}

- (void)hide
{
    [self dismissAnimated:NO];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)rotateStatusBarAnimatedWithFrame:(NSValue *)frameValue {
    [UIView animateWithDuration:ROTATION_ANIMATION_DURATION animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self rotateStatusBarWithFrame:frameValue];
        [UIView animateWithDuration:ROTATION_ANIMATION_DURATION animations:^{
            self.alpha = 1;
        }];
    }];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)rotateStatusBarWithFrame:(NSValue *)frameValue {
    CGRect frame = [frameValue CGRectValue];
    UIInterfaceOrientation orientation = STATUS_BAR_ORIENTATION;
    
    if (UIDeviceOrientationPortrait == orientation) {
        self.transform = CGAffineTransformIdentity;
    } else if (UIDeviceOrientationPortraitUpsideDown == orientation) {
        self.transform = CGAffineTransformMakeRotation(M_PI);
    } else if (UIDeviceOrientationLandscapeRight == orientation) {
        self.transform = CGAffineTransformMakeRotation(M_PI * (-90.0f) / 180.0f);
    } else {
        self.transform = CGAffineTransformMakeRotation(M_PI * 90.0f / 180.0f);
    }
    
    self.frame = frame;
    [self setProgress:self.progress animated:NO];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)animatateview:(UIView *)view show:(BOOL)show completion:(MCStatusBarBasicBlock)completion {
    [self animatateview:view withAnimationType:self.animation show:show completion:completion];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)animatateview:(UIView *)view
    withAnimationType:(MCStatusBarOverlayAnimationType)animationType
                 show:(BOOL)show
           completion:(MCStatusBarBasicBlock)completion {
    
    if (MCStatusBarOverlayAnimationTypeFade == animationType) {
        [self fadeAnimatateview:view show:show completion:completion];
        
    } else if (MCStatusBarOverlayAnimationTypeFromTop == animationType) {
        [self fromTopAnimatateview:view show:show completion:completion];
        
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)fadeAnimatateview:(UIView *)view show:(BOOL)show completion:(MCStatusBarBasicBlock)completion {
    if (show) {
         [view.superview setHidden:NO];
        view.alpha = 0;
//        view.hidden = NO tgrtgrd;
    }
    
//    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        view.alpha = (show) ? 1 : 0;
//    } completion:^(BOOL finished) {
        if (NO == show) {
//            view.hidden = YES;
            [view.superview setHidden:YES];
            view.alpha = 1;
        }
        
        if (nil != completion)
            completion();
//    }];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)fromTopAnimatateview:(UIView *)view show:(BOOL)show completion:(MCStatusBarBasicBlock)completion {
    __block CGRect frame = view.frame;
    CGFloat previousY = view.frame.origin.y;
    
    if (show) {
        view.hidden = NO;
        view.alpha = 0;
        frame.origin.y = -CGRectGetHeight(self.frame);
        view.frame = frame;
    }
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        frame.origin.y += (show ? 1 : -1) * CGRectGetHeight(self.frame);
        view.frame = frame;
        view.alpha = (show) ? 1 : 0;
    } completion:^(BOOL finished) {
        if (NO == show) {
            frame.origin.y = previousY;
            view.frame = frame;
            view.hidden = YES;
            view.alpha = 1;
        }
        
        if (nil != completion)
            completion();
    }];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)initializeToDefaultState {
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    [self rotateStatusBarWithFrame:[NSValue valueWithCGRect:statusBarFrame]];
    [self setProgress:0];
    [_progressView.superview setHidden:NO];
//    _progressView.hidden = NO;
    
    [self setStatusBarStyle:[UIApplication sharedApplication].statusBarStyle animated:NO];
}


@end
