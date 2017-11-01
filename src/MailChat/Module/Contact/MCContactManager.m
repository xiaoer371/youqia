//
//  MCContactManager.m
//  NPushMail
//
//  Created by wuwenyu on 16/2/25.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCContactManager.h"
#import "MCBranchInfo.h"
#import "MCBranchEmplyoeeInfo.h"
#import "MCAccountDatabase.h"
#import "MCEnterpriseSyncConfig.h"
#import "MCServerAPI+EIS.h"
#import "MCAccountConfig.h"

static const NSInteger kMailChatFrequentContactCount = 100;

@interface MCContactManager ()

@property (nonatomic,strong) NSMutableDictionary *allContacts;

@end

@implementation MCContactManager {
    MCContactTable *_contactTable;
    MCGroupsTable *_groupTable;
}

- (id)init {
    
    self = [super init];
    if (self) {
        _contactTable = [[MCContactTable alloc] init];
        _groupTable = [[MCGroupsTable alloc] init];
        _allContacts = [NSMutableDictionary new];
        
        NSArray *contacts = [_contactTable getContacts];
        for (MCContactModel *contact in contacts) {
            if (!contact.account) {
                continue;
            }
            [_allContacts setObject:contact forKey:contact.account];
        }
        
        [self addDefaultContacts];
        
        MCBranchEmplyoeeInfo *branchLeader = [_contactTable getLeaderWithEmail:AppStatus.currentUser.email];
        if (branchLeader) {
            _leader = [self getOrCreateContactWithEmail:branchLeader.email name:nil];
        }
    }
    return self;
}

+ (MCContactManager *)sharedInstance {
    return AppStatus.accountData.contactManager;
}

- (MCContactModel *)helperContact
{
    return [self getContactWithEmail:kMailChatHelper];
}


- (NSArray *)getContacts
{
    NSMutableArray *contacts = [NSMutableArray new];
    [self.allContacts.allValues enumerateObjectsUsingBlock:^(MCContactModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.deleteFlag) {
            [contacts addObject:obj];
        }
    }];
    
    return contacts;
}

- (MCContactModel *)getContactWithEmail:(NSString *)email
{
    NSString *realMail = email;
    MCContactModel *model = self.allContacts[email];
    if (!model) {
        // 判断是否是35邮箱，替换域
        NSString *domin = [email mailDomain];
        if ([domin isEqualToString:@"china-channel.com"]){
            realMail = [email stringByReplacingOccurrencesOfString:domin withString:@"35.cn"];
            model = self.allContacts[realMail];
        }
    }
    
    return model;
}

- (MCContactModel *)getOrCreateContactWithEmail:(NSString *)email name:(NSString *)name
{
    @synchronized (self.allContacts) {
        
        NSString *realMail = email;
        MCContactModel *model = self.allContacts[email];
        if (!model) {
            // 判断是否是35邮箱，替换域
            NSString *domin = [email mailDomain];
            if ([domin isEqualToString:@"china-channel.com"]){
                realMail = [email stringByReplacingOccurrencesOfString:domin withString:@"35.cn"];
                model = self.allContacts[realMail];
            }
            
            // 匿名用户
            if (!model && [email hasSuffix:@"$@"]) {
                NSString *nickName = PMLocalizedStringWithKey(@"Anonymous");
                model = [MCContactModel contactWithEmail:realMail emailNickName:nickName];
                return model;
            }
        }
        
        //如果缓存或者数据库中已经存在该model，则直接返回
        if (model) {
            // 如果名字变了，更新一下名字，同时更新缓存数据
            if (name && ![model.emailNickName isEqualToString:name]) {
                NSString *oldDisplayName = model.displayName;
                //NOTE:这里前提是传进来的时候是从邮件那边传入的，如果是消息的则需要另外考虑。
                model.emailNickName = [name trim];
                if (![oldDisplayName isEqualToString:model.displayName] || !model.pinyin || !model.pinyinFirstChar ) {
                    model.pinyin = [MCContactModel getPinyin:model.displayName];
                    model.pinyinFirstChar = [MCContactModel getPinYinFirstCharWith:model.displayName];
                }
                //更新邮箱昵称
                [_contactTable updateContactEmailNickName:[name trim] email:realMail];
            }
        }
        else{
            model = [MCContactModel contactWithEmail:realMail emailNickName:name];
            // 如果是当前用户，就使用当前用户的头像和设置
            if ([model.account isEqualToString:AppStatus.currentUser.email]) {
                model.headDefaultColorStr = [AppStatus.currentUser.color hexString];
                model.headChecksum = AppStatus.currentUser.avatar;
            }
            [_contactTable insertContact:model];
            self.allContacts[realMail] = model;
            // 新建的用户首先更新一下服务器的联系人信息
            [self updatePersonalContacts:@[model] success:nil failure:nil];
        }
        
        return model;
    }
   
}


- (void)insertContact:(MCContactModel *)model {
    
    @synchronized (self.allContacts) {
        
        // 判断是否是35邮箱，替换域
        NSString *domin = [[model.account mailDomain] lowercaseString];
        if ([domin isEqualToString:@"china-channel.com"]){
            NSString *realMail = [model.account stringByReplacingOccurrencesOfString:domin withString:@"35.cn"];
            model.account =realMail;
        }
        
        MCContactModel *contact = [self getContactWithEmail:model.account];
        if (!contact) {
            [_contactTable insertContact:model];
            self.allContacts[model.account] = model;
        }
    }
}

- (void)deleteContacts:(NSArray *)contacts {
    @synchronized (self.allContacts) {
        [_contactTable deleteContacts:contacts];
        for (MCContactModel *model in contacts) {
            MCContactModel *cacheModel = [self.allContacts objectForKey:model.account];
            if (cacheModel) {
                cacheModel.deleteFlag = YES;
                cacheModel.importantFlag = NO;
                cacheModel.weights = 0;
            }
        }
    }
}

- (void)deleteCacheContacts:(NSArray *)contacts {
    @synchronized (self.allContacts) {
        for (MCContactModel *model in contacts) {
            MCContactModel *cacheModel = [self.allContacts objectForKey:model.account];
            if (cacheModel) {
                [self.allContacts removeObjectForKey:model.account];
            }
        }
    }
}

- (void)updateContact:(MCContactModel *)model
{
    [_contactTable updateModel:model];
}

- (void)addWeight:(NSInteger)weight toContact:(MCContactModel *)model
{
    model.weights += weight;
    [_contactTable updateWeight:model];
}

- (NSMutableArray *)getImportantContactsWithImportFlag:(BOOL)importFlag {
    NSMutableArray *contacts = [NSMutableArray new];
    [self.allContacts.allValues enumerateObjectsUsingBlock:^(MCContactModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.importantFlag == importFlag && !obj.deleteFlag) {
            [contacts addObject:obj];
        }
    }];
    
    return contacts;
}

- (void)updateImportFlagWithEmail:(NSString *)email importFlag:(BOOL)importFlag {
    MCContactModel *model = self.allContacts[email];
    model.importantFlag = importFlag;
    model.deleteFlag = NO;
    [_contactTable updateImportFlagWithEmail:email importFlag:importFlag];
}

- (void)updateContactWithNoteInfo:(MCContactModel *)model {
    [self.allContacts setObject:model forKey:model.account];
    [_contactTable updateContactWithNoteInfo:model];
}

#pragma mark - 个人联系人

- (NSArray *)getPersonalContacts
{
    NSMutableArray *personalContacts = [NSMutableArray new];
    for (MCContactModel *contact in self.allContacts.allValues) {
        if (!contact.isCompanyUser && !contact.deleteFlag) {
            [personalContacts addObject:contact];
        }
    }
    
    return personalContacts;
}

- (void)updatePersonalContacts:(NSArray *)contacts success:(ActionBlock)success failure:(FailureBlock)failure
{
    [ServerAPI syncContacts:contacts success:^(MCContactInfoConfig *response) {
        
        for (MCContactModel *remoteContact in response.infos) {
            MCContactModel *localContact = self.allContacts[remoteContact.account];
            [self updateMailchatContactInfo:localContact withOtherContact:remoteContact];
        }
        if (success) {
            success();
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)updateMailchatContactInfo:(MCContactModel *)contact withOtherContact:(MCContactModel *)otherContact
{
    NSString *oldDisplayName = contact.displayName;
    contact.youqiaNickName = otherContact.youqiaNickName;
    if (otherContact.company) {
        contact.company = otherContact.company;
    }
    if (otherContact.position) {
        contact.position = otherContact.position;
    }
    if (otherContact.enterpriseDepartMent) {
        contact.enterpriseDepartMent = otherContact.enterpriseDepartMent;
    }
    contact.lastUpdateTime = otherContact.lastUpdateTime;
    contact.youqiaFlag = YES;
    if (otherContact.headChecksum) {
        contact.headChecksum = otherContact.headChecksum;
    }
    
    if (![oldDisplayName isEqualToString:contact.displayName] || !contact.pinyin || !contact.pinyinFirstChar ) {
        contact.pinyin = [MCContactModel getPinyin:contact.displayName];
        contact.pinyinFirstChar = [MCContactModel getPinYinFirstCharWith:contact.displayName];
    }
    
    [_contactTable updateModel:contact];
}

#pragma mark - 企业联系人模块


- (void)updateEnterpriseContactsSuccess:(ActionBlock)success failure:(FailureBlock)failure
{
    MCAccountConfig *accountConfig = AppStatus.accountData.accountConfig;
    
    [ServerAPI getEnterpriseContactsWithEmail:AppStatus.currentUser.email lastSyncTimestamp:accountConfig.eisSyncTimestamp success:^(MCEnterpriseSyncConfig *entInfo) {
        accountConfig.isBusinessContactDisabled = NO;
        [self mergeEnterpriseServerData:entInfo config:accountConfig success:success failure:failure];
    } failrue:^(NSError *error) {
        if (error.code == MCAPIErrorCodeEnterpriseContactDisabled) {
            accountConfig.isBusinessContactDisabled = YES;
        }
        
        if (failure) {
            failure(error);
        }
    }];
}

- (void)mergeEnterpriseServerData:(MCEnterpriseSyncConfig *)model config:(MCAccountConfig *)config success:(ActionBlock)success failure:(FailureBlock)failure {
    
    config.eisSyncTimestamp = model.syncTimestamp;
    if (!model.hasNewValue) {
        if (success) {
            success();
        }
        return;
    }
    
    if (model.companyName) {
        config.company = model.companyName;
    }
    
    NSMutableArray *localContacts = [[self getContacts] mutableCopy];
    NSArray *serverContacts = model.emplyoeeInfo.models;
    
    NSMutableArray *updatedContacts = [[NSMutableArray alloc] initWithCapacity:localContacts.count];
    NSMutableArray *insertedContacts = [[NSMutableArray alloc] initWithCapacity:localContacts.count];
    NSMutableArray *deletedContacts = [[NSMutableArray alloc] init];
    
    // 不能直接替换本地的ContactModel，因为很多地方已经对它的属性进行监听，以在头像，名字变化的时候跟着变化
    // 所以这边要比对更新属性
    for (MCContactModel *serverContact in serverContacts) {
        serverContact.company = model.companyName;
        NSUInteger index = [localContacts indexOfObject:serverContact];
        if (index != NSNotFound) {
            MCContactModel *localContact = localContacts[index];
            [self updateContact:localContact withOtherContact:serverContact];
            [updatedContacts addObject:localContact];
            [localContacts removeObjectAtIndex:index];
        }
        else{
            [self.allContacts setObject:serverContact forKey:serverContact.account];
            [insertedContacts addObject:serverContact];
        }
    }
    
    // 删掉服务器没有的
    for (MCContactModel *contact in localContacts) {
        if (contact.isCompanyUser) {
            [deletedContacts addObject:contact];
            [self.allContacts removeObjectForKey:contact.account];
        }
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        for (MCContactModel *contact in insertedContacts) {
            contact.pinyinFirstChar = [MCContactModel getPinYinFirstCharWith:contact.displayName];
            contact.pinyin = [MCContactModel getPinyin:contact.displayName];
        }
        
        [_contactTable deleteContacts:deletedContacts];
        [_contactTable insertContacts:insertedContacts];
        [_contactTable updateContacts:updatedContacts];
        
        /**
         *  前期未实现增量更新的时候处理方式
         */
        [_contactTable deleteEnterpriseData];
        if (model.branchInfo) {
            [_contactTable updateBranchWithBranchList:model.branchInfo.models];
        }
        
        if (model.branchEmplyoeeInfo) {
            [_contactTable updateBranchEmployeeWithBranchEmplyoeeList:model.branchEmplyoeeInfo.models];
        }
        
        [self findoutLeaderWithBranchEmployeeInfo:model.branchEmplyoeeInfo.models];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                success();
            }
        });
        
    });
}

- (void)updateContact:(MCContactModel *)contact withOtherContact:(MCContactModel *)otherContact
{
    NSString *oldDisplayName = contact.displayName;
    
    contact.headChecksum = otherContact.headChecksum;
    if (otherContact.company) {
        contact.company = otherContact.company;
    }
    contact.isCompanyUser = otherContact.isCompanyUser;
    if (otherContact.enterpriseUserName) {
        contact.enterpriseUserName = otherContact.enterpriseUserName;
    }
    if (otherContact.youqiaNickName) {
        contact.youqiaNickName = otherContact.youqiaNickName;
    }
    if (otherContact.headImageUrl) {
        contact.headChecksum = otherContact.headChecksum;
    }
    contact.youqiaFlag = otherContact.youqiaFlag;
    if (otherContact.enterpriseMobile_phone) {
        contact.enterpriseMobile_phone = otherContact.enterpriseMobile_phone;
    }
    if (otherContact.enterpriseWork_phone) {
        contact.enterpriseWork_phone = otherContact.enterpriseWork_phone;
    }
    if (otherContact.enterpriseHome_phone) {
        contact.enterpriseHome_phone = otherContact.enterpriseHome_phone;
    }
    contact.enterpriseSortId = otherContact.enterpriseSortId;
    contact.enterpriseTopId = otherContact.enterpriseTopId;
    
    if (![oldDisplayName isEqualToString:contact.displayName] || !contact.pinyin || !contact.pinyinFirstChar ) {
        contact.pinyin = [MCContactModel getPinyin:contact.displayName];
        contact.pinyinFirstChar = [MCContactModel getPinYinFirstCharWith:contact.displayName];
    }
    contact.isCompanyUser = YES;
}

- (void)findoutLeaderWithBranchEmployeeInfo:(NSArray *)branchEmployees
{
    _leader = nil;
    MCBranchEmplyoeeInfo *myBranch = nil;
    for (MCBranchEmplyoeeInfo *info in branchEmployees) {
        if ([info.email isEqualToString:AppStatus.currentUser.email]) {
            myBranch = info;
        }
    }
    
    if (myBranch) {
        for (MCBranchEmplyoeeInfo *info in branchEmployees) {
            if (info.isLeader && [info.branch_id isEqualToString:myBranch.branch_id]) {
                _leader = [self getOrCreateContactWithEmail:info.email name:nil];
                break;
            }
        }
    }
    
}


- (NSArray *)getAllEnterpriseBranchs {
   return [_contactTable getAllEnterpriseBranch];
}

- (NSArray *)getAllEnterpriseBranchEmplyoees {
    return [_contactTable getAllEnterpriseBranchEmplyoeeInfo];
}

- (int)getBranchEmplyoeesCountWithBranchId:(NSString *)branchId {
    return [_contactTable getBranchEmplyoeesCountWithBranchId:branchId];
}

- (NSArray *)getEnterpriseBranchEmployeeInfosByBranchId:(NSString*)branchId {
    return [_contactTable getEnterpriseBranchEmployeeInfosByBranchId:branchId];
}

- (MCBranchInfo *)getEnterpriseBranchInfoWithBranchId:(NSString *)branchId {
    return [_contactTable getEnterpriseBranchInfoWithBranchId:branchId];
}

- (NSArray *)getAllEnterpriseEmployees
{
    return [self getAllEnterpriseContacts];
}

- (NSArray *)getSameDominContactInfoByDomin:(NSString *)domin {
    NSMutableArray *sameDomainContacts = [[NSMutableArray alloc] init];
    [self.allContacts.allValues enumerateObjectsUsingBlock:^(MCContactModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[obj.account mailDomain] isEqualToString:domin] && !obj.deleteFlag) {
            [sameDomainContacts addObject:obj];
        }
    }];
    
    return sameDomainContacts;
}

- (NSArray *)getTopWeightedContacts
{
    NSMutableArray *contacts = [NSMutableArray new];
    [self.allContacts.allValues enumerateObjectsUsingBlock:^(MCContactModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.deleteFlag) {
            [contacts addObject:obj];
        }
    }];
    NSArray *weightedArray = [contacts sortedArrayUsingComparator:^NSComparisonResult(MCContactModel *obj1, MCContactModel *obj2) {
        if (obj1.weights > obj2.weights) {
            return NSOrderedAscending;
        }
        else if (obj1.weights == obj2.weights){
            return NSOrderedSame;
        }
        else {
            return NSOrderedDescending;
        }
    }];
    
    // 取前面100个权重不是0的联系人
    NSInteger count = weightedArray.count < kMailChatFrequentContactCount ? weightedArray.count : kMailChatFrequentContactCount;
    NSInteger index = -1;
    for (NSInteger i = 0; i < count; i++) {
        MCContactModel *model = weightedArray[i];
        if (model.weights < kMailChatContactImportantWeight) {
            break;
        }
        index = i;
    }
    
    if (index == -1) {
        return @[];
    }
    
    return [weightedArray subarrayWithRange:NSMakeRange(0, index + 1)];
}

#pragma mark - 分组模块

- (NSMutableArray *)getGroups {
   return [_groupTable getGroups];
}

- (NSString *)getGroupIdWithGroupName:(NSString *)groupName {
    return [_groupTable getGroupIdWithGroupName:groupName];
}

- (void)addDefaultGroups {
    [_groupTable addDefaultGroups];
}

#pragma mark - Private


- (void)addDefaultContacts
{
    MCContactModel *helperModel = [self getContactWithEmail:kMailChatHelper];
    if (!helperModel) {
        helperModel = [self getOrCreateContactWithEmail:kMailChatHelper name:PMLocalizedStringWithKey(@"PM_Login_HelperName")];
        helperModel.importantFlag = YES;
        helperModel.youqiaFlag = YES;
        [self updateContact:helperModel];
    }
    
}

- (NSMutableArray *)getAllEnterpriseContacts
{
    NSMutableArray *contacts = [NSMutableArray new];
    [self.allContacts.allValues enumerateObjectsUsingBlock:^(MCContactModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isCompanyUser) {
            [contacts addObject:obj];
        }
    }];
    
    return contacts;
}

@end
