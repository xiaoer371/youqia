//
//  MCVipSectionCell.h
//  NPushMail
//
//  Created by zhang on 2017/2/14.
//  Copyright © 2017年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCVIPMailListCell.h"

typedef void(^readMailBlock) (MCMailModel *mail);
typedef void(^vipMailDesMarkBlock) (MCMailModel *mail);
typedef void(^deleteMailBlock) (MCMailModel *mail);
typedef void(^backlogMailBlock) (MCMailModel *mail);
typedef void(^loadMailContentBlock) (MCMailModel *mail);
typedef void(^didSelectedMailBlock) (MCMailModel *mail);
typedef void (^showMoreMailsBlock) (BOOL isBacklogMail);
static NSString *const kMVipSectionCellIdentity = @"vipSectionCellId";


@interface MCVipSectionCell : UITableViewCell
//dataSource
@property (nonatomic,strong)NSMutableArray *mails;
@property (nonatomic,assign)BOOL isAvatarShow;
@property (nonatomic,assign)BOOL isBacklogMail;


@property (nonatomic,copy)readMailBlock readMailCallBack;
@property (nonatomic,copy)vipMailDesMarkBlock vipMailDesMarkCallBack;
@property (nonatomic,copy)deleteMailBlock deleteMailCallBack;
@property (nonatomic,copy)backlogMailBlock backlogCallBack;
@property (nonatomic,copy)loadMailContentBlock loadMailCotentCallback;
@property (nonatomic,copy)didSelectedMailBlock didSelectedMailCallback;
@property (nonatomic,copy)showMoreMailsBlock showMoreMailsCallback;
@property (nonatomic,weak)IBOutlet UITableView *vipSectionTableView;

+ (UINib*)registNib;
- (void)reloadData;

- (void)insertMail:(MCMailModel*)mail inIndexPath:(NSIndexPath*)indexPath;

@end
