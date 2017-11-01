//
//  MCIFlyWaverView.m
//  NPushMail
//
//  Created by wuwenyu on 16/11/8.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIFlyWaverView.h"
#import "UIColor+Hex.h"

@interface MCIFlyWaverView()

@property (nonatomic, strong) Waver *waver;
@property (nonatomic, strong) UILabel *titleLabel;

@end

static const CGFloat speechBtnWidth = 60;
static const CGFloat speechBtnHeight = 60;

@implementation MCIFlyWaverView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initWaverView];
    }
    return self;
}

- (void)initWaverView {
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.5)];
    topLine.backgroundColor = [UIColor colorWithHexString:@"0x8d8d8d"];
    
    self.backgroundColor = [UIColor colorWithHexString:@"0xf0f0f0"];
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = [UIFont systemFontOfSize:15.0f];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = @"请说话";
    _titleLabel.textColor = [UIColor colorWithHexString:@"0x595959"];
//    [self addSubview:_titleLabel];
    
    _speechEndBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _speechEndBtn.frame = CGRectMake((self.frame.size.width - speechBtnWidth)/2, self.frame.size.height - speechBtnHeight - 20, speechBtnWidth, speechBtnHeight);
    [_speechEndBtn addTarget:self action:@selector(speechEnd) forControlEvents:UIControlEventTouchUpInside];
    [_speechEndBtn setTitle:@"完成" forState:UIControlStateNormal];
    [_speechEndBtn setBackgroundColor:AppStatus.theme.tintColor];
    _speechEndBtn.layer.cornerRadius = CGRectGetWidth(_speechEndBtn.frame)/2;
    _speechEndBtn.clipsToBounds = YES;
//    [_speechEndBtn setImage:[UIImage imageNamed:@"endSpeechBtnBg.png"] forState:UIControlStateNormal];
    [_speechEndBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    _waver = [[Waver alloc] initWithFrame:CGRectMake(0, 20, self.frame.size.width, self.frame.size.height - CGRectGetMinY(_speechEndBtn.frame) + 20)];
    _waver.backgroundColor = [UIColor colorWithHexString:@"0xf0f0f0"];
    [self addSubview:_waver];
    [self addSubview:topLine];
    [self addSubview:_speechEndBtn];
}

- (void)speechEnd {
    if (self.speechEndBlock) {
        self.speechEndBlock();
    }
}

- (void)startUpdate {
    [self.speechEndBtn setTitle:@"完成" forState:UIControlStateNormal];
    [self.speechEndBtn setImage:nil forState:UIControlStateNormal];
    
    __weak MCIFlyWaverView *weakSelf = self;
    if (_waver) {
        if (!_waver.waverLevelCallback) {
            _waver.waverLevelCallback = ^(Waver * waver) {
                waver.level = weakSelf.volume/60;
            };
        }
    }
}

- (void)pauseUpdate
{
    [self.speechEndBtn setTitle:@"" forState:UIControlStateNormal];
    [self.speechEndBtn setImage:[UIImage imageNamed:@"startSpeechBtnBg.png"] forState:UIControlStateNormal];
}

- (void)stopUpdate {
    [self pauseUpdate];
    if (_waver) {
        _waver.waverLevelCallback = nil;
    }
}

@end
