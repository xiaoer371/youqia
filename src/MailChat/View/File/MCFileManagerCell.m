//
//  MCFileManagerCell.m
//  NPushMail
//
//  Created by wuwenyu on 16/3/14.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCFileManagerCell.h"
#import "MCFileBaseModel.h"
#import "MCFileCore.h"
#import "MCTool.h"
#import "NSDate+Category.h"

const static CGFloat kMCMailListCellSelectedIndicatorSize = 24;

@implementation MCFileManagerCell {
    MCFileBaseModel *_fileModel;
}

+ (instancetype)instanceFromNib {
    return [[[NSBundle mainBundle]loadNibNamed:@"MCFileManagerCell" owner:nil options:nil]lastObject];
}

- (void)awakeFromNib {
    // Initialization code
    [self reset];
}

- (void)reset {
    _isSelected = NO;
    CGRect indicatorFrame = CGRectMake(- kMCMailListCellSelectedIndicatorSize, fabs(self.frame.size.height - kMCMailListCellSelectedIndicatorSize)/ 2, kMCMailListCellSelectedIndicatorSize, kMCMailListCellSelectedIndicatorSize);
    _selectedIndicator = [[UIImageView alloc] initWithFrame:indicatorFrame];
    _selectedIndicator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin| UIViewAutoresizingFlexibleTopMargin;
    [self.contentView addSubview:_selectedIndicator];
}

- (void)configureCellWithModel:(id)model {
    if ([model isMemberOfClass:[MCFileBaseModel class]]) {
        _fileModel = (MCFileBaseModel *)model;
        _isSelected = _fileModel.isSelected;
        if (_isSelected){
            [_selectedIndicator setImage:AppStatus.theme.selectStateImage];
            
        } else {
            [_selectedIndicator setImage:AppStatus.theme.unselectStateImage];
        }
        
        self.fileNameLabel.text = _fileModel.displayName;
        self.fileIconImageView.image = [[MCTool shared] fileImageIconWithFileName:_fileModel.displayName];
        self.fileSizeLabel.textColor = [[[MCThemeManager sharedManager] theme] fontTintColor];
        self.fileSizeLabel.text = [[MCTool shared] getFileSizeWithLength:_fileModel.size];
        self.fileReciveTimeLabel.text = [[[MCTool shared] getDateFromTimeSeconds:_fileModel.downLoadDate] minuteDescription];
        self.fileReciveTimeLabel.textColor = [[[MCThemeManager sharedManager] theme] fontTintColor];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    if (_isSelected){
        if (((UITableView *)self.superview).isEditing){
            self.backgroundView.backgroundColor = [UIColor colorWithRed:223.0/255.0 green:230.0/255.0 blue:250.0/255.0 alpha:1.0];
        } else {
            self.backgroundView.backgroundColor = [UIColor clearColor];
        }
        
        self.textLabel.textColor = [UIColor darkTextColor];
        [_selectedIndicator setImage:AppStatus.theme.selectStateImage];
        
    } else {
        
        self.backgroundView.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor grayColor];
        [_selectedIndicator setImage:AppStatus.theme.unselectStateImage];
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    [UIView commitAnimations];
}

- (void)changeSelectedState {
    _isSelected = !_isSelected;
    _fileModel.isSelected = _isSelected;
    [self setNeedsLayout];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
