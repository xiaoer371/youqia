//
//  MCMailAttachListCell.m
//  NPushMail
//
//  Created by zhang on 15/12/25.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import "MCMailAttachListCell.h"
#import "NSString+imageType.h"
#import "FBKVOController.h"
#import "MCTool.h"

const static CGFloat    kMCMailAttachListCellCornerRadius    = 5.0;
const static NSString*  kMCMailAttachListCellUnknowAttachName = @"unknow";

@implementation MCMailAttachListCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    _backgroungView.layer.cornerRadius = kMCMailAttachListCellCornerRadius;
    _backgroungView.backgroundColor = AppStatus.theme.mailStyle.mailAttachCellBackgroundColor;
    self.attachSizeLable.textColor = AppStatus.theme.fontTintColor;
    self.attachNameLable.textColor = AppStatus.theme.titleTextColor;
}

- (void)setMcMailAttachment:(MCMailAttachment *)mcMailAttachment
{
    [self removeObserver];
    _mcMailAttachment = mcMailAttachment;
    _attachSizeLable.text = [[MCTool shared] getFileSizeWithLength:(long)mcMailAttachment.size];
    _attachStateImageView.image = [UIImage imageNamed:mcMailAttachment.isDownload?@"mc_mailDetail_attachShow.png":@"mc_mailDetail_attachDown.png"];
    _attachNameLable.text  = mcMailAttachment.name?mcMailAttachment.name:kMCMailAttachListCellUnknowAttachName;
    _attachImageView.image = [UIImage imageNamed:[mcMailAttachment.fileExtension chatFileItemImageName]];
    [self registeredObserver];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

//private
- (void)removeObserver {
    
    [self.KVOController unobserveAll];
}

- (void)registeredObserver {
    
    __weak typeof(self) weekSelf = self;
    [self.KVOController observe:_mcMailAttachment keyPath:@"isDownload" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        BOOL isDownload = [change[NSKeyValueChangeNewKey] boolValue];
       weekSelf.attachStateImageView.image = [UIImage imageNamed:isDownload?@"mc_mailDetail_attachShow":@"mc_mailDetail_attachDown"];
    }];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.KVOController unobserveAll];
}

@end
