//
//  MCIMSessionManager.m
//  NPushMail
//
//  Created by admin on 2/29/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCIMConversationManager.h"
#import "MCMsgConversationTable.h"
#import "MCIMGroupManager.h"
#import "MCContactManager.h"
#import "MCIMAppModel.h"
#import "MCIMMessageSender.h"

@interface MCIMConversationManager ()

@property (nonatomic,strong) MCMsgConversationTable *db;
@property (nonatomic,strong) NSMutableDictionary *conversationDict;
@end

@implementation MCIMConversationManager

#pragma mark - Lifecycle

- (instancetype)init
{
    if (self = [super init]) {
        _db = [MCMsgConversationTable new];
        [self commonInit];
    }
    
    return self;
}

+ (instancetype)shared
{
    DDLogDebug(@"Get conversation manager");
    return AppStatus.accountData.imConversationManager;
}

#pragma mark - Public

- (NSArray *)getAllConversations
{
    NSMutableArray *visivalConversations = [[NSMutableArray alloc] init];
    [self.conversationDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, MCIMConversationModel *obj, BOOL * _Nonnull stop) {
        if (obj.state == MailChatConversationStateNormal) {
            [visivalConversations addObject:obj];
        }
    }];
    return visivalConversations;
}

- (MCIMConversationModel *)conversationForMessage:(MCIMMessageModel *)msg
{
    MCIMConversationModel *conversation = [self getConversationWithPeerId:msg.peerId];
    if (!conversation) {
        id peer = [self getPeerWithPeerId:msg.peerId conversationType:msg.conversationType];
        // 没找到群组，肯定是群组状态有问题
        if (!peer) {
            DDLogError(@"Peer not found for message, peerId = %@", msg.peerId);
            return nil;
        }
        conversation = [MCIMConversationModel new];
        conversation.peerId = msg.peerId;
        conversation.peer = peer;
        conversation.type = msg.conversationType;
    }
    return conversation;
}

- (MCIMConversationModel *)conversationForGroup:(MCIMGroupModel *)group
{
    MCIMConversationModel *conversation = [self getConversationWithPeerId:group.groupId];
    if (conversation) {
        conversation.lastMsgTime =[NSDate new];
        return conversation;
    }
    
    conversation = [MCIMConversationModel new];
    conversation.peer = group;
    conversation.peerId = group.groupId;
    conversation.type = MailChatConversationTypeGroup;
    conversation.lastMsgTime =[NSDate new];
    [self.conversationDict setObject:conversation forKey:conversation.peerId];
    
    return conversation;
}

- (MCIMConversationModel *)conversationForContact:(MCContactModel *)contact
{
    MCIMConversationModel *conversation = [self getConversationWithPeerId:contact.account];
    if (conversation) {
        return conversation;
    }
    
    conversation = [MCIMConversationModel new];
    conversation.peer = contact;
    conversation.peerId = contact.account;
    conversation.type = MailChatConversationTypeSingle;
    [self.conversationDict setObject:conversation forKey:conversation.peerId];
    
    return conversation;
}

- (void)updateConversation:(MCIMConversationModel *)conversation withMessage:(MCIMMessageModel *)msg
{
    conversation.state = MailChatConversationStateNormal;
    conversation.lastMessage = msg;
    if (!msg.isSender && !conversation.isChatting) {
        conversation.unreadCount++;
    }
    // uid 为0 表示发起会话，还没有开始聊天
    if (conversation.uid == 0) {
        [self insertConversation:conversation];
    }
    else{
        [self updateConversation:conversation];
    }
    msg.conversationId = conversation.uid;
}

- (MCIMConversationModel *)getConversationWithPeerId:(NSString *)peerId
{
    return self.conversationDict[peerId];
}

- (void)insertConversation:(MCIMConversationModel *)model
{
    @synchronized (self.conversationDict) {
        [self.db insertModel:model];
        [self.conversationDict setObject:model forKey:model.peerId];
    }
}

- (void)updateConversation:(MCIMConversationModel *)model
{
    [self.db updateModel:model];
}

- (void)removeConversation:(MCIMConversationModel *)model
{
    model.state = MailChatConversationStateDeleted;
    [self.db updateModel:model];
}

- (void)deleteConversationPermantelyWithPeerId:(NSString *)peerId
{
    @synchronized (self.conversationDict) {
        MCIMConversationModel *model = self.conversationDict[peerId];
        if (model) {
            [self.conversationDict removeObjectForKey:peerId];
            [self.db deleteById:model.uid];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate conversationDidDeleted:model];
            });
        }
    }
}

#pragma mark - Private

- (void)commonInit
{
    _conversationDict = [NSMutableDictionary new];
    NSArray *models = [_db allModels];
    for (MCIMConversationModel *model in models) {
        [_conversationDict setObject:model forKey:model.peerId];
        model.peer = [self getPeerWithPeerId:model.peerId conversationType:model.type];
    }
}

- (id<MCIMPeerModelProtocol>)getPeerWithPeerId:(NSString *)peerId conversationType:(MailChatConversationType)type
{
    id<MCIMPeerModelProtocol> peer;
    if (type == MailChatConversationTypeSingle) {
        peer = [[MCContactManager sharedInstance] getOrCreateContactWithEmail:peerId name:peerId];
    }
    else if (type == MailChatConversationTypeGroup){
        peer = [[MCIMGroupManager shared] getGroupWithGroupId:peerId];
    }
    else if (type == MailChatConversationTypeApp){
        // 返回oa 对象
        if ([peerId isEqualToString:kMailChatOA]) {
            static MCIMAppModel *oaModel = nil;
            if (!oaModel) {
                oaModel = [MCIMAppModel new];
                oaModel.appId = kMailChatOA;
                oaModel.peerName = PMLocalizedStringWithKey(@"PM_Msg_Push_OA");
                oaModel.avatarPlaceHolder = [UIImage imageNamed:@"mc_chat_oa.png"];
            }
            peer = oaModel;
        }

    }
    else if (type == MailChatConversationTypeFeiba){
        // 返回飞巴 对象
        if ([peerId isEqualToString:kMailChatFeiBa]) {
            static MCIMAppModel *feiBaModel = nil;
            if (!feiBaModel) {
                feiBaModel = [MCIMAppModel new];
                feiBaModel.appId = kMailChatFeiBa;
                feiBaModel.peerName = @"迎新特价机票";
                feiBaModel.avatarPlaceHolder = [UIImage imageNamed:@"mc_feiba.png"];
            }
            peer = feiBaModel;
        }
        
    }
    else if (type == MailChatConversationTypeEvent){
        if ([peerId isEqualToString:kMailChatWeiYa]) {
            static MCIMAppModel *weiYaModel = nil;
            if (!weiYaModel) {
                weiYaModel = [MCIMAppModel new];
                weiYaModel.appId = kMailChatWeiYa;
                weiYaModel.peerName = @"35年会节目投票";
                weiYaModel.avatarPlaceHolder = [UIImage imageNamed:@"weiya.png"];
            }
            peer = weiYaModel;
        }
    }else if (type == MailChatConversationTypeEventlive){
        if ([peerId isEqualToString:kMailChatWeiYa1]) {
            static MCIMAppModel *weiYaModel = nil;
            if (!weiYaModel) {
                weiYaModel = [MCIMAppModel new];
                weiYaModel.appId = kMailChatWeiYa1;
                weiYaModel.peerName = @"35年会直播通道";
                weiYaModel.avatarPlaceHolder = [UIImage imageNamed:@"weiya.png"];
            }
            peer = weiYaModel;
        }
    }
    else{
        
    }
    
    if (!peer) {
        DDLogError(@"Conversation peer not found = %@",peerId);
    }
    return peer;
}

- (void)addFeiBaConversation
{
    [self addDefaultConversationWithPeerId:kMailChatFeiBa conversationType:MailChatConversationTypeFeiba];
}

- (void)addWeiYaConversation
{
    if ([AppStatus.currentUser.email is35Mail]) {
        [self addDefaultConversationWithPeerId:kMailChatWeiYa  conversationType:MailChatConversationTypeEvent];
        [self addDefaultConversationWithPeerId:kMailChatWeiYa1 conversationType:MailChatConversationTypeEventlive];
    }
}

- (void)addHelperConversation
{
    [self addDefaultConversationWithPeerId:kMailChatHelper conversationType:MailChatConversationTypeSingle];
}

- (void)addOAConversation
{
    [self addDefaultConversationWithPeerId:kMailChatOA conversationType:MailChatConversationTypeApp];
}

- (MCIMConversationModel * )addDefaultConversationWithPeerId:(NSString *)peerId conversationType:(MailChatConversationType)type
{
    MCIMConversationModel *defaultConversation = [[MCIMConversationManager shared] getConversationWithPeerId:peerId];
    if (!defaultConversation) {
        id<MCIMPeerModelProtocol> defaultPeer = [[MCIMConversationManager shared] getPeerWithPeerId:peerId conversationType:type];
        defaultConversation = [MCIMConversationModel new];
        defaultConversation.type = type;
        defaultConversation.peerId = peerId;
        defaultConversation.peer = defaultPeer;
        defaultConversation.lastMsgTime = [NSDate new];
        switch (type) {
            case MailChatConversationTypeApp:
            {
                defaultConversation.content = PMLocalizedStringWithKey(@"PM_Msg_OAWelcome");
                [[MCIMConversationManager shared] insertConversation:defaultConversation];
            }
                break;
            case MailChatConversationTypeSingle:{
                NSString *welcome = PMLocalizedStringWithKey(@"PM_Msg_HelperWelcome");
               [[MCIMMessageSender shared] sendFakeMessageWithText:welcome from:kMailChatHelper conversation:defaultConversation messageType:IMMessageTypeText];
            }
                break;
            case MailChatConversationTypeFeiba:
            {
                defaultConversation.unreadCount = 1;
                defaultConversation.content = @"杭州政府扶持 飞巴商旅给您实在优惠";
                [[MCIMConversationManager shared] insertConversation:defaultConversation];
            }
                break;
            case MailChatConversationTypeEvent:
            {
                defaultConversation.unreadCount = 1;
                defaultConversation.content = @"谁能摘取桂冠，由你决定";
                defaultConversation.onTopTime = 1;
                [[MCIMConversationManager shared] insertConversation:defaultConversation];
            }
                break;
            case MailChatConversationTypeEventlive:
            {
                defaultConversation.unreadCount = 1;
                defaultConversation.content = @"变革 执行 致远 精诚21年";
                defaultConversation.onTopTime = 2;
                [[MCIMConversationManager shared] insertConversation:defaultConversation];
            }
                break;
                
            default:
                break;
        }
    }
    return defaultConversation;
}


@end
