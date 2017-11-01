//
//  MCIMOAContentView.m
//  NPushMail
//
//  Created by swhl on 16/3/22.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMOAContentView.h"

@interface MCIMOAContentView ()


@property (nonatomic,strong)UIImageView *contentBgImgView;
@property (nonatomic,strong)UIView  *line;
@property (nonatomic,strong)UILabel *lookLabel;
@property (nonatomic,strong)UIImageView *nextImgView;
@property (nonatomic,strong)UILabel *contentLabel;

@property (nonatomic,strong)UIButton *clickViewBtn;

@end


@implementation MCIMOAContentView

-(instancetype)init
{
    self =[super init];
    if (self) {
        [self _initSubViews];
    }
    return self;
}
-(void)_initSubViews{
    //内容
    _contentBgImgView = [[UIImageView alloc] init];
    [self addSubview:_contentBgImgView];
    
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.numberOfLines = 2;
    _contentLabel.font =[UIFont systemFontOfSize:16.0f];
    _contentLabel.textColor = [UIColor whiteColor];
    [self addSubview:_contentLabel];
    
    
    _line = [[UIView alloc] init];
    _line.backgroundColor =[UIColor whiteColor];
    [self addSubview:_line];
    
    _lookLabel = [[UILabel alloc] init];
    _lookLabel.textColor = [UIColor whiteColor];
    _lookLabel.font = [UIFont systemFontOfSize:14.0f];
    _lookLabel.text = @"查看详情";
    [self addSubview:_lookLabel];
    
    _nextImgView = [[UIImageView alloc] init];
    _nextImgView.image = [UIImage imageNamed:@"oa_arror.png"];
    [self addSubview:_nextImgView];
    
    
    _clickViewBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    _clickViewBtn.frame=CGRectZero;
    [_clickViewBtn addTarget:self action:@selector(clickView:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_clickViewBtn];
    
    
}
#define ContentMarginW 0
#define ContentMarginH 0
#define ContentMarginX 3

-(void)setFrameWithOAmodel:(MCIMOAMessageModel *)oaModel originPoint:(CGPoint)originPoint
{
    NSString *title =oaModel.type ==1?[NSString stringWithFormat:@"公告:%@",oaModel.title]:oaModel.title;
    _contentLabel.text =title;
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16.0f],NSFontAttributeName, nil];
    CGSize size = [title boundingRectWithSize:CGSizeMake(ScreenWidth-100, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    
    _contentLabel.frame =CGRectMake(ContentMarginW+ContentMarginX, ContentMarginH+4, size.width, size.height);
    
    float originY3 =CGRectGetMaxY(_contentLabel.frame)+1;
    _line.frame =CGRectMake(ContentMarginW, originY3, size.width, 0.5);
    
    float endX =CGRectGetMinX(_contentLabel.frame)+_contentLabel.frame.size.width;
    _lookLabel.frame =CGRectMake(ContentMarginW+ContentMarginX, originY3+1, 100, 25);
    
    _nextImgView.frame =CGRectMake(endX-20, originY3+6, 20, 20);
    
    _contentBgImgView.frame =CGRectMake(ContentMarginW-10, ContentMarginH,  size.width+20, size.height+25+6);
    UIImage *image =[UIImage imageNamed:@"oa_bubble.png"];
    _contentBgImgView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(30, 50, 20, 20)];
    
    _clickViewBtn.frame =CGRectMake(ContentMarginW, ContentMarginH,size.width, size.height+25);
    
    self.frame =CGRectMake(originPoint.x, originPoint.y, size.width, size.height+25+2);
}

-(void)clickView:(UIButton*)sender
{
    if ([self.delegate respondsToSelector:@selector(didSelectContentView)]) {
        [self.delegate didSelectContentView];
    }
}


@end
