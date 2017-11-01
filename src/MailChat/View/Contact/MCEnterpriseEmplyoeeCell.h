//
//  MCEnterpriseEmplyoeeCell.h
//  NPushMail
//
//  Created by wuwenyu on 16/3/2.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MCEnterpriseContactCellItem;
@interface MCEnterpriseEmplyoeeCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatorImgView;
@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *remarkLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *displayNameTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatorImgViewLeftConstraint;
+ (instancetype)instanceFromNib;
-(void) configureCellWithEmplyoeeItem:(MCEnterpriseContactCellItem *)item;

@end
