//
//  MCMailAttachListCell.h
//  NPushMail
//
//  Created by zhang on 15/12/25.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCMailAttachment.h"

@interface MCMailAttachListCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIImageView *attachImageView;
@property (weak, nonatomic) IBOutlet UILabel     *attachNameLable;
@property (weak, nonatomic) IBOutlet UILabel     *attachSizeLable;
@property (weak, nonatomic) IBOutlet UIView      *backgroungView;
@property (weak, nonatomic) IBOutlet UIImageView *attachStateImageView;


@property (nonatomic,strong)MCMailAttachment     *mcMailAttachment;

@end
