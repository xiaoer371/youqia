//
//  MCContactGroupCell.h
//  NPushMail
//
//  Created by wuwenyu on 16/1/5.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCContactGroupCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *groupAvatorImgView;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
+ (instancetype)instanceFromNib;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *arrorRightConstraint;
- (void)configureCellWithModel:(id)model;
@end
