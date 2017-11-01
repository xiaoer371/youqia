//
//  MCEnterpriseBranchCell.h
//  NPushMail
//
//  Created by wuwenyu on 16/3/2.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MCEnterpriseContactCellItem;
@interface MCEnterpriseBranchCell : UITableViewCell
@property (nonatomic, assign) BOOL isSelected;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
+ (instancetype)instanceFromNib;
- (void)changeSelectedState;
- (void)setSelectedStatusWithNO;
- (void)configureCellWithBranchItem:(MCEnterpriseContactCellItem *)item;
/**
 *  主要配置联系人选择时的cell
 *
 *  @param model 目前有MCBranchInfo 和 nsstring类型
 */
- (void)configureCellWithModel:(id)model;
@end
