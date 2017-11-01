//
//  MCSelectedMemberCell.m
//  NPushMail
//
//  Created by wuwenyu on 16/4/1.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCSelectedMemberCell.h"
#import "MCContactModel.h"
#import "UIImageView+WebCache.h"
#import "MCAvatarHelper.h"
#import "UIImageView+MCCorner.h"
#import "TITokenField.h"
#import "UIView+MJExtension.h"

@implementation MCSelectedMemberCell {
    TIToken *_token;
    UIButton *_btn;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initViews];
}

- (void)initViews {
    _token = [[TIToken alloc] initWithTitle:@""];
    _token.userInteractionEnabled = NO;
    _token.frame = CGRectMake(paddingX, paddingY, _token.frame.size.width, _token.frame.size.height);
    [self addSubview:_token];
}

- (void)configureCellWithModel:(MCContactModel *)model indexPath:(NSIndexPath *)path {
    _token.title = model.displayName;
    if (path.row == 0) {
        [_token setMj_x:textFieldPaddingX];
    }else {
        [_token setMj_x:paddingX];
    }
}

@end
