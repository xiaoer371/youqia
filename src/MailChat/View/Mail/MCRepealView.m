//
//  MCRepealView.m
//  NPushMail
//
//  Created by zhang on 16/9/19.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCRepealView.h"
#import "NSString+Extension.h"
@interface MCRepealView ()

@property (nonatomic,assign)BOOL repeal;
@property (nonatomic,strong) UIButton *undoButton;
@property (nonatomic,strong) UILabel *messageLabel;
@property (nonatomic,assign)BOOL show;
@property (nonatomic,assign)NSTimeInterval timeItervlOld;


@property (nonatomic,copy) dispatch_block_t undoBlock;
@property (nonatomic,copy) dispatch_block_t commitBlock;

@end

const static CGFloat kMCRepealViewMargin = 13.0;
@implementation MCRepealView

+ (instancetype)shared
{
    static id instance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [MCRepealView new];
    });
    
    return instance;
}

- (id)init
{
    if (self = [super init]) {
        _delaySeconds = 5;
        [self initViews];
    }
    return self;
}

- (void)initViews {
    self.frame = CGRectMake(0,ScreenHeigth, ScreenWidth, 49);
    self.backgroundColor = [UIColor colorWithHexString:@"3d92fe"];
    _undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_undoButton setTintColor:[UIColor whiteColor]];
    [_undoButton setTitle:PMLocalizedStringWithKey(@"PM_Mail_RepealMails") forState:UIControlStateNormal];
    _undoButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    CGSize size = [_undoButton.titleLabel.text mcStringSizeWithBoldFont:16.0 maxWidth:MAXFLOAT maxHight:CGRectGetHeight(self.frame)];
    _undoButton.frame = CGRectMake(CGRectGetWidth(self.frame) - size.width - kMCRepealViewMargin, 0, size.width, CGRectGetHeight(self.frame));
    [_undoButton addTarget:self action:@selector(onUndo:) forControlEvents:UIControlEventTouchUpInside];
    
    _messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(kMCRepealViewMargin, 0, CGRectGetWidth(self.frame) - CGRectGetWidth(_undoButton.frame) - 2*kMCRepealViewMargin, CGRectGetHeight(self.frame))];
    _messageLabel.font = [UIFont systemFontOfSize:14];
    _messageLabel.textColor = [UIColor whiteColor];
    _messageLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.textAlignment = NSTextAlignmentLeft;
    _messageLabel.text = PMLocalizedStringWithKey(@"PM_Mail_DidDeleteMails");
    _messageLabel.numberOfLines = 0;
    
    [self addSubview:_messageLabel];
    [self addSubview:_undoButton];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
}

- (void)setMessage:(NSString *)message
{
    _messageLabel.text = message;
}

- (void)setDoItemTitle:(NSString *)doItemTitle {
    if (doItemTitle) {
        [_undoButton setTitle:doItemTitle forState:UIControlStateNormal];
        _messageLabel.textAlignment = NSTextAlignmentLeft;
        _undoButton.hidden = NO;
        _messageLabel.frame = CGRectMake(kMCRepealViewMargin, 0, CGRectGetWidth(self.frame) - CGRectGetWidth(_undoButton.frame) - 2*kMCRepealViewMargin, CGRectGetHeight(self.frame));
    }else {
        _undoButton.hidden = YES;
        _messageLabel.frame = CGRectMake(kMCRepealViewMargin, 0, CGRectGetWidth(self.frame) - kMCRepealViewMargin*2, CGRectGetHeight(self.frame));
        _messageLabel.textAlignment = NSTextAlignmentCenter;
    }
}

- (void)onUndo:(UIButton*)sender {
    
    self.undoBlock();
    [self dismissWithUndo:YES];
}

- (void)showWithUndoBlock:(dispatch_block_t)undoBlock commitBlock:(dispatch_block_t)commitBlock
{
    self.show = YES;
    self.undoBlock = undoBlock;
    self.commitBlock = commitBlock;
 
    [self.superview bringSubviewToFront:self];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.frame;
        rect.origin.y = CGRectGetHeight(self.superview.frame) - rect.size.height;
        self.frame = rect;
        
    } completion:^(BOOL finished) {
    }];
    [self delayDismiss];
}


- (void)dismiss {
    if (!_show) {
        return;
    }
    [self dismissWithUndo:NO];
}

- (void)dismissWithUndo:(BOOL)shouldUndo {
    _show = NO;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.frame;
        rect.origin.y += rect.size.height;
        self.frame = rect;
    } completion:^(BOOL finished) {
        
    }];
    if (!shouldUndo) {
        if (self.commitBlock) {
           self.commitBlock();
        }
    }
}

- (void)delayDismiss {

    _timeItervlOld = [[NSDate date] timeIntervalSince1970];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delaySeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSTimeInterval timeItervlNew = [[NSDate date] timeIntervalSince1970];
        if (!_show || (timeItervlNew - _timeItervlOld) < self.delaySeconds) {
            return ;
        }
        [self dismiss];
    });
}
@end
