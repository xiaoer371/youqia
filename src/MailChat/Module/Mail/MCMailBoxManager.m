//
//  MCMailBoxManager.m
//  NPushMail
//
//  Created by admin on 1/18/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCMailBoxManager.h"
#import "MCMailboxTable.h"
#import "MCAccountManager.h"
#import "MCMailProviderPool.h"

@implementation MCMailBoxManager
{
    MCMailboxTable *_db;
}

- (instancetype)init
{
    if (self = [super init]) {
        _db = [MCMailboxTable new];
    }
    return self;
}

- (NSArray *)getLocalFoldersForUser:(NSInteger)userId
{
    return [_db getModelsForUser:userId];
}

- (NSArray *)getSortLocalFoldersForUser:(NSInteger)userId {
    
    NSArray *models = [_db getModelsForUser:userId];
    
    //排序
    NSArray*array = [models sortedArrayUsingComparator:
                     ^NSComparisonResult(MCMailBox *obj1, MCMailBox *obj2) {
                         //先按type排序
                         NSNumber *number1 = [NSNumber numberWithInt:obj1.type];
                         NSNumber *number2 = [NSNumber numberWithInt:obj2.type];
                         NSComparisonResult result = [number1 compare:number2];
                         return result;
                     }];
    //对层级排序
    NSMutableArray *mailboxes = [NSMutableArray new];
    for (MCMailBox *box in array) {
        if (box.parentId > 0) {
            for (MCMailBox *b in array) {
                if (box.parentId == b.uid) {
                    NSInteger index = [mailboxes indexOfObject:b];
                    if (index != NSNotFound) {
                        [mailboxes insertObject:box atIndex:index +1];
                    } else {
                        [mailboxes addObject:box];
                    }
                    break;
                }
            }
        } else {
            [mailboxes addObject:box];
        }
    }
    return mailboxes;
}

- (MCMailBox *)getBoxWithId:(NSInteger)boxId
{
    return [_db getModelById:boxId];
}

- (MCMailBox *)getMailBoxWithAccount:(NSInteger)accountId path:(NSString *)boxPath
{
    return [_db getMailBoxWithAccount:accountId path:boxPath];
}

- (MCMailBox *)getMailBoxWithAccount:(NSInteger)accountId type:(MCMailFolderType)type
{
    return [_db getMailBoxWithAccount:accountId type:type];
}

- (MCMailBox *)getMailBoxWithAccount:(NSInteger)accountId folderName:(NSString *)name level:(NSInteger)level {
    return [_db getMailBoxWithAccount:accountId name:name level:level];
}

- (void)syncMailBoxesForUser:(NSInteger)userId success:(SuccessBlock)success failure:(FailureBlock)failure
{
    id<MCMailProviderProtocol> provider = [self providerWithAccountId:userId];
    [provider getAllFoldersSuccess:^(NSArray *serverFolders) {
        
        // 解决并发同步的问题
        @synchronized (self) {
            NSArray *localFolders = [self getSortLocalFoldersForUser:userId];
            NSArray *existedLocalFolders = [self removeDeletedFoldersWithServerFolders:serverFolders andLocalFolders:localFolders];
            NSArray *updatedFolders = [self saveServerFolders:serverFolders andLocalFolders:existedLocalFolders];
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    success(updatedFolders);
                });
            }
        }
        
    } failure:^(NSError *error) {
        DDLogError(@"getALLFolders failure = %@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            //失败时，加载本地数据
            if (failure) {
                failure(error);
            }
        });
    }];
}

- (void)getFolderInfo:(MCMailBox *)folder success:(SuccessBlock)success failure:(FailureBlock)failure
{
    id<MCMailProviderProtocol> provider = [self providerWithAccountId:folder.accountId];
    return [provider getFolderInfo:folder.path success:success failure:failure];
}

- (void)updateFolder:(MCMailBox *)folder withInfo:(MCMailBoxInfo *)folderInfo
{
    folder.uidNext = folderInfo.uidNext;
    folder.uidValidity = folderInfo.uidValidity;
    folder.totalCount = folderInfo.messageCount;
    folder.highestModSeqValue = folderInfo.highestModSeqValue;
    folder.syncUtc = [[NSDate new] timeIntervalSince1970];
    
    [_db updateModel:folder];
}

#pragma mark - Private

/**
 *  删掉服务器不存在的自定义文件夹，常规文件夹不删除
 *
 *  @param serverFolders 服务器的文件夹列表
 *  @param localFolders  本地的文件夹列表
 *
 *  @return 删除后本地剩下的文件夹
 */
- (NSArray *)removeDeletedFoldersWithServerFolders:(NSArray *)serverFolders andLocalFolders:(NSArray *)localFolders
{
    NSMutableArray *existedFolders = [[NSMutableArray alloc] initWithCapacity:localFolders.count];
    
    for (MCMailBox *box in localFolders) {
        
        // 重复的文件夹
        if ([existedFolders containsObject:box]) {
            [_db deleteById:box.uid];
            continue;
        }
        
        if ([serverFolders containsObject:box]) {
            [existedFolders addObject:box];
            continue;
        }
 
        [_db deleteById:box.uid];
    }
    
    return existedFolders;
}

- (NSArray *)saveServerFolders:(NSArray *)serverFolders andLocalFolders:(NSArray *)localFolders
{
    NSArray *newFolders = [self getNewFoldersWithServerFolders:serverFolders andLocalFolders:localFolders];
    
    if (newFolders.count == 0) {
        return localFolders;
    }
    
    NSMutableArray *newLocalFolders = [localFolders mutableCopy];
    //按Path排序才能保证parent box先被插入到数据库，才有id
    newFolders = [newFolders sortedArrayUsingComparator:^NSComparisonResult(MCMailBox *obj1, MCMailBox *obj2) {
        return [obj1.path compare:obj2.path];
    }];
    
    for (MCMailBox *box in newFolders) {
        
        NSString *delimiter = [NSString stringWithFormat:@"%c",box.delimiter];
        NSRange range = [box.path rangeOfString:delimiter options:NSBackwardsSearch];
        // 有上级文件夹
        if (range.length > 0 && ![box.path hasPrefix:@"INBOX."]) {
            NSString *parentPath = [box.path substringToIndex:range.location];
            MCMailBox *parentBox = [self findMailBoxByPath:parentPath inFolders:newLocalFolders];
            if (!parentBox) {
                DDLogError(@"parentBox of path :%@ does not existed", box.path);
            }
            box.parentId = parentBox.uid;
            //常规文件夹默认为一级文件夹
            if (box.type == MCMailFolderTypeOther) {
                 box.level = parentBox.level + 1;
            }
        }
        [_db insertModel:box];
        [newLocalFolders addObject:box];
    }
    //按文件夹类型排序
    NSArray*array = [newLocalFolders sortedArrayUsingComparator:
                     ^NSComparisonResult(MCMailBox *obj1, MCMailBox *obj2) {
                         //先按type排序
                         NSNumber *number1 = [NSNumber numberWithInt:obj1.type];
                         NSNumber *number2 = [NSNumber numberWithInt:obj2.type];
                         NSComparisonResult result = [number1 compare:number2];
                         return result;
                     }];
    //对层级排序
    NSMutableArray *mailboxes = [NSMutableArray new];
    for (MCMailBox *box in array) {
        if (box.parentId > 0) {
            for (MCMailBox *b in array) {
                if (box.parentId == b.uid) {
                    NSInteger index = [mailboxes indexOfObject:b];
                    if (index != NSNotFound) {
                        [mailboxes insertObject:box atIndex:index +1];
                    } else {
                        [mailboxes addObject:box];
                    }
                    break;
                }
            }
        } else {
            [mailboxes addObject:box];
        }
    }
    
    return mailboxes;
}

- (NSArray *)getNewFoldersWithServerFolders:(NSArray *)serverFolders andLocalFolders:(NSArray *)localFolders
{
    NSMutableArray *newFolders = [[NSMutableArray alloc] initWithCapacity:serverFolders.count];
    for (MCMailBox *box in serverFolders) {
        if (![localFolders containsObject:box]) {
            [newFolders addObject:box];
        }
    }
    return newFolders;
}

- (MCMailBox *)findMailBoxByPath:(NSString *)path inFolders:(NSArray *)folders
{
    for (MCMailBox *box in folders) {
        if ([box.path isEqualToString:path]) {
            return box;
        }
    }
    
    return nil;
}

- (id<MCMailProviderProtocol>)providerWithAccountId:(NSInteger)accountId
{
    MCAccount *account = [[MCAccountManager shared] accountWithId:accountId];
    if (account) {
        return [[MCMailProviderPool shared] providerForAccount:account];
    }
    
    return nil;
}


@end
