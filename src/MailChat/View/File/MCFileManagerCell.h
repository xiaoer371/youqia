//
//  MCFileManagerCell.h
//  NPushMail
//
//  Created by wuwenyu on 16/3/14.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCFileManagerCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *fileIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileReciveTimeLabel;
//选中状态
@property (nonatomic,assign) BOOL          isSelected;
@property (nonatomic,strong) UIImageView    *selectedIndicator;
- (void)changeSelectedState;
+ (instancetype)instanceFromNib;
- (void)configureCellWithModel:(id)model;

@end
