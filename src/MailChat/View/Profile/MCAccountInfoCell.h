//
//  MCAccountInfoBaseCell.h
//  NPushMail
//
//  Created by zhang on 16/4/25.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MCSwitchONComplete)(BOOL on);


@interface MCAccountInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *mcTitle;
@property (weak, nonatomic) IBOutlet UIImageView *mcAvatar;
@property (weak, nonatomic) IBOutlet UISwitch *mcSwitch;
@property (nonatomic,strong)MCAccount *account;
@property (nonatomic,strong)NSString *title;
@property (weak, nonatomic) IBOutlet UILabel *mcName;

@property (nonatomic,copy)MCSwitchONComplete mcSwitchONComplete;
@end
