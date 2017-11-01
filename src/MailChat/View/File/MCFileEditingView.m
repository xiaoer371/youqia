//
//  MCFileEditingView.m
//  NPushMail
//
//  Created by wuwenyu on 16/3/16.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCFileEditingView.h"

const static NSInteger kMCManagerViewItemCount = 3;
const static CGFloat   kMCManagerViewItemButtonFontSize = 15.0;

@implementation MCFileEditingView {
    CGFloat _viewOriginY;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _viewOriginY = frame.origin.y;
        self.userInteractionEnabled = YES;
        self.frame = CGRectMake(0, frame.origin.y, frame.size.width, frame.size.height);
        self.backgroundColor = AppStatus.theme.toolBarBackgroundColor;
        UIImageView *lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 1)];
        lineImageView.image = [UIImage imageNamed:@"spaceLine.png"];
        [self addSubview:lineImageView];
        
        for (int i = 0; i < kMCManagerViewItemCount; i ++) {
            UIButton*buttton = [UIButton buttonWithType:UIButtonTypeCustom];
            buttton.frame = CGRectMake(i * (frame.size.width / kMCManagerViewItemCount), 0, frame.size.width / kMCManagerViewItemCount, frame.size.height);
            [buttton setTitle:self.titles[i] forState:UIControlStateNormal];
            buttton.tag = i + 1;
            [buttton addTarget:self action:@selector(itemSelected:) forControlEvents:UIControlEventTouchUpInside];
            buttton.titleLabel.font = [UIFont systemFontOfSize:kMCManagerViewItemButtonFontSize];
            [buttton setTitleColor:AppStatus.theme.fontTintColor forState:UIControlStateNormal];
            buttton.userInteractionEnabled = NO;
            
            UIImageView *vLine = [[UIImageView alloc] init];
            vLine.backgroundColor = AppStatus.theme.toolBarSeparatorColor;
            vLine.frame = CGRectMake((i + 1) * frame.size.width / kMCManagerViewItemCount, (CGRectGetHeight(frame) - 30)/ 2, 1, 30);
            [self addSubview:vLine];
            [self addSubview:buttton];
        }
    }
    return self;
}

- (void)setBtnEnable:(BOOL)enableFlag {
    for (int i = 0; i < kMCManagerViewItemCount; i ++) {
        UIButton*buttton = (UIButton*)[self viewWithTag:i + 1];
        [buttton setUserInteractionEnabled:enableFlag];
        [buttton setTitleColor:enableFlag ? AppStatus.theme.tintColor:AppStatus.theme.fontTintColor forState:UIControlStateNormal];
    }
}

- (void)itemSelected:(id)sender {
    UIButton *btn = (UIButton *)sender;
    MCFileEditType type = MCFileEditSendMsg;
    switch (btn.tag) {
        case 1:
            type = MCFileEditSendMsg;
            break;
        case 2:
            type = MCFileEditForMailAttachment;
            break;
        case 3:
            type = MCFileEditDelete;
            break;
        default:
            break;
    }
    if ([self.delegate respondsToSelector:@selector(fileEditDidSelectOption:)]) {
        [self.delegate fileEditDidSelectOption:type];
    }
}

- (void)show:(BOOL)show {
    CGFloat y = _viewOriginY;
    y = show ? y - CGRectGetHeight(self.frame) : y;
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = self.frame;
        rect.origin.y = y;
        self.frame = rect;
    }];
}

- (NSMutableArray *)titles {
    if (!_titles) {
        _titles = [NSMutableArray arrayWithObjects:PMLocalizedStringWithKey(@"PM_Contact_SengMsg"), PMLocalizedStringWithKey(@"PM_FileForMailAttachment"), PMLocalizedStringWithKey(@"PM_Msg_DelMsgCell"), nil];
    }
    return _titles;
}

@end
