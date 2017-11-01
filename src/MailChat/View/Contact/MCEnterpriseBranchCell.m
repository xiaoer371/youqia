//
//  MCEnterpriseBranchCell.m
//  NPushMail
//
//  Created by wuwenyu on 16/3/2.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCEnterpriseBranchCell.h"
#import "MCEnterpriseContactCellItem.h"
#import "MCBranchInfo.h"
#import "UIView+MJExtension.h"
#import "MCContactModel.h"
#import "MCGroup.h"

static const CGFloat nameLabelOffsetX = 14;
static const CGFloat countLabelWidth = 40;
const static CGFloat kMCMailListCellSelectedIndicatorSize = 24;

@implementation MCEnterpriseBranchCell {
    UIImageView *_selectedIndicator;
    id _model;
}

+ (instancetype)instanceFromNib
{
    return [[[NSBundle mainBundle]loadNibNamed:@"MCEnterpriseBranchCell" owner:nil options:nil]lastObject];
}

- (void)awakeFromNib {
    // Initialization code
    [self reset];
}

-(void)reset {
    self.contentView.frame = CGRectMake(0, 0, ScreenWidth, 44);
    self.clipsToBounds = YES;
    self.countLabel.textColor = AppStatus.theme.fontTintColor;
    _isSelected = NO;
    CGRect indicatorFrame = CGRectMake(- kMCMailListCellSelectedIndicatorSize, fabs(self.frame.size.height - kMCMailListCellSelectedIndicatorSize)/ 2, kMCMailListCellSelectedIndicatorSize, kMCMailListCellSelectedIndicatorSize);
    _selectedIndicator = [[UIImageView alloc] initWithFrame:indicatorFrame];
    _selectedIndicator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.contentView addSubview:_selectedIndicator];
}

-(void)configureCellWithBranchItem:(MCEnterpriseContactCellItem *)item {
    self.separatorInset = UIEdgeInsetsMake(self.separatorInset.top, 0, self.separatorInset.bottom, self.separatorInset.right);
    if (item.isOpen) {
        //展开的状态，则不显示分割线
        self.separatorInset = UIEdgeInsetsMake(self.separatorInset.top, CGRectGetWidth(self.contentView.frame), self.separatorInset.bottom, self.separatorInset.right);
    }
    self.nameLabel.text = item.branchInfo.name;
    self.countLabel.textAlignment = NSTextAlignmentRight;
    self.countLabel.frame = CGRectMake(ScreenWidth - 12 - countLabelWidth, self.countLabel.frame.origin.y, countLabelWidth, 21);
    self.countLabel.textColor = AppStatus.theme.fontTintColor;
    if (item.size) {
        int emplyoeeCount = item.size;
        if (emplyoeeCount > 0) {
            self.countLabel.text = [NSString stringWithFormat:@"%d", emplyoeeCount];
        }
    }else {
        self.countLabel.text = @"";
    }
    if (item.isOpen) {
        self.arrowImgView.image = [UIImage imageNamed:@"enterpriseArrowDown.png"];
    }else {
        self.arrowImgView.image = [UIImage imageNamed:@"enterpriseArrowNormal.png"];
    }
    self.arrowImgView.mj_x = item.branchItemOriginX;
    self.nameLabel.mj_x = CGRectGetMaxX(self.arrowImgView.frame) + nameLabelOffsetX;
    self.nameLabel.mj_w = CGRectGetMinX(self.countLabel.frame) - CGRectGetMinX(self.nameLabel.frame);
}

- (void)configureCellWithModel:(id)model {
    _model = model;
    self.separatorInset = UIEdgeInsetsMake(self.separatorInset.top, 0, self.separatorInset.bottom, self.separatorInset.right);
    if (model) {
        self.countLabel.hidden = YES;
        self.arrowImgView.hidden = YES;
        self.nameLabel.mj_x = 12;
        
        if ([model isMemberOfClass:[MCEnterpriseContactCellItem class]]) {
            MCEnterpriseContactCellItem *info = model;
            self.nameLabel.text = info.branchInfo.name;
        }
        if ([model isMemberOfClass:[MCGroup class]]) {
            MCGroup *info = model;
            self.nameLabel.text = info.name;
            _isSelected = info.isSelected;
            if (_isSelected){
                [_selectedIndicator setImage:AppStatus.theme.selectStateImage];
                
            } else {
                [_selectedIndicator setImage:AppStatus.theme.unselectStateImage];
            }
        }
    }
}

- (void)changeSelectedState {
    _isSelected = !_isSelected;
    if ([_model isMemberOfClass:[MCGroup class]]) {
        MCGroup *info = _model;
        info.isSelected = _isSelected;
        [self setNeedsLayout];
    }
}

- (void)setSelectedStatusWithNO {
    _isSelected = NO;
    if ([_model isMemberOfClass:[MCGroup class]]) {
        MCGroup *info = _model;
        info.isSelected = _isSelected;
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    if (_isSelected){
//        if (((UITableView *)self.superview).isEditing){
//            self.backgroundView.backgroundColor = [UIColor colorWithRed:223.0/255.0 green:230.0/255.0 blue:250.0/255.0 alpha:1.0];
//        } else {
//            self.backgroundView.backgroundColor = [UIColor whiteColor];
//        }
        self.backgroundColor = [UIColor whiteColor];
        self.textLabel.textColor = AppStatus.theme.fontTintColor;
        [_selectedIndicator setImage:AppStatus.theme.selectStateImage];
        
    } else {
        self.backgroundColor = [UIColor whiteColor];
        self.textLabel.textColor = AppStatus.theme.fontTintColor;
        [_selectedIndicator setImage:AppStatus.theme.unselectStateImage];
    }
    [UIView commitAnimations];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
