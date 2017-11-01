//
//  MCAddAtttachmentCell.m
//  NPushMail
//
//  Created by zhang on 16/8/17.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAddAtttachmentCell.h"
#import "NSString+imageType.h"
#import "MCTool.h"
@implementation MCAddAtttachmentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _mcBackgroundView.layer.cornerRadius = 5.0;
//    _mcBackgroundView.layer.borderWidth = 0.5;
//    _mcBackgroundView.layer.borderColor =  AppStatus.theme.toolBarSeparatorColor.CGColor;
    _mcBackgroundView.clipsToBounds = YES;
    _mcAttachNameLabel.textColor = [UIColor colorWithHexString:@"808080"];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, CGRectGetWidth(_mcSizeBGView.frame) + 30, CGRectGetHeight(_mcSizeBGView.frame));
    UIColor *color1 = [UIColor colorWithHexString:@"7f7f7f" alpha:1.0];
    UIColor *color2 = [UIColor colorWithHexString:@"7f7f7f" alpha:0.5];
    UIColor *color3 = [UIColor colorWithHexString:@"7f7f7f" alpha:0.0];
    gradient.colors =   @[(id)color3.CGColor,(id)color2.CGColor,(id)color1.CGColor];
    [_mcSizeBGView.layer addSublayer:gradient];
}

- (void)setAttachment:(MCMailAttachment *)attachment {
    _attachment = attachment;
    if (!attachment.thumbImage) {
        if (attachment.isImage | [[attachment.fileExtension lowercaseString] isEqualToString:@"jpg"]|[[attachment.fileExtension lowercaseString] isEqualToString:@"png"]) {
            if (attachment.data) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *image = [UIImage imageWithData:attachment.data scale:0.1];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        attachment.thumbImage = [UIImage getScaleSizeWithImg:image andMaxSize:_mcAttachImageView.frame.size];
                        _mcAttachImageView.image = attachment.thumbImage;
                        attachment.isImage = YES;
                    });
                });
            } else {
                _mcAttachImageView.image = [UIImage imageNamed:[attachment.fileExtension attachmentBigItemImageName]];
            }
        } else {
            _mcAttachImageView.image = [UIImage imageNamed:[attachment.fileExtension attachmentBigItemImageName]];
        }
    } else {
        _mcAttachImageView.image = attachment.thumbImage;
       
    }
    _mcAttachSizeLabel.text = [[MCTool shared] getFileSizeWithLength:(long)attachment.size];
    _mcAttachNameLabel.text = attachment.name;
}
- (IBAction)toDeleteAttach:(UIButton *)sender {
    
    if (_mcDeleteAttachComplete) {
        _mcDeleteAttachComplete (_attachment);
    }
}

@end
