//
//  MCSignatureCell.m
//  NPushMail
//
//  Created by zhang on 16/4/18.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCSignatureCell.h"


@interface MCSignatureCell ()<UITextViewDelegate>

@end

@implementation MCSignatureCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    // Initialization code
    _accoutLable.textColor = AppStatus.theme.fontTintColor;
    _accoutLable.backgroundColor = [UIColor clearColor];
    _mcTitleBackgrondView.backgroundColor = [UIColor colorWithHexString:@"f7f7f9"];
    _signatureTextView.delegate = self;
    self.backgroundColor = AppStatus.theme.backgroundColor;
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, _signatureTextView.frame.origin.y, ScreenWidth, 0.5)];
    line.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
    [self addSubview:line];
//    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 0.5, ScreenWidth, 0.5)];
//    line2.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
//    [self addSubview:line2];
}

- (void)setMcAccount:(MCAccount *)mcAccount {
    _mcAccount = mcAccount;
    _accoutLable.text = mcAccount.email;
    _signatureTextView.text = mcAccount.signature;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
#pragma mark UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    _mcAccount.signature = textView.text;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([_delegate respondsToSelector:@selector(signatureCell:beginEditting:)]) {
        [_delegate signatureCell:self beginEditting:textView];
    }
}
@end
