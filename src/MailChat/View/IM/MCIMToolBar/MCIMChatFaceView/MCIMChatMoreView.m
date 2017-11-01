//
//  MCIMChatMoreView.m
//  NPushMail
//
//  Created by swhl on 16/3/29.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMChatMoreView.h"

static const CGFloat MCSubViewOriginY = 12;
static const CGFloat MCImageViewSize  = 59.0f;

@interface MCIMChatMoreView ()

@end

@implementation MCIMChatMoreView


- (instancetype)initWithFrame:(CGRect)frame isHelperAccount:(BOOL)isHelperAccount
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initSubView:isHelperAccount];
    }
    return self;
}

-(void)_initSubView:(BOOL)isHelperAccount
{
    self.backgroundColor = AppStatus.theme.chatStyle.moreViewBackGroundColor;
    
    NSUInteger num = isHelperAccount?4:3;
    
    CGFloat paddingX = (ScreenWidth - num*MCImageViewSize)/(num+1);
    
//    photo
    UIImageView *photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(paddingX, MCSubViewOriginY, MCImageViewSize, MCImageViewSize)];
    photoImageView.image =AppStatus.theme.chatStyle.morePhothImage;
    [self addSubview:photoImageView];
    
    UIButton *photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    photoBtn.frame =photoImageView.frame;
    [photoBtn addTarget:self action:@selector(phontBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    photoBtn.backgroundColor = [UIColor clearColor];
    [self addSubview:photoBtn];
    
    CGFloat labY = CGRectGetMaxY(photoBtn.frame);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(paddingX, labY, 60, 20)];
    label.text = PMLocalizedStringWithKey(@"PM_IMChat_MoreViewPhoto");
    label.font = [UIFont systemFontOfSize:12.0f];
    label.textColor =[UIColor colorWithHexString:@"#8a8a8a"];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];

//    拍照
    CGFloat takePhotoX = CGRectGetMaxX(photoImageView.frame)+paddingX;
    UIImageView *takePhotoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(takePhotoX, MCSubViewOriginY, MCImageViewSize, MCImageViewSize)];
    takePhotoImageView.image = AppStatus.theme.chatStyle.moreTakeImage;
    [self addSubview:takePhotoImageView];
    
    UIButton *takePhBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    takePhBtn.frame =takePhotoImageView.frame;
    [takePhBtn addTarget:self action:@selector(takePhotesAction:) forControlEvents:UIControlEventTouchUpInside];
    takePhBtn.backgroundColor = [UIColor clearColor];
    [self addSubview:takePhBtn];
    
    CGFloat lab2Y = CGRectGetMaxY(photoImageView.frame);
    UILabel *label2 =[[UILabel alloc] initWithFrame:CGRectMake(takePhotoX, lab2Y, 60, 20)];
    label2.text = PMLocalizedStringWithKey(@"PM_Login_TakePhoto");
    label2.font = [UIFont systemFontOfSize:12.0f];
    label2.textColor =[UIColor colorWithHexString:@"#8a8a8a"];
    label2.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label2];
    
//    文件
    CGFloat fileX = CGRectGetMaxX(takePhotoImageView.frame)+paddingX;
    UIImageView *fileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(fileX, MCSubViewOriginY, MCImageViewSize, MCImageViewSize)];
    fileImageView.image =AppStatus.theme.chatStyle.moreFileImage;
    [self addSubview:fileImageView];
    
    UIButton *fileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    fileBtn.frame =fileImageView.frame;
    [fileBtn addTarget:self action:@selector(fileAction:) forControlEvents:UIControlEventTouchUpInside];
    fileBtn.backgroundColor = [UIColor clearColor];
    [self addSubview:fileBtn];
    
    CGFloat fileY = CGRectGetMaxY(fileImageView.frame);
    UILabel *label3 =[[UILabel alloc] initWithFrame:CGRectMake(fileX, fileY, 60, 20)];
    label3.text = PMLocalizedStringWithKey(@"PM_IMChat_MoreViewFile");
    label3.font = [UIFont systemFontOfSize:12.0f];
    label3.textColor =[UIColor colorWithHexString:@"#8a8a8a"];
    label3.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label3];
    
    //小助手新增 一键日志
    if (isHelperAccount) {
        CGFloat logX = CGRectGetMaxX(fileImageView.frame)+paddingX;
        UIImageView *logImageView = [[UIImageView alloc] initWithFrame:CGRectMake(logX, MCSubViewOriginY, MCImageViewSize, MCImageViewSize)];
        logImageView.image =AppStatus.theme.chatStyle.moreFileImage;
        [self addSubview:logImageView];
        
        UIButton *logBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        logBtn.frame =logImageView.frame;
        [logBtn addTarget:self action:@selector(logAction:) forControlEvents:UIControlEventTouchUpInside];
        logBtn.backgroundColor = [UIColor clearColor];
        [self addSubview:logBtn];
        
        CGFloat logY = CGRectGetMaxY(logImageView.frame);
        UILabel *label4 =[[UILabel alloc] initWithFrame:CGRectMake(logX, logY, 60 , 20)];
        label4.text = PMLocalizedStringWithKey(@"PM_IMChat_sendHelpLog");
        label4.font = [UIFont systemFontOfSize:12.0f];
        label4.textColor =[UIColor colorWithHexString:@"#8a8a8a"];
        label4.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label4];
    }
}

- (void)phontBtnAction:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectPhotos)]) {
        [self.delegate didSelectPhotos];
    }
}

- (void)takePhotesAction:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectTakePhotos)]) {
        [self.delegate didSelectTakePhotos];
    }
}

- (void)fileAction:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectFile)]) {
        [self.delegate didSelectFile];
    }
}
- (void)logAction:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSendLogFileToHelper)]) {
        [self.delegate didSendLogFileToHelper];
    }
}

@end
