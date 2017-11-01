//
//  MCSegmentHeadView.m
//  NPushMail
//
//  Created by wuwenyu on 15/12/30.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import "MCSegmentHeadView.h"

#define DefaultBgColor [UIColor whiteColor]
#define DefaultTextNomalColor [UIColor blackColor]
#define DefaultTextSelectedColor [UIColor redColor]
#define DefaultLineColor [UIColor redColor]
#define DefaultTitleFont 15
#define LineHeigh 2

@interface MCSegmentHeadView()

@property(nonatomic, strong)NSMutableArray *buttonsArray;
@property(nonatomic, strong)UIImageView *lineImageView;

@end

@implementation MCSegmentHeadView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.backgroundColor = DefaultBgColor;
        self.buttonsArray = [[NSMutableArray alloc] init];
        //默认
        self.bgColor = DefaultBgColor;
        self.textNomalColor = DefaultTextNomalColor;
        self.textSelectedColor = DefaultTextSelectedColor;
        self.lineColor = DefaultLineColor;
        self.titleFont = DefaultTitleFont;
    }
    return self;
}

- (void)addSubSegmentView
{
    [self.buttonsArray removeAllObjects];
    float width = self.frame.size.width / (self.dataArray.count);
    UIImageView* hLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 0.5, CGRectGetWidth(self.frame), 0.5)];
    hLine.image = [UIImage imageNamed:@""];
    hLine.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
    [self addSubview:hLine];
    
    for (int i = 0; i < self.dataArray.count; i++) {
        @autoreleasepool {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(i * width, 0, width, self.frame.size.height)];
            button.tag = i+1;
            button.backgroundColor = [UIColor clearColor];
            [button setTitle:[self.dataArray objectAtIndex:i] forState:UIControlStateNormal];
            [button setTitleColor:self.textNomalColor    forState:UIControlStateNormal];
            [button setTitleColor:self.textSelectedColor forState:UIControlStateSelected];
            button.titleLabel.font = [UIFont systemFontOfSize:_titleFont];
            [button addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
            
//            //竖线
//            UIImageView* vLine = [[UIImageView alloc] initWithFrame:CGRectMake((i + 1) * width - 1, 0, 1, self.frame.size.height)];
//            vLine.backgroundColor = [UIColor lightGrayColor];
//            vLine.image = [UIImage imageNamed:@""];
            
            //默认第一个选中
            if (i == 0) {
                button.selected = YES;
            }
            else{
                button.selected = NO;
            }
            
            [self.buttonsArray addObject:button];
            [self addSubview:button];
        }
    }
//    UIButton *searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.dataArray.count * width, 0, width, self.frame.size.height)];
//    searchBtn.backgroundColor = [UIColor clearColor];
//    [searchBtn addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
//    searchBtn.selected = NO;
//    [searchBtn setImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
//    [self addSubview:searchBtn];
    
    self.lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-LineHeigh, width, LineHeigh)];
    self.lineImageView.backgroundColor = _lineColor;
    [self addSubview:self.lineImageView];
    
}

- (void)tapAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    __weak MCSegmentHeadView *weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.lineImageView.frame = CGRectMake(button.frame.origin.x, weakSelf.frame.size.height - LineHeigh, button.frame.size.width, LineHeigh);
    }];
    
    for (UIButton *subButton in self.buttonsArray) {
        if (button == subButton) {
            subButton.selected = YES;
        }
        else{
            subButton.selected = NO;
        }
    }
    if ([self.delegate respondsToSelector:@selector(selectedIndex:)]) {
        [self.delegate selectedIndex:button.tag -1];
    }
}

- (void)searchAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(searchAction)]) {
        [self.delegate searchAction];
    }
}

- (void)selectIndex:(NSInteger)index {
    for (UIButton *subButton in self.buttonsArray) {
        if (index != subButton.tag) {
            subButton.selected = NO;
        }
        else{
            __weak MCSegmentHeadView *weakSelf = self;
            [UIView animateWithDuration:0.2 animations:^{
                weakSelf.lineImageView.frame = CGRectMake(subButton.frame.origin.x, weakSelf.frame.size.height - LineHeigh, subButton.frame.size.width, LineHeigh);
            } completion:^(BOOL finished) {
                subButton.selected = YES;
            }];
        }
    }
}

#pragma mark -- set
-(void)setDataArray:(NSArray *)dataArray{
    if (_dataArray != dataArray) {
        _dataArray = dataArray;
        [self addSubSegmentView];
    }
}

-(void)setLineColor:(UIColor *)lineColor{
    if (_lineColor != lineColor) {
        self.lineImageView.backgroundColor = lineColor;
        _lineColor = lineColor;
    }
}

-(void)setTextNomalColor:(UIColor *)textNomalColor{
    if (_textNomalColor != textNomalColor) {
        for (UIButton *subButton in self.buttonsArray){
            [subButton setTitleColor:textNomalColor forState:UIControlStateNormal];
        }
        _textNomalColor = textNomalColor;
    }
}

-(void)setTextSelectedColor:(UIColor *)textSelectedColor{
    if (_textSelectedColor != textSelectedColor) {
        for (UIButton *subButton in self.buttonsArray){
            [subButton setTitleColor:textSelectedColor forState:UIControlStateSelected];
        }
        _textSelectedColor = textSelectedColor;
    }
}

-(void)setTitleFont:(CGFloat)titleFont{
    if (_titleFont != titleFont) {
        for (UIButton *subButton in self.buttonsArray){
            subButton.titleLabel.font = [UIFont systemFontOfSize:titleFont] ;
        }
        _titleFont = titleFont;
    }
}

@end
