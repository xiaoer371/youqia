//
//  MCIMLatestView.m
//  NPushMail
//
//  Created by swhl on 16/7/13.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMLatestView.h"
#import "PHAsset+MCLastImage.h"          //ios 8.0 以上
#import "ALAssetsLibrary+MCLastImage.h"  //ios 8.0 以下
#import "HZPhotoBrowser.h"

static const CGFloat mcLastViewWidth = 64.0f;
static const CGFloat mcLastViewHeight = 103.0f;
static const CGFloat mcLastViewSubPadding = 2.0f;

static const CGFloat mcTimerHiddenTime = 5.0f;
static const CGFloat mcLatestImageSpace = 300.0f;


//记录最后一张照片的时间
static NSString * const mcLatestImageisShow = @"mcLatestImageisShow";

@interface MCIMLatestView ()<HZPhotoBrowserDelegate>

@property (nonatomic, strong) UIImageView  * lastImageView;
@property (nonatomic, strong) UIImage      * image;

/**
 *   控制界面 5s后消失
 */
@property (nonatomic, strong) NSTimer  *timer;

@property (nonatomic, assign) NSUInteger  length;

@end


@implementation MCIMLatestView

- (void)dealloc
{
    self.delegate = nil;
    [_timer invalidate];
    _timer = nil;
}

- (instancetype)initWithDelegate:(id <MCIMLatestViewDelegate>)delegate
{
    CGRect frame = CGRectMake(0, 80, mcLastViewWidth, mcLastViewHeight);
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate;
        [self  _initSubviews];
    }
    return self;
}

- (instancetype)initWithOrigin:(CGPoint)origin
{
    CGRect frame = CGRectMake(origin.x, origin.y, mcLastViewWidth, mcLastViewHeight);
    self = [super initWithFrame:frame];
    if (self) {
        [self  _initSubviews];
    }
    return self;
}

- (void)_initSubviews
{
    self.hidden = YES;
    CGRect rect = self.bounds;
    UIImageView *bubbleIamgeView = [[UIImageView alloc] initWithFrame:rect];
    UIImage *image = [UIImage imageNamed:@"mc_im_latestBubble.png"];
    bubbleIamgeView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 20, 30)];
    [self addSubview:bubbleIamgeView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(mcLastViewSubPadding, mcLastViewSubPadding, rect.size.width-2*mcLastViewSubPadding, 30)];
    label.text = PMLocalizedStringWithKey(@"PM_IMChat_latestImage");
    label.numberOfLines = 2;
    label.font = [UIFont systemFontOfSize:12];
    [self addSubview:label];
    
    _lastImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 34, mcLastViewWidth-2*2, mcLastViewWidth-4)];
    _lastImageView.layer.cornerRadius = 2;
    _lastImageView.layer.masksToBounds =YES;
    //给图层添加一个有色边框
    _lastImageView.layer.borderWidth = 1;
    _lastImageView.layer.borderColor = [AppStatus.theme.tableViewSeparatorColor CGColor];
    
    if (EGOVersion_iOS8) {
        [self loadLastImageWithPHAsset];
    }else{
        [self loadLastImageWithALAsset];
    }
    [self addSubview:_lastImageView];
    
    UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectBtn.frame = self.bounds;
    selectBtn.backgroundColor = [UIColor clearColor];
    [selectBtn addTarget:self action:@selector(didSelectViewImage:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:selectBtn];
}

- (void)didSelectViewImage:(UIButton *)sender
{
    [_timer invalidate];
    _timer = nil;
    self.hidden = YES;
    
    HZPhotoBrowser *browserVc = [[HZPhotoBrowser alloc] init];
    browserVc.sourceImagesContainerView = sender;
    browserVc.imageCount = 1; // 图片总数
    browserVc.currentImageIndex =0;
    browserVc.delegate = self;
    browserVc.browserType = BrowserTypeSend;
    browserVc.fullImageSize = self.length;
    [browserVc show];
    
}

- (void )photoBrowser:(HZPhotoBrowser *)browser
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectLastImage:)]) {
        if (browser.isFullImage) {
            [self.delegate selectLastImage:_lastImageView.image];
        }else{
            if (_image) {
                [self.delegate selectLastImage:_image];
            }
        }
    }
}

- (UIImage *)photoBrowser:(HZPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    return _lastImageView.image;
}

- (void)loadLastImageWithPHAsset
{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied){
        self.hidden = YES;
        // 无权限
        return;
    }
    //ios 8.0 以后
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    PHAsset *asset =  [PHAsset latestAsset];
    NSDate *date =  asset.creationDate;
    int saveNum = [date timeIntervalSince1970];
    if ([self isShowPhoto:date]) {
        self.hidden = YES;
        return;
    }
    int num = [date timeIntervalSinceNow];
    if (abs(num) <= mcLatestImageSpace) {
        self.hidden = NO;
        [userDefaults setObject:@(abs(saveNum)) forKey:mcLatestImageisShow];
        [userDefaults synchronize];
    }
    
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:PHImageContentModeAspectFit resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        //
        _length = imageData.length;
        _lastImageView.image = [UIImage imageWithData:imageData];
    }];
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(ScreenWidth, ScreenHeigth) contentMode:PHImageContentModeDefault options:PHImageContentModeAspectFit resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        //
        _image =result;
    }];

}

- (void)loadLastImageWithALAsset
{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied){
        self.hidden = YES;
        // 无权限
        return;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
    // ios 8.0 以下
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    ALAssetsLibrary *assetsLibrary =   [[ALAssetsLibrary alloc] init];
    [assetsLibrary latestAsset:^(ALAsset * _Nullable asset, NSError * _Nullable error) {
        NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
        if ([self isShowPhoto:date]) {
            self.hidden = YES;
            return;
        }
        int saveNum = [date timeIntervalSince1970];
        int num = [date timeIntervalSinceNow];
        if (abs(num) <= mcLatestImageSpace) {
            self.hidden = NO;
            [userDefaults setObject:@(abs(saveNum)) forKey:mcLatestImageisShow];
            [userDefaults synchronize];
        }
        if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            _image = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
            CGImageRef fullResImage = [rep fullResolutionImage];
            _lastImageView.image = [UIImage imageWithCGImage:fullResImage
                                                       scale:[rep scale]
                                                 orientation:(UIImageOrientation)[rep orientation]];
        }
    }];
#pragma clang diagnostic pop
}

- (BOOL)isShowPhoto:(NSDate*)date
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:mcLatestImageisShow]) {
        
        NSDate *date =  [NSDate date];
        int saveNum = [date timeIntervalSince1970];
        [userDefaults setObject:@(abs(saveNum)) forKey:mcLatestImageisShow];
        [userDefaults synchronize];
        return YES;
        
    }else return ([date timeIntervalSince1970] == [[userDefaults objectForKey:mcLatestImageisShow] doubleValue]);
}

- (void)timeAction:(id)sender
{
    [_timer invalidate];
    _timer = nil;
    self.hidden = YES;
}

- (void)isShowLatestImage
{
    if (EGOVersion_iOS8) {
        [self loadLastImageWithPHAsset];
    }else{
        [self loadLastImageWithALAsset];
    }
}

-(void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    if (hidden) {
        return;
    }else{
        [_timer invalidate];
        _timer = nil;
        _timer  = [NSTimer scheduledTimerWithTimeInterval:mcTimerHiddenTime target:self selector:@selector(timeAction:) userInfo:nil repeats:YES];
    }
}


@end
