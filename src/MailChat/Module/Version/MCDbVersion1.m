//
//  MCDbVersion1.m
//  NPushMail
//
//  Created by admin on 7/7/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCDbVersion1.h"
#import "MCAccount.h"
#import "MCLoginManager.h"
#import "MCServerAPI+Account.h"
#import "MCAccountManager.h"
#import "MCMsgConversationTable.h"
#import "MCMsgContentTable.h"
#import "NSString+Extension.h"
#import "MCUDID.h"
#import "MCAppSetting.h"
#import "MCAccountDatabase.h"
#import "MCMsgGroupTable.h"
#import "MCMailConfigManager.h"
#import "SDWebImageManager.h"
#import "MCAvatarHelper.h"
#import "MCContactTable.h"
#import "MCContactModel.h"


@interface MCDbVersion1 ()

@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;
@property (nonatomic, strong) FMDatabaseQueue *messageQueue;

@end

@implementation MCDbVersion1

- (NSInteger)version
{
    return 1;
}

- (BOOL)upgradeDatabase
{
    [self createDBQueues];
    
    NSArray *accounts = [self upgradeAccounts];
    if (!accounts) {
        return NO;
    }
    
    // 默认登录第一个用户
    MCAccount *account = [accounts firstObject];
    AppSettings.lastAccountId = account.accountId;
    
    for (MCAccount *account in accounts) {
        [self upgradeMessageForAccount:account];
        [self upgradeContactsForAccount:account];
    }
    
    [self upgradeSettings];
    
    return YES;
}

- (void)createDBQueues
{
    NSString *databasePath = [AppStatus.documentDir stringByAppendingPathComponent:@"database.sqlite"];
    _databaseQueue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
    NSString *messagePath = [AppStatus.documentDir stringByAppendingPathComponent:@"message.sqlite"];
    _messageQueue = [FMDatabaseQueue databaseQueueWithPath:messagePath];
}

- (NSArray *)upgradeAccounts
{
    NSMutableArray *accounts = [NSMutableArray new];
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = @"SELECT * FROM account";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            MCAccount *account = [[self class] accountWithResultSet:rs];
            if ([account.email isEmail]) {
                [accounts addObject:account];
            }
        }
    }];
    
    if (accounts.count == 0) {
        return nil;
    }
    
    __block BOOL success = YES;
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    [self authenticateUserSuccess:^(id response) {
        dispatch_group_leave(group);
    } failure:^(NSError *error) {
        DDLogError(@"Authenticate user error when upgrade database = %@",error);
        success = NO;
        dispatch_group_leave(group);
    }];
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    if (!success) {
        return nil;
    }
    
    // 回调queue不能在主线程里面，否则的话会死锁
    MCServerAPI *api = [[MCServerAPI alloc] init];
    api.manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (MCAccount *account in accounts) {
        dispatch_group_enter(group);
        [api addMailToUser:account.email withPassword:account.password authCode:nil shouldValidate:NO success:^(id response) {
            dispatch_group_leave(group);
        } failure:^(NSError *error) {
            if (error.code != MCAPIErrorCodeEmailAlreadyBinded) {
                success = NO;
            }
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    if (!success) {
        DDLogError(@"Add mail to user failure");
        return nil;
    }
    
    NSMutableArray *goodAccounts = [[NSMutableArray alloc] initWithCapacity:accounts.count];
    NSDictionary *mailConfigs = [MCMailConfigManager getOldMailConfigs];
    MCAccountManager *accountMgr = [[MCAccountManager alloc] init];
    for (MCAccount *account in accounts) {
        account.config = mailConfigs[[account.email mailDomain]];
        // 没有邮箱配置的帐号就不升级了，因为升级了也登录不进去
        if (!account.config) {
            DDLogError(@"%@ acccount does not have config",account.email);
            continue;
        }
        // 已经存在的帐号不再添加
        if (![accountMgr accountWithEmail:account.email]) {
            [accountMgr insertAccount:account];
            [goodAccounts addObject:account];
        }
    }
    
    return goodAccounts;
}

+ (MCAccount *)accountWithResultSet:(FMResultSet *)rs
{
    MCAccount *account = [MCAccount new];
    account.email = [rs stringForColumn:@"email"];
    account.password = [rs stringForColumn:@"password"];
    account.displayName = [rs stringForColumn:@"displayName"];
    account.signature = [rs stringForColumn:@"signature"];
    account.type = [rs intForColumn:@"type"];
    account.isEIS = account.type == MCMailType35_30;
    account.deleted = [rs stringForColumn:@"deleted"]? YES : NO;
    NSString *colorString = [MCAvatarHelper randomColorHexString];
    account.color = [UIColor colorWithHexString:colorString];
    
    return account;
}

- (BOOL)upgradeMessageForAccount:(MCAccount *)account
{
    DDLogVerbose(@"Upgrade message for account:%@",account.email);
    
    MCAccountDatabase *accountDb = [[MCAccountDatabase alloc] initWithAccount:account];
    MCMsgConversationTable *conversationTable = [[MCMsgConversationTable alloc] initWithDbQueue:accountDb.dbQueue];
    MCMsgContentTable *msgTable = [[MCMsgContentTable alloc] initWithDbQueue:accountDb.dbQueue];
    MCMsgGroupTable *groupTable = [[MCMsgGroupTable alloc] initWithDbQueue:accountDb.dbQueue];
    
    // 小助手不升级消息
    if ([account.email isEqualToString:@"help@mailchat.cn"] ||
        [account.email isEqualToString:@"fb@mailchat.cn"]) {
        return YES;
    }
    
    
    NSArray *conversationList = [self getConversationsForAccount:account];
    if (conversationList.count == 0) {
        return YES;
    }
    
    for (MCIMConversationModel *conversation in conversationList) {
        [conversationTable insertModel:conversation];
        // 判断群租是否存在
        if (conversation.type == MailChatConversationTypeGroup) {
            MCIMGroupModel *group = [groupTable groupWithGroupId:conversation.peerId];
            if (!group) {
                // 获取就数据库的群组信息
                group = [self getGroupWithGroupId:conversation.peerId];
                if (group) {
                    group.isSaved = conversation.isChatting;
                    [groupTable insertModel:group];
                    conversation.peer = group;
                }
                else {
                    // 如果旧数据库没有这个群，也就不要显示了
                    continue;
                }
            }
            else {
                conversation.peer = group;
            }
        }
        conversation.isChatting = NO;
        
        NSArray *messages = [self getMessagesForConversation:conversation withAccount:account];
        for (MCIMMessageModel *msg in messages) {
            [msgTable insertModel:msg];
        }
    }
    
    return YES;
}

- (NSArray *)getConversationsForAccount:(MCAccount *)account
{
    NSMutableArray *list = [NSMutableArray new];
    NSString *tableName = [NSString stringWithFormat:@"conversationNew%@",account.email];
    [self.messageQueue inDatabase:^(FMDatabase *db) {
        if ([db tableExists:tableName]) {
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM '%@'", tableName];
            FMResultSet *rs = [db executeQuery:sql];
            while ([rs next]) {
                MCIMConversationModel *model = [self conversationWithResultSet:rs];
                if (model) {
                    [list addObject:model];
                }
            }
        }
    }];
    
    return list;
}

- (MCIMGroupModel *)getGroupWithGroupId:(NSString *)groupId
{
    __block MCIMGroupModel *model = nil;
    [self.messageQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM groupInfo_table_TEST WHERE groupTopic = ?";
        FMResultSet *rs = [db executeQuery:sql, groupId];
        while ([rs next]) {
            model = [MCIMGroupModel new];
            model.groupId = [rs stringForColumn:@"groupTopic"];
            model.groupName = [rs stringForColumn:@"groupName"];
        }
    }];
    
    return model;
}

- (MCIMConversationModel *)conversationWithResultSet:(FMResultSet *)rs
{
    MCIMConversationModel *model = [MCIMConversationModel new];
    model.peerId = [rs stringForColumn:@"conversationEmail"];
    model.content = [rs stringForColumn:@"content"];
    if ([model.peerId hasSuffix:@"/a"]) {
        return nil;
    }
    model.type = [model.peerId isEmail] ? MailChatConversationTypeSingle : MailChatConversationTypeGroup;
    model.lastMsgTime = [rs dateForColumn:@"contentTime"];
    model.onTopTime = [rs intForColumn:@"settop"];
    //用isChatting 来临时保存数据，省的再创建一个字断
    model.isChatting = [rs boolForColumn:@"groupId"];
    model.isShield = [rs boolForColumn:@"isPush"];
    return model;
}

- (NSArray *)getMessagesForConversation:(MCIMConversationModel *)conversation withAccount:(MCAccount *)account
{
    NSMutableArray *list = [NSMutableArray new];
    NSString *tableName = [NSString stringWithFormat:@"message_table_%@",account.email];
    [self.messageQueue inDatabase:^(FMDatabase *db) {
        if ([db tableExists:tableName]) {
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE chatter = ?", tableName];
            FMResultSet *rs = [db executeQuery:sql, conversation.peerId];
            while ([rs next]) {
                MCIMMessageModel *model = [self messageModelWithResultSet:rs];
                model.conversationId = conversation.uid;
                model.conversationType = conversation.type;
                if (model) {
                    [list addObject:model];
                }
            }
        }
    }];
    
    return list;
}

- (MCIMMessageModel *)messageModelWithResultSet:(FMResultSet *)rs
{
    MCIMMessageModel *model = nil;
    
    NSString *msgType = [rs stringForColumn:@"messageType"];
    if ([msgType isEqualToString:@"0"]) {
        model = [MCIMMessageModel new];
        model.content = [rs stringForColumn:@"content"];
    }
    else if ([msgType isEqualToString:@"1"]){
        MCIMImageModel *imgModel = [MCIMImageModel new];
        NSString *content = [rs stringForColumn:@"content"];
        NSArray *tokens = [content componentsSeparatedByString:@"/"];
        if (tokens.count >= 2) {
            NSString *firstToken = tokens[0];
            NSString *checksum = [firstToken substringToIndex:firstToken.length - 2];
            imgModel.checksum = checksum;
            imgModel.name = tokens[1]?:@"";
            imgModel.size = [rs intForColumn:@"size"];
            model = imgModel;
        }
        else {
            // 发送的图片没有checksum，只有名字，如这样的格式 F6ED84DD-1EE9-4133-85A2-E4659B5D5B9C##F6ED84DD-1EE9-4133-85A2-E4659B5D5B9C_loca.jpg
            UIImage *sentImage = [self imageWithFileName:content];
            if (sentImage) {
                imgModel.messageId = [rs stringForColumn:@"messageID"];
                imgModel.checksum = @"image";
                imgModel.name = content;
                imgModel.size = [rs intForColumn:@"size"];
                [[SDWebImageManager sharedManager] saveImageToCache:sentImage forURL:[NSURL URLWithString:imgModel.localPath]];
                model = imgModel;
            }
            
        }
    }
    else if ([msgType isEqualToString:@"2"]){
        MCIMFileModel *fileModel = [MCIMFileModel new];
        NSString *content = [rs stringForColumn:@"content"];
        NSArray *tokens = [content componentsSeparatedByString:@"/"];
        if (tokens.count >= 2) {
            fileModel.checksum = tokens[0];
            fileModel.name = tokens[1]?:@"";
            fileModel.size = [rs intForColumn:@"size"];
            model = fileModel;
        }
        else {
            NSString *path = [NSString stringWithFormat:@"chatFile/%@",content];
            NSString *filePath = [AppStatus.documentDir stringByAppendingPathComponent:path];
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                fileModel.messageId = [rs stringForColumn:@"messageID"];
                fileModel.checksum = @"file";
                fileModel.name = content;
                fileModel.size = [rs intForColumn:@"size"];
                model = fileModel;
            }
        }
        
    }
    else if ([msgType isEqualToString:@"3"]){
        MCIMVoiceModel *voiceModel = [MCIMVoiceModel new];
        voiceModel.seconds = [rs intForColumn:@"size"];
        voiceModel.localPath = [rs stringForColumn:@"content"];
        model = voiceModel;
    }
    
    if (model) {
        model.messageId = [rs stringForColumn:@"messageID"];
        model.timeStamp = [rs intForColumn:@"chatTime"];
        model.time = [rs dateForColumn:@"chatTime"];
        model.from = [rs stringForColumn:@"fromAdr"];
        model.to = [rs stringForColumn:@"toAdr"];
        model.state = IMMessageStateSuccess;
    }
    
    return model;
}

- (void)upgradeContactsForAccount:(MCAccount *)account
{
    MCAccountDatabase *accountDb = [[MCAccountDatabase alloc] initWithAccount:account];
    MCContactTable *contactTable = [[MCContactTable alloc] initWithDbQueue:accountDb.dbQueue];
    NSArray *oldContacts = [self getAllContactForAccount:account];
    for (MCContactModel *model in oldContacts) {
        [contactTable insertOrReplaceContact:model];
    }
}

- (NSArray *)getAllContactForAccount:(MCAccount *)account
{
    NSMutableArray *contactsArray = [[NSMutableArray alloc] init];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = [NSString stringWithFormat:@"CONTACAT_%@",account.email];
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM '%@'",tableName];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            MCContactModel *model = [self contactModelWithResultSet:rs];
            [contactsArray addObject:model];
        }
    }];
    
    return contactsArray;
}

- (MCContactModel *)contactModelWithResultSet:(FMResultSet *)rs
{
    MCContactModel *model = [[MCContactModel alloc] init];
    model.account = [rs stringForColumn:@"email"];
    model.pinyinFirstChar = [rs stringForColumn:@"firsChar"];
    model.headChecksum = [rs stringForColumn:@"headUrl"];
    model.pinyin = [rs stringForColumn:@"pinyin"];
    // 以前重要联系人都是随机的，默认不升级过去
    //model.importantFlag = [rs boolForColumn:@"important"];
    model.youqiaFlag = [rs boolForColumn:@"youqiaUser"];
    model.deleteFlag = [rs boolForColumn:@"Del"];
    model.company = [rs stringForColumn:@"company"];
    model.position = [rs stringForColumn:@"position"];
    model.note = [rs stringForColumn:@"note"];
    model.youqiaNickName = [rs stringForColumn:@"displayName"];
    model.phoneNumbers = [rs stringForColumn:@"phone"];
    model.isCompanyUser = [rs boolForColumn:@"isCompanyUser"];
    model.isLeader = [rs boolForColumn:@"isLeader"];
    model.groupId = [rs stringForColumn:@"groupId"];
    model.notePhoneNumbers = [rs stringForColumn:@"notePhoneNumbers"];
    model.noteDisplayName = [rs stringForColumn:@"noteDisplayName"];
    model.enterpriseUserName = [rs stringForColumn:@"enterpriseUserName"];
    model.headDefaultColorStr = [MCAvatarHelper randomColorHexString];
    
    return model;
}

- (void)upgradeSettings
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [paths objectAtIndex:0];
    NSString* filename = [documentPath stringByAppendingPathComponent:@"preference.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filename]) {
        return;
    }
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithContentsOfFile:filename];
    //是否开启手势密码
    BOOL gesturePasswordFlag = NO;
    NSNumber* value = [dic objectForKey:@"isOnGesturePwd"];
    if (value) {
        gesturePasswordFlag = [value boolValue];
    }
    [AppSettings setGesturePasswordFlag:gesturePasswordFlag];
}


#pragma mark - Private

- (void)authenticateUserSuccess:(SuccessBlock)success failure:(FailureBlock)failure
{
    if (AppSettings.user) {
        success(AppSettings.user);
        return;
    }
    
    MCServerAPI *api = [[MCServerAPI alloc] init];
    api.manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSString *userId = [NSString stringWithFormat:@"iosu_%@",[MCUDID newUUID]];
    NSString *password = [MCUDID newUUID];
    NSString *deviceName = [[UIDevice currentDevice] name];
    NSString* clientVer = nil;
    NSString* versionStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (Debug_Flag == 1) {
        //debug版本
        clientVer = [NSString stringWithFormat:@"R:%@:D",versionStr];
    }else {
        //release版本
        clientVer = [NSString stringWithFormat:@"R:%@",versionStr];
    }
    
    [api authenticateUser:userId password:password clientId:AppSettings.clientId deviceName:deviceName apnsToken:AppSettings.apnsToken  clientVer:clientVer success:^(MCUserInfo *user) {
        AppSettings.user = user;
        if (success) {
            success(user);
        }
        
    } failure:^(NSError *error){
        if (failure) {
            failure(error);
        }
    }];
}

- (UIImage *)imageWithFileName:(NSString *)fileName
{
    NSString *path = [NSString stringWithFormat:@"chatImage/%@",fileName];
    NSString *imagePath = [AppStatus.documentDir stringByAppendingPathComponent:path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        return [UIImage imageWithContentsOfFile:imagePath];
    }
    
    return nil;
}


@end
