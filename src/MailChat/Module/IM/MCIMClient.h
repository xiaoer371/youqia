//
//  MCIMConnection.h
//  NPushMail
//
//  Created by admin on 2/25/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCWeakProxy.h"

typedef NS_ENUM(int, MCIMClientState) {
    MCIMClientStateStarting,
    MCIMClientStateConnecting,
    MCIMClientStateError,
    MCIMClientStateConnected,
    MCIMClientStateClosing,
    MCIMClientStateClosed
};


@class MCIMClient;

@protocol MCIMClientDelegate <NSObject>
@optional
- (void)imclient:(MCIMClient *)client didReceiveData:(NSData *)data onTopic:(NSString *)topic retain:(BOOL)retain;
- (void)imclient:(MCIMClient *)client messageDelevied:(NSInteger)msgId;
- (void)imclient:(MCIMClient *)client connectionStateChanged:(MCIMClientState)state;

@end

@interface MCIMClient : NSObject

+ (instancetype)shared;

@property (nonatomic,assign) MCIMClientState state;

@property (nonatomic,strong) NSArray *topics;

- (instancetype)initWithClientId:(NSString *)clientId;

- (void)connect;
- (void)disconnect;

- (void)subscribeTopics:(NSArray *)topics success:(ActionBlock)success failure:(FailureBlock)failure;
- (void)unsubscribeToTopics:(NSArray *)topics success:(ActionBlock)success failure:(FailureBlock)failure;;

/**
 *  添加回调。
 *
 *  @param delegate 要添加的回调代理，target 必须是 MCIMConnectionDelegate
 */
- (void)addDelegate:(MCWeakProxy *)delegate;
- (void)removeDelegate:(MCWeakProxy *)delegate;

- (NSInteger)sendData:(NSData *)data topic:(NSString *)topic qos:(NSInteger)qos;

@end
