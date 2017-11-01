//
//  MailManager.m
//  NPushMail
//
//  Created by admin on 12/14/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import "MCMailManager.h"
#import "MCMailProviderProtocol.h"
#import "MCIMAPProvider.h"
#import "MCMailBoxManager.h"
#import "MCAppStatus.h"
#import "MCMailSyncTable.h"
#import "MCMailContentTable.h"
#import "MCMailAttachmentManager.h"
#import "NSString+MCO.h"
#import "MCFileCore.h"
#import "MCFileManager.h"
#import "MCUDID.h"
#import "MCAttachment.h"
#import "MCCallbackUtils.h"
#import "MCAccountManager.h"
#import "MCMailSearchManager.h"
#import "MCNotificationCenter.h"
#import "MCContactManager.h"
#import "MCDatabaseHelper.h"
#import "MCMailProviderPool.h"
#import "MCModelConversion.h"
#import "MCMailTagManager.h"

@implementation MCMailSyncResult

@end

static NSInteger const kMailChatSyncMaxTryTimes = 5;

@interface MCMailManager ()

@property (nonatomic,strong) MCAccount *account;
@property (nonatomic,strong) id<MCMailProviderProtocol> provider;
@property (nonatomic,strong) MCMailSyncTable *dbSync;
@property (nonatomic,strong) MCMailContentTable *dbMail;
@property (nonatomic,strong) MCMailBoxManager *boxManager;
@property (nonatomic,strong) MCMailAttachmentManager *attachmentManager;
@property (nonatomic,strong) MCMailBox *syncBox;
@property (nonatomic,strong) MCMailSearchManager *searchManager;
@property (nonatomic,strong) MCMailTagManager *tagManager;

// 按uid从大到小排列，已经显示的邮件
@property (nonatomic,strong) NSArray *uidSortedMails;
//搜索结果uid
@property (nonatomic,strong)NSMutableArray *searchResultUids;
@end

@implementation MCMailManager

#pragma mark - Lifecycle

- (instancetype)init
{
    if (self = [super init]) {
        _dbMail = [MCMailContentTable new];
        _dbSync = [MCMailSyncTable new];
    }
    
    return self;
}

- (instancetype)initWithAccount:(MCAccount *)account
{
    if (self = [super init]) {
        _account = account;
        
        _dbMail = [MCMailContentTable new];
        _dbSync = [MCMailSyncTable new];
        
        _provider = [[MCMailProviderPool shared] providerForAccount:account];
        _boxManager = [[MCMailBoxManager alloc] init];
        _attachmentManager = [[MCMailAttachmentManager alloc]initWithProvider:_provider];
        _searchResultUids = [NSMutableArray new];
        _searchManager = [[MCMailSearchManager alloc] initWithAccount:account];
        _tagManager = [[MCMailTagManager alloc] init];
    }
    return self;
}

#pragma mark - Login

+ (void)loginWithUserName:(NSString *)userName
                 password:(NSString *)password
                   config:(MCMailConfig *)config
                  success:(ActionBlock)success
                  failure:(FailureBlock)failure
{
    MCAccount *account = [[MCAccount alloc] init];
    account.email = userName;
    account.password = password;
    account.config = config;
    MCIMAPProvider *provider = [MCMailProviderPool createProviderWithAccount:account];
    [provider loginSuccess:^{
        [[MCMailProviderPool shared] updateProvider:provider accout:account];
        if (success) {
            success();
        }
    }  failure:failure];
}

- (void)loginSuccess:(ActionBlock)success failure:(FailureBlock)failure
{
    [self.provider loginSuccess:success failure:failure];
}

#pragma mark - Folder

- (void)getAllFoldersSuccess:(SuccessBlock)success failure:(FailureBlock)failure
{
    NSInteger accountId = self.account.accountId;
    if (AppStatus.networkStatus == NotReachable) {
        if (success) {
            NSArray *folders = [self getLocalFoldersWithUserId:accountId];
            success(folders);
        }
    }
    else{
        [self.boxManager syncMailBoxesForUser:accountId success:success failure:failure];
    } 
}

- (NSArray*)getLocalFoldersWithUserId:(NSInteger)userId {
    return [self.boxManager getSortLocalFoldersForUser:userId];
}

#pragma mark - Sync

- (void)syncMailsCompletion:(FailureBlock)completion
{
    NSInteger accountId = self.account.accountId;
    NSArray *syncModels = [_dbSync getModelsWithAccountId:accountId];
    DDLogVerbose(@"Sync models count = %ld", (long)syncModels.count);
    // 不需要同步
    if (syncModels.count == 0) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    if (AppStatus.networkStatus == NotReachable) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __weak typeof(self) weakSelf =self;
        NSMutableArray *errors = [NSMutableArray new];
        dispatch_group_t group = dispatch_group_create();
        // NOTE: 目前邮件一封一封的同步，因为需要同步的邮件不会非常多，所以性能上暂时不考虑
        for (MCMailSyncModel *model in syncModels) {
            // 有些同步会错误，如果超过尝试次数，直接删除
            if (model.tryTimes > kMailChatSyncMaxTryTimes) {
                [self.dbSync deleteById:model.uid];
                continue;
            }
            MCMailModel *mail = [_dbMail getModelById:model.mailId];
            if (!mail) {
                [self.dbSync deleteById:model.uid];
                continue;
            }
            dispatch_group_enter(group);
            if (model.syncType == MCMailSyncRead) {
                MCMailFlagStoreKind kind = mail.isRead ? MCMailFlagStoreKindAdd : MCMailFlagStoreKindRemove;
                [self.provider storeFlag:MCMailFlagSeen toMails:@[mail] storeKind:kind success:^() {
                    [weakSelf.dbSync deleteById:model.uid];
                    dispatch_group_leave(group);
                } failure:^(NSError *error) {
                    model.tryTimes++;
                    [weakSelf.dbSync updateTryTimes:model];
                    [errors addObject:error];
                    dispatch_group_leave(group);
                }];
            }
            else if (model.syncType == MCMailSyncStar){
                MCMailFlagStoreKind kind = mail.isStar ? MCMailFlagStoreKindAdd : MCMailFlagStoreKindRemove;
                [_provider storeFlag:MCMailFlagStar toMails:@[mail] storeKind:kind success:^() {
                    [weakSelf.dbSync deleteById:model.uid];
                    dispatch_group_leave(group);
                } failure:^(NSError *error) {
                    model.tryTimes++;
                    [weakSelf.dbSync updateTryTimes:model];
                    [errors addObject:error];
                    dispatch_group_leave(group);
                }];
            }
            else{
                MCMailBox *fromBox = [self.boxManager getBoxWithId:model.fromBoxId];
                MCMailBox *toBox = [self.boxManager getBoxWithId:model.toBoxId];
                [self moveMails:@[mail] fromFolder:fromBox toFolder:toBox success:^{
                    [weakSelf.dbSync deleteById:model.uid];
                    dispatch_group_leave(group);
                } failure:^(NSError *error) {
                    model.tryTimes++;
                    [weakSelf.dbSync updateTryTimes:model];
                    [errors addObject:error];
                    dispatch_group_leave(group);
                }];
            }
        }
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        if (errors.count > 0) {
            DDLogError(@"Sync mails error = %@",errors[0]);
            completion(errors[0]);
        }
        else{
            completion(nil);
        }
    });
}

#pragma mark - Mail


- (NSArray *)getPendingMailsWithFolderId:(NSInteger)folderId {
     return [_dbMail getPendingMailsWithBoxId:folderId];
}

- (NSArray *)getStarMails {
    return [_dbMail getStarMailsWithAccountId:self.account.accountId];
}

- (NSArray *)getLocalMailsInFolder:(MCMailBox *)folder beginUid:(NSInteger)beginUid endUid:(NSInteger)endUid
{
    return [_dbMail getMailsWithFolder:folder.uid beginUid:beginUid endUid:endUid];
}

- (NSArray *)getLocalMailsInFolder:(MCMailBox *)folder belowUid:(NSInteger)belowId limit:(NSInteger)limit
{
    return [_dbMail getMailsWithFolder:folder.uid belowUid:belowId limit:limit];
}

- (NSArray *)getLocalImportantMailsWithFolder:(MCMailBox*)folder {
    return [_dbMail getAllImportantMailsWithFolder:folder];
}

- (NSArray *)getLocalBacklogMailsWithFolder:(MCMailBox*)folder {
    return [_dbMail getAllBackLogMailsWithFolder:folder];
}

- (NSInteger)getUnreadMailCountWihtFolder:(MCMailBox *)folder limit:(NSInteger)limit {
    return [_dbMail unreadMailCountWithFolder:folder limit:limit];
}

- (MCMailModel *)getLocalMailWithMessageId:(NSString *)messageId
{
    return [_dbMail getMailWithMessageId:messageId];
}

- (MCMailModel *)getMailWithSubject:(NSString *)subject box:(NSInteger)boxId
{
    return [_dbMail getMailWithSubject:subject box:boxId];
}

- (NSArray*)getContactMailsWithEmail:(NSString*)email fromIndex:(NSInteger)index {
    //获取往来邮件 过滤掉已删除，草稿箱，待发送 ，垃圾箱 文件夹邮件
    MCMailBox *draftBox = [self.boxManager getMailBoxWithAccount:self.account.accountId type:MCMailFolderTypeDrafts];
    MCMailBox *pendingBox = [self.boxManager getMailBoxWithAccount:self.account.accountId type:MCMailFolderTypePending];
    MCMailBox *spamBox = [self.boxManager getMailBoxWithAccount:self.account.accountId type:MCMailFolderTypeSpam];
    MCMailBox *trashBox = [self.boxManager getMailBoxWithAccount:self.account.accountId type:MCMailFolderTypeTrash];
    NSArray *boxUids = @[@(draftBox.uid),@(pendingBox.uid),@(spamBox.uid),@(trashBox.uid)];
    return [_dbMail getContactMailsWithEmail:email  outFolderUids:boxUids fromIndex:index];
}

- (void)fetchLatestMailsWithFolder:(MCMailBox *)folder windowSize:(NSInteger)windowSize forceUpdate:(BOOL)forceUpdate success:(SuccessBlock)success failure:(FailureBlock)failure
{
    __weak typeof(self) wSelf = self;
    // 先同步代处理的命令
    [self syncMailsCompletion:^(NSError *error) {
        
        [self.boxManager getFolderInfo:folder success:^(MCMailBoxInfo *folderInfo) {
            
            MCMailSyncResult *syncResult = [MCMailSyncResult new];
            
            //没有新邮件，更新显示邮件的状态
            if (folder.uidNext == folderInfo.uidNext &&
                folder.totalCount == folderInfo.messageCount
                && !forceUpdate) {
                syncResult.hasNewData = NO;
                if (success) {
                    success(syncResult);
                }
            }
            // 文件夹被清空了，需要删除本地的数据
            else if (folderInfo.messageCount == 0) {
                [wSelf.boxManager updateFolder:folder withInfo:folderInfo];
                syncResult.hasNewData = YES;
                syncResult.shouldClearCache = YES;
                if (success) {
                    success(syncResult);
                }
            }
            else {
                // 如果uidValidity 改变了，要清除本地数据
                if (folder.uidValidity != 0 && folder.uidValidity != folderInfo.uidValidity) {
                    DDLogError(@"uidValidity of folder:%@ is changed", folder.path);
                    syncResult.shouldClearCache = YES;
                }
                
                syncResult.hasNewData = YES;
                NSInteger messageCountToLoad = MIN(folderInfo.messageCount, windowSize);
                [wSelf.provider getMailsByNumbersInFolder:folder
                      requestKind:MCIMAPMessageRequestKindFlags
                          numbers:NSMakeRange(folderInfo.messageCount - messageCountToLoad + 1, (messageCountToLoad - 1))
                          success:^(id response) {
                              [wSelf.boxManager updateFolder:folder withInfo:folderInfo];
                              NSArray *mails = (NSArray *)response;
                              //加载的数量小于预期的，删除缓存的邮件
                              if (mails.count < messageCountToLoad || mails.count == folderInfo.messageCount) {
                                  syncResult.isEnd = YES;
                              }
                              syncResult.data = mails;
                              if (success) {
                                  success(syncResult);
                              }
                              
                          } failure:^(NSError *error) {
                              if (failure) {
                                  failure(error);
                              }
                          }];
            }
        } failure:^(NSError *error) {
            failure(error);
        }];
    }];
}


- (void)loadMailContent:(MCMailModel *)mail
               inFolder:(MCMailBox *)folder
                 urgent:(BOOL)urgent
                 success:(SuccessBlock)success
                 failure:(FailureBlock)failure {
    [_provider updateMailContent:mail inFolder:folder urgent:urgent success:^(id response) {
        if ([self needTagImportantMail:mail]) {
            MCMailTagManager *tagMgr = [[MCMailTagManager alloc] init];
            mail.tags = [tagMgr mailTagForMail:mail];
        }
        [_dbMail updateMailContent:mail];
        [MCCallbackUtils reportSuccessOnMainThread:success withResponse:mail];
    } failure:^(NSError *error) {
        DDLogError(@"load mail content error == %@, messageId == %ld",error,(long)mail.messageUid);
        [MCCallbackUtils reportErrorOnMainThread:failure withError:error];
    }];
}

- (void)moveMails:(NSArray *)mails
       fromFolder:(MCMailBox *)fromFolder
         toFolder:(MCMailBox *)toFolder
          success:(ActionBlock)success
          failure:(FailureBlock)failure {
    
    if (fromFolder.type == MCMailFolderTypePending) {
        [_dbMail deleteMails:mails];
        if (success) {
           success();
        }
        return;
    }
    if (fromFolder.type == MCMailFolderTypeDrafts) {
        toFolder = fromFolder;
    } else if (!toFolder) {
        toFolder = [self getBoxIdWithFolderType:MCMailFolderTypeTrash];
    }
    //本地删除移动
    if ([toFolder.path isEqualToString:fromFolder.path]) {
        //已删除直接删除
        [_dbMail deleteMails:mails];
        
    } else {
        //删除邮件取消tags
        for (MCMailModel *mail in  mails) {
            mail.tags = MCMailTagNone;
        }
        [_dbMail moveMails:mails toFolder:toFolder];
    }
    if (!toFolder) {
        return;
    }
    if (fromFolder.type == MCMailFolderTypeStarred) {
        for (MCMailModel *mail in mails) {
            __weak typeof(self)weekSelf = self;
            [_provider moveMails:@[mail] fromFolder:mail.folder toFolder:toFolder.path success:success failure:^(NSError *error) {
                MCMailSyncModel *syncModel = [weekSelf mailSyncModelWithMail:mail toBoxId:toFolder.uid syncType:MCMailSyncDeleteOrMove];
                [_dbSync insertModel:syncModel];
            }];
            
        }
        
    } else {
        __weak typeof(self)weekSelf = self;
        [_provider moveMails:mails fromFolder:fromFolder.path toFolder:toFolder.path success:success failure:^(NSError *error) {
            for (MCMailModel *mail in mails) {
                MCMailSyncModel *syncModel = [weekSelf mailSyncModelWithMail:mail toBoxId:toFolder.uid syncType:MCMailSyncDeleteOrMove];
                [_dbSync insertModel:syncModel];
            }
            if (failure) {
                failure(error);
            }
        }];
    }
}

- (void)setReadFlag:(BOOL)isRead forMails:(NSArray *)mails success:(SuccessBlock)success failure:(FailureBlock)failure {
    
    NSMutableArray*needMarkMails = [NSMutableArray new];//过滤需要mark的邮件
    for (MCMailModel*mail in mails) {
        if (mail.isRead == !isRead) {
            mail.isRead = isRead;
            [needMarkMails addObject:mail];
        }
    }
    if (success) {
       success([NSNumber numberWithInteger:needMarkMails.count]);
    }
    [_dbMail updateMailStatus:needMarkMails];
     __weak typeof(self)weekSelf = self;
    [_provider storeFlag:MCMailFlagSeen toMails:needMarkMails storeKind:isRead?MCMailFlagStoreKindAdd:MCMailFlagStoreKindRemove success:nil failure:^(NSError *error) {
        for (MCMailModel *mail in needMarkMails) {
            MCMailSyncModel *syncModel = [weekSelf mailSyncModelWithMail:mail toBoxId:mail.boxId syncType:MCMailSyncRead];
            [_dbSync insertModel:syncModel];
        }
    }];
}

- (void)setStarBoxReadFlag:(BOOL)isRead forMails:(NSArray*)mails sucess:(SuccessBlock)success failure:(FailureBlock)failure {
    NSMutableArray*needMarkMails = [NSMutableArray new];//过滤需要mark的邮件
    for (MCMailModel*mail in mails) {
        if (mail.isRead == !isRead) {
            mail.isRead = isRead;
            [needMarkMails addObject:mail];
        }
    }
    
    if (success) {
        success(needMarkMails);
    }
    [_dbMail updateMailStatus:needMarkMails];
    
    __weak typeof(self)weekSelf = self;
    for (MCMailModel *mail in needMarkMails) {
        @synchronized (mail) {
            [_provider storeFlag:MCMailFlagSeen toMails:@[mail] storeKind:isRead?MCMailFlagStoreKindAdd:MCMailFlagStoreKindRemove success:nil failure:^(NSError *error) {
                MCMailSyncModel *syncModel = [weekSelf mailSyncModelWithMail:mail toBoxId:mail.boxId syncType:MCMailSyncRead];
                [_dbSync insertModel:syncModel];
            }];
        }
    }
}

- (void)setStarFlag:(BOOL)star forMails:(NSArray *)mails success:(ActionBlock)success failure:(FailureBlock)failure {
    
    NSMutableArray*needMarkMails = [NSMutableArray new];
    for (MCMailModel*mail in mails) {
        if (mail.isStar  != star) {
            mail.isStar = star;
            [needMarkMails addObject:mail];
        }
    }
    
    [_dbMail updateMailStatus:needMarkMails];
    __weak typeof(self)weekSelf = self;
    [_provider storeFlag:MCMailFlagStar toMails:needMarkMails storeKind:star?MCMailFlagStoreKindAdd:MCMailFlagStoreKindRemove success:success failure:^(NSError *error) {
        for ( MCMailModel *mail in needMarkMails) {
            MCMailSyncModel *syncModel = [weekSelf mailSyncModelWithMail:mail toBoxId:mail.boxId syncType:MCMailSyncStar];
            [_dbSync insertModel:syncModel];
        }
    }];
    
    //添加收藏权重
    if (star) {
        for (MCMailModel *mail in needMarkMails) {
            if (!mail.from) {
                continue;
            }
            MCContactModel *contact = [MCModelConversion contactModelWithMailAddress:mail.from];
            [[MCContactManager sharedInstance] addWeight:10 toContact:contact];
        }
    }
}

- (void)setAnswerFlag:(BOOL)isAnswer
              forMail:(MCMailModel*)mail
              success:(ActionBlock)success
              failure:(FailureBlock)failure {
    mail.isAnswer = isAnswer;
    [_dbMail updateMailStatus:@[mail]];
    [_provider storeFlag:MCMailFlagAnswered toMails:@[mail]
               storeKind:isAnswer?MCMailFlagStoreKindAdd :MCMailFlagStoreKindRemove
                 success:success
                 failure:failure];
}

+ (MCMailModel *)mailForNotification:(MCMailNotificationModel *)notifyModel
{
    MCAccount *account = [[MCAccountManager shared] accountWithEmail:notifyModel.toMail];
    if (!account) {
        DDLogError(@"[addMailNotification] cannot find account for email %@",notifyModel.toMail);
        return nil;
    }
    
    MCMailBoxManager *boxMgr = [MCMailBoxManager new];
    MCMailBox *box = [boxMgr getMailBoxWithAccount:account.accountId path:notifyModel.folder];
    if (!box) {
        if (notifyModel.folderName) {
            box = [boxMgr getMailBoxWithAccount:account.accountId folderName:notifyModel.folderName level:notifyModel.level];
        }
        if (!box) {
            DDLogError(@"[addMailNotification] cannot find folder %@",notifyModel.folder);
            return nil;
        }
    }
    
    if (!notifyModel.mailUid) {
        return nil;
    }
    
    MCMailContentTable *mailTable = [MCMailContentTable new];
    MCMailModel *mail = [mailTable getMailWithFolder:box.uid mailUid:notifyModel.mailUid];
    if (mail) {
        return mail;
    }
    
    mail = [MCMailModel new];
    mail.accountId = account.accountId;
    mail.boxId = box.uid;
    mail.folder = box.path;
    mail.messageUid = notifyModel.mailUid;
    mail.from = notifyModel.from;
    MCMailAddress *toAddr = [[MCMailAddress alloc] init];
    toAddr.email = account.email;
    toAddr.name = account.displayName;
    mail.to = @[toAddr];
    mail.subject = notifyModel.subject;
    mail.messageContentString = notifyModel.briefContent;
    mail.receivedDate = [NSDate dateWithTimeIntervalSince1970:notifyModel.time];
    mail.isDeleted = YES;
    mail.isPush = YES;
    mail.mailFlags = mail.mailFlags&(~MCMailFlagStar);
    return mail;
}

+ (void)addMail:(MCMailModel *)mail
{
    MCMailContentTable *mailTable = [MCMailContentTable new];
    [mailTable insertModel:mail];
}

- (void)updateTagsMails:(NSArray *)mails {
    [_dbMail updateMailStatus:mails];
}

#pragma mark - attachment

- (BOOL)getAttachmentDataInfo:(MCMailAttachment*)attachment progress:(ProgressBlock)progress success:(SuccessBlock)success failure:(FailureBlock)failure {
    
     return [_attachmentManager getAttachmentDataWith:attachment progress:progress success:success failure:failure];
}

- (void)loadInlineAttachment:(NSArray*)inlineAttachments success:(SuccessBlock)success failure:(FailureBlock)failure {
    [_attachmentManager toLoadInlineAttachment:inlineAttachments success:success failure:failure];
}

- (NSArray*)getAttachmentsWithMailId:(NSInteger)mailId {
    return [_attachmentManager getAttachmentsWithMail:mailId];
}

- (NSArray*)getInlineAttachmetsWithMailId:(NSInteger)mailId {
    
    return [_attachmentManager getInlineAttachmemtWithMail:mailId];
}

- (void)updataAttachmentInfo:(MCMailAttachment*)attachment mail:(MCMailModel*)mail{ 
    attachment.cid = nil;
    mail.hasAttachment = YES;
    if (attachment.localPath) {
        attachment.isDownload = YES;
    }
    [_attachmentManager updataAttachmentInfoWithAttachment:attachment];
    [_dbMail updateMailContent:mail];
}

- (void)deleteAttachmentLocalFileUpdateInfoWithUid:(NSInteger)uid {
    [_attachmentManager deleteAttachmentLocalFielWithUid:uid];
}

//TODO:搜索邮件

- (void)beginSearchWithLocMails:(NSArray *)locMails {
    [_searchManager beginSeachWithlocMails:locMails];
}
- (void)deleteSearchMails:(NSArray*)mails {
    [_searchManager deleteSearchMails:mails];
}

- (NSArray*)searchLocMailsSearchText:(NSString*)searchText
                          searchKind:(NSInteger)searchKind
{
    return [_searchManager searchLocMailsSearchText:searchText searchKind:searchKind];
}

- (void)searchFromServerWithFolder:(MCMailBox*)folder
                           success:(SuccessBlock)success
                           failure:(FailureBlock)failure {
    [_searchManager searchFromServerWithFolder:folder success:success failure:failure];
}

- (void)loadMoreSearchWithfolder:(MCMailBox*)folder
                        success:(SuccessBlock)success
                        failure:(FailureBlock)failure {
    [_searchManager loadMoreSearchWithfolder:folder success:success failure:failure];
}

#pragma mark - Send mail

- (void)smtpConnectSuccess:(SuccessBlock)success failure:(FailureBlock)failure {
    [_provider smtpConnectWithSuccess:success failure:failure];
}

- (void)sendEmailWithMail:(MCMailModel*)mail success:(SuccessBlock)success failure:(FailureBlock)failure progress:(ProgressBlock)proggress {
    
    __block MCMailBox* pendingBox = [self getBoxIdWithFolderType:MCMailFolderTypePending];
    __block MCMailBox* sentBox = [self getBoxIdWithFolderType:MCMailFolderTypeSent];
    MCMailBox *draftsBox = [self getBoxIdWithFolderType:MCMailFolderTypeDrafts];
    if (mail.boxId == draftsBox.uid) {
        DDLogDebug(@"草稿箱邮件发送");
        [self moveMails:@[mail] fromFolder:draftsBox toFolder:draftsBox success:nil failure:nil];
    }
    
    NSData *mailData = [self mailDataWithMail:mail];
    __weak typeof(self)weekSelf = self;
    [_provider sendEmailWithData:mailData success:^(id response) {
        [self eventSendStatus:YES];
        //本地保存已发送 （需获取对于邮箱的boxid）
        if (!sentBox) {
            DDLogDebug(@"无法找到已发送文件夹");
            if (success) { 
                success(nil);
            }
            return;
        }
        [weekSelf saveTempMailWithMail:mail MailBox:sentBox];
        //同步到已发送文件夹
        [_provider appendMailWithData:mailData folder:sentBox.path isSent:YES success:nil failure:nil];
        if (success) {
            success(nil);
        }
    } failure:^(NSError *error) {
        //TODO:本地保存待发送 （需获取对于邮箱的boxid）
        //重置messageuid
        mail.messageUid = arc4random() % NSNotFound;
        NSString*message = error.userInfo[@"MCOSMTPResponseKey"];
        if (message) {
            mail.messageContentString = message;
        } else {
            mail.messageContentString = PMLocalizedStringWithKey(@"PM_Mail_SendFailure");
        }
        [weekSelf saveTempMailWithMail:mail MailBox:pendingBox];
        if (failure) {
            DDLogDebug(@"%@",error);
            failure(error);
        }
        [self eventSendStatus:NO];
    } progress:proggress];
    
}

- (void)eventSendStatus:(BOOL)success
{
    NSString *key = @"others";
    if (AppStatus.currentUser.type == MCMailTypeGmail) {
        key = @"gmail";
    }
    NSString *value = success ? @"success" : @"failure";
    [MCUmengManager addEventWithKey:mc_mail_send attributes:@{key : value}];
}

//保存草稿
- (void)saveDraftWithMail:(MCMailModel *)mail  success:(SuccessBlock)success failure:(FailureBlock)failure {
    
    NSData *mailData = [self mailDataWithMail:mail];
    //本地保存 （然后根据获取服务器草稿邮件对比删除）  ps：上传服务器失败后是否再次上传（保存失败记录）
    MCMailBox *mailBox = [self getBoxIdWithFolderType:MCMailFolderTypeDrafts];
    if (!mailBox) {
        return;
    }
    [self saveTempMailWithMail:mail MailBox:mailBox];
    [_provider moveMails:@[mail] fromFolder:mailBox.path toFolder:mailBox.path success:^{
        [_provider appendMailWithData:mailData folder:mailBox.path isSent:NO success:success failure:failure];
    } failure:^(NSError *error) {
        [_provider appendMailWithData:mailData folder:mailBox.path isSent:NO success:success failure:failure];
    }];
}
//TODO:生成.eml文件
- (MCMailAttachment*)addMailAsAttachmentWithMail:(MCMailModel*)mail {
    
    MCMailAttachment *emlFile = [MCMailAttachment new];
    emlFile.name = [NSString stringWithFormat:@"%@.eml",mail.subject];
    emlFile.fileExtension = @"eml";
    emlFile.data = [self mailDataWithMail:mail];
    return emlFile;
}

//TODO:取消操作
- (void)cancelOpration {
    [_provider cancelImapOprations];
}

#pragma mark - Delegate

- (void)accountAuthDidChanged:(MCAccount *)account
{
    [[MCAccountManager shared] updateAccount:account];
}

#pragma mark - Private

- (NSData *)mailDataWithMail:(MCMailModel *)mail
{
    return [self.provider buildMessageDataWithMail:mail];
}

- (MCMailBox*)getBoxIdWithFolderType:(MCMailFolderType)mCMailFolderType {
    
    NSArray *mailBoxses = [_boxManager getLocalFoldersForUser:self.account.accountId];
    for (MCMailBox *mailBox in mailBoxses) {
        if (mailBox.type == mCMailFolderType) {
            return mailBox;
        }
    }
    return nil;
}

//保存待发送
- (BOOL)savePendingMail:(MCMailModel*)mail {
    MCMailBox* pengdingBox = [self getBoxIdWithFolderType:MCMailFolderTypePending];
    if (pengdingBox) {
        [self saveTempMailWithMail:mail MailBox:pengdingBox];
        return YES;
    }
    return NO;
}
- (void)saveTempMailWithMail:(MCMailModel*)mail MailBox:(MCMailBox*)mailBox {
    
    mail.boxId = mailBox.uid;
    mail.folder = mailBox.path;
    mail.accountId = self.account.accountId;
    mail.receivedDate = [NSDate date];
    mail.isRead = YES;
    mail.isDeleted = YES;
    NSMutableArray* attachments = [NSMutableArray new];
    [attachments addObjectsFromArray:mail.attachments];
    [attachments addObjectsFromArray:mail.inlineAttachments];
    for (MCMailAttachment *attach in attachments ) {
        if (attach.data && !attach.localPath) {
            MCFileManager *fileManager = [MCFileCore sharedInstance].getFileModule;
            NSString *path =[fileManager saveFileWithData:attach.data folder:mailFileDirectory fileName:attach.name];
            attach.localPath = path;
            attach.isDownload = YES;
            mail.hasAttachment = YES;
            [[MCFileCore sharedInstance] saveFileInDbWithModel:attach];
        }
    }
    
    [_dbMail insertMails:@[mail]];
}

- (void)getNewMailsByUids:(NSIndexSet *)uids withFolder:(MCMailBox *)folder success:(SuccessBlock)success failure:(FailureBlock)failure
{
    [_provider getMailsByUidsInFolder:folder requestKind:MCIMAPMessageRequestKindFullHeaders uids:uids success:^(id response) {
        if (success) {
            success(response);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}


- (void)updateDisplayMails:(NSArray *)displayMails serverMails:(NSArray *)serverMails folder:(MCMailBox *)folder success:(SuccessBlock)success failure:(FailureBlock)failure
{
    
    NSMutableArray *combinedArray = [NSMutableArray new];
    NSMutableArray *updateMails   = [NSMutableArray new];     //本地已经存在，需要更新状态的邮件
    NSMutableArray *newMails      = [NSMutableArray new];    //本地不存在，必需从服务器加载的邮件
    
    //根据服务器的邮件组织本地已经有的邮件
    NSArray *localMails = [self loadLocalMailsWithFolder:folder displayMails:displayMails serverMails:serverMails];
    NSMutableArray *mutableLocalMails = [[NSMutableArray alloc] initWithArray:localMails];
    NSMutableArray *synMails = [[NSMutableArray alloc]initWithArray:serverMails];
    if (localMails.count > 0) {
        for (MCMailModel *mail in synMails) {

            NSInteger index = [mutableLocalMails indexOfObject:mail];
            if (index != NSNotFound) {
                [updateMails addObject:mutableLocalMails[index]];
                [mutableLocalMails removeObjectAtIndex:index];
            }
            else{
                [newMails addObject:mail];
            }
        }
    }
    else{
        [newMails addObjectsFromArray:serverMails];
    }
    //判断删除的邮件
    if (mutableLocalMails.count > 0 && folder.accountId == self.account.accountId) {
        [_dbMail deleteMails:mutableLocalMails];
    }
    
    if (newMails.count == 0) {
        self.uidSortedMails = [updateMails copy];
        NSArray *returnArray = [updateMails sortedArrayUsingComparator:^NSComparisonResult(MCMailModel *obj1, MCMailModel *obj2) {
            return [obj2.receivedDate compare:obj1.receivedDate];
        }];
        if (success) {
            success(returnArray);
        }
    }
    else{
        __weak typeof(self) weakSelf = self;
        //在加载完新邮件就返回，让UI早点显示。状态的更新直接用KVO进行监听
        [self loadNewMailBriefWithFolder:folder mails:newMails success:^(id response) {
            NSArray *mails = response;
            [combinedArray addObjectsFromArray:mails];
            [combinedArray addObjectsFromArray:updateMails];
            weakSelf.uidSortedMails = [combinedArray sortedArrayUsingComparator:^NSComparisonResult(MCMailModel *obj1, MCMailModel *obj2) {
                return obj1.messageUid > obj2.messageUid ? NSOrderedAscending : NSOrderedDescending;
            }];
            
            if (success) {
                NSArray *returnArray = [combinedArray sortedArrayUsingComparator:^NSComparisonResult(MCMailModel *obj1, MCMailModel *obj2) {
                    return [obj2.receivedDate compare:obj1.receivedDate];
                }];
                success(returnArray);
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    }
    
    
    // 更新现有邮件的已读未读状态
    [self updateMailStatus:updateMails withFolder:folder success:nil failure:nil];
}

- (void)loadNewMailBriefWithFolder:(MCMailBox *)folder mails:(NSArray *)mails success:(SuccessBlock)success failure:(FailureBlock)failure
{
    
    if (!mails || mails.count == 0) {
        success(mails);
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    [self.provider updateMails:mails inFolder:folder requestKind:MCIMAPMessageRequestKindFullHeaders success:^(id response) {
       [weakSelf insertMails:mails];
        success(mails);
    } failure:^(NSError *error) {
        if (error.code == 3) { // MCOErrorParse
            [weakSelf fetchNewMailBriefOnebyOneWithFolder:folder mails:mails success:success failure:failure];
        } else {
            if (failure) {
                failure(error);
            }
        }
    }];
}

- (void)fetchNewMailBriefOnebyOneWithFolder:(MCMailBox *)folder mails:(NSArray *)mails success:(SuccessBlock)success failure:(FailureBlock)failure
{
    NSMutableArray *resultMails = [[NSMutableArray alloc] initWithCapacity:mails.count];
    for (MCMailModel *mail in mails) {
        __weak typeof(self)weakSelf = self;
        [self.provider updateMails:@[mail] inFolder:folder requestKind:MCIMAPMessageRequestKindFullHeaders success:^(id response) {
            [resultMails addObject:mail];
            if (resultMails.count == mails.count) {
                [weakSelf insertMails:resultMails];
                // resultMails 不一定有顺序
                success(mails);
            }
        } failure:^(NSError *error) {
            if (error.code == 3) { // MCOErrorParse
                [self.provider fetchFullMail:mail inFolder:folder success:^{
                    
                    for (MCMailAttachment *att in mail.attachments) {
                        [weakSelf.attachmentManager saveAttachmentInfo:att];
                    }
                    for (MCMailAttachment *inlineAtt in mail.inlineAttachments) {
                        [weakSelf.attachmentManager saveAttachmentInfo:inlineAtt];
                    }
                    [resultMails addObject:mail];
                    if (resultMails.count == mails.count) {
                        [weakSelf insertMails:resultMails];
                        // resultMails 不一定有顺序
                        success(mails);
                    }

                } failure:^(NSError *error) {
                    // 解析错误，就不解析了，加上一个占位符
                    mail.messageContentString = PMLocalizedStringWithKey(@"PM_Mail_ParseError");
                    mail.messageContentHtml = mail.messageContentString;
                    MCMailModel *preMail = [resultMails lastObject];
                    mail.receivedDate = preMail ? [[NSDate alloc] initWithTimeInterval:-1 sinceDate:preMail.receivedDate] : [NSDate new];   // 加一个当前时间避免每次排序都排最上面
                    [resultMails addObject:mail];
                    if (resultMails.count == mails.count) {
                       [weakSelf insertMails:resultMails];
                        success(mails);
                    }
                }];
            }
            else {
                if (failure) {
                    failure(error);
                }
            }
        }];
    }
}

// 遇到解析错误的，就一封一封的取邮件的结构体，避免一封邮件错误，所有的邮件都加载不下来
- (void)loadNewMailBriefOnebyOneWithFolder:(MCMailBox *)folder mails:(NSArray *)mails success:(SuccessBlock)success failure:(FailureBlock)failure
{
    NSMutableArray *resultMails = [[NSMutableArray alloc] initWithCapacity:mails.count];
    for (MCMailModel *mail in mails) {
        NSIndexSet *uids = [NSIndexSet indexSetWithIndex:mail.messageUid];
        __weak typeof(self)weakSelf = self;
        [self.provider getMailsByUidsInFolder:folder requestKind:MCIMAPMessageRequestKindFullHeaders uids:uids success:^(id response) {
            
            NSArray *responseArray = (NSArray *)response;
            if (responseArray.count > 0) {
                [resultMails addObject:responseArray[0]];
            }
            
            if (resultMails.count == mails.count) {
                [weakSelf insertMails:resultMails];
                success(resultMails);
            }

        } failure:^(NSError *error) {
            if (error.code == 3) { // MCOErrorParse
                // 解析错误，通过获取整封邮件解析
                [weakSelf.provider getFullMailFolder:folder byUid:mail.messageUid success:^(id response) {
                    
                    MCMailModel *model = (MCMailModel*)response;
                    //保存附件
                    for (MCMailAttachment *att in model.attachments) {
                        [weakSelf.attachmentManager saveAttachmentInfo:att];
                    }
                    for (MCMailAttachment *inlineAtt in model.inlineAttachments) {
                        [weakSelf.attachmentManager saveAttachmentInfo:inlineAtt];
                    }
                    [resultMails addObject:model];
                    if (resultMails.count == mails.count) {
                        [weakSelf insertMails:resultMails];
                        success(resultMails);
                    }
                    
                } failure:^(NSError *error) {
                    // 解析错误，就不解析了，加上一个占位符
                    mail.messageContentString = PMLocalizedStringWithKey(@"PM_Mail_ParseError");
                    mail.messageContentHtml = mail.messageContentString;
                    MCMailModel *preMail = [resultMails lastObject];
                    mail.receivedDate = preMail ? [[NSDate alloc] initWithTimeInterval:-1 sinceDate:preMail.receivedDate] : [NSDate new];   // 加一个当前时间避免每次排序都排最上面
                    [resultMails addObject:mail];
                    if (resultMails.count == mails.count) {
                        [weakSelf insertMails:resultMails];
                        success(resultMails);
                    }
                }];
                
            } else {
                if (failure) {
                    failure(error);
                }
            }
            
        }];
    }
}

- (void)updateMailStatus:(NSArray *)mailsToUpdate withFolder:(MCMailBox *)folder success:(SuccessBlock)success failure:(FailureBlock)failure
{
    if (mailsToUpdate.count == 0) {
        if (success) {
            success(mailsToUpdate);
        }
        return;
    }
    
    NSMutableIndexSet *uids = [NSMutableIndexSet indexSet];
    for (MCMailModel *mail in mailsToUpdate) {
        [uids addIndex:mail.messageUid];
    }
    
    [_provider getMailsByUidsInFolder:folder requestKind:MCIMAPMessageRequestKindFlags uids:uids success:^(id response) {
        NSArray *mailFlags = (NSArray *)response;
        
        [[self class] mails:mailsToUpdate updateStatus:mailFlags];
        [_dbMail updateMailStatus:mailsToUpdate];
        
        if (success) {
            success(mailsToUpdate);
        }
        
    } failure:failure];
}

/**
 *  加载显示的邮件和服务器的uid之间的本地邮件，其实就是上拉时数据库已经有的邮件
 *
 *  @param folder       文件夹
 *  @param displayMails 已经显示的邮件
 *  @param serverMails  服务器的邮件列表
 *
 *  @return 本地数据库存在的邮件
 */
- (NSArray *)loadLocalMailsWithFolder:(MCMailBox *)folder displayMails:(NSArray *)displayMails serverMails:(NSArray *)serverMails
{
    // 第一次还没有本地缓存，直接使用窗口邮件的uid range 到数据库加载
    if (!displayMails || displayMails.count == 0) {
        MCMailModel *beginModel = [serverMails lastObject];
        // endUid 要改为uidNext才会把已删除的上面的邮件选出来，判断不存在的才会删除
        //防止无uidNext情况
        NSInteger endIndex ;
        if (folder.uidNext > 0) {
            endIndex = folder.uidNext;
        } else {
            MCMailModel *endModel = [serverMails firstObject];
            endIndex = endModel.messageUid;
            [_dbMail deleteMailsInFolder:beginModel.boxId aboveUid:endIndex];
        }
        return [_dbMail getMailsWithFolder:beginModel.boxId beginUid:beginModel.messageUid endUid:endIndex];
    }
    
    // 新的窗口在显示的窗口之上
    MCMailModel *serverLastModel = [serverMails lastObject];
    MCMailModel *localFirstModel = [displayMails firstObject];
    MCMailModel *localLastModel = [displayMails lastObject];
    if (serverLastModel.messageUid > localFirstModel.messageUid) {
        return nil;
    }
    
    // 新的窗口最后一条在显示的中间，要去掉多余的缓存
    if (serverLastModel.messageUid > localLastModel.messageUid) {
        NSInteger index = [displayMails indexOfObject:serverLastModel];
        if (index == NSNotFound) {
            return @[];
        }
        NSMutableArray *localMails = [[NSMutableArray alloc] initWithCapacity:index + 1];
        for (NSInteger i = 0; i <= index; i ++) {
            [localMails addObject:displayMails[i]];
        }
        return localMails;
    }
    
    // 新窗口的最后一条刚好是本地的最后一条
    if (serverLastModel.messageUid == localLastModel.messageUid) {
        return displayMails;
    }
    
    // 新窗口包含显示的窗口，加载本地新窗口需要显示的数据
    if (serverLastModel.messageUid < localLastModel.messageUid) {
        
        NSMutableArray *localMails = [[NSMutableArray alloc] initWithArray:displayMails];
        NSArray *moreMails = [self getLocalMailsInFolder:folder beginUid:serverLastModel.messageUid endUid:localLastModel.messageUid - 1];
        if (moreMails && moreMails.count > 0) {
            [localMails addObjectsFromArray:moreMails];
        }
        
        return localMails;
    }
    
    return nil;
}

- (MCMailModel *)findMailInArray:(NSArray *)mails withUid:(NSInteger)uid
{
    for (MCMailModel *mail in mails) {
        if (mail.messageUid == uid) {
            return mail;
        }
    }
    
    return nil;
}

- (MCMailSyncModel*)mailSyncModelWithMail:(MCMailModel*)mail toBoxId:(NSInteger)toBoxId syncType:(MCMailSyncType)syncType  {
    
    MCMailSyncModel *syncModel = [MCMailSyncModel new];
    syncModel.accountId = mail.accountId;
    syncModel.mailId = mail.uid;
    syncModel.toBoxId = toBoxId;
    syncModel.fromBoxId = mail.boxId;
    syncModel.syncType = syncType;
    return syncModel;
}

- (void)insertMails:(NSArray *)mails
{
    //已发送已删除草稿箱垃圾箱 不分析重要邮件
    BOOL tagImportMail = [self needTagImportantMail:mails[0]];
    if (tagImportMail) {
        for (MCMailModel *mail in mails) {
            mail.tags = [self.tagManager mailTagForMail:mail];
        }
    }
    
    [self.dbMail insertMails:mails];
    [self insertContactInfoWithMails:mails];
}

- (BOOL)needTagImportantMail:(MCMailModel*)mail {
 
    MCMailBox *box = [self.boxManager getMailBoxWithAccount:mail.accountId path:mail.folder];
    if (box.type == MCMailFolderTypeSent||
        box.type == MCMailFolderTypeSpam||
        box.type == MCMailFolderTypeTrash||
        box.type == MCMailFolderTypeDrafts||
        box.type == MCMailFolderTypePending) {
        return NO;
    }
    return YES;
}


//TODO:插入联系人信息
- (void)insertContactInfoWithMails:(NSArray*)mails {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (MCMailModel *mail in mails) {
            NSMutableArray *ads = [NSMutableArray new];
            if (mail.from) {
                [ads addObject:mail.from];
            }
            if (mail.to) {
                [ads addObjectsFromArray:mail.to];
            }
            if (mail.cc) {
                [ads addObjectsFromArray:mail.cc];
            }
            
            for (MCMailAddress *ad in ads) {
                if (![ad.email isEmail]) {
                    continue;
                }
                MCContactModel*contactModel = [MCContactModel contactWithEmail:ad.email emailNickName:ad.name];
                [[MCContactManager sharedInstance] insertContact:contactModel];
            }
        }
    });
}




+ (void)mails:(NSArray *)mails updateStatus:(NSArray *)newMails
{
    NSUInteger n1 = mails.count;
    NSInteger n2 = newMails.count;
    NSInteger i = 0, j = 0;
    MCMailModel *m1 = nil, *m2 = nil;
    while (i < n1 && j < n2) {
        m1 = mails[i];
        m2 = newMails[j];
        if (m1.messageUid > m2.messageUid) {
            i++;
        }
        else if (m1.messageUid < m2.messageUid) {
            j++;
        }
        else {
            m1.isRead = m2.isRead;
            m1.isStar = m2.isStar;
            m1.isDeleted = m2.isDeleted;
            i++;
            j++;
        }
    }
}

@end
