//
//  MCIMService.m
//  NPushMail
//
//  Created by admin on 3/3/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCIMService.h"
#import "MCMessageParser.h"
#import "MCQueue.h"
#import "MCIMProcessor.h"
#import "MCIMTopicManager.h"

@interface MCIMService () <MCIMClientDelegate>

@property (nonatomic,strong) MCAccount *account;

@property (nonatomic,strong) MCWeakProxy *delegateProxy;

@property (nonatomic,strong) MCIMProcessor *processor;
@property (nonatomic,strong) dispatch_queue_t processQueue;

@property (nonatomic,strong) MCIMTopicManager *topicManager;

@property (atomic,assign) BOOL isTopicSynced;
@property (atomic,assign) BOOL isGroupUpdated;


@end

@implementation MCIMService

#pragma mark - Lifecycle

- (instancetype)initWithAccount:(MCAccount *)account
{
    if (self = [super init]) {
        _processQueue = dispatch_queue_create("com.mailchat.msg.processor", DISPATCH_QUEUE_SERIAL);
        _account = account;
        _processor = [MCIMProcessor new];
        _client = [MCIMClient shared];
        _delegateProxy = [MCWeakProxy proxyWithTarget:self];
        [_client addDelegate:_delegateProxy];
        _topicManager = [[MCIMTopicManager alloc] initWithAccount:account];
    }
    
    return self;
}

- (void)dealloc
{
    [self stop];
    if (_client && _delegateProxy) {
        [_client removeDelegate:_delegateProxy];
    }
}

#pragma mark - Public

- (void)run
{
    _isRunning = YES;
    [_client connect];
}

- (void)stop
{
    [_client disconnect];
    _isRunning = NO;
}

#pragma mark - Delegate

- (void)imclient:(MCIMClient *)client connectionStateChanged:(MCIMClientState)state
{
    DDLogVerbose(@"mqtt connection changed : %d",state);
    if (state == MCIMClientStateConnected) {
        [self syncTopics];
    }
}

- (void)imclient:(MCIMClient *)client didReceiveData:(NSData *)data onTopic:(NSString *)topic retain:(BOOL)retain
{
    DDLogVerbose(@"Receive data on topic:%@",topic);
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.processQueue, ^{
        DDLogVerbose(@"Process data on topic:%@",topic);
        [weakSelf.processor processData:data ofTopic:topic];
    });
}

#pragma mark - Private

//考虑把数据同步这一块分离出来
- (void)syncTopics
{
    if (!self.isTopicSynced) {
        self.isTopicSynced = YES;
        NSString *email = self.account.email;
        NSString *selfTopic = [NSString stringWithFormat:@"%@/1",email];
        NSString *sysTopic = [NSString stringWithFormat:@"%@/s",email];
        NSString *oaTopic = [NSString stringWithFormat:@"%@/a",email];
        NSArray *fixTopics = @[selfTopic,sysTopic,oaTopic];
        [self.client subscribeTopics:fixTopics success:nil failure:nil];
    }
    
    [self acceptInvitations];
    
    if (!self.isGroupUpdated) {
        [self syncGroups];
    }
}

- (void)acceptInvitations
{
    MCIMGroupManager *groupMGr = [MCIMGroupManager shared];
    __weak MCIMGroupManager *weakGroupMgr = groupMGr;
    [groupMGr getInvitationsSuccess:^(NSArray *invitations) {
        if (invitations.count == 0) {
            return;
        }
        
        [weakGroupMgr joinGroupWithInvitations:invitations success:^(id response) {
            DDLogVerbose(@"Join group success = %@",invitations);
        } failure:^(NSError *error) {
            DDLogError(@"Join Gorups error = %@",error);
        }];
    } failure:^(NSError *error) {
        DDLogError(@"get invitations error = %@",error);
    }];
}

- (void)syncGroups
{
    DDLogVerbose(@"[syncGroups]");
    self.isGroupUpdated = YES;
    [[MCIMGroupManager shared] updateUserGroupsSuccess:^(NSArray *groups) {
        if (groups.count == 0) {
            return;
        }
        NSMutableArray *groupIds = [[NSMutableArray alloc] initWithCapacity:groups.count];
        for (MCIMGroupModel *group in groups) {
            [groupIds addObject:group.groupId];
        }
        DDLogVerbose(@"Group Ids = %@",groupIds);
        [self.client subscribeTopics:groupIds success:^{
            
        } failure:^(NSError *error) {
            self.isGroupUpdated = NO;
        }]; 
        
    } failure:^(NSError *error) {
        self.isGroupUpdated = NO;
    }];
}

@end
