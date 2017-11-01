//
//  MCSearchBar.m
//  NPushMail
//
//  Created by wuwenyu on 16/8/10.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCSearchBar.h"
#import "UIView+MJExtension.h"
#import "NSString+Extension.h"

@interface MCSearchBar()<UITextFieldDelegate>
@property(nonatomic, strong) UIImageView *leftView;
@property(nonatomic, strong) UIButton *searchBarCancelBtn;
@end

static const CGFloat leftViewHeight = 15;
static const CGFloat leftViewWidth = 15;
static const CGFloat leftViewPaddingX = 5;
static const CGFloat textFieldHeight = 30;
static const CGFloat cancelBtnWidth = 45;

@implementation MCSearchBar

-(id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    self.backgroundColor = AppStatus.theme.tintColor;
    self.userInteractionEnabled = YES;
    if (!_textFieldBgView) {
        _textFieldBgView = [[UIImageView alloc] initWithFrame:CGRectMake(textFieldBgViewPaddingX, (CGRectGetHeight(self.frame) - textFieldHeight)/2, CGRectGetWidth(self.frame) - textFieldBgViewPaddingX*3 - cancelBtnWidth, textFieldHeight)];
        _textFieldBgView.image = [[UIImage imageNamed:@"searchBarBg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 20, 10, 20) resizingMode:UIImageResizingModeStretch];
        _textFieldBgView.userInteractionEnabled = YES;
        [self addSubview:_textFieldBgView];
    }
    if (!_leftView) {
        _leftView = [[UIImageView alloc] initWithFrame:CGRectMake(leftViewPaddingX, (CGRectGetHeight(_textFieldBgView.frame) - leftViewHeight)/2, leftViewWidth, leftViewHeight)];
        _leftView.image = [UIImage imageNamed:@"searchIcon.png"];
        [_textFieldBgView addSubview:_leftView];
    }
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_leftView.frame) + leftViewPaddingX, 1, CGRectGetWidth(_textFieldBgView.frame) - CGRectGetWidth(_leftView.frame) - leftViewPaddingX*2, textFieldHeight)];
        _textField.backgroundColor = [UIColor clearColor];
        _textField.tintColor = AppStatus.theme.tintColor;
        _textField.placeholder = self.placeholder;
        _textField.returnKeyType = UIReturnKeySearch;
        _textField.delegate = self;
        [_textField addTarget:self action:@selector(textFieldValueChange:) forControlEvents:UIControlEventEditingChanged];
        [_textFieldBgView addSubview:_textField];
    }
    if (!_searchBarCancelBtn) {
        _searchBarCancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_searchBarCancelBtn setTitle:PMLocalizedStringWithKey(@"PM_Common_Cancel") forState:UIControlStateNormal];
        [_searchBarCancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [[_searchBarCancelBtn titleLabel] setFont:[UIFont systemFontOfSize:17.0f]];
        [_searchBarCancelBtn addTarget:self action:@selector(searchCancelAction:) forControlEvents:UIControlEventTouchUpInside];
        CGSize size = [PMLocalizedStringWithKey(@"PM_Common_Cancel") mcStringSizeWithFont:17.0f maxWidth:2000 maxHight:21];
        _textFieldBgView .frame = CGRectMake(textFieldBgViewPaddingX, (CGRectGetHeight(self.frame) - textFieldHeight)/2, CGRectGetWidth(self.frame) - textFieldBgViewPaddingX*3 - size.width, textFieldHeight);
        _searchBarCancelBtn.frame = CGRectMake(CGRectGetMaxX(_textFieldBgView.frame) + textFieldBgViewPaddingX, (CGRectGetHeight(self.frame) - 21)/2, size.width, 21);
        [self addSubview:_searchBarCancelBtn];
    }
}

#pragma mark - params

-(void) setSearchBackgroundColor:(UIColor *)backgroundColor {
    _searchBackgroundColor = backgroundColor;
    self.backgroundColor = backgroundColor;
}

-(void) setIsBecomeFirstResponder:(BOOL)isBecomeFirstResponder {
   

}

-(void) setText:(NSString *)text {
    _text = text;
    _textField.text = text;
}

-(void) setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    _textField.textColor = textColor;
}

-(void) setFont:(UIFont *)font {
    _font = font;
    [_textField setFont:font];
}

-(void) setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    [_textField setPlaceholder:placeholder];
}

-(void) setPlaceholderFont:(UIFont *)placeholderFont {
    _placeholderFont = placeholderFont;
    [_textField setValue:placeholderFont forKey:@"_placeholderLabel.font"];
}

-(void) setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = placeholderColor;
    [_textField setValue:placeholderColor forKey:@"_placeholderLabel.textColor"];
}

#pragma mark - textFieldValueChange
-(void) textFieldValueChange:(UITextField *)textField {
    _text = textField.text;
    if ([self.delegate respondsToSelector:@selector(searchBar:textDidChange:)]) {
        [self.delegate searchBar:self textDidChange:_text];
    }
}

- (void) searchCancelAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(searchBarCancelAction:)]) {
        [self.delegate searchBarCancelAction:self];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)]) {
        [self.delegate searchBarShouldBeginEditing:self];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarDidBeginEditing:)]) {
        [self.delegate searchBarDidBeginEditing:self];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarShouldEndEditing:)]) {
        [self.delegate searchBarShouldEndEditing:self];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarDidEndEditing:)]) {
        [self.delegate searchBarDidEndEditing:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(searchBarSearchAction:)]) {
        [self.delegate searchBarSearchAction:self];
    }
    return YES;
}

@end
