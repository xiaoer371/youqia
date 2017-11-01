//
//  HZPhotoBrowser.h
//  photobrowser
//
//  Created by aier on 15-2-3.
//  Copyright (c) 2015年 aier. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    BrowserTypeDefault = 0,
    BrowserTypeDelete,
    BrowserTypeSend,
    BrowserTypeOther,
} BrowserType;

@class HZButton, HZPhotoBrowser;

@protocol HZPhotoBrowserDelegate <NSObject>

@required

- (UIImage *)photoBrowser:(HZPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index;

/**
 *  如果调用- (void)deleteItem; 必须实现此代理
 */
- (BOOL)photoBrowser:(HZPhotoBrowser *)browser deleteImageForIndex:(NSInteger)index;

@optional

- (NSURL *)photoBrowser:(HZPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index;


- (void)photoBrowser:(HZPhotoBrowser *)browser;

/**
 *  单击图片操作
 */
- (void)didSelectPhoto:(HZPhotoBrowser *)browser;

@end


@interface HZPhotoBrowser : UIView <UIScrollViewDelegate>

@property (nonatomic, weak)   UIView *sourceImagesContainerView;
@property (nonatomic, assign) NSInteger currentImageIndex;
@property (nonatomic, assign) NSInteger imageCount;
@property (nonatomic, assign) BOOL firstShowStatic;
@property (nonatomic, assign) BrowserType browserType;
@property (nonatomic, assign) BOOL isFullImage;
@property (nonatomic, assign) NSUInteger fullImageSize;
@property (nonatomic, weak) id<HZPhotoBrowserDelegate> delegate;

- (void)show;

/**
 *  如果调用 -(void)deleteItem; 必须实现此代理
 */
- (void)deleteItem;



@end
