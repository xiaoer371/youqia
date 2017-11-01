//
//  MCIMChatFileBubbleView.m
//  NPushMail
//
//  Created by swhl on 16/2/23.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMChatFileBubbleView.h"
#import "NSString+ImageType.h"
#import "NSString+Extension.h"
#import <KVOController/FBKVOController.h>

NSString *const kRouterEventFileBubbleTapEventName = @"kRouterEventFileBubbleTapEventName";

const static NSInteger   MCPaddingX = 8;
const static NSInteger   MCFileImageSize = 40;
const static CGFloat     mcImagePadding  = 9.0f;


@interface MCIMChatFileBubbleView ()

@property (nonatomic, strong ) UIImageView *imageView;  //文件格式imageview
@property (nonatomic, strong ) UILabel     *titleLabel; //文件标题
@property (nonatomic, strong ) UILabel     *sizeLabel;  //文件大小
@property (nonatomic, strong ) UILabel     *loadState;  //文件下载状态

@end

@implementation MCIMChatFileBubbleView

- (id)initWithFrame:(CGRect)frame
{
    
    CGRect rect = CGRectMake(0, 0, 200, 70);
    self =[super initWithFrame:rect];
    if (self) {

        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(mcImagePadding, 15, MCFileImageSize, MCFileImageSize)];
        _imageView.backgroundColor = [UIColor orangeColor];
        [self addSubview:_imageView];
        
        CGFloat originX = CGRectGetMaxX(_imageView.frame);
        CGFloat originY = CGRectGetMinY(_imageView.frame);
        _titleLabel =[[UILabel alloc] initWithFrame:CGRectMake(originX+9, originY,0 /*120*/,0 /*40*/)];
        _titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _titleLabel.numberOfLines = 2;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self addSubview:_titleLabel];
        
        _sizeLabel =[[UILabel alloc] initWithFrame:CGRectMake(originX+9, 50, 120, 15)];
        _sizeLabel.font =[UIFont systemFontOfSize:10.0f];
        _sizeLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:_sizeLabel];
        
        _loadState =[[UILabel alloc] initWithFrame:CGRectMake(150, 50, 40, 15)];
        _loadState.font =[UIFont systemFontOfSize:10.0f];
        _loadState.textColor = [UIColor lightGrayColor]; //[UIColor colorWithHexString:@"cccccc"];
        [self addSubview:_loadState];
        
        [self.backImageView setFrame:self.bounds];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
}

#pragma mark - setter

- (void)setModel:(MCIMFileModel *)model
{
    [self.KVOController unobserveAll];
    
    [super setModel:model];
    
    self.titleLabel.text = model.name;
    self.imageView.image =[UIImage imageNamed:[model.name attachmentBigItemImageName]];
    self.sizeLabel.text = [model.name sizeWithfloat:model.size];
    if (model.downloadState == IMFileDownloaded) {
        self.loadState.text = PMLocalizedStringWithKey(@"PM_Mail_MailAttchmentPreview");
    }else{
        self.loadState.text = PMLocalizedStringWithKey(@"PM_Mail_MailAttDownload");
    }
    
    __weak typeof(self) weakSelf = self;
    [self.KVOController observe:self.model keyPath:@"downloadState" options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
          MCIMFileModel*fileModel = (MCIMFileModel *)weakSelf.model;
          if (fileModel.downloadState == IMFileDownloaded) {
              self.loadState.text = PMLocalizedStringWithKey(@"PM_Mail_MailAttchmentPreview");
          }else{
              self.loadState.text = PMLocalizedStringWithKey(@"PM_Mail_MailAttDownload");
          }
      }];
    [self  reSetSubViewsFrame];
}

- (void)reSetSubViewsFrame{
    MCIMFileModel * fileModel = (MCIMFileModel * )self.model;
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:14.0f],NSFontAttributeName, nil];
    CGSize size = [fileModel.name boundingRectWithSize:CGSizeMake(120, 40) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    
    if(self.model.isSender){
        
        CGRect rectTitleLab = _titleLabel.frame;
        rectTitleLab.size = size;
        _titleLabel.frame = rectTitleLab;
        
    }else{
        CGRect rectImgView = _imageView.frame;
        rectImgView.origin.x = mcImagePadding + MCPaddingX;
        _imageView.frame = rectImgView;
        
        
        CGRect rectTitleLab = _titleLabel.frame;
        rectTitleLab.origin.x = mcImagePadding +MCFileImageSize + 9 + MCPaddingX;
        rectTitleLab.size = size;
        _titleLabel.frame = rectTitleLab;
        
        CGRect rectSize = _sizeLabel.frame;
        rectSize.origin.x = mcImagePadding +MCFileImageSize + 9  + MCPaddingX;
        _sizeLabel.frame = rectSize;
        
        CGRect rectLoadState = _loadState.frame;
        rectLoadState.origin.x = 150 + MCPaddingX;
        _loadState.frame = rectLoadState;
        
    }
}



#pragma mark - public

-(void)bubbleViewPressed:(id)sender
{
    [self routerEventWithName:kRouterEventFileBubbleTapEventName userInfo:@{KMESSAGEKEY:self.model}];
}

+(CGFloat)heightForBubbleWithObject:(MCIMMessageModel *)object
{
    CGFloat height = object.isSender?0:20;
    return 80+height;
}

@end
