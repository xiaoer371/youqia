//
//  MCAddAtttachmentCell.h
//  NPushMail
//
//  Created by zhang on 16/8/17.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCMailAttachment.h"
#import "UIImage+Utility.h"

typedef void(^deleteAttachComplete) (MCMailAttachment *attach);

@interface MCAddAtttachmentCell : UICollectionViewCell
@property (nonatomic,strong) MCMailAttachment *attachment;
@property (nonatomic,weak) IBOutlet UIView *mcBackgroundView;
@property (nonatomic,weak) IBOutlet UIImageView *mcAttachImageView;
@property (nonatomic,weak) IBOutlet UIView *mcSizeBGView;
@property (nonatomic,weak) IBOutlet UILabel *mcAttachSizeLabel;
@property (nonatomic,weak) IBOutlet UILabel *mcAttachNameLabel;
@property (nonatomic,copy) deleteAttachComplete mcDeleteAttachComplete;

@end
