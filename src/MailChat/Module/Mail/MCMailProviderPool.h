//
//  MCMailProviderPool.h
//  NPushMail
//
//  Created by admin on 8/11/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCMailProviderProtocol.h"

@interface MCMailProviderPool : NSObject

+ (instancetype)shared;

- (id<MCMailProviderProtocol>)providerForAccount:(MCAccount *)account;


/**
 创建一个新的provider，此provider不加到pool中

 @param account Provider对应的账户信息

 @return 新的provider
 */
+ (id<MCMailProviderProtocol>)createProviderWithAccount:(MCAccount *)account;


/**
  更新provider
 */
- (void)updateProvider:(id<MCMailProviderProtocol>)provider accout:(MCAccount*)account;
@end
