//
//  SRRefreshView.m
//  SlimeRefresh
//
//  Created by zrz on 12-6-15.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "SRRefreshView.h"
#import "SRSlimeView.h"
#import "SRDefine.h"
#import <QuartzCore/QuartzCore.h>
#import "FBKVOController.h"
@interface SRRefreshView()

@property (nonatomic, assign)   BOOL    broken;
@property (nonatomic, strong)   UIScrollView    *scrollView;
@property (nonatomic, strong)   UIView *mcNoteView;
@property (nonatomic, strong)   UILabel *resultLabel;

@end

@implementation SRRefreshView {
    UIActivityIndicatorView *_activityIndicatorView;
    CGFloat     _oldLength;
    BOOL        _unmissSlime;
    CGFloat     _dragingHeight;
}

@synthesize delegate = _delegate, broken = _broken;
@synthesize loading = _loading, scrollView = _scrollView;
@synthesize slime = _slime, refleshView = _refleshView;
@synthesize block = _block, upInset = _upInset;
@synthesize slimeMissWhenGoingBack = _slimeMissWhenGoingBack;
@synthesize activityIndicationView = _activityIndicatorView;


- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithHeight:44];
    return self;
}

- (id)initWithHeight:(CGFloat)height
{
    CGRect frame = CGRectMake(0, 0, ScreenWidth, height);
    self = [super initWithFrame:frame];
    if (self) {
        _slime = [[SRSlimeView alloc] initWithFrame:
                  CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
        _slime.startPoint = CGPointMake(frame.size.width / 2, height / 2);
        
        [self addSubview:_slime];
        
        _refleshView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sr_refresh"]];
        _refleshView.center = _slime.startPoint;
        _refleshView.bounds = CGRectMake(0.0f, 0.0f, kRefreshImageWidth, kRefreshImageWidth);
        [self addSubview:_refleshView];
        
        _activityIndicatorView = [[UIActivityIndicatorView alloc]
                                  initWithActivityIndicatorStyle:
                                  UIActivityIndicatorViewStyleGray];
        [_activityIndicatorView stopAnimating];
        _activityIndicatorView.center = _slime.startPoint;
        [self addSubview:_activityIndicatorView];
        
        [_slime setPullApartTarget:self
                            action:@selector(pullApart:)];
        _dragingHeight = height;
        
        
        
        _mcNoteView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, height)];
        _mcNoteView.center = _activityIndicatorView.center;
        _mcNoteView.hidden = YES;
        _mcNoteView.backgroundColor = AppStatus.theme.backgroundColor;
        
        UIImageView *mcNoteImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, (CGRectGetHeight(_mcNoteView.frame) - 14)/2, 14, 14)];
        mcNoteImageView.image = [UIImage imageNamed:@"mc_mailListRefresh.png"];
        
        _resultLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(mcNoteImageView.frame)+5, 0, ScreenWidth, height)];
        _resultLabel.textAlignment = NSTextAlignmentLeft;
        _resultLabel.textColor = AppStatus.theme.fontTintColor;
        _resultLabel.font = [UIFont systemFontOfSize:14.0];
        
        [_mcNoteView addSubview:mcNoteImageView];
        [_mcNoteView addSubview:_resultLabel];
        [self addSubview:_mcNoteView];
        
        __weak typeof(self)weekSelf = self;
        
        [self.KVOController observe:_resultLabel keyPath:@"text" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            NSString *text = change[NSKeyValueChangeNewKey];
            CGSize textSize = [text mcStringSizeWithFont:14.0];
            CGRect rect  = weekSelf.mcNoteView.frame;
            rect.size.width = 14 + 5 + textSize.width;
            weekSelf.mcNoteView.frame = rect;
            weekSelf.mcNoteView.center = weekSelf.activityIndicationView.center;
        }];
    }
    return self;
}

#pragma mark - setters

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (_slime.state == SRSlimeStateNormal) {
        _slime.frame = CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height);
        _slime.startPoint = CGPointMake(frame.size.width / 2, _dragingHeight / 2);
    }
    _refleshView.center = _slime.startPoint;
    _activityIndicatorView.center = _slime.startPoint;
}

- (void)setUpInset:(CGFloat)upInset
{
    _upInset = upInset;
    UIEdgeInsets inset = _scrollView.contentInset;
    inset.top = _upInset;
    _scrollView.contentInset = inset;
    
}

- (void)setSlimeMissWhenGoingBack:(BOOL)slimeMissWhenGoingBack
{
    _slimeMissWhenGoingBack = slimeMissWhenGoingBack;
    if (!slimeMissWhenGoingBack) {
        _slime.alpha = 1;
    }else {
        CGPoint p = _scrollView.contentOffset;
        self.alpha = -(p.y + _upInset) / _dragingHeight;
    }
}

- (void)setLoading:(BOOL)loading
{
    if (_loading == loading) {
        return;
    }
    _loading = loading;
    if (_loading) {
        [_activityIndicatorView startAnimating];
        CAKeyframeAnimation *aniamtion = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        
        aniamtion.values = [NSArray arrayWithObjects:
                            [NSValue valueWithCATransform3D:
                             CATransform3DRotate(CATransform3DMakeScale(0.01, 0.01, 0.1),
                             -M_PI, 0, 0, 1)],
//                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.6, 1.6, 1)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity],nil];
        aniamtion.keyTimes = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:0],
                              [NSNumber numberWithFloat:0.6],
                              [NSNumber numberWithFloat:1], nil];
        aniamtion.timingFunctions = [NSArray arrayWithObjects:
                                     [CAMediaTimingFunction functionWithName:
                                      kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:
                                      kCAMediaTimingFunctionEaseInEaseOut],
                                      nil];
        aniamtion.duration = 0.7;
        _activityIndicatorView.layer.transform = CATransform3DIdentity;
        [_activityIndicatorView.layer addAnimation:aniamtion
                                            forKey:@""];
        //_slime.hidden = YES;
        _refleshView.hidden = YES;
        if (!_scrollView.isDragging) {
            UIEdgeInsets inset = _scrollView.contentInset;
            inset.top = _upInset + _dragingHeight;
            _scrollView.contentInset = inset;
        }
        if (!_unmissSlime){
            _slime.state = SRSlimeStateMiss;
        }else {
            _unmissSlime = NO;
        }
    }else {
        
        [_activityIndicatorView stopAnimating];
        _slime.hidden = NO;
        _refleshView.hidden = NO;
        _refleshView.layer.transform = CATransform3DIdentity;
        [UIView transitionWithView:_scrollView
                          duration:0.3f
                           options:UIViewAnimationOptionBeginFromCurrentState
                        animations:^{
                            UIEdgeInsets inset = _scrollView.contentInset;
                            inset.top = _upInset;
                            _scrollView.contentInset = inset;
                            if (_scrollView.contentOffset.y == -_upInset &&
                                _slimeMissWhenGoingBack) {
                                self.alpha = 0.0f;
                            }
                        } completion:^(BOOL finished) {
                            //_notSetFrame = NO;
                            _mcNoteView.hidden = YES;
                        }];
        
    }
}

- (void)setLoadingWithExpansion {
    
    self.loading = YES;
    [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x, -_dragingHeight) animated:YES];
    [self scrollViewDidScroll];
    [self scrollViewDidEndDraging];
    [self pullApart:self];
    self.broken = NO;
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        self.scrollView = (id)[self superview];
        CGRect rect = self.frame;
        rect.origin.y = rect.size.height?-rect.size.height:-_dragingHeight;
        rect.size.width = _scrollView.frame.size.width;
        self.frame = rect;
        self.slime.toPoint = self.slime.startPoint;
        
        UIEdgeInsets inset = self.scrollView.contentInset;
        inset.top = _upInset;
        self.scrollView.contentInset = inset;
    }else if (!self.superview) {
        self.scrollView = nil;
    }
}

#pragma mark - action

- (void)pullApart:(SRRefreshView*)refreshView
{
    //拉断了
    self.broken = YES;
    _unmissSlime = YES;
    self.loading = YES;
    if ([_delegate respondsToSelector:@selector(slimeRefreshStartRefresh:)]) {
        [(id)_delegate performSelector:@selector(slimeRefreshStartRefresh:)
                            withObject:self
                            afterDelay:0.0];
    }
    if (_block) {
        _block(self);
    }
}

- (void)scrollViewDidScroll
{
    CGPoint p = _scrollView.contentOffset;
    CGRect rect = self.frame;
    if (p.y <= - _dragingHeight - _upInset) {
        rect.origin.y = p.y + _upInset;
        rect.size.height = -p.y;
        rect.size.height = ceilf(rect.size.height);
        self.frame = rect;
        if (!self.loading) {
            [_slime setNeedsDisplay];
        }
        if (!_broken) {
            float l = -(p.y + _dragingHeight + _upInset);
            if (l <= _oldLength) {
                l = MIN(distansBetween(_slime.startPoint, _slime.toPoint), l);
                CGPoint ssp = _slime.startPoint;
                _slime.toPoint = CGPointMake(ssp.x, ssp.y + l);
                CGFloat pf = (1.0f-l/_slime.viscous) * (1.0f-kStartTo) + kStartTo;
                _refleshView.layer.transform = CATransform3DMakeScale(pf, pf, 1);
            }else if (self.scrollView.isDragging) {
                CGPoint ssp = _slime.startPoint;
                _slime.toPoint = CGPointMake(ssp.x, ssp.y + l);
                CGFloat pf = (1.0f-l/_slime.viscous) * (1.0f-kStartTo) + kStartTo;
                _refleshView.layer.transform = CATransform3DMakeScale(pf, pf, 1);
            }
            _oldLength = l;
        }
        if (self.alpha != 1.0f) self.alpha = 1.0f;
    }else if (p.y < -_upInset) {
        rect.origin.y = -_dragingHeight;
        rect.size.height = _dragingHeight;
        self.frame = rect;
        [_slime setNeedsDisplay];
        _slime.toPoint = _slime.startPoint;
        if (_slimeMissWhenGoingBack) self.alpha = -(p.y + _upInset) / _dragingHeight;
    }
}

- (void)scrollViewDidEndDraging
{
    if (_broken) {
        if (self.loading) {
            [UIView transitionWithView:_scrollView
                              duration:0.2
                               options:UIViewAnimationOptionBeginFromCurrentState
                            animations:^{
                                UIEdgeInsets inset = _scrollView.contentInset;
                                inset.top = _upInset + _dragingHeight;
                                _scrollView.contentInset = inset;
                            } completion:^(BOOL finished) {
                                self.broken = NO;
                            }];
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.2f];
            [UIView commitAnimations];
        }else {
            [self performSelector:@selector(setBroken:)
                       withObject:nil afterDelay:0.2];
            self.loading = NO;
        }
    }
}


- (void)endRefresh
{
    [self endRefreshWithResult:nil];
}

- (void)endRefreshWithResult:(NSString*)result {
    
    if (self.loading) {
        
        if (result) {
            _mcNoteView.hidden= NO;
            _resultLabel.text = result;
        }
        [self performSelector:@selector(restore)
                   withObject:nil
                   afterDelay:0];
    }
    _oldLength = 0;
}

- (void)restore
{
    _slime.toPoint = _slime.startPoint;
    [UIView transitionWithView:_activityIndicatorView
                      duration:0.3f
                       options:UIViewAnimationOptionAllowUserInteraction
                    animations:^
     {
         _activityIndicatorView.layer.transform = CATransform3DRotate(
                                                                      CATransform3DMakeScale(0.01f, 0.01f, 0.1f), -M_PI, 0, 0, 1);
     } completion:^(BOOL finished)
     {
         self.loading = NO;
         _slime.state = SRSlimeStateNormal;
 //some bug here.
 //             CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:
 //                                            @"transform"];
 //             animation.fromValue = [NSValue valueWithCATransform3D:
 //                                    CATransform3DMakeScale(0.1, 0.1, 1)];
 //             animation.toValue = [NSValue valueWithCATransform3D:
 //                                  CATransform3DIdentity];
 //             animation.duration = 0.2f;
 //             [_slime.layer addAnimation:animation
 //                                 forKey:@""];
     }];
}

@end
