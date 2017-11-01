//
//  MCAddAttachmentViewCell.h
//  NPushMail
//
//  Created by zhang on 15/12/25.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCMailAttachment.h"
#import "UIImage+Utility.h"
@interface MCAddAttachmentViewCell : UICollectionViewCell

@property (nonatomic,strong)MCMailAttachment  *mailAttachment;
@property (nonatomic,strong)UIImageView       *imageView;
@property (nonatomic,strong)UILabel           *nameLable;
@property (nonatomic,strong)UILabel           *sizeLable;

@end
