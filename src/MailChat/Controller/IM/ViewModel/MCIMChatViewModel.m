//
//  MCIMChatViewModel.m
//  NPushMail
//
//  Created by admin on 4/12/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCIMChatViewModel.h"
#import "MCIMMessageManager.h"
#import "MCNotificationCenter.h"
#import "MCChatViewCell.h"
#import "MCIMChatNoticeCell.h"
#import "MCIMMessageManager.h"
#import "MCIMMessageSender.h"
#import "MCContactManager.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "MCNotificationCenter.h"

static const NSInteger kMailchatMessagePageNumber = 10;

@interface MCIMChatViewModel ()
@property (nonatomic,strong) MCIMMessageManager *messageMgr;
@property (nonatomic,weak) id notificationObj;
//记录消息删除，table的containSize 变化的误差值（ps：用来判断消息是否在底部）
@property (nonatomic,assign) float contentErrorHeight;
@end

@implementation MCIMChatViewModel

- (void)dealloc
{
    if (self.notificationObj) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.notificationObj];
    }
}

#pragma mark - Lifecycle

- (instancetype)initWithConversation:(MCIMConversationModel *)conversation tableView:(UITableView *)tableView
{
    if (self = [super init]) {
        _conversation = conversation;
        _contentErrorHeight = 0.0f;
        _msgList = [NSMutableArray new];
        self.messageMgr = [MCIMMessageManager new];
        [self loadMoreData];
        
        _tableView = tableView;
        [_tableView registerClass:[MCIMChatNoticeCell class] forCellReuseIdentifier:@"MCIMChatNoticeCell"];
        _tableView.dataSource = self;
        
        __weak typeof(self) weakSelf = self;
        // 监听收到的消息
        self.notificationObj = [[NSNotificationCenter defaultCenter] addObserverForName:MCNotificationDidReceiveMessage object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            MCIMMessageModel *msg = note.object;
            if ([msg.peerId isEqualToString:weakSelf.conversation.peerId]) {
                [weakSelf addMessage:note.object];
            }
        }];
    }
    return self;
}

#pragma mark - Tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.msgList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.msgList count]) {
        id obj = [self.msgList objectAtIndex:indexPath.row];
        MCIMMessageModel *model = (MCIMMessageModel *)obj;
        
        if (model.type ==IMMessageTypeNotice ) {
            MCIMChatNoticeCell *cell =(MCIMChatNoticeCell *)[_tableView dequeueReusableCellWithIdentifier:@"MCIMChatNoticeCell" forIndexPath:indexPath];
            cell.model = model;
            return cell;
        }
        
        NSString *cellIdentifier = [MCChatViewCell cellIdentifierForMessageModel:model];
        MCChatViewCell *cell = (MCChatViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            DDLogDebug(@"Create cell for row index %@",indexPath);
            cell = [[MCChatViewCell alloc] initWithMessageModel:model reuseIdentifier:cellIdentifier];
        }
        cell.showTime = model.isShowTime?:[self showTimeLabel:indexPath];
        cell.messageModel = model;
        
        return cell;
    }
    return nil;
}

#pragma mark - 是否显示 时间
-(BOOL)showTimeLabel:(NSIndexPath*)indexPath
{
    if (indexPath.row >0)
    {
        int currentTime =0;
        int oldTime =0;
//        =============currentTime================
        MCIMMessageModel *currentModel =self.msgList[indexPath.row];
        currentTime = [currentModel.time  timeIntervalSince1970];
//        ================oldTime=================
        MCIMMessageModel *lastModel =self.msgList[indexPath.row-1];
        oldTime = [lastModel.time timeIntervalSince1970];
        
        int seconds =currentTime-oldTime;
        if (seconds >180) {
            currentModel.isShowTime = YES;
            return YES;
        }
        currentModel.isShowTime = NO;
        return NO;
    }else{
        // 等于0 的情况  一个model
        MCIMMessageModel *currentModel =self.msgList[indexPath.row];
        currentModel.isShowTime = YES;
        return YES;
    }
}

#pragma mark - loadMoreData
-(void)loadMoreData
{
    @synchronized (self.msgList) {
        
        NSInteger maxId = self.msgList.count > 0 ? [self.msgList[0] uid] : NSIntegerMax;
        NSArray *nextPageMessages = [self.messageMgr getConversationMessages:self.conversation.uid fromId:maxId number:kMailchatMessagePageNumber];
        if (nextPageMessages.count > 0) {
            for (NSInteger i = nextPageMessages.count - 1; i >= 0 ; i --) {
                MCIMMessageModel *model = (MCIMMessageModel*)nextPageMessages[i];
                
                if (!model.contactModel) {
                    model.contactModel = [[MCContactManager sharedInstance] getOrCreateContactWithEmail:model.from name:model.from];
                }
                [self.msgList insertObject:model atIndex:0];
            }
        }
    }
}

- (void)deleteMessageModel:(MCIMMessageModel*)msg
{
    @synchronized (self.msgList) {
        if (!msg) return;
       NSInteger rowIndex = [self.msgList indexOfObject:msg];
        [self.msgList removeObjectAtIndex:rowIndex];
        [self.messageMgr deleteMessage:msg];
        CGFloat originH = _tableView.contentOffset.y;
        self.conversation.lastMessage = [self.messageMgr getLastMessageModelWithConversationId:self.conversation.uid];
        [MCNotificationCenter postNotification:MCNotificationDeleteMessage object:self.conversation];
        [self.tableView endEditing:YES];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView endUpdates];
        CGFloat endH = _tableView.contentOffset.y;
        self.contentErrorHeight = originH ==endH?1.0f:originH-endH;
    }
}

#pragma mark - Private

- (void)commonInit
{
    
}

- (void)addMessage:(MCIMMessageModel *)msg
{
    @synchronized (self.msgList) {
        if (!msg.contactModel) {
            msg.contactModel = [[MCContactManager sharedInstance] getOrCreateContactWithEmail:msg.from name:msg.from];
        }
        [self.msgList addObject:msg];
        NSInteger rowIndex = self.msgList.count - 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView endUpdates];
        
        self.moreMsgAlertView.newNum++;
        if ([self isBottom]) {
            [self tableViewScrollToBottom];
        }else{
            [self.moreMsgAlertView refreshData:self.moreMsgAlertView.newNum];
        }
    }
}

- (BOOL)isBottom
{
    CGPoint contentOffsetPoint = _tableView.contentOffset;
    CGRect frame = _tableView.frame;
    if (ceil(_tableView.contentSize.height) < (int)frame.size.height) {
        return YES;
    }
    BOOL isBottom = (floor(contentOffsetPoint.y)+_tableView.contentInset.bottom) >= (ceil(_tableView.contentSize.height)  - (int)frame.size.height-self.contentErrorHeight -10);
    // 自己重发消息，不提醒未读数消息数
    if (self.contentErrorHeight > 0 && isBottom ==NO) {
        self.moreMsgAlertView.newNum = 0;
    }
    self.contentErrorHeight = 0.0f;
    return isBottom;
}

- (void)tableViewScrollToBottom
{
    if (self.msgList.count==0) return;
    
    if ([self.tableView numberOfSections] > 0) {
        NSInteger lastSectionIndex = [self.tableView numberOfSections] - 1;
        NSInteger lastRowIndex = [self.tableView numberOfRowsInSection:lastSectionIndex] - 1;
        if (lastRowIndex &&lastRowIndex > 0) {
            NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
            [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition: UITableViewScrollPositionBottom animated:YES];
        }
    }
    self.moreMsgAlertView.hidden = YES;
}

#pragma mark - control  Images 
-(NSMutableArray *)controlImageSources
{
    if(!_controlImageSources)
    {
         _controlImageSources = [[NSMutableArray alloc] initWithCapacity:0];
        
        for (MCIMMessageModel *messageModel in self.msgList) {
            if (messageModel.type == IMMessageTypeImage) {
                [_controlImageSources addObject:messageModel];
            }
        }
    }
    return _controlImageSources;
}

@end
