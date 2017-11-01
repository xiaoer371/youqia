//
//  MCAddAttachmentViewCell.m
//  NPushMail
//
//  Created by zhang on 15/12/25.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import "MCAddAttachmentViewCell.h"
#import "NSString+imageType.h"

#import "MCTool.h"
@interface MCAddAttachmentViewCell ()

@end

const static CGFloat kMCAddAttachmentViewCellSpace     = 10.0;
const static CGFloat kMCAddAttachmentViewCellLableFont = 11.0f;

@implementation MCAddAttachmentViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height-kMCAddAttachmentViewCellSpace)];
        [self.contentView addSubview:_imageView];
        
        _nameLable = [[UILabel alloc]initWithFrame:CGRectMake(0, self.contentView.frame.size.height - 3*kMCAddAttachmentViewCellSpace, self.contentView.frame.size.width, 2*kMCAddAttachmentViewCellSpace)];
       _nameLable.font = [UIFont systemFontOfSize:kMCAddAttachmentViewCellLableFont];
        _nameLable.backgroundColor = RGBACOLOR(225, 225, 225, 0.3);
        _nameLable.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_nameLable];
        
        _sizeLable = [[UILabel alloc]initWithFrame:CGRectMake(0, self.contentView.frame.size.height - kMCAddAttachmentViewCellSpace, self.contentView.frame.size.width, kMCAddAttachmentViewCellSpace)];
        _sizeLable.font = [UIFont systemFontOfSize:kMCAddAttachmentViewCellLableFont];
        _sizeLable.textAlignment = NSTextAlignmentCenter;
        _sizeLable.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_sizeLable];
    }
    return self;
}

- (void)setMailAttachment:(MCMailAttachment *)mailAttachment{
    
    _mailAttachment = mailAttachment;
    
    if (!mailAttachment.thumbImage) {
        if (mailAttachment.isImage ||
            [[mailAttachment.fileExtension lowercaseString] isEqualToString:@"jpg"]||
            [[mailAttachment.fileExtension lowercaseString] isEqualToString:@"png"]) {
            if (mailAttachment.data) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *image = [UIImage imageWithData:mailAttachment.data scale:0.1];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        mailAttachment.thumbImage = [UIImage getScaleSizeWithImg:image andMaxSize:_imageView.frame.size];
                        _imageView.image = mailAttachment.thumbImage;
                        mailAttachment.isImage = YES;
                    });
                });
            } else {
                _imageView.image = [UIImage imageNamed:[mailAttachment.fileExtension attachmentBigItemImageName]];
            }
        } else {
            _imageView.image = [UIImage imageNamed:[mailAttachment.fileExtension attachmentBigItemImageName]];
        }
    } else {
        _imageView.image = mailAttachment.thumbImage;
    }
    _sizeLable.text = [[MCTool shared] getFileSizeWithLength:(long)mailAttachment.size];
    _nameLable.text = mailAttachment.name;
}

@end
