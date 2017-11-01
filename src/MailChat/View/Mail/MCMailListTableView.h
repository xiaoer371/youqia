//
//  MCMailListTableView.h
//  NPushMail
//
//  Created by zhang on 16/3/2.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCMailManager.h"
#import "SRRefreshView.h"
@class MCMailListTableView;

@protocol MCMailTableViewDelegate <NSObject>

- (void)tableViewDidRefresh;

@end

@interface MCMailListTableView : UITableView
@property (nonatomic,strong)SRRefreshView *refreshView;
@property (nonatomic,weak)id <MCMailTableViewDelegate>refreshDelegate;

- (void)endRefreshWithResult:(LoadMailResult)result;
@end
