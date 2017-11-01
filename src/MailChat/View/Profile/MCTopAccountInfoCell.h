//
//  MCTopAccountInfoCell.h
//  NPushMail
//
//  Created by wuwenyu on 16/8/22.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^delAccountBlock)(id account);

@interface MCTopAccountInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatorImgView;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIImageView *currentAccountImgView;
- (void)configureCellWithModel:(id)model;
- (IBAction)deleteAccountAction:(id)sender;
@property(nonatomic, strong) delAccountBlock delAccountBlock;
@end
