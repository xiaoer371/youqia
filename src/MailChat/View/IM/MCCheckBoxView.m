//
//  MCCheckBoxView.m
//  NPushMail
//
//  Created by swhl on 16/12/9.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCCheckBoxView.h"

#define MCSubBtnTag 222

@interface MCCheckBoxView ()

@property (nonatomic, strong) NSArray  *titles;

@end

@implementation MCCheckBoxView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUp];
}

- (instancetype)initWithFrame:(CGRect)frame Titles:(NSArray *)titles
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titles = titles;
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    self.selectIndex = 0;
    CGFloat width = self.bounds.size.width/self.titles.count;
//    CGFloat height = self.bounds.size.height;
    for (int i=0; i<self.titles.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:self.titles[i] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        btn.frame = CGRectMake(i*(width+5), 10, width+10, 24);
        btn.tag = MCSubBtnTag +i;
        [btn setImage:[UIImage imageNamed:@"check_unSelected.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
    }
}

- (void)btnAction:(UIButton *)sender
{
    for (UIButton *btn in self.subviews) {
        if (btn.tag != sender.tag) {
            [btn setImage:[UIImage imageNamed:@"check_unSelected.png"] forState:UIControlStateNormal];
        }
    }
    [sender setImage:[UIImage imageNamed:@"check_selected.png"] forState:UIControlStateNormal];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelect:index:)]) {
        [self.delegate didSelect:self index:(sender.tag-MCSubBtnTag)];
    }
}

- (void)setSelectIndex:(NSInteger)selectIndex
{
    UIButton *btn = (UIButton *)[self viewWithTag:selectIndex+MCSubBtnTag];
    [btn setImage:[UIImage imageNamed:@"check_selected.png"] forState:UIControlStateNormal];
}



@end
