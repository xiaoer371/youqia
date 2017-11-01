//
//  MCContactInfoBottomView.m
//  NPushMail
//
//  Created by wuwenyu on 16/2/3.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCContactInfoBottomView.h"

@implementation MCContactInfoBottomView {
    UIButton *_writeMailBtn;
    UIButton *_sendMsgBtn;
    UIImageView *_vLineImageView;
    UIImageView *_hLineImageView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _writeMailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _writeMailBtn.frame = CGRectMake(0, 0, CGRectGetWidth(frame)/2, CGRectGetHeight(frame));
        [_writeMailBtn setTitle:PMLocalizedStringWithKey(@"PM_Contact_WriteMail") forState:UIControlStateNormal];
        [_writeMailBtn setTitleColor:AppStatus.theme.tintColor forState:UIControlStateNormal];
        [_writeMailBtn addTarget:self action:@selector(writeMailAction:) forControlEvents:UIControlEventTouchUpInside];
        [[_writeMailBtn titleLabel] setFont:[UIFont systemFontOfSize:17.0f]];
        _sendMsgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendMsgBtn setTitleColor:AppStatus.theme.tintColor forState:UIControlStateNormal];
        [[_sendMsgBtn titleLabel] setFont:[UIFont systemFontOfSize:17.0f]];
        _sendMsgBtn.frame = CGRectMake(CGRectGetMaxX(_writeMailBtn.frame), 0, CGRectGetWidth(frame)/2, CGRectGetHeight(frame));
        [_sendMsgBtn setTitle:PMLocalizedStringWithKey(@"PM_Contact_SengMsg") forState:UIControlStateNormal];
        [_sendMsgBtn addTarget:self action:@selector(sendMsgAction:) forControlEvents:UIControlEventTouchUpInside];
        _vLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_writeMailBtn.frame), 9, 1, 30)];
        _vLineImageView.backgroundColor = AppStatus.theme.toolBarSeparatorColor;
        
        _hLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0.5)];
        _hLineImageView.backgroundColor = AppStatus.theme.toolBarSeparatorColor;
        [self addSubview:_writeMailBtn];
        [self addSubview:_sendMsgBtn];
        [self addSubview:_vLineImageView];
        [self addSubview:_hLineImageView];
        /*
        NSString *className = NSStringFromClass([self class]);
        NSArray *nibView =  [[NSBundle mainBundle] loadNibNamed:className owner:self options:nil];
        UIView *v = [nibView objectAtIndex:0];
        [self addSubview:v];
         */
    }
    return self;
}

- (void)writeMailAction:(id)sender {
    if (_writeMailBlock) {
        _writeMailBlock();
    }
}

- (void)sendMsgAction:(id)sender {
    if (_sendMsgBlock) {
        _sendMsgBlock();
    }
}
@end
