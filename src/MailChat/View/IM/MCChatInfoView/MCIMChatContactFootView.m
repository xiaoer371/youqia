//
//  MCIMChatContactFootView.m
//  NPushMail
//
//  Created by swhl on 16/4/21.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMChatContactFootView.h"

@interface MCIMChatContactFootView ()

@property (nonatomic ,strong) UIButton *didSelectBtn;

@end


@implementation MCIMChatContactFootView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UIImageView *lineImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 0, ScreenWidth, 0.5)];
        lineImage.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
        [self addSubview:lineImage];
        
        UIImageView *nextImage = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth-40, 12, 20, 20)];
        nextImage.image = [UIImage imageNamed:@"cellArror.png"];
        [self addSubview:nextImage];
        
        [self addSubview:self.textLab];
        [self addSubview:self.didSelectBtn];
    }
    return self;
}

-(UILabel *)textLab
{
    if (!_textLab) {
        _textLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 7, ScreenWidth-80, 30)];
    }
    return _textLab;
}

-(UIButton *)didSelectBtn
{
    if (!_didSelectBtn) {
        _didSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _didSelectBtn.backgroundColor =[UIColor clearColor];
        _didSelectBtn.frame = CGRectMake(0, 0, ScreenWidth, 44);
        [_didSelectBtn addTarget:self action:@selector(didSelectBtnAcition:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _didSelectBtn;
}

-(void)didSelectBtnAcition:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectAction)]) {
        [self.delegate didSelectAction];
    }
}

@end
