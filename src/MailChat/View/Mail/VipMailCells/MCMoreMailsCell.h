//
//  MCMoreMailsCell.h
//  NPushMail
//
//  Created by zhang on 2016/12/8.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const kMCMoreMailsCellId = @"moreMailsCellIdentity";

@interface MCMoreMailsCell : UITableViewCell

@property (nonatomic,weak)IBOutlet UIButton *moreMailsButton;
@property (nonatomic,copy)dispatch_block_t showMoreMailsCallback;
@property (nonatomic,assign)NSInteger mailCount;

+ (UINib*)registNib;

@end
