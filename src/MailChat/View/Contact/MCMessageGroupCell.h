//
//  MCMessageGroupCell.h
//  NPushMail
//
//  Created by wuwenyu on 16/7/12.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCMessageGroupCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatorImgView;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
+ (instancetype)instanceFromNib;
- (void)configureCellWithModel:(id)model;

@end
