//
//  MCIMChatSwitchView.m
//  NPushMail
//
//  Created by swhl on 16/3/1.
//  Copyright © 2016年 sprite. All rights reserved.
//

#define OR_X 15
#define OR_Y 3
#define label_h 30

#import "MCIMChatSwitchView.h"

@implementation MCIMChatSwitchView

- (instancetype)initWithFrame:(CGRect)frame
                    WithTitle:(NSString *)title
                      swithon:(BOOL)on_off
{
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor =[UIColor whiteColor];
        float width = self.frame.size.width;
        float height =  self.frame.size.height;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(OR_X,(height-label_h)/2 , width, label_h)];
        label.text = title;
        [self addSubview:label];
        
        _switchView = [[UISwitch alloc] initWithFrame:CGRectMake(width-60, (height-label_h)/2, label_h, label_h)];
        _switchView.on = on_off;
        [_switchView addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_switchView];
        
        UIImageView *lineImage = [[UIImageView alloc] initWithFrame:CGRectMake(OR_X, height-0.5, width, 0.5)];
        lineImage.backgroundColor = AppStatus.theme.tableViewSeparatorColor;
        [self addSubview:lineImage];
        
    }
    return self;
}

-(void)click:(UISwitch *)sender
{
    if ([_delegate respondsToSelector:@selector(swithAction:)]) {
        [_delegate swithAction:self.switchView];
    }
}

-(void)setTag:(NSInteger)tag
{
    [super setTag:tag];
    _switchView.tag = tag;
}

@end
