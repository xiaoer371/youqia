//
//  MCMailDetailWebView.m
//  NPushMail
//
//  Created by zhang on 15/12/25.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import "MCMailDetailWebView.h"
#import "FBKVOController.h"

CG_INLINE CGRect
CGRectSetX(CGRect rect, CGFloat x)
{
    rect.origin.x = x;
    return rect;
}

CG_INLINE CGRect
CGRectSetY(CGRect rect, CGFloat y)
{
    rect.origin.y = y;
    return rect;
}


CG_INLINE UIEdgeInsets
UIEdgeInsetsSetTop(UIEdgeInsets insets, CGFloat top)
{
    insets.top = top;
    return insets;
}


CG_INLINE UIEdgeInsets
UIEdgeInsetsSetBottom(UIEdgeInsets insets, CGFloat bottom)
{
    insets.bottom = bottom;
    return insets;
}
CG_INLINE CGPoint
CGPointSetY (CGPoint point ,CGFloat y)
{
    point.y = y;
    return point;
}

@interface MCMailDetailWebView ()

@property (nonatomic,strong)UIActivityIndicatorView *mcActivityIndicatorView;
@property (nonatomic,strong)UIScrollView *mcScrollView;
@end


@implementation MCMailDetailWebView

- (id) initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.opaque = NO;
        _mcScrollView = self.scrollView;
        self.backgroundColor = [UIColor clearColor];
        _mcActivityIndicatorView = [[UIActivityIndicatorView alloc]init];
        _mcActivityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _mcActivityIndicatorView.center = CGPointMake(ScreenWidth/2, ScreenHeigth/4);
        [_mcScrollView addSubview:_mcActivityIndicatorView];
    }
    return self;
}

- (void)setFooterView:(UIView *)footerView
{
    if (_footerView) {
        [_footerView removeFromSuperview];
        _footerView = nil;
    }
    _footerView = footerView ;
    _footerView.frame = CGRectSetY(_footerView.frame, self.scrollView.contentSize.height);
    _mcScrollView.contentInset = UIEdgeInsetsSetBottom(self.scrollView.contentInset, CGRectGetHeight(footerView.frame));
    [_mcScrollView addSubview:footerView];
}

- (void)setHeaderView:(UIView *)headerView
{
    if (_headerView) {
        [_headerView removeFromSuperview];
         _headerView = nil;
    }
    _headerView = headerView;
    CGFloat height = CGRectGetHeight(headerView.frame);
    _headerView.frame = CGRectSetY(_headerView.frame, - height);
    _mcScrollView.contentInset = UIEdgeInsetsSetTop(_mcScrollView.contentInset, height);
    _mcScrollView.contentOffset = CGPointMake(0, - height);
    _headerView.clipsToBounds = YES;
    [_mcScrollView addSubview:headerView];
}


//change hight
- (void)headerViewHeightChange:(CGFloat)height animated:(BOOL)animated {
    
    [UIView animateWithDuration:animated?0.3:0 animations:^{
        _mcScrollView.contentOffset = CGPointSetY(_mcScrollView.contentOffset, - height);
        _mcScrollView.contentInset = UIEdgeInsetsSetTop(_mcScrollView.contentInset, height);
        _headerView.frame = CGRectMake(_headerView.frame.origin.x, -height, _headerView.frame.size.width, height);
        _footerView.frame = CGRectSetY(_footerView.frame, _mcScrollView.contentSize.height);
    }];
  
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
//    DDLogDebug(@"size ==%@   contentSize == %@ ==== %@",NSStringFromCGSize(self.frame.size),NSStringFromCGSize(self.scrollView.contentSize),NSStringFromCGSize([self sizeThatFits:CGSizeZero]));
    
    if (scrollView.contentSize.height  == scrollView.frame.size.height) {
        _footerView.frame = CGRectSetY(_footerView.frame, scrollView.frame.size.height - _footerView.frame.size.height - _headerView.frame.size.height);
    } else {
        _footerView.frame = CGRectSetY(_footerView.frame, scrollView.contentSize.height);
    }
    CGFloat webViewWidth = self.frame.size.width;
    //缩小到小于webview宽度时
    if (scrollView.contentSize.width < webViewWidth) {
        CGSize contentSize = scrollView.contentSize;
        contentSize.width = webViewWidth;
        scrollView.contentSize = contentSize;
    }
    //左右露边
    _headerView.frame = CGRectSetX(_headerView.frame, scrollView.contentOffset.x);
    _footerView.frame = CGRectSetX(_footerView.frame, scrollView.contentOffset.x);
    
}

//UIActivityIndicatorView
- (void)loading {
    [_mcActivityIndicatorView startAnimating];
}
- (void)stopLoading {
    [_mcActivityIndicatorView stopAnimating];
}

@end
