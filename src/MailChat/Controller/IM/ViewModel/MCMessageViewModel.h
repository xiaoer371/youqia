//
//  MCMessageViewModel.h
//  NPushMail
//
//  Created by admin on 4/15/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGSwipeTableCell.h"

@class MCIMConversationModel;


@interface MCMessageViewModel : NSObject <UITableViewDataSource>

/**
 *  总的未读数
 */
@property (nonatomic,assign) NSInteger unreadCount;

@property (nonatomic,strong) NSMutableArray *dataArray;

- (instancetype)initWithTableView:(UITableView*)tableView cellDelegate:(id<MGSwipeTableCellDelegate>)cellDelegate;

// 设置会话置顶
- (void)setTop:(MCIMConversationModel*)conversationModel;

- (void)clearAllUnreadCount;

@end
