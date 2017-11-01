//
//  MCAttachDownloadView.m
//  NPushMail
//
//  Created by zhang on 16/3/28.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAttachDownloadView.h"
#import "NSString+ImageType.h"
#import "MCTool.h"
#import "MCProgressView.h"

@interface MCAttachDownloadView ()

@property (nonatomic,strong) UIImageView *itemImageview;
@property (nonatomic,strong) UIView      *progressView;
@property (nonatomic,strong) UILabel     *infoLabel;
@property (nonatomic,strong) UILabel     *nameLabel;
@property (nonatomic,strong) MCProgressView *mcProgressView;
@property (nonatomic) MCDownloadFiletype  type;

@end

const CGFloat kMCAttachDownloadViewImageViewWidth = 75.0;
const CGFloat kMCAttachDownloadViewNameLabelWidth = 200.0;
const CGFloat kMCAttachDownloadViewNameLabelHight = 40.0;
const CGFloat kMCAttachDownloadViewNameLabelFont  = 15.0;
const CGFloat kMCAttachDownloadViewProgressViewWidth = 196.0;

CG_INLINE CGPoint
CGPointSetY (CGPoint point, CGFloat y ){
    point.y = y;
    return point;
}


@implementation MCAttachDownloadView

- (instancetype)initWithType:(MCDownloadFiletype)type withFileModel:(id)fileModel
{
    self = [super init];
    if (self) {
        self.type = type;
        self.fileModel = fileModel;
        [self setUp];
    }
    return self;
}

//setup
- (void)setUp
{
    
    self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeigth - NAVIGATIONBARHIGHT);
    _itemImageview = [[UIImageView alloc]initWithFrame:CGRectMake((ScreenWidth- kMCAttachDownloadViewImageViewWidth)/2, 85, kMCAttachDownloadViewImageViewWidth, kMCAttachDownloadViewImageViewWidth)];
    
    _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth - kMCAttachDownloadViewNameLabelWidth)/2, _itemImageview.frame.origin.y + _itemImageview.frame.size.height + 27, kMCAttachDownloadViewNameLabelWidth, kMCAttachDownloadViewNameLabelHight)];
    _nameLabel.font = [UIFont systemFontOfSize:kMCAttachDownloadViewNameLabelFont];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.numberOfLines = 2;
    _nameLabel.textColor = AppStatus.theme.titleTextColor;

    _mcProgressView = [[MCProgressView alloc]initWithFrame:CGRectMake((ScreenWidth - kMCAttachDownloadViewProgressViewWidth - 12 - 26)/2, _nameLabel.frame.origin.y + _nameLabel.frame.size.height + 33, kMCAttachDownloadViewProgressViewWidth, 5)];
    _mcProgressView.trackColor = [UIColor colorWithHexString:@"e5e5e5"];
    _mcProgressView.progressColor = [UIColor colorWithHexString:@"569af1"];
    _mcProgressView.progressWidth = CGRectGetHeight(_mcProgressView.frame);
    _mcProgressView.backgroundColor = [UIColor redColor];
    
    
    
    UIButton*cancelDownLoad = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelDownLoad.frame = CGRectMake(CGRectGetMaxX(_mcProgressView.frame) + 12, _mcProgressView.frame.origin.y, 26, 26);
    cancelDownLoad.center = CGPointSetY(cancelDownLoad.center,_mcProgressView.center.y);
    [cancelDownLoad setImage:[UIImage imageNamed:@"mc_attachCancelDownload.png"] forState:UIControlStateNormal];
    [cancelDownLoad addTarget:self action:@selector(cancelAttachmentDownload:) forControlEvents:UIControlEventTouchUpInside];
    
    _infoLabel = [[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth - kMCAttachDownloadViewNameLabelWidth)/2, _mcProgressView.frame.origin.y + _mcProgressView.frame.size.height + 29, kMCAttachDownloadViewNameLabelWidth, 15)];
    _infoLabel.font = [UIFont systemFontOfSize:13.0f];
    _infoLabel.textAlignment = NSTextAlignmentCenter;
    _infoLabel.textColor = [UIColor colorWithHexString:@"777777"];
    [self addSubview:_itemImageview];
    [self addSubview:_nameLabel];
    [self addSubview:_mcProgressView];
    [self addSubview:cancelDownLoad];
    [self addSubview:_infoLabel];
    
    if (self.type ==MCDownloadFiletypeFromEmail) {
       MCMailAttachment *mailAttachment = (MCMailAttachment*)self.fileModel;
        _itemImageview.image = [UIImage imageNamed:[mailAttachment.fileExtension attachmentBigItemImageName]];
        _nameLabel.text = mailAttachment.name;
        self.progress = 0.0;
    }else
    {
        MCIMFileModel *fileModel = (MCIMFileModel*)self.fileModel;
        _itemImageview.image = [UIImage imageNamed:[fileModel.name attachmentBigItemImageName]];
        _nameLabel.text = fileModel.name;
        self.progress = 0.0;
    }
    
}

//cancel download callback
- (void)cancelAttachmentDownload:(id)sender {
    if (_cancelDownloadAttachment) {
        _cancelDownloadAttachment();
    }
}

- (void)setProgress:(CGFloat)progress {
    
    if (self.type ==MCDownloadFiletypeFromEmail) {
        MCMailAttachment *mailAttachment = (MCMailAttachment*)self.fileModel;
        if (!mailAttachment.size | (mailAttachment.size == 0)) {
            return;
        }
        _mcProgressView.progress = progress;
        _infoLabel.text = [NSString stringWithFormat:PMLocalizedStringWithKey(@"PM_FilePreview_Downloading"),[[MCTool shared] getFileSizeWithLength:progress*mailAttachment.size],[[MCTool shared] getFileSizeWithLength:mailAttachment.size]];
    } else {
        MCIMFileModel *fileModel = (MCIMFileModel*)self.fileModel;
        if (fileModel.size == 0) {
            return;
        }
        CGFloat p = progress/(CGFloat)fileModel.size;
        _mcProgressView.progress = p;
        _infoLabel.text = [NSString stringWithFormat:PMLocalizedStringWithKey(@"PM_FilePreview_Downloading"),[[MCTool shared] getFileSizeWithLength:progress],[[MCTool shared] getFileSizeWithLength:fileModel.size]];
    }
    
}

@end
