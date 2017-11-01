//
//  MCVipSectionHeaderView.h
//  NPushMail
//
//  Created by zhang on 2017/2/16.
//  Copyright © 2017年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCVipSectionHeaderView : UITableViewHeaderFooterView

@property (nonatomic,copy)dispatch_block_t showVipNoteCallBack;
@property (nonatomic,strong)NSString *title;
@property (nonatomic,assign)BOOL showVipNoteItem;

@end
