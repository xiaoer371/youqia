//
//  DNFullImageButton.m
//  ImagePicker
//
//  Created by DingXiao on 15/3/2.
//  Copyright (c) 2015年 Dennis. All rights reserved.
//

#import "DNFullImageButton.h"
#import "UIView+DNImagePicker.h"

#define kDNFullImageButtonFont  [UIFont systemFontOfSize:14]

@interface DNFullImageButton ()
@property (nonatomic, strong) UIButton *fullImageButton;
@property (nonatomic, strong) UILabel  *fullImageLabel;
@property (nonatomic, strong) UILabel  *imageSizeLabel;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@end

@implementation DNFullImageButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.height = 28;
        self.width = CGRectGetWidth([[UIScreen mainScreen] bounds])/2 -20;
        [self fullImageButton];
        [self fullImageLabel];
        [self imageSizeLabel];
        [self indicatorView];
        self.selected = NO;
    }
    return self;
}

- (void)addTarget:(id)target action:(SEL)action
{
    [self.fullImageButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (UILabel *)imageSizeLabel
{
    if (nil == _imageSizeLabel) {
        _imageSizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 4, CGRectGetWidth(self.frame)- 100, 20)];
        _imageSizeLabel.backgroundColor = [UIColor clearColor];
        _imageSizeLabel.font = [UIFont systemFontOfSize:14.0f];
        _imageSizeLabel.textAlignment = NSTextAlignmentLeft;
        _imageSizeLabel.textColor = [UIColor whiteColor];
        [self addSubview:_imageSizeLabel];
    }
    return _imageSizeLabel;
}

- (UIButton *)fullImageButton
{
    if (nil == _fullImageButton) {
        _fullImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _fullImageButton.frame =CGRectMake(0, 0, 28, 28);
        _fullImageButton.backgroundColor = [UIColor clearColor];
        [_fullImageButton setImage:[UIImage imageNamed:@"mc_imageDesSelect.png"] forState:UIControlStateNormal];
        [_fullImageButton setImage:[UIImage imageNamed:@"mc_imageDidSelect.png"] forState:UIControlStateSelected];
        [self addSubview:_fullImageButton];
    }
    return _fullImageButton;
}

- (UILabel *)fullImageLabel
{
    if (nil == _fullImageLabel) {
        CGFloat x =  CGRectGetMaxX(_fullImageButton.frame);
        NSString * text= NSLocalizedStringFromTable(@"fullImage", @"DNImagePicker", @"原图");
        CGSize size = [text boundingRectWithSize:CGSizeMake(70, 28)  options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:kDNFullImageButtonFont} context:nil].size;
        _fullImageLabel = [[UILabel alloc] initWithFrame:CGRectMake( x, 0, size.width+10, 28)];
        _fullImageLabel.text = text;
        _fullImageLabel.textColor =_fullImageButton.selected?[UIColor whiteColor]:[UIColor lightGrayColor];
        _fullImageLabel.font =kDNFullImageButtonFont;
        [self addSubview:_fullImageLabel];
    }
    return _fullImageLabel;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (nil == _indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.fullImageButton.width+self.fullImageLabel.width, 2, 26, 26)];
        _indicatorView.hidesWhenStopped = YES;
        [_indicatorView stopAnimating];
        [self addSubview:_indicatorView];
    }
    return _indicatorView;
}

- (void)setSelected:(BOOL)selected
{
    if (_selected != selected) {
        _selected = selected;
        self.fullImageButton.selected = _selected;
        self.fullImageLabel.textColor =_selected?[UIColor whiteColor]:[UIColor lightGrayColor];
        CGFloat labelWidth = self.width - _fullImageLabel.width;
        self.imageSizeLabel.left = _fullImageLabel.width+_fullImageButton.width;
        self.imageSizeLabel.width = labelWidth;
        self.imageSizeLabel.hidden = !_selected;
    }
}

- (void)setText:(NSString *)text
{
    self.imageSizeLabel.text = text;
}

- (void)shouldAnimating:(BOOL)animate
{
    if (self.selected) {
        self.imageSizeLabel.hidden = animate;
        if (animate) {
            [self.indicatorView startAnimating];
        } else {
            [self.indicatorView stopAnimating];
        }
    }
}
@end
