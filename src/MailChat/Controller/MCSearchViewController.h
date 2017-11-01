//
//  MCSearchViewController.h
//  NPushMail
//
//  Created by wuwenyu on 16/8/11.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseViewController.h"
#import "MCSearchBar.h"
#import "MCSegmentHeadView.h"

@interface MCSearchViewController : MCBaseViewController<MCSearchBarDelegate, UITableViewDelegate, SegmentTapViewDelegate>

@property(nonatomic, strong) UITableView *mainTableView;
@property(nonatomic, strong) MCSearchBar *searchBar;
@property(nonatomic, strong) MCSegmentHeadView *segmentView;
/**
 *  分区初始化
 *
 *  @param scopes 分区标题
 *
 *  @return
 */
- (id)initWithScopes:(NSArray *)scopes;
@end
