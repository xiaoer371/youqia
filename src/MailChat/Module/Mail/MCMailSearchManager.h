//
//  MCMailSearchManager.h
//  NPushMail
//
//  Created by zhang on 16/5/24.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCMailProviderProtocol.h"
#import "MCMailContentTable.h"
@interface MCMailSearchManager : NSObject


- (instancetype)initWithAccount:(MCAccount *)account;

- (void)beginSeachWithlocMails:(NSArray*)locMails;

- (void)deleteSearchMails:(NSArray*)mails;

- (NSArray*)searchLocMailsSearchText:(NSString*)searchText searchKind:(MCSearchMailKind) searchKind;

- (void)searchFromServerWithFolder:(MCMailBox*)folder success:(SuccessBlock)success failure:(FailureBlock)failure;

- (void)loadMoreSearchWithfolder:(MCMailBox*)folder  success:(SuccessBlock)success failure:(FailureBlock)failure;


@end
