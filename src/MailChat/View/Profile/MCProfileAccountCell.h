//
//  MCProfileAccountCell.h
//  NPushMail
//
//  Created by zhang on 16/4/12.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCProfileAccountCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *mCAccountImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mCAccountLabelTopConstraints;
@property (weak, nonatomic) IBOutlet UILabel *mCAccountLabel;
//data
@property (nonatomic,strong)MCAccount *mCAccount;
@property (weak, nonatomic) IBOutlet UILabel *oaAccountLabel;

@property (nonatomic,copy)dispatch_block_t accountInfoComplete;
@end
