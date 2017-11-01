//
//  MCMailBoxSyncManager.m
//  NPushMail
//
//  Created by admin on 8/24/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCMailBoxSyncManager.h"
#import "MCMailManager.h"
#import "MCMailContentTable.h"
#import "MCAccountManager.h"
#import "MCMailBoxSyncPool.h"
@interface MCMailBoxSyncManager ()

@property (nonatomic, strong) MCMailManager *mailManager;

@property (nonatomic,strong) MCMailContentTable *dbMail;

@property (nonatomic,strong) NSArray *uidSoredMails;

@property (atomic,assign) BOOL isLoading;

@property (nonatomic,strong) NSMutableArray *successCallbacks;
@property (nonatomic,strong) NSMutableArray *failureCallbacks;

@end

@implementation MCMailBoxSyncManager

- (instancetype)initWithMailBox:(MCMailBox *)mailBox
{
    if (self = [super init]) {
        _uidSoredMails = [NSMutableArray new];
        _successCallbacks = [NSMutableArray new];
        _failureCallbacks = [NSMutableArray new];
        _folder = mailBox;
        _dbMail = [MCMailContentTable new];
        MCAccount *account = [[MCAccountManager shared] accountWithId:mailBox.accountId];
        _mailManager = [[MCMailManager alloc] initWithAccount:account];
        
    }
    return self;
}

- (NSArray *)getLocalMailsWithWindowSize:(NSInteger)windowSize
{
    DDLogVerbose(@"getLocalMailsWithWindowSize : %ld",windowSize);
    if (windowSize == self.uidSoredMails.count) {
        return [self.uidSoredMails copy];
    }
    
    if (windowSize < self.uidSoredMails.count) {
        NSArray *localMails = [self.uidSoredMails subarrayWithRange:NSMakeRange(0, windowSize)];
        return localMails;
    }
    
    NSInteger maxUid = NSIntegerMax;
    if (self.uidSoredMails.count > 0) {
        MCMailModel *lastMail = self.uidSoredMails.lastObject;
        maxUid = lastMail.messageUid;
    }
    DDLogVerbose(@"folderId = %ld, folderPath = %@",self.folder.uid, self.folder.path);
    NSArray *cachedMails = [self.mailManager getLocalMailsInFolder:self.folder belowUid:maxUid limit:windowSize - self.uidSoredMails.count];
    NSMutableArray *mails = [[NSMutableArray alloc] initWithArray:self.uidSoredMails];
    [mails addObjectsFromArray:cachedMails];
    
    if (!self.uidSoredMails || self.uidSoredMails.count == 0) {
        self.uidSoredMails = [mails copy];
    }
    
    return mails;

}

- (NSArray*)getAllStarMails {
    
    NSMutableArray *starMails = [[self.mailManager getStarMails] mutableCopy];
    MCMailBoxSyncPool *boxSyncPool = [MCMailBoxSyncPool shared];
    NSArray *managers = boxSyncPool.managers;
    for (MCMailBoxSyncManager *manager in managers) {
        if (manager.uidSoredMails.count > 0) {
            for (MCMailModel *mail in manager.uidSoredMails) {
                if ([starMails containsObject:mail]) {
                    NSInteger index = [starMails indexOfObject:mail];
                    [starMails replaceObjectAtIndex:index withObject:mail];
                }
            }
        }
    }
    return starMails;
}

- (NSArray*)getContactMailsWithContact:(NSString*)email fromIndex:(NSInteger)index {
    
    NSMutableArray *contactMails = [[self.mailManager getContactMailsWithEmail:email fromIndex:index] mutableCopy];
    MCMailBoxSyncPool *boxSyncPool = [MCMailBoxSyncPool shared];
    NSArray *managers = boxSyncPool.managers;
    for (MCMailBoxSyncManager *manager in managers) {
        if (manager.uidSoredMails.count > 0) {
            for (MCMailModel *mail in manager.uidSoredMails) {
                if ([contactMails containsObject:mail]) {
                    NSInteger index = [contactMails indexOfObject:mail];
                    [contactMails replaceObjectAtIndex:index withObject:mail];
                }
            }
        }
    }
    return contactMails;
}

- (NSArray*)getLocalImportantMails {
    
    return [self.mailManager getLocalImportantMailsWithFolder:self.folder];
}

- (NSArray *)getLocalBackLogMails{
    return [self.mailManager getLocalBacklogMailsWithFolder:self.folder];
}

- (NSArray*)getPendingMails {
    return [self.mailManager getPendingMailsWithFolderId:self.folder.uid];
}

- (void)getLatestMailsWithWindowSize:(NSInteger)windowSize
                             success:(SuccessBlock)success
                             failure:(FailureBlock)failure
{
    DDLogVerbose(@"getLatestMailsWithWindowSize = %ld",windowSize);
    
    // 确保同一个文件夹的 windowSize 是一致的，这样，如果已经一个发起请求，直接等待回调即可，不必再请求一次。
    @synchronized (self) {
        if (success) {
            [self.successCallbacks addObject:[success copy]];
        }
        if (failure) {
            [self.failureCallbacks addObject:[failure copy]];
        }
        // 直接返回，等待同样的回调
        if (self.isLoading) {
            DDLogVerbose(@"isLoading, return directly");
            return;
        }
        self.isLoading = YES;
    }
    
    DDLogVerbose(@"fetchLatestMailsWithFolder");
    // 本地的数据
    NSMutableArray *localMails = [[self getLocalMailsWithWindowSize:windowSize] mutableCopy];
    // Fource update 设置为 YES 每次都去更新
    [self.mailManager fetchLatestMailsWithFolder:self.folder windowSize:windowSize forceUpdate:YES success:^(id response) {
        MCMailSyncResult *result = (MCMailSyncResult *)response;
        if (!result.hasNewData) {
            self.uidSoredMails = localMails;
            [self.mailManager updateMailStatus:localMails withFolder:self.folder success:^(id response) {
                [self success:response];
            } failure:^(NSError *error) {
                [self failure:error];
            }];
        }
        else {
            if (result.shouldClearCache) {
                [localMails removeAllObjects];
                [self.dbMail deleteMailsInFolder:self.folder.uid];
                
            }
            else if (result.isEnd) {
                [self.dbMail deleteMailsInFolder:self.folder.uid belowUid:[result.data.lastObject messageUid]];
            }
            
            if (localMails.count == 0) {
                [self.mailManager loadNewMailBriefWithFolder:self.folder mails:result.data success:^(id response) {
                    self.uidSoredMails = response;
                    [self success:response];
                } failure:^(NSError *error) {
                    [self failure:error];
                }];
            }
            else {
                NSArray *mergeResults = [[self class] mergeServerMails:result.data withLocalMails:localMails];
                NSArray *mails = mergeResults[0];
                NSArray *newMails = mergeResults[1];
                NSArray *deletedMails = mergeResults[2];
                NSArray *intersectionMails = mergeResults[3];
                [_dbMail deleteMails:deletedMails];
                [_dbMail updateMailStatus:intersectionMails];
                self.uidSoredMails = mails;
                // 更新新邮件的headers
                [self.mailManager loadNewMailBriefWithFolder:self.folder mails:newMails success:^(id response) {
                    [self success:mails];
                } failure:^(NSError *error) {
                    [self failure:error];
                }];
    
            }
        }
    } failure:^(NSError *error) {
        [self failure:error];
    }];
    
}

- (void)success:(id)response
{
    @synchronized (self) {
        DDLogVerbose(@"success callback");
        for (SuccessBlock cb in self.successCallbacks) {
            cb(response);
        }
        [self.successCallbacks removeAllObjects];
        self.isLoading = NO;
    }
}

- (void)failure:(NSError *)error
{
    @synchronized (self) {
        DDLogVerbose(@"failure callback");
        for (FailureBlock cb in self.failureCallbacks) {
            cb(error);
        }
        [self.failureCallbacks removeAllObjects];
        self.isLoading = NO;
    }
}

+ (NSArray *)mergeServerMails:(NSArray *)serverMails withLocalMails:(NSArray *)localMails
{
    NSMutableArray *mServerMails = [[NSMutableArray alloc] initWithArray:serverMails];
    NSMutableArray *newMails = [[NSMutableArray alloc] initWithCapacity:serverMails.count];
    NSMutableArray *deletedMails = [[NSMutableArray alloc] initWithCapacity:localMails.count];
    NSMutableArray *intersectionMails = [[NSMutableArray alloc] initWithCapacity:localMails.count];
    
    NSUInteger serverCount = serverMails.count;
    NSUInteger localCount = localMails.count;
    NSInteger i = 0, j = 0;
    MCMailModel *sMail, *lMail;
    while (i < serverCount && j < localCount) {
        sMail = serverMails[i];
        lMail = localMails[j];
        if (sMail.messageUid > lMail.messageUid) {
            [newMails addObject:sMail];
            i++;
        } else if (sMail.messageUid < lMail.messageUid){
            [deletedMails addObject:lMail];
            j++;
        }
        else {
            lMail.mailFlags = sMail.mailFlags;
            [intersectionMails addObject:lMail];
            mServerMails[i] = lMail;
            i++;
            j++;
        }
    }
    
    if (i < serverCount) {
        NSArray *noCached = [serverMails subarrayWithRange:NSMakeRange(i, serverCount - i)];
        [newMails addObjectsFromArray:noCached];
    }
    
    return @[mServerMails,newMails,deletedMails,intersectionMails];
}

@end
