//
//  MCContactInfoCell.m
//  NPushMail
//
//  Created by wuwenyu on 16/2/17.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCContactInfoCell.h"
#import "MCContactBaseInfo.h"
#import "MCContactModel.h"
#import "NSString+Extension.h"

@implementation MCContactInfoCell {
    NSIndexPath *_indexPath;
    MCContactModel *_model;
}

+ (instancetype)instanceFromNib {
    return [[[NSBundle mainBundle]loadNibNamed:@"MCContactInfoCell" owner:nil options:nil]lastObject];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)configureCellWithModel:(id)model indexPath:(NSIndexPath *)index phones:(NSMutableArray *)phones enterpriseInfos:(NSMutableArray *)enterpriseInfos {
    _indexPath = index;
    _model = model;
    self.enterpriseIconImageView.hidden = YES;
    if (index.section == 0) {
        if (enterpriseInfos) {
            //企业类型联系人
            MCContactBaseInfo *info = [enterpriseInfos objectAtIndex:index.row];
            self.titleLabel.textColor = AppStatus.theme.fontTintColor;
            self.valueLabel.textColor = AppStatus.theme.fontTintColor;
            if ([info.title isEqualToString:PMLocalizedStringWithKey(@"PM_Contact_Phone")]) {
                self.valueLabel.textColor = AppStatus.theme.tintColor;
            }
            self.titleLabel.text = info.title;
            self.valueLabel.text = info.value;
            if ([info.title isEqualToString:PMLocalizedStringWithKey(@"PM_ContactEnterpriseCompany")]) {
                self.enterpriseIconImageView.hidden = NO;
            }
        }else {
            //普通的联系人，只有手动添加的备注(目前只有电话备注)
            self.titleLabel.textColor = AppStatus.theme.fontTintColor;
            self.valueLabel.textColor = AppStatus.theme.tintColor;
            self.titleLabel.text = PMLocalizedStringWithKey(@"PM_Contact_Phone");
            self.valueLabel.text = [phones objectAtIndex:index.row];
        }
    }
}

- (IBAction)valueClickAction:(id)sender {
    if ([self.titleLabel.text isEqualToString:PMLocalizedStringWithKey(@"PM_Contact_Phone")]) {
        NSString *phoneNumber = self.valueLabel.text;
        if ([phoneNumber trim].length != 0 && ![phoneNumber isEqual:[NSNull null]] && phoneNumber) {
            NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phoneNumber]];
            UIWebView* phoneCallWebView = [[UIWebView alloc] init];
            [self.superview.superview.superview addSubview:phoneCallWebView];
            [phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneURL]];
        }
    }
}
@end
