//
//  MCIMChatImageBubbleView.m
//  NPushMail
//
//  Created by swhl on 16/2/23.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMChatImageBubbleView.h"
#import "UIImageView+WebCache.h"

NSString *const kRouterEventImageBubbleTapEventName = @"kRouterEventImageBubbleTapEventName";

static const CGFloat mcMinImageSizeWidth   = 60.0f;  // 设置图片最小显示高度
static const CGFloat mcMinImageSizeHeight  = 60.0f;  // 设置图片最小显示宽度

@interface MCIMChatImageBubbleView ()

@end

@implementation MCIMChatImageBubbleView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_imageView];
    }
    
    return self;
}

//- (CGSize)sizeThatFits:(CGSize)size
//{
//    MCIMImageModel *imageModel = (MCIMImageModel *)self.model;
//    CGSize retSize = imageModel.imageSize;
//    if (retSize.width == 0 || retSize.height == 0) {
//        retSize.width = MAX_SIZE;
//        retSize.height = MAX_SIZE;
//    }
//    if (retSize.width > retSize.height) {
//        CGFloat height =  MAX_SIZE / retSize.width  *  retSize.height;
//        retSize.height = height;
//        retSize.width = MAX_SIZE;
//    }else {
//        CGFloat width = MAX_SIZE / retSize.height * retSize.width;
//        retSize.width = width;
//        retSize.height = MAX_SIZE;
//    }
//    return CGSizeMake(retSize.width + BUBBLE_VIEW_PADDING * 2 + BUBBLE_ARROW_WIDTH, 2 * BUBBLE_VIEW_PADDING + retSize.height);
//}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    frame.size.width -= (2*BUBBLE_VIEW_PADDINGX+3);
    frame.size.height -= 2*BUBBLE_VIEW_PADDING;
    if (self.model.isSender) {
        frame.origin.x = 5;
    }else{
        frame.origin.x = 12;
    }
    
    frame.origin.y = BUBBLE_VIEW_PADDING;
    [self.imageView setFrame:frame];
}

#pragma mark - setter

- (void)setModel:(MCIMMessageModel *)model
{
    [super setModel:model];
    
    MCIMImageModel *imageModel = (MCIMImageModel *)model;
    
    NSURL *localUrl = [NSURL URLWithString:imageModel.localPath];
    if ([[SDWebImageManager sharedManager] cachedImageExistsForURL:localUrl]){
        [self.imageView sd_setImageWithURL:localUrl placeholderImage:[UIImage imageNamed:@"mc_chat_placeholder.png"]];
    }
    else{
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageModel.thumbnailPath] placeholderImage:[UIImage imageNamed:@"mc_chat_placeholder.png"] options:SDWebImageAllowInvalidSSLCertificates completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                imageModel.thumbnailImg = image;
            }
        }];
    }
    
    [self reSetSubViewsFrame];
    
}

- (void)reSetSubViewsFrame
{
    MCIMImageModel *imageModel = (MCIMImageModel *)self.model;
    CGSize retSize = imageModel.imageSize;
    
    if (retSize.width == 0 || retSize.height == 0) {
        retSize.width = MAX_SIZE;
        retSize.height = MAX_SIZE;
    }
    
    if (retSize.width > retSize.height) {
        CGFloat height =  MAX_SIZE / retSize.width  *  retSize.height;
        retSize.height = MAX(height, mcMinImageSizeHeight);
        retSize.width = MAX_SIZE;
    }else {
        CGFloat width = MAX_SIZE / retSize.height * retSize.width;
        retSize.width = MAX(width, mcMinImageSizeWidth);
        retSize.height = MAX_SIZE;
    }
    
    CGFloat s_width = retSize.width + BUBBLE_VIEW_PADDING * 2 + BUBBLE_ARROW_WIDTH;
    CGFloat s_height = 2 * BUBBLE_VIEW_PADDING + retSize.height;

    self.mc_size = CGSizeMake(s_width,s_height);
    
}
#pragma mark - public

-(void)bubbleViewPressed:(id)sender
{
    [self routerEventWithName:kRouterEventImageBubbleTapEventName
                     userInfo:@{KMESSAGEKEY:self.model,@"imgView":self.imageView}];
}

+(CGFloat)heightForBubbleWithObject:(MCIMMessageModel *)object
{
    MCIMImageModel *imageModel = (MCIMImageModel *)object;
    CGSize retSize = imageModel.imageSize;
    if (retSize.width == 0 || retSize.height == 0) {
        retSize.width = MAX_SIZE;
        retSize.height = MAX_SIZE;
    }else if (retSize.width > retSize.height) {
        CGFloat height =  MAX_SIZE / retSize.width  *  retSize.height;
        retSize.height = MAX(mcMinImageSizeHeight, height);
        retSize.width = MAX_SIZE;
    }else {
        CGFloat width = MAX_SIZE / retSize.height * retSize.width;
        retSize.width = MAX(mcMinImageSizeWidth, width);
        retSize.height = MAX_SIZE;
    }
    CGFloat height = object.isSender?0:20;
    return 2 * BUBBLE_VIEW_PADDING + retSize.height +10+height;
}

@end
