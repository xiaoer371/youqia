//
//  MCIMChatViewModel.h
//  NPushMail
//
//  Created by admin on 4/12/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCIMConversationModel.h"
#import "MCIMMessageModel.h"
#import "MCIMMoreMsgAlertView.h"

@interface MCIMChatViewModel : NSObject <UITableViewDataSource>

@property (nonatomic, readonly, strong) MCIMConversationModel *conversation;
@property (nonatomic, readonly, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *msgList;
@property (nonatomic, strong) NSMutableArray     *controlImageSources; //要预览的model
@property (nonatomic, strong) MCIMMoreMsgAlertView    *moreMsgAlertView;


- (instancetype)initWithConversation:(MCIMConversationModel *)conversation
                           tableView:(UITableView *)tableView;

//上拉加载跟多
- (void)loadMoreData;

- (BOOL)showTimeLabel:(NSIndexPath*)indexPath;

- (void)deleteMessageModel:(MCIMMessageModel*)msg;

@end
