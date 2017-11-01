//
//  MCMessageViewController.h
//  NPushMail
//
//  Created by zhang on 16/1/18.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseViewController.h"
#import "MCMessageViewModel.h"

@interface MCMessageViewController : MCBaseViewController

@property (nonatomic, strong) MCMessageViewModel *messageViewModel;
@property (nonatomic, strong)  UITableView       *tableView;


@end
