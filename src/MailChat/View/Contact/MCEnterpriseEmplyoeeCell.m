//
//  MCEnterpriseEmplyoeeCell.m
//  NPushMail
//
//  Created by wuwenyu on 16/3/2.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCEnterpriseEmplyoeeCell.h"
#import "MCContactModel.h"
#import "MCEnterpriseContactCellItem.h"
#import "MCTool.h"
#import "UIImageView+WebCache.h"
#import "UIView+MJExtension.h"
#import "MCAvatarHelper.h"
#import "UIImageView+MCCorner.h"
#import "FBKVOController.h"

static const CGFloat avatorOriginX = 20;

@interface MCEnterpriseEmplyoeeCell()

@property(nonatomic, strong) MCEnterpriseContactCellItem *contactItem;

@end

@implementation MCEnterpriseEmplyoeeCell

+ (instancetype)instanceFromNib {
    return [[[NSBundle mainBundle]loadNibNamed:@"MCEnterpriseEmplyoeeCell" owner:nil options:nil]lastObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self reset];
}

- (void)reset {
    self.avatorImgViewLeftConstraint.constant = avatorOriginX;
    [self.avatorImgView cornerRadiusWithMask];
    self.remarkLabel.textColor = AppStatus.theme.tintColor;
    self.positionLabel.textColor = AppStatus.theme.fontTintColor;
}

-(void) configureCellWithEmplyoeeItem:(MCEnterpriseContactCellItem *)item {
    [self removeObserver];
    _contactItem = item;
    if (!item.employeeInfo.headImageUrl) {
        if (!item.employeeInfo.headDefaultColorStr) {
            item.employeeInfo.headDefaultColorStr = [MCAvatarHelper randomColorHexString];
        }
        self.avatorImgView.image = item.employeeInfo.avatarPlaceHolder;
    }else {
        if (!item.employeeInfo.headDefaultColorStr) {
            item.employeeInfo.headDefaultColorStr = [MCAvatarHelper randomColorHexString];
        }
        [self.avatorImgView sd_setImageWithURL:[NSURL URLWithString:item.employeeInfo.headImageUrl] placeholderImage:item.employeeInfo.avatarPlaceHolder options:SDWebImageAllowInvalidSSLCertificates];
    }
    self.avatorImgViewLeftConstraint.constant = item.emplyoeeItemOriginX;
    self.displayNameLabel.text = item.employeeInfo.enterpriseUserName;
    if (item.employeeInfo.youqiaFlag) {
        //使用邮洽
        self.remarkLabel.text = PMLocalizedStringWithKey(@"PM_Contact_YouQiaUser");
    }else  self.remarkLabel.text = @"";
    
    self.separatorInset = UIEdgeInsetsMake(self.separatorInset.top, CGRectGetMinX(self.displayNameLabel.frame), self.separatorInset.bottom, self.separatorInset.right);
    if (item.employeeInfo.isLeader) {
        self.positionLabel.text = PMLocalizedStringWithKey(@"PM_ContactEnterpriseLeader");
        self.displayNameTopConstraint.constant = 8;
    }else {
        self.displayNameTopConstraint.constant = 18;
        self.positionLabel.text = @"";
    }
    [self registeredObserver];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)registeredObserver {
    
    __weak typeof(self) weakSelf = self;
    [self.KVOController observe:weakSelf.contactItem.employeeInfo keyPath:@"headImageUrl" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *headImageUrl = change[NSKeyValueChangeNewKey];
            [weakSelf.avatorImgView sd_setImageWithURL:[NSURL URLWithString:headImageUrl] placeholderImage:weakSelf.contactItem.employeeInfo.avatarPlaceHolder options:SDWebImageAllowInvalidSSLCertificates];
        });
    }];
}

- (void)removeObserver {
    
    [self.KVOController unobserveAll];
}

@end
