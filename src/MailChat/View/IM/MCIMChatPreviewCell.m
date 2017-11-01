//
//  MCIMChatPreviewCell.m
//  NPushMail
//
//  Created by swhl on 16/4/28.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMChatPreviewCell.h"

@interface MCIMChatPreviewCell ()

@property (nonatomic ,strong) UIScrollView *scrollView;
@property (nonatomic ,strong) UIImageView  *imageView;

@end

@implementation MCIMChatPreviewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self.contentView addSubview:self.scrollView];
        [self.scrollView addSubview:self.imageView];
        
    }
    return self;
}

-(UIScrollView *)scrollView
{
    if (!_scrollView) {
        CGRect rect = self.frame;
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
        _scrollView.contentSize = CGSizeMake(rect.size.width, rect.size.height);
        _scrollView.backgroundColor =[UIColor blueColor];
        [_scrollView setMaximumZoomScale:3.0f];
        [_scrollView setMinimumZoomScale:1.0f];
        [_scrollView setZoomScale:[_scrollView  minimumZoomScale]];
    }
    return _scrollView;
}

-(UIImageView *)imageView
{
    if (!_imageView) {
        CGRect rect = self.frame;
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.image = [UIImage imageNamed:@"authFailure.png"];
        _imageView.userInteractionEnabled = YES;
        
        //双击手势
        UITapGestureRecognizer *doubelGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singlePressToDo:)];
        doubelGesture.numberOfTapsRequired = 2;
        doubelGesture.numberOfTouchesRequired = 1;
        [_imageView addGestureRecognizer:doubelGesture];
        
        UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
        longPressGr.minimumPressDuration = 0.5;
        [_imageView addGestureRecognizer:longPressGr];
        
    }
    return _imageView;
}

-(void)singlePressToDo:(id)sender
{
    CGPoint pointInView = [sender locationInView:_imageView];
    [self zoomInZoomOut:pointInView];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(handleDoubleFingerEvent)]) {
        [self.delegate handleDoubleFingerEvent];
    }
}

-(void)longPressToDo:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(handleLongFingerEvent)]) {
        [self.delegate handleLongFingerEvent];
    }
}

- (void) zoomInZoomOut:(CGPoint)point {
    // Check if current Zoom Scale is greater than half of max scale then reduce zoom and vice versa
    CGFloat newZoomScale = _scrollView.zoomScale > (_scrollView.maximumZoomScale/2)?_scrollView.minimumZoomScale:_scrollView.maximumZoomScale;
    
    CGSize scrollViewSize = _scrollView.bounds.size;
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = point.x - (w / 2.0f);
    CGFloat y = point.y - (h / 2.0f);
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    [_scrollView zoomToRect:rectToZoomTo animated:YES];
}

@end
