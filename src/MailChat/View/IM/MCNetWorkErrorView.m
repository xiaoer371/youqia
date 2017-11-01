//
//  MCNetWorkErrorView.m
//  NPushMail
//
//  Created by swhl on 16/1/20.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCNetWorkErrorView.h"

@interface MCNetWorkErrorView ()
@property (nonatomic, assign) IMNoticeType  type;

@end

@implementation MCNetWorkErrorView

-(instancetype)initWithFrame:(CGRect)frame
             actionViewBlock:(actionViewBlock)actionBlock
{
    return [self initWithFrame:frame actionViewBlock:actionBlock noticeType:IMNoticeTypeNetError];
}

-(instancetype)initWithFrame:(CGRect)frame
             actionViewBlock:(actionViewBlock)actionBlock
                  noticeType:(IMNoticeType)type
{
    self =[super initWithFrame:frame];
    if (self) {
        self.actionBlock = actionBlock;
        self.type = type;
        [self initSubviewWithFrame:frame];
    }
    return self;
}
-(void)initSubviewWithFrame:(CGRect)rect
{
    
    UIImageView *imageView =[[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 22, 22)];
    [self addSubview:imageView];
    
    
    UILabel *label =[[UILabel alloc] initWithFrame:CGRectMake(15+40, 5, ScreenWidth-15*2, 34)];
    label.textColor = [UIColor colorWithHexString:@"333333"];
    [self addSubview:label];
    
    if (self.type == IMNoticeTypeNetError) {
        self.backgroundColor = [UIColor colorWithHexString:@"fbfad3"];
        imageView.image = [UIImage imageNamed:@"net_err.png"];
        label.font =[UIFont systemFontOfSize:16.0f];
        label.text = PMLocalizedStringWithKey(@"PM_IMChat_NetworkErr");
    }else{
        self.backgroundColor = AppStatus.theme.toolBarBackgroundColor;
        imageView.image = [UIImage imageNamed:@"mc_pcClientSmall.png"];
        label.font =[UIFont systemFontOfSize:14.0f];
        label.text = PMLocalizedStringWithKey(@"PM_PCWindows_convNotice");

    }
    
    UIButton *button =[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame =CGRectMake(0, 0, rect.size.width, rect.size.height);
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(clickViewAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
}

-(void)clickViewAction:(UIButton*)sender
{
    if (self.actionBlock) {
        self.actionBlock(self.type);
    }
}



@end
