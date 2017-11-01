//
//  MCIMConnection.m
//  NPushMail
//
//  Created by admin on 2/25/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCIMClient.h"
#import <MQTTClient/MQTTClient.h>
#import "MQTTSessionManager.h"
#import "MCAppSetting.h"
#import <FBKVOController.h>

@interface MCIMClient () <MQTTSessionManagerDelegate>

@property (nonatomic,copy) NSString *clientId;
@property (nonatomic,strong) MQTTSessionManager *sessionManager;
@property (nonatomic,strong) NSMutableArray *delegates;

@end

@implementation MCIMClient

- (instancetype)initWithClientId:(NSString *)clientId
{
    if (self = [super init]) {
        _clientId = [clientId copy];
        _delegates = [NSMutableArray new];
        
        [self commonInit];
        DDLogVerbose(@"Create connection with client id = %@",clientId);
    }
    
    return self;
}

- (void)dealloc
{
    [self disconnect];
}

+ (instancetype)shared
{
    return AppStatus.accountData.imClient;
}

- (void)connect
{
    MQTTSSLSecurityPolicy *policy = [MQTTSSLSecurityPolicy policyWithPinningMode:MQTTSSLPinningModeCertificate];
    policy.allowInvalidCertificates = YES;
    policy.validatesCertificateChain = NO;
    policy.validatesDomainName = NO;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ca" ofType:@"der"];
    NSData *crtData = [NSData dataWithContentsOfFile:filePath];
    policy.pinnedCertificates = [[NSMutableArray alloc] initWithObjects:crtData, nil];
    
    NSString *host = AppSettings.mqttHost;
    NSUInteger port = AppSettings.mqttPort;
    
    
    [self.sessionManager  connectTo:host
                               port:port
                                tls:YES
                          keepalive:60
                              clean:false
                               auth:false
                               user:nil
                               pass:nil
                               will:false
                          willTopic:nil
                            willMsg:nil
                            willQos:0
                     willRetainFlag:FALSE
                       withClientId:self.clientId
                     securityPolicy:policy
                       certificates:nil];
}

- (void)disconnect
{
    if (self.sessionManager) {
        [self.sessionManager disconnect];
    }
}

- (NSInteger)sendData:(NSData *)data topic:(NSString *)topic qos:(NSInteger)qos
{
    return [self.sessionManager sendData:data topic:topic qos:qos retain:NO];
}

- (void)subscribeTopics:(NSArray *)topics success:(ActionBlock)success failure:(FailureBlock)failure
{
    NSMutableDictionary *topicsDict = [[NSMutableDictionary alloc] initWithCapacity:topics.count];
    for (NSString *topic in topics) {
        [topicsDict setObject:@(2) forKey:topic];
    }
    
    [self.sessionManager addSubscriptions:topicsDict complete:^(NSError *error, NSArray<NSNumber *> *gQoss) {
        if (error) {
            DDLogError(@"Subscribe topics error = %@",error);
            if (failure) {
                failure(error);
            }
        }
        else{
            if (success) {
                success();
            }
        }
    }];
}

- (void)unsubscribeToTopics:(NSArray *)topics success:(ActionBlock)success failure:(FailureBlock)failure
{
    [self.sessionManager.session unsubscribeTopics:topics unsubscribeHandler:^(NSError *error) {
        if (!error) {
            NSMutableDictionary *newTopics = [self.sessionManager.subscriptions mutableCopy];
            for (NSString *topic in topics) {
                [newTopics removeObjectForKey:topic];
            }
            self.sessionManager.subscriptions = newTopics;
            if (success) {
                success();
            }
        }
        else{
            DDLogError(@"unsubscribeToTopics error = %@",error);
            if (failure) {
                failure(error);
            }
        }
    }];
    
    
}

- (void)addDelegate:(id<MCIMClientDelegate>)delegate
{
    if (![self.delegates containsObject:delegate]) {
        [self.delegates addObject:delegate];
    }
}

- (void)removeDelegate:(id<MCIMClientDelegate>)delegate
{
    [self.delegates removeObject:delegate];
}

#pragma mark - delegate

- (void)handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained
{
    [self.delegates enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id<MCIMClientDelegate> delegate = obj;
        if ([delegate respondsToSelector:@selector(imclient:didReceiveData:onTopic:retain:)]) {
            [delegate imclient:self didReceiveData:data onTopic:topic retain:retained];
        }
    }];
}

- (void)messageDelivered:(UInt16)msgID
{
    [self.delegates enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id<MCIMClientDelegate> delegate = obj;
        if ([delegate respondsToSelector:@selector(imclient:messageDelevied:)]) {
            [delegate imclient:self messageDelevied:msgID];
        }
    }];
}

#pragma mark - Private

- (void)commonInit
{    
    _sessionManager = [[MQTTSessionManager alloc] initWithPersistence:YES maxWindowSize:16 maxMessages:1024 maxSize:64 * 1024 * 1024];
    _sessionManager.delegate = self;
    
    __weak typeof(self) weakSelf = self;
    [self.KVOController observe:self.sessionManager keyPath:@"state" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        weakSelf.state = (MCIMClientState)weakSelf.sessionManager.state;
        [weakSelf.delegates enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id<MCIMClientDelegate> delegate = obj;
            if ([delegate respondsToSelector:@selector(imclient:connectionStateChanged:)]) {
                [delegate imclient:weakSelf connectionStateChanged:weakSelf.state];
            }
        }];
    }];
}


@end
