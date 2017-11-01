//
//  MCProfileSetCell.h
//  NPushMail
//
//  Created by zhang on 16/4/12.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^loadAvatarChangeValue) (BOOL on);


@interface MCProfileSetCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *mCAddAccountImage;
@property (weak, nonatomic) IBOutlet UILabel *mCSetLable;
@property (weak, nonatomic) IBOutlet UILabel *mcCacheFileSize;

@property (weak, nonatomic) IBOutlet UISwitch *mcShowAvatarSwitch;
@property (copy,nonatomic)loadAvatarChangeValue loadAvatarChangeValueCallback;
@property (weak, nonatomic) IBOutlet UIView *updateBadge;

@property (nonatomic,strong)NSString *mcSettingTitle;

@end
