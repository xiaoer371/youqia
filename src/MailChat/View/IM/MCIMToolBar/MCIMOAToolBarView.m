//
//  MCIMOAToolBarView.m
//  NPushMail
//
//  Created by swhl on 16/3/22.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMOAToolBarView.h"

@implementation MCIMOAToolBarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor =[UIColor colorWithHexString:@"f5f5f5"];
        [self _initSubView:frame];
    }
    return self;
}

-(void)_initSubView:(CGRect)frame
{
    float width =self.frame.size.width/3;
    float height =self.frame.size.height;
    
    UIView *lineView =[[UIView alloc] initWithFrame:CGRectMake(0, 0 , width*3, 1)];
    lineView.backgroundColor =[UIColor lightGrayColor];
    [self addSubview:lineView];
    
    
    
    UIButton *btn1 =[UIButton buttonWithType:UIButtonTypeCustom];
    [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn1.frame=CGRectMake(0, 1, width, height);
    [btn1 setTitle:PMLocalizedStringWithKey(@"PM_Msg_OA_Commission") forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal]; //333333
    
    [btn1 addTarget:self action:@selector(bt1Action:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn1];
    
    UIButton *btn2 =[UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn2.frame=CGRectMake(width, 1, width, height);
    [btn2 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn2 setTitle:PMLocalizedStringWithKey(@"PM_Msg_OA_LaunchFromMe") forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(bt2Action:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn2];
    
    
    
    UIButton *btn3 =[UIButton buttonWithType:UIButtonTypeCustom];
    [btn3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn3.frame=CGRectMake(2*width, 1, width, height);
    [btn3 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btn3 setTitle:PMLocalizedStringWithKey(@"PM_Mail_More") forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(bt3Action:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn3];
    
    UIView *lineView1 =[[UIView alloc] initWithFrame:CGRectMake(width, 13, 1, 24)];
    lineView1.backgroundColor =[UIColor lightGrayColor];
    UIView *lineView2 =[[UIView alloc] initWithFrame:CGRectMake(width*2, 13, 1, 24)];
    lineView2.backgroundColor =[UIColor lightGrayColor];
    [self addSubview:lineView1];
    [self addSubview:lineView2];
    
}
-(void)bt1Action:(UIButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(commissionAction)]) {
        [self.delegate commissionAction];
    }
}

-(void)bt2Action:(UIButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(launchAction)]) {
        [self.delegate launchAction];
    }
    
}

-(void)bt3Action:(UIButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(didOAAction)]) {
        [self.delegate didOAAction];
    }
    
}


@end
