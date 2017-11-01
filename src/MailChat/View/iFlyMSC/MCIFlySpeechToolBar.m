//
//  MCIFlySpeechToolBar.m
//  NPushMail
//
//  Created by wuwenyu on 16/11/9.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIFlySpeechToolBar.h"

@interface MCIFlySpeechToolBar()

@end

@implementation MCIFlySpeechToolBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    self.backgroundColor = AppStatus.theme.toolBarBackgroundColor;
    _speechBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _speechBtn.frame = CGRectMake(20, 5, CGRectGetWidth(self.frame) - 80, (CGRectGetHeight(self.frame) - 10)/2);
    [_speechBtn setTitle:@"说出你的内容" forState:UIControlStateNormal];
    [_speechBtn addTarget:self action:@selector(startRec) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_speechBtn];
}

- (void)startRec {
    [_speechBtn setEnabled:NO];
    if (_startRecBlock) {
        _startRecBlock();
    }
}

@end
