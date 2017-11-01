//
//  MCEnterpriseInfoCell.m
//  NPushMail
//
//  Created by wuwenyu on 16/7/7.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCEnterpriseInfoCell.h"
#import "UILabel+Common.h"

@implementation MCEnterpriseInfoCell {
    UILabel *_titleLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initViews];
}

- (void)initViews {
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(paddingX, paddingY, 0, 21)];
    _titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self addSubview:_titleLabel];
}

- (void)configureWithTitle:(NSString *)title enableSelect:(BOOL)flag {
    _titleLabel.text = title;
    if (flag) {
        _titleLabel.textColor = AppStatus.theme.tintColor;
        title = [title stringByAppendingString:@">"];
    }else {
        _titleLabel.textColor = AppStatus.theme.fontTintColor;
    }
    _titleLabel.text = title;
    CGSize labelSize = [_titleLabel estimateUISizeByHeight:21];
    _titleLabel.frame = CGRectMake(paddingX, paddingY, labelSize.width, labelSize.height);
}

@end
