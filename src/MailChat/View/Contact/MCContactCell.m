//
//  MCContactCell.m
//  NPushMail
//
//  Created by wuwenyu on 16/1/4.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCContactCell.h"
#import "MCContactModel.h"
#import "UIImageView+WebCache.h"
#import "MCAvatarHelper.h"
#import "UIImageView+MCCorner.h"
#import "FBKVOController.h"
#import "MCAppSetting.h"
#import "MCTool.h"

@interface MCContactCell()

@property (nonatomic,strong)MCContactModel *contactModel;

@end

const static CGFloat kMCMailListCellSelectedIndicatorSize = 24;

@implementation MCContactCell {
    /**
     *  选择／ 取消的图片
     */
    UIImageView *_selectedIndicator;
}

+ (instancetype)instanceFromNib {
    return [[[NSBundle mainBundle]loadNibNamed:@"MCContactCell" owner:nil options:nil]lastObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
    [self.headerImgView cornerRadiusWithMask];
    self.accountLabel.textColor = AppStatus.theme.fontTintColor;
    self.nickNameLabel.textColor = AppStatus.theme.titleTextColor;
    self.youQiaFlagLabel.textColor = AppStatus.theme.tintColor;
    [self.inviteBtn setTitleColor:AppStatus.theme.tintColor forState:UIControlStateNormal];
    [self.inviteBtn setTitle:PMLocalizedStringWithKey(@"PM_Message_Invitations") forState:UIControlStateNormal];
    self.youQiaFlagLabel.layer.masksToBounds = YES;
    
    _isSelected = NO;
    CGRect indicatorFrame = CGRectMake(- kMCMailListCellSelectedIndicatorSize, fabs(self.frame.size.height - kMCMailListCellSelectedIndicatorSize)/ 2, kMCMailListCellSelectedIndicatorSize, kMCMailListCellSelectedIndicatorSize);
    _selectedIndicator = [[UIImageView alloc] initWithFrame:indicatorFrame];
    _selectedIndicator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.contentView addSubview:_selectedIndicator];
    
    self.canSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.canSelectBtn.frame = CGRectMake(-40, 0, ScreenWidth+40, ScreenHeigth);
    self.canSelectBtn.backgroundColor =[UIColor clearColor];
    self.canSelectBtn.hidden = YES;
//    [self bringSubviewToFront:self.canSelectBtn];
    /**
     *  这里因为uiview 层级的关系 加到cell上 不是加到contentview上。
     */
//    [self addSubview:self.canSelectBtn];
    
    UIImageView *didSelectImg =[[UIImageView alloc] initWithFrame:CGRectMake(12+40, 14 ,22,22)];
    didSelectImg.image =[UIImage imageNamed:@"didSelect.png"];
//    [self.canSelectBtn addSubview:didSelectImg];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)configureCellWithModel:(id)model {
    [self removeObserver];
    if (model) {
        if ([model isMemberOfClass:[MCContactModel class]]) {
            MCContactModel *obj = (MCContactModel *)model;
            _contactModel = obj;
            _isSelected = obj.isSelect;
            if (obj.cantEdit) {
                //灰显,不可编辑
                [_selectedIndicator setImage:AppStatus.theme.cantEditStateImage];
            }else{
                if (_isSelected){
                    [_selectedIndicator setImage:AppStatus.theme.selectStateImage];
                    
                } else {
                    [_selectedIndicator setImage:AppStatus.theme.unselectStateImage];
                }
            }
            if (AppSettings.showWeight) {
                self.weightLabel.hidden = NO;
                self.weightLabel.text = [NSString stringWithFormat:@"%ld",(long)obj.weights];
            }else self.weightLabel.hidden = YES;
            
            [self.headerImgView sd_setImageWithURL:[NSURL URLWithString:obj.headImageUrl] placeholderImage:obj.avatarPlaceHolder options:SDWebImageAllowInvalidSSLCertificates];
            if (obj.youqiaFlag) {
                self.youQiaFlagLabel.text = PMLocalizedStringWithKey(@"PM_Contact_YouQiaUser");
                self.inviteBtn.hidden = YES;
            }else{
               self.youQiaFlagLabel.text =  @"";
                self.inviteBtn.hidden = NO;
            }
           
            self.nickNameLabel.text = obj.displayName;
            self.accountLabel.text = obj.account;
        }
        [self registeredObserver];
    }
}
- (IBAction)inviteAction:(id)sender {
    
    [[MCTool shared] shareYouqia];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    if (_contactModel.cantEdit) {
        [_selectedIndicator setImage:AppStatus.theme.cantEditStateImage];
        [UIView commitAnimations];
        return;
    }
    if (_isSelected){
        if (((UITableView *)self.superview).isEditing){
            self.backgroundView.backgroundColor = [UIColor colorWithRed:223.0/255.0 green:230.0/255.0 blue:250.0/255.0 alpha:1.0];
        } else {
            self.backgroundView.backgroundColor = [UIColor clearColor];
        }
        
//        self.textLabel.textColor = AppStatus.theme.fontTintColor;
        [_selectedIndicator setImage:AppStatus.theme.selectStateImage];
        
    } else {
        
        self.backgroundView.backgroundColor = [UIColor clearColor];
//        self.textLabel.textColor = AppStatus.theme.fontTintColor;
        [_selectedIndicator setImage:AppStatus.theme.unselectStateImage];
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    [UIView commitAnimations];
}

- (void)changeSelectedState {
    _isSelected = !_isSelected;
    _contactModel.isSelect = _isSelected;
    [self setNeedsLayout];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
}

- (void)registeredObserver {
    
    __weak typeof(self) weakSelf = self;
    [self.KVOController observe:weakSelf.contactModel keyPath:@"headImageUrl" options: NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *headImageUrl = change[NSKeyValueChangeNewKey];
            [weakSelf.headerImgView sd_setImageWithURL:[NSURL URLWithString:headImageUrl] placeholderImage:weakSelf.contactModel.avatarPlaceHolder options:SDWebImageAllowInvalidSSLCertificates];
        });
    }];
    
    [self.KVOController observe:weakSelf.contactModel keyPath:@"displayName" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *disPlayName = change[NSKeyValueChangeNewKey];
            weakSelf.nickNameLabel.text = disPlayName;
        });
    }];
}

- (void)removeObserver {
    
    [self.KVOController unobserveAll];
}

@end
