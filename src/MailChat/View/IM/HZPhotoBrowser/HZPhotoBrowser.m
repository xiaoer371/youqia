//
//  HZPhotoBrowser.m
//  photobrowser
//
//  Created by aier on 15-2-3.
//  Copyright (c) 2015年 aier. All rights reserved.
//

#import "HZPhotoBrowser.h"
#import "UIImageView+WebCache.h"
#import "HZPhotoBrowserView.h"
#import "SwipeView.h"
#import "HZPhotoBrowserConfig.h"
#import "UIViewController+DNImagePicker.h"
#import "DNSendButton.h"
#import "DNFullImageButton.h"
#import "UIView+MCExpand.h"
#import "JDStatusBarNotification.h"
#import "MCTool.h"

//  =============================================
#define kAnimationDuration 0.35f

@interface HZPhotoBrowser ()< SwipeViewDataSource, SwipeViewDelegate>

@property (nonatomic, strong) SwipeView    *swipeView;
@property (nonatomic, strong) DNSendButton *sendButton;
@property (nonatomic, strong) UILabel      *sizeLabel;
@property (nonatomic, strong) DNFullImageButton *fullImageButton;
@property (nonatomic, strong) UIToolbar    *toolbar;
@property (nonatomic, strong) UIView       *noticeView; //save
@property (nonatomic, strong) UIImageView  *imageView;  //save


@end

@implementation HZPhotoBrowser 
{
    BOOL _hasShowedFistView;
    UIActivityIndicatorView *_indicatorView;
    UILabel *_indexLabel;
    UIView  *_contentView;
    NSTimer *_timer;
    UILabel *_saveLab;
    BOOL    isShowIndex;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = HZPhotoBrowserBackgrounColor;
        isShowIndex = NO;
    }
    return self;
}

//当视图移动完成后调用
- (void)didMoveToSuperview
{
    [self setupScrollView];
    [self setupToolbars];
    [self showFirstImage];
}

- (void)dealloc
{
    [_indicatorView removeFromSuperview];
    _indicatorView = nil;
    _swipeView.delegate = nil;
    _swipeView.dataSource = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupToolbars
{
    // 1. 序标
    UILabel *indexLabel = [[UILabel alloc] init];
    indexLabel.textAlignment = NSTextAlignmentCenter;
    indexLabel.textColor = [UIColor whiteColor];
    indexLabel.font = [UIFont boldSystemFontOfSize:20];
    indexLabel.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.3f];
    indexLabel.bounds = CGRectMake(0, 0, 80, 30);
    indexLabel.center = CGPointMake(kAPPWidth * 0.5, 30);
    indexLabel.layer.cornerRadius = 15;
    indexLabel.clipsToBounds = YES;
    if (self.imageCount > 1) {
        indexLabel.text = [NSString stringWithFormat:@"%ld/%ld",self.currentImageIndex+1,(long)self.imageCount];
        _indexLabel = indexLabel;
        [self addSubview:indexLabel];
    }
    
    // 2.保存按钮
    if (self.browserType  == BrowserTypeDefault) {
        UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        saveButton.frame =CGRectMake(30, ScreenHeigth - 30 - 40, 60, 38);
        [saveButton setTitle:PMLocalizedStringWithKey(@"PM_Msg_GroupNameSave") forState:UIControlStateNormal];
        [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        saveButton.layer.borderWidth = 0.1;
        saveButton.layer.borderColor = [UIColor whiteColor].CGColor;
        saveButton.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.3f];
        saveButton.layer.cornerRadius = 2;
        saveButton.clipsToBounds = YES;
        [saveButton addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:saveButton];

    }
    // 2.删除按钮
    if (self.browserType  == BrowserTypeSend) {
        [self creatSendToolView];
    }
}


#pragma mark 保存图像
- (void)saveImage
{
    HZPhotoBrowserView *tempView = (HZPhotoBrowserView*)_swipeView.currentItemView;
    UIImageWriteToSavedPhotosAlbum(tempView.imageview.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
    [_indicatorView removeFromSuperview];
    _indicatorView = nil;
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    indicator.center = self.center;
    _indicatorView = indicator;
    [[UIApplication sharedApplication].keyWindow addSubview:indicator];
    [indicator startAnimating];
    
    [_saveLab removeFromSuperview];
    [_imageView removeFromSuperview];
    _noticeView = nil;
    
    _noticeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    _noticeView.backgroundColor = [UIColor clearColor];
    _noticeView.hidden = YES;
    _noticeView.center = self.center;

    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((200-16)/2, 2, 16, 16)];
    _imageView.image = [UIImage imageNamed:@"mc_saveImage.png"];
    [_noticeView addSubview:_imageView];
    
    _saveLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 200, 30)];
    _saveLab.textColor = [UIColor grayColor];
    _saveLab.font = [UIFont systemFontOfSize:16.0];
    _saveLab.textAlignment = NSTextAlignmentCenter;
    [_noticeView addSubview:_saveLab];
    [[UIApplication sharedApplication].keyWindow addSubview:_noticeView];

}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *msg = nil ;
    if(error != NULL){
        msg = PMLocalizedStringWithKey(@"PM_IMAGE_SaveImageErr");
    }else{
        msg = PMLocalizedStringWithKey(@"PM_IMAGE_SaveImageSuc");
    }
     [_indicatorView removeFromSuperview];
    _saveLab.text = msg;
    _noticeView.hidden = NO;
    _timer =nil;
    [_timer invalidate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(timeAction:) userInfo:nil repeats:nil];
    
}

- (void)timeAction:(id)sender
{
    _noticeView.hidden = YES;
    _noticeView =nil;
    [_noticeView removeFromSuperview];
}

- (void)creatSendToolView
{
    UIToolbar *navToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0,ScreenWidth, 64)];
    if ([[UIToolbar class] respondsToSelector:@selector(appearance)]) {
        [navToolbar setBackgroundImage:nil forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        [navToolbar setBackgroundImage:nil forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsCompact];
    }
    navToolbar.barStyle = UIBarStyleBlackTranslucent;
    navToolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self addSubview:navToolbar];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(12, 11 , 40, 40);
    [backBtn setImage:[AppStatus.theme.commonBackImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [backBtn addTarget:self  action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [navToolbar addSubview:backBtn];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth-40)/2, 16, 40, 30)];
    label.text = @"1/1";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:16.0f];
    [navToolbar addSubview:label];
    
    [self addSubview:self.toolbar];
    [self setupBarButtonItems];
    
}

- (void)backAction:(UIButton *)sender
{
     [self hidePhotoBrowser:nil];
}

- (void)deleteItem
{
    BOOL isDelede = [self.delegate photoBrowser:self deleteImageForIndex:_swipeView.currentPage];
    if (isDelede) {
        _indexLabel.text = [NSString stringWithFormat:@"%ld/%ld",_swipeView.currentPage+1,(long)self.imageCount];
        [_swipeView reloadData];
    }else{
        [self hidePhotoBrowser:nil];
    }
}

- (void)fullImageButtonAction
{
    _fullImageButton.text = [NSString stringWithFormat:@"(%@)",[[MCTool shared] getFileSizeWithLength:self.fullImageSize]];
    _fullImageButton.selected =!_fullImageButton.selected;
    _isFullImage = _fullImageButton.selected;
}

- (DNFullImageButton *)fullImageButton
{
    if (nil == _fullImageButton) {
        _fullImageButton = [[DNFullImageButton alloc] initWithFrame:CGRectZero];
        [_fullImageButton addTarget:self action:@selector(fullImageButtonAction)];
        _fullImageButton.selected = self.isFullImage;
        
        [_fullImageButton moveToY:8];
        [_fullImageButton moveToX:12];
    }
    return _fullImageButton;
}

- (DNSendButton *)sendButton
{
    if (nil == _sendButton) {
        _sendButton = [[DNSendButton alloc] initWithFrame:CGRectZero];
        _sendButton.title = NSLocalizedStringFromTable(@"send", @"DNImagePicker", @"发送");
        [_sendButton addTaget:self action:@selector(sendButtonAction)];
        [_sendButton moveToY:8];
        [_sendButton moveToX:ScreenWidth - 80];
    }
    return  _sendButton;
}

- (UILabel *)sizeLabel
{
    if (nil == _sizeLabel) {
        CGFloat x = CGRectGetMaxX(_fullImageButton.frame);
        _sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+15,0,80,28)];
        _sizeLabel.text = [NSString stringWithFormat:@"(%@)",[[MCTool shared] getFileSizeWithLength:self.fullImageSize]];
        _sizeLabel.textAlignment = NSTextAlignmentLeft;
        _sizeLabel.textColor = [UIColor whiteColor];
        _sizeLabel.font = [UIFont systemFontOfSize:13.0f];
        _sizeLabel.hidden = YES;
        [_sizeLabel moveToY:8];
    }
    return  _sizeLabel;
}

- (void)setupBarButtonItems
{
    _isFullImage = NO;
    [self.toolbar addSubview:self.fullImageButton];
    [self.toolbar addSubview:self.sendButton];
   // [self.toolbar addSubview:self.sizeLabel];
}

- (UIToolbar *)toolbar
{
    if (nil == _toolbar) {
        CGFloat height = 44;
        _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - height, self.bounds.size.width, height)];
        if ([[UIToolbar class] respondsToSelector:@selector(appearance)]) {
            [_toolbar setBackgroundImage:nil forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
            [_toolbar setBackgroundImage:nil forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsCompact];
        }
        _toolbar.barStyle = UIBarStyleBlackTranslucent;
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    }
    return _toolbar;
}

- (void)sendButtonAction
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(photoBrowser:)]) {
        [self.delegate photoBrowser:self];
        [self hidePhotoBrowser:nil];
    }
}

- (void)setupScrollView
{
    _swipeView = [[SwipeView alloc] initWithFrame:self.bounds];
    _swipeView.userInteractionEnabled = YES;
    _swipeView.alignment = SwipeViewAlignmentCenter;
    _swipeView.delegate = self;
    _swipeView.dataSource = self;
    _swipeView.pagingEnabled = YES;
    _swipeView.truncateFinalPage = YES;
    _swipeView.currentPage = self.currentImageIndex;
    [self addSubview:_swipeView];
}

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return self.imageCount;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    HZPhotoBrowserView *tempView  = (HZPhotoBrowserView*)view;
    if (!tempView)
    {
       tempView = [[HZPhotoBrowserView alloc] initWithFrame:self.swipeView.bounds];
        //处理单击
        if (self.browserType  == BrowserTypeDefault) {
            __weak __typeof(self)weakSelf = self;
            tempView.singleTapBlock = ^(UITapGestureRecognizer *recognizer){
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                [strongSelf photoClick:recognizer];
            };
        }
        
        if (self.browserType  == BrowserTypeDelete) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectPhoto:)]) {
                __weak __typeof(self)weakSelf = self;
                tempView.singleTapBlock = ^(UITapGestureRecognizer *recognizer){
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    _indexLabel.hidden = !isShowIndex;
                    isShowIndex =!isShowIndex;
                    [strongSelf.delegate didSelectPhoto:self];
                };
            }
        }
        
    }else{
    }
    if ([self highQualityImageURLForIndex:index]) {
        [tempView setImageWithURL:[self highQualityImageURLForIndex:index] placeholderImage:[self placeholderImageForIndex:index]];
    } else {
        tempView.imageview.image = [self placeholderImageForIndex:index];
    }
    return tempView;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    _indexLabel.text = [NSString stringWithFormat:@"%ld/%ld",swipeView.currentPage+1,(long)self.imageCount];
}

- (void)swipeViewWillBeginDragging:(SwipeView *)swipeView
{
    HZPhotoBrowserView *view =(HZPhotoBrowserView*) swipeView.currentItemView;  //(HZPhotoBrowserView*)[swipeView itemViewAtIndex:_swipePage];
    if (view.scrollview.zoomScale >1) {
        [view.scrollview setZoomScale:1.0 animated:YES]; //还原
    }
}

- (void)show
{
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = HZPhotoBrowserBackgrounColor;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    _contentView.center = window.center;
    _contentView.bounds = window.bounds;
    
    self.center = CGPointMake(_contentView.bounds.size.width * 0.5, _contentView.bounds.size.height * 0.5);
    self.bounds = CGRectMake(0, 0, _contentView.bounds.size.width, _contentView.bounds.size.height);
    
    [_contentView addSubview:self];
    
    window.windowLevel = UIWindowLevelStatusBar+10.0f;//隐藏状态栏
    
    [window addSubview:_contentView];
    
    
}
- (void)onDeviceOrientationChangeWithObserver
{
    [self onDeviceOrientationChange];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

-(void)onDeviceOrientationChange
{
    if (!shouldLandscape) {
        return;
    }
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;

    if (UIDeviceOrientationIsLandscape(orientation)) {
        [UIView animateWithDuration:kAnimationDuration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)orientation];
            self.transform = (orientation==UIDeviceOrientationLandscapeRight)?CGAffineTransformMakeRotation(M_PI*1.5):CGAffineTransformMakeRotation(M_PI/2);
            self.bounds = CGRectMake(0, 0, screenBounds.size.height, screenBounds.size.width);
            [self setNeedsLayout];
            [self layoutIfNeeded];
        } completion:nil];
    }else if (orientation==UIDeviceOrientationPortrait){
        [UIView animateWithDuration:kAnimationDuration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)orientation];
            self.transform = (orientation==UIDeviceOrientationPortrait)?CGAffineTransformIdentity:CGAffineTransformMakeRotation(M_PI);
            self.bounds = screenBounds;
            [self setNeedsLayout];
            [self layoutIfNeeded];
        } completion:nil];
    }
}


- (void)showFirstImage
{
    UIView *sourceView = self.sourceImagesContainerView;
    CGRect rect = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
   
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.frame = rect;
    tempView.image = [self placeholderImageForIndex:self.currentImageIndex];
    [self addSubview:tempView];
    tempView.contentMode = UIViewContentModeScaleAspectFit;
    
    CGFloat placeImageSizeW = tempView.image.size.width<1?40:tempView.image.size.width;
    CGFloat placeImageSizeH = tempView.image.size.height<1?40:tempView.image.size.height;
    CGRect targetTemp;

    CGFloat placeHolderH = (placeImageSizeH * kAPPWidth)/placeImageSizeW;
    if (placeHolderH <= KAppHeight) {
        targetTemp = CGRectMake(0, (KAppHeight - placeHolderH) * 0.5 , kAPPWidth, placeHolderH);
    } else {//图片高度>屏幕高度
        targetTemp = CGRectMake(0, 0, kAPPWidth, placeHolderH);
    }
    
    //先隐藏scrollview
    _swipeView.hidden = YES;
    _indexLabel.hidden = YES;

    [UIView animateWithDuration:_firstShowStatic?0:HZPhotoBrowserShowImageAnimationDuration animations:^{
        //将点击的临时imageview动画放大到和目标imageview一样大
        tempView.frame = targetTemp;
    } completion:^(BOOL finished) {
        //动画完成后，删除临时imageview，让目标imageview显示
        _hasShowedFistView = YES;
        [tempView removeFromSuperview];
        _swipeView.hidden = NO;
        _indexLabel.hidden = NO;
    }];
}

- (UIImage *)placeholderImageForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:placeholderImageForIndex:)]) {
        return [self.delegate photoBrowser:self placeholderImageForIndex:index];
    }
    return nil;
}

- (NSURL *)highQualityImageURLForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:highQualityImageURLForIndex:)]) {
        return [self.delegate photoBrowser:self highQualityImageURLForIndex:index];
    }
    return nil;
}

#pragma mark 单击
- (void)photoClick:(UITapGestureRecognizer *)recognizer
{
    _indexLabel.hidden = YES;
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    if (UIDeviceOrientationIsLandscape(orientation)) {
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)UIDeviceOrientationPortrait];
            self.transform = CGAffineTransformIdentity;
            self.bounds = CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height);
            [self setNeedsLayout];
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self hidePhotoBrowser:recognizer];
        }];
    } else {
        [self hidePhotoBrowser:recognizer];
    }
}

- (void)hidePhotoBrowser:(UITapGestureRecognizer *)recognizer
{
//    HZPhotoBrowserView *view = (HZPhotoBrowserView *)recognizer.view;
    HZPhotoBrowserView *view =(HZPhotoBrowserView *)_swipeView.currentItemView;

    UIImageView *currentImageView = view.imageview;
    UIView *sourceView = self.sourceImagesContainerView;
    CGRect targetTemp = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
    
    UIImageView *tempImageView = [[UIImageView alloc] init];
    tempImageView.image = currentImageView.image;
    CGFloat tempImageSizeH = tempImageView.image.size.height<1?40:tempImageView.image.size.height;
    CGFloat tempImageSizeW = tempImageView.image.size.width<1?40:tempImageView.image.size.width;
    CGFloat tempImageViewH = (tempImageSizeH * kAPPWidth)/tempImageSizeW;
    
    if (tempImageViewH < KAppHeight) {//图片高度<屏幕高度
        tempImageView.frame = CGRectMake(0, (KAppHeight - tempImageViewH)*0.5, kAPPWidth, tempImageViewH);
    } else {
        tempImageView.frame = CGRectMake(0, 0, kAPPWidth, tempImageViewH);
    }
    [self addSubview:tempImageView];
    _indexLabel.hidden = YES;
    _swipeView.hidden = YES;
    self.backgroundColor = [UIColor clearColor];
    _contentView.backgroundColor = [UIColor clearColor];
    self.window.windowLevel = UIWindowLevelNormal;//显示状态栏
    [UIView animateWithDuration:HZPhotoBrowserHideImageAnimationDuration animations:^{
        tempImageView.frame = targetTemp;
    } completion:^(BOOL finished) {
        [_contentView removeFromSuperview];
        [tempImageView removeFromSuperview];
    }];
}


@end
