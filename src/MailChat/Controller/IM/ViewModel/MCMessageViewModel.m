//
//  MCMessageViewModel.m
//  NPushMail
//
//  Created by admin on 4/15/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCMessageViewModel.h"
#import "MCIMConversationCell.h"
#import "MCMessageViewController.h"
#import "MCIMConversationManager.h"
#import "MCNotificationCenter.h"
#import "MCIMMessageSender.h"

@interface MCMessageViewModel ()<MCIMConversationProtocol>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) id swipeTableCellDelegate;
@property (nonatomic, weak) id msgNotifyObserver;

@end

@implementation MCMessageViewModel

#pragma mark - Lifecycle

-(instancetype)initWithTableView:(UITableView*)tableView cellDelegate:(id<MGSwipeTableCellDelegate>)cellDelegate
{
    self = [super init];
    if (self) {
        
        self.swipeTableCellDelegate = cellDelegate;
        
        [self loadData];
        
        self.tableView = tableView;
        [self.tableView registerNib:[MCIMConversationCell cellNib] forCellReuseIdentifier:[MCIMConversationCell reuseIdentifier]];
        self.tableView.dataSource = self;
        [self.tableView reloadData]; //必须reloadData，否则帐号切换过来后，收到消息，初始状态行数不一致
    
        [MCIMConversationManager shared].delegate = self;
        __weak typeof(self) weakSelf = self;
        self.msgNotifyObserver = [[NSNotificationCenter defaultCenter] addObserverForName:MCNotificationDidReceiveMessage object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            DDLogVerbose(@"Receive message notification");
            [weakSelf receiveMessage:note.object];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:MCNotificationDeleteMessage object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [weakSelf reloadDidDeleteMsg:note.object];
        }];
        
    }
    return self;
}

- (void)dealloc
{
    DDLogDebug(@"MCMessageViewModel dealloc");
    
    if (self.msgNotifyObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.msgNotifyObserver];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MCNotificationDeleteMessage object:nil];
}

#pragma mark -  Table View data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCIMConversationCell *cell = (MCIMConversationCell*)[tableView dequeueReusableCellWithIdentifier:[MCIMConversationCell reuseIdentifier] forIndexPath:indexPath];
    cell.delegate = self.swipeTableCellDelegate;
    cell.conversationModel = self.dataArray[indexPath.row];
     __weak typeof(self) weakSelf = self;
    cell.dragBadgeOutViewBlock = ^(MCIMConversationModel* conversationModel){
        weakSelf.unreadCount -= conversationModel.unreadCount;
    };
    return cell;
}

#pragma mark - MCIMConversationProtocol

- (void)conversationDidAdded:(MCIMConversationModel *)conversation
{
    @synchronized (self.dataArray) {
        NSInteger firstNonTopIndex = [self getFirstNonTopIndex];
        [self.dataArray insertObject:conversation atIndex:firstNonTopIndex];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:firstNonTopIndex inSection:0];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
}

- (void)conversationDidDeleted:(MCIMConversationModel *)conversation
{
    @synchronized (self.dataArray) {
        NSInteger index = [self.dataArray indexOfObject:conversation];
        if (index != NSNotFound) {
            self.unreadCount -= conversation.unreadCount;
            [self.dataArray removeObjectAtIndex:index];
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }
    }
}

#pragma mark - Receive message

- (void)reloadDidDeleteMsg:(MCIMConversationModel *)conversation
{
    @synchronized (self.dataArray) {
        NSInteger index = [self.dataArray indexOfObject:conversation];
        if (index != NSNotFound) {
            [self.tableView beginUpdates];
            [self.tableView  reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }
    }
}

#pragma mark - Receive message

- (void)receiveMessage:(MCIMMessageModel *)msg
{
    @synchronized (self.dataArray) {
        MCIMConversationModel *conversation = [[MCIMConversationManager shared] getConversationWithPeerId:msg.peerId];
        if (!conversation) return;
        NSInteger firstNonTopIndex = [self getFirstNonTopIndex];
        NSInteger index = [self.dataArray indexOfObject:conversation];
        
        //新会话，插入
        if (index == NSNotFound) {
            [self.dataArray insertObject:conversation atIndex:firstNonTopIndex];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:firstNonTopIndex inSection:0];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
            [self updateUnreadCount];
            return;
        }
        
        [self updateUnreadCount];
        
        // 已经在第一条，刷新内容即可
        if (index == 0 || index == firstNonTopIndex) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            //不需要重新排序
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            return;
        }
        
        //默认移到第一条
        NSInteger fromIndex = index;
        NSInteger toIndex = 0;
        //如果是非置顶的，移到置顶的后面
        if (index > firstNonTopIndex) {
            toIndex = firstNonTopIndex;
        }
        [self.dataArray removeObjectAtIndex:fromIndex];
        [self.dataArray insertObject:conversation atIndex:toIndex];
        NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:toIndex inSection:0];
        NSIndexPath *fromIndexPath = [NSIndexPath indexPathForRow:fromIndex inSection:0];
        [self.tableView moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
        [self.tableView reloadRowsAtIndexPaths:@[fromIndexPath,toIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - loadData

- (void)loadData
{
    [self addDefaultConversations];
    NSArray *array = [[MCIMConversationManager shared] getAllConversations];

    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"_onTopTime"ascending:NO];
    NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"_lastMsgTime"ascending:NO];
    NSArray *tempArray = [array sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor1, sortDescriptor2, nil]];
    _dataArray = [NSMutableArray arrayWithArray:tempArray];
    [self updateUnreadCount];
}

-(void)setTop:(MCIMConversationModel*)conversationModel
{
    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"_onTopTime"ascending:NO];
    NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"_lastMsgTime"ascending:NO];
    NSArray *tempArray = [_dataArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor1, sortDescriptor2,nil]];
    _dataArray = [NSMutableArray arrayWithArray:tempArray];
    [self.tableView reloadData];
}

- (void)clearAllUnreadCount
{
    for (MCIMConversationModel *model in self.dataArray) {
        if (model.unreadCount>0) {
            model.unreadCount = 0;
            [[MCIMConversationManager shared] updateConversation:model];
            
            NSInteger index = [self.dataArray indexOfObject:model];
            if (index != NSNotFound) {
                MCIMConversationCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                [cell.badge startbomAnimation];
            }
        }
    }
    self.unreadCount = 0;
}

- (void)updateUnreadCount
{
    NSUInteger count = 0;
    for (MCIMConversationModel *model in self.dataArray) {
        if (model.isShield) {
            continue;
        }
        count += model.unreadCount;
    }
    self.unreadCount = count;
}

- (NSInteger)getFirstNonTopIndex
{
    for (NSInteger i = 0; i < self.dataArray.count; i++) {
        MCIMConversationModel *model = self.dataArray[i];
        if (model.onTopTime == 0) {
            return i;
        }
    }
    return 0;
}

- (void)addDefaultConversations
{
    ///TODO: 飞巴目前还在测试。  已接入测试完成，如果要测试的话把下面注释打开就行
    [[MCIMConversationManager shared] addFeiBaConversation];
    
    ///TODO:  35尾牙投票
    // [[MCIMConversationManager shared] addWeiYaConversation];
    
    /// 添加 默认OA 会话
    [[MCIMConversationManager shared] addOAConversation];
    /// 添加 默认小助手 会话
    [[MCIMConversationManager shared] addHelperConversation];

}





@end
