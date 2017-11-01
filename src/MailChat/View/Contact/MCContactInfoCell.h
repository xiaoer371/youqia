//
//  MCContactInfoCell.h
//  NPushMail
//
//  Created by wuwenyu on 16/2/17.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCContactInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIImageView *enterpriseIconImageView;
+ (instancetype)instanceFromNib;
- (IBAction)valueClickAction:(id)sender;
- (void)configureCellWithModel:(id)model indexPath:(NSIndexPath *)index phones:(NSMutableArray *)phones enterpriseInfos:(NSMutableArray *)enterpriseInfos;
@end
