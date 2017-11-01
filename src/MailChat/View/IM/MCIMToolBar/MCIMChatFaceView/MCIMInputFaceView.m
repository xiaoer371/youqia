//
//  MCIMInputFaceView.m
//  NPushMail
//
//  Created by swhl on 16/3/29.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMInputFaceView.h"
#import "MCIMChatFaceView.h"

const static NSInteger   kMailChatFaceViewHeight = 216;  //表情view 高度

@interface MCIMInputFaceView ()<UIScrollViewDelegate,MCIMChatFaceViewDelegate>

@property (nonatomic, strong) UIScrollView   *faceScrollView;
@property (nonatomic, strong) UIPageControl  *pageControl;
@property (nonatomic, strong) NSArray *plistFaces;



@end

@implementation MCIMInputFaceView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initSubviews];
    }
    return self;
}

-(void)_initSubviews
{
    self.backgroundColor = AppStatus.theme.chatStyle.chatToolBarBackColor;
    [self addSubview:self.faceScrollView];

    _pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake((ScreenWidth -100)/2,kMailChatFaceViewHeight-30, 100, 30)];
    [_pageControl setCurrentPage:0];
    _pageControl.pageIndicatorTintColor = RGBACOLOR(195, 179, 163, 1);
    _pageControl.currentPageIndicatorTintColor =  RGBACOLOR(132, 104, 77, 1);
    _pageControl.numberOfPages = 3;   //指定页面个数
    [_pageControl setBackgroundColor:[UIColor clearColor]];
    [_pageControl addTarget:self action:@selector(changePage:)forControlEvents:UIControlEventValueChanged];
    
    [self addSubview:_pageControl];
    
}

-(UIScrollView *)faceScrollView
{
    if (!_faceScrollView) {
        _faceScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, kMailChatFaceViewHeight)];
        _faceScrollView.backgroundColor = AppStatus.theme.chatStyle.chatToolBarBackColor;
        MCIMChatFaceView *faceView = [[MCIMChatFaceView alloc] initWithFrame:CGRectMake(0, 0.5, ScreenWidth *3 , kMailChatFaceViewHeight)];
        faceView.delegate = self;
        
        self.plistFaces = [faceView getPlistFaces];
        [_faceScrollView addSubview:faceView];
        
        [_faceScrollView setShowsVerticalScrollIndicator:NO];
        [_faceScrollView setShowsHorizontalScrollIndicator:YES];
        _faceScrollView.contentSize = CGSizeMake(ScreenWidth*3, kMailChatFaceViewHeight);
        _faceScrollView.pagingEnabled = YES;
        _faceScrollView.delegate = self;
        
    }
    return _faceScrollView;
}

#pragma mark - MCIMChatFaceViewDelegate
-(void)selectedFacialView:(NSString*)str
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectFaceStr:)]) {
        [self.delegate didSelectFaceStr:str];
    }
}

-(void)sendMessageText:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSendMessage:)]) {
        [self.delegate didSendMessage:sender];
    }
}

-(void)deleteFacialView:(NSString*)str
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDeleteFaceStr:)]) {
        [self.delegate didDeleteFaceStr:str];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    int page = _faceScrollView.contentOffset.x / ScreenWidth;//通过滚动的偏移量来判断目前页面所对应的小白点
    _pageControl.currentPage = page;//pagecontroll响应值的变化
}

-(void)changePage:(id)sender
{
    NSInteger page = _pageControl.currentPage;//获取当前pagecontroll的值
    [_faceScrollView setContentOffset:CGPointMake(ScreenWidth * page, 0)];//根据pagecontroll的值来改变scrollview的滚动位置，以此切换到指定的页面
}

-(NSArray *)getPlistFaces
{
    return self.plistFaces;
}


@end
