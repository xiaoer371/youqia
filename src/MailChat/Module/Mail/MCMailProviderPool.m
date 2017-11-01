//
//  MCMailProviderPool.m
//  NPushMail
//
//  Created by admin on 8/11/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCMailProviderPool.h"
#import "MCIMAPProvider.h"
#import "MCGmailProvider.h"

@interface MCMailProviderPool ()

// 因为Account的数据不会很多，用Dictionary会占用内存，直接用Array
@property (nonatomic,strong) NSMutableArray *proviers;

@end

@implementation MCMailProviderPool

- (instancetype)init
{
    self = [super init];
    if (self) {
        _proviers = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (instancetype)shared
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (id<MCMailProviderProtocol>)providerForAccount:(MCAccount *)account
{
    id<MCMailProviderProtocol> provider = [self findProvierWithAccount:account];
    if (provider) {
        return provider;
    }
    
    @synchronized (_proviers) {
        provider = [self findProvierWithAccount:account];
        if (!provider) {
            provider = [self.class createProviderWithAccount:account];
            [_proviers addObject:provider];
        }
        
        return provider;
    }
    
}

- (id<MCMailProviderProtocol>)findProvierWithAccount:(MCAccount *)account
{
    for (id<MCMailProviderProtocol> provider in _proviers) {
        if ([provider.account isEqual:account]) {
            return provider;
        }
    }
    
    return nil;
}

+ (id<MCMailProviderProtocol>)createProviderWithAccount:(MCAccount *)account
{
    if (account.type == MCMailTypeGmail && account.authType == MCAccountAuthTypeOAuth) {
        return [[MCGmailProvider alloc] initWithAccount:account];
    }
    else {
        return [[MCIMAPProvider alloc] initWithAccount:account];
    }
}

- (void)updateProvider:(id<MCMailProviderProtocol>)provider accout:(MCAccount*)account {
    
    if (!provider) {
        return;
    }
    @synchronized (_proviers) {
        //更新prevideer；
        id <MCMailProviderProtocol>oldPrevider = [self findProvierWithAccount:account];
        if (oldPrevider) {
            NSInteger index = [_proviers indexOfObject:oldPrevider];
            [_proviers replaceObjectAtIndex:index withObject:provider];
        } else {
            [_proviers addObject:provider];
        }
    }
}

@end
