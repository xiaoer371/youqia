//
//  MCAvatarImageViewHelper.m
//  NPushMail
//
//  Created by wuwenyu on 16/7/12.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAvatarImageViewHelper.h"
#import "UIImageView+WebCache.h"

#define showAler(a) [[[UIAlertView alloc] initWithTitle:nil message:a delegate:nil cancelButtonTitle:PMLocalizedStringWithKey(@"PM_Common_Sure") otherButtonTitles:nil, nil] show]

#define TAG_IMAGE 30
static UIImageView *orginImageView;

@interface MCAvatarImageViewHelper()<UIScrollViewDelegate,UIActionSheetDelegate>

@property (nonatomic,strong)UIScrollView *backScrollView;

@end

@implementation MCAvatarImageViewHelper

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static MCAvatarImageViewHelper *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];      // or some other init method
    });
    return _sharedObject;
}

#pragma mark - UIScrollView
// 返回一个放大或者缩小的视图
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    UIImageView *imageView =(UIImageView*)[scrollView viewWithTag:TAG_IMAGE];
    
    return imageView;
}
// 开始放大或者缩小
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:
(UIView *)view
{
    NSLog(@"scrollViewWillBeginZooming");
}
// 缩放结束时
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    NSLog(@"scrollViewDidEndZooming : %f", scale);
}
// 视图已经放大或缩小
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidZoom");
    
    UIImageView *imageView =(UIImageView*)[scrollView viewWithTag:TAG_IMAGE];
    imageView.frame =CGRectMake(0, 0, ScreenWidth, ScreenHeigth);
    
    //    scrollView.contentSize = CGSizeMake(ScreenWidth, ScreenHeigth);
    
}

#pragma mark - UITapGestureRecognizer
//单击
-(void)handleSingleTapFrom:(id)sender {
}
//双击
-(void)handleDoubleTapFrom:(id)sender {
}

+(void)showImage:(UIImageView*)avatarImageView withBigImgUrl:(NSURL*)bigPicUrl{
    __block UIImage *image=avatarImageView.image;
    orginImageView = avatarImageView;
    orginImageView.alpha = 0;
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    UIView *backgroundView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeigth)];
    CGRect oldframe=[avatarImageView convertRect:avatarImageView.frame toView:window];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha=1;
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:oldframe];
    imageView.image=image;
    imageView.tag=1;
    [backgroundView addSubview:imageView];
    [window addSubview:backgroundView];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer: tap];
    
    UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
    longPressGr.minimumPressDuration = 1.0;
    [backgroundView addGestureRecognizer:longPressGr];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        
        if (image.size.width>0) {
            imageView.frame=CGRectMake(0,(ScreenHeigth-image.size.height*ScreenWidth/image.size.width)/2, ScreenWidth, image.size.height*ScreenWidth/image.size.width);
        }else{
            imageView.frame=CGRectMake(0,(ScreenHeigth-100*ScreenWidth/100)/2, ScreenWidth, 100*ScreenWidth/100);
        }
        backgroundView.alpha=1;
    } completion:^(BOOL finished) {
        if (bigPicUrl) {
            [imageView sd_setImageWithURL:bigPicUrl placeholderImage:image options:SDWebImageAllowInvalidSSLCertificates completed:^(UIImage *image1, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (error || image1==nil) {
                    return ;
                }
                orginImageView.image = image1;
                imageView.image = image1;
                image = image1;
                if (image.size.width>0) {
                    imageView.frame=CGRectMake(0,(ScreenHeigth-image.size.height*ScreenWidth/image.size.width)/2, ScreenWidth, image.size.height*ScreenWidth/image.size.width);
                }else{
                    imageView.frame=CGRectMake(0,(ScreenHeigth-100*ScreenWidth/100)/2, ScreenWidth, 100*ScreenWidth/100);
                }
            }];
        }
    }];
}

+(void)hideImage:(UITapGestureRecognizer*)tap{
    UIView *backgroundView=tap.view;
    UIImageView *imageView=(UIImageView*)[tap.view viewWithTag:1];
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=[orginImageView convertRect:orginImageView.bounds toView:[UIApplication sharedApplication].keyWindow];
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
        orginImageView.alpha = 1;
        backgroundView.alpha=0;
    }];
}

+(void)longPressToDo:(UILongPressGestureRecognizer*)tap
{
    if([tap state] == UIGestureRecognizerStateBegan) {
        //长按事件开始
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        UIActionSheet *actionSheet= [[UIActionSheet alloc] initWithTitle:nil delegate:[self sharedInstance] cancelButtonTitle:PMLocalizedStringWithKey(@"PM_Common_Cancel") destructiveButtonTitle:nil otherButtonTitles:PMLocalizedStringWithKey(@"PM_IMAGE_SaveImageToAlbum"),nil];
        [actionSheet showInView:window];
    }
    
}

#pragma mark - Add Picture
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //保存到相册
        if (orginImageView.image) {
            [self saveImageToPhotos:orginImageView.image];
        }
    }
    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
}
- (void)saveImageToPhotos:(UIImage*)savedImage
{
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}
// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSString *msg = nil ;
    if(error != NULL){
        
        msg = PMLocalizedStringWithKey(@"PM_IMAGE_SaveImageErr");
        
    }else{
        msg = PMLocalizedStringWithKey(@"PM_IMAGE_SaveImageSuc");
    }
    
    showAler(msg);
}

@end
