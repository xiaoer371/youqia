//
//  MCContactGroupCell.m
//  NPushMail
//
//  Created by wuwenyu on 16/1/5.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCContactGroupCell.h"
#import "MCGroup.h"
#import "UIImageView+MCCorner.h"

@implementation MCContactGroupCell

+ (instancetype)instanceFromNib
{
    return [[[NSBundle mainBundle]loadNibNamed:@"MCContactGroupCell" owner:nil options:nil]lastObject];
}

- (void)awakeFromNib {
    // Initialization code
    self.groupNameLabel.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)configureCellWithModel:(id)model {
    NSString *titleKey = (NSString *)model;
    self.groupNameLabel.text = PMLocalizedStringWithKey(titleKey);
    self.groupAvatorImgView.image = [UIImage imageNamed:@"customGroupIcon.png"];
    if ([titleKey isEqualToString:@"PM_Contacts_Type_En"]) {
        self.groupAvatorImgView.image = [UIImage imageNamed:@"enterpriseContactsIcon.png"];
    }
    if ([titleKey isEqualToString:@"PM_Contacts_Type_Personal"]) {
        self.groupAvatorImgView.image = [UIImage imageNamed:@"recentContactIcon.png"];
    }
    if ([titleKey isEqualToString:@"PM_ContactMessageGroups"]) {
        self.groupAvatorImgView.image = [UIImage imageNamed:@"msgGroupIcon.png"];
    }
}

@end
