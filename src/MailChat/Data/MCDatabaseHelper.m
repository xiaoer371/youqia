//
//  DatabaseHelper.m
//  NPushMail
//
//  Created by admin on 12/15/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import "MCDatabaseHelper.h"
#import "MCAccountDatabase.h"

static NSString* const kMailChatDatabaseName = @"mailchat.db";

@implementation MCDatabaseHelper
{
    NSMutableDictionary *_accountDatabaseList;
}

#pragma mark - Lifecycle

+ (MCDatabaseHelper *)shared
{
    static dispatch_once_t token = 0;
    static id _sharedObject = nil;
    dispatch_once(&token, ^{
        _sharedObject = [[MCDatabaseHelper alloc] init];
    });
    return _sharedObject;
}

- (instancetype)init
{
    if (self = [super init]) {
        _accountDatabaseList = [NSMutableDictionary new];
        [self initDatabase];
    }
    
    return self;
}

#pragma mark - Public

- (MCAccountDatabase *)databaseWithAccount:(MCAccount *)account
{
    @synchronized (_accountDatabaseList) {
        MCAccountDatabase *accountDb = _accountDatabaseList[account.email];
        if (!accountDb) {
            accountDb = [[MCAccountDatabase alloc] initWithAccount:account];
            [_accountDatabaseList setObject:accountDb forKey:account.email];
        }
        
        return accountDb;
    }
}

#pragma mark - Private

- (void)initDatabase
{
    NSString *dbPath = [AppStatus.documentDir stringByAppendingPathComponent:kMailChatDatabaseName];
    DDLogDebug(@"Database Path = %@",dbPath);
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    
    [self createTables];
}

- (void)createTables
{
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        [self createAccountTable:db];
        [self createAccountConfigTable:db];
        [self createAppConfigTable:db];
        
        [self createMailBoxTable:db];
        [self createMailContentTable:db];
        [self createMailAttachmentTable:db];
        [self createMailSyncTable:db];
        [self createBaseFileTable:db];
        
    }];
}



- (void)createAccountTable:(FMDatabase *)db
{
    if (![db tableExists:@"Account"]){
        NSString*sqlStr = [NSString stringWithFormat:@"CREATE TABLE Account (accountId INTEGER PRIMARY KEY  AUTOINCREMENT  DEFAULT 0,"
                           "email TEXT NOT NULL,"
                           "password TEXT,"
                           "type INTEGER,"
                           "isEIS INTEGER,"
                           "authType INTEGER NOT NULL DEFAULT 0,"
                           "authData BLOB,"
                           "displayName TEXT,"
                           "color INTEGER DEFAULT 0,"
                           "avatar TEXT,"
                           "company TEXT,"
                           "dept TEXT,"
                           "title TEXT,"
                           "deleted INTEGER DEFAULT 0,"
                           "signature  TEXT default %@,"
                           "status INTEGER DEFAULT 0,"
                           "mailConfig text)",@"发自邮洽"];
        [db executeUpdate:sqlStr];
    }
}

- (void)createAccountConfigTable:(FMDatabase *)db
{
    if (![db tableExists:@"AccountConfig"]){
        NSString*sqlStr = [NSString stringWithFormat:@"CREATE TABLE AccountConfig (id INTEGER PRIMARY KEY  AUTOINCREMENT  DEFAULT 0, accountId INTEGER NOT NULL, configKey TEXT NOT NULL, configValue TEXT NOT NULL )"];
        [db executeUpdate:sqlStr];
    }
}

- (void)createAppConfigTable:(FMDatabase *)db
{
    if (![db tableExists:@"AppConfig"]){
        NSString*sqlStr = [NSString stringWithFormat:@"CREATE TABLE AppConfig (configKey TEXT NOT NULL PRIMARY KEY, configValue TEXT NOT NULL )"];
        [db executeUpdate:sqlStr];
    }
}


- (void)createMailBoxTable:(FMDatabase *)db
{
    if (![db tableExists:@"MailBox"]) {
        
        NSString *sql = @"CREATE TABLE MailBox (id INTEGER PRIMARY KEY AUTOINCREMENT DEFAULT 0,\
        accountId INTEGER NOT NULL, \
        name TEXT, \
        path TEXT, \
        type INTEGER NOT NULL DEFAULT 0, \
        flags INTEGER NOT NULL DEFAULT 0, \
        folderOrder INTEGER NOT NULL DEFAULT 0, \
        uidValidity INTEGER NOT NULL DEFAULT 0, \
        uidFractured INTEGER NOT NULL DEFAULT 0, \
        totalCount INTEGER NOT NULL DEFAULT 0, \
        unreadCount INTEGER NOT NULL DEFAULT 0, \
        syncUtc REAL NOT NULL DEFAULT 0, \
        parentId INTEGER NOT NULL DEFAULT 0, \
        level INTEGER NOT NULL DEFAULT 0 )";
        
        [db executeUpdate:sql];
    }
}

- (void)createMailContentTable:(FMDatabase *)db
{
    if (![db tableExists:@"MailContent"]){
        NSString *sql = @"CREATE TABLE MailContent (id INTEGER PRIMARY KEY AUTOINCREMENT DEFAULT 0,\
        accountId INTEGER NOT NULL,\
        boxId INTEGER NOT NULL,\
        folder TEXT,\
        messageUid INTEGER, \
        messageId TEXT,\
        size INTEGER, \
        isRead INTEGER DEFAULT 0,\
        fromMail TEXT, \
        tos TEXT, \
        ccs TEXT, \
        bccs TEXT, \
        replyTo TEXT,\
        receivedDate INTEGER,\
        subject TEXT,\
        content TEXT,\
        summary TEXT,\
        referenceIds TEXT,\
        inReplyTo TEXT,\
        conversationId TEXT,\
        customMarkId  TEXT,\
        hasAttachment INTEGER NOT NULL DEFAULT 0,\
        isDeleted INTEGER NOT NULL DEFAULT 0, \
        isStar INTEGER NOT NULL DEFAULT 0,\
        status INTEGER NOT NULL DEFAULT 0,\
        tags INTEGER NOT NULL DEFAULT 0,\
        xPriority INTEGER NOT NULL DEFAULT 0,\
        flags INTEGER DEFAULT 0)";
        
        NSString *createIndexSql = @"CREATE INDEX `idx_mail_content_received_date` ON `MailContent` (`receivedDate` DESC )";
        NSString *createMessageUidIndexSql = @"CREATE INDEX `idx_mail_content_messageuid` ON `MailContent` ( `boxId`, `messageUid` DESC )";
        
        [db executeUpdate:sql];
        [db executeUpdate:createIndexSql];
        [db executeUpdate:createMessageUidIndexSql];
    }
    
}


/*attachment.mailUid = imapMessage.uid;
 attachment.partId  = imapPart.partID;
 attachment.name    = imapPart.filename;
 attachment.fileExtension = [imapPart.filename pathExtension];
 attachment.size    = imapPart.size;
 attachment.partEncode = (MCAttachEncode)imapPart.encoding;
 attachment.cid     = imapPart.contentID;
 if (!haveAttachment) {
 haveAttachment = attachment.cid?NO:YES;
 }
 attachment.mimeType = imapPart.mimeType;
 attachment.partFolder = folder.path;
 attachment.boxId      = folder.uid;*/

- (void)createMailAttachmentTable:(FMDatabase *)db
{
    if (![db tableExists:@"MailAttachment"]) {
        
        NSString *sql = @"CREATE TABLE MailAttachment (id INTEGER PRIMARY KEY AUTOINCREMENT  DEFAULT 0, mailId INTEGER NOT NULL, mailUid INTEGER ,partId TEXT,name TEXT,cid text,size INTEGER,mimeType TEXT,partEncoding INTEGER,localPath TEXT,partFolder TEXT, fileExtension TEXT,receiveDate  INTEGER,fromAddress TEXT, isDownload INTEGER)";
        
        [db executeUpdate:sql];
    }
}

- (void)createMailSyncTable:(FMDatabase *)db
{
    if (![db tableExists:@"MailSync"]) {
        NSString *sql = @"CREATE TABLE MailSync (id INTEGER PRIMARY KEY AUTOINCREMENT DEFAULT 0, accountId INTEGER NOT NULL, mailId INTEGER NOT NULL, type INTEGER, fromBoxId INTEGER, toBoxId INTEGER, tryTimes INTEGER DEFAULT 0)";
        [db executeUpdate:sql];
    }
}

/**
 *  创建基础文件管理数据库
 *
 *  @param db
 */
- (void)createBaseFileTable:(FMDatabase *)db {
    if (![db tableExists:@"FileBase"]) {
        NSString *sql = @"CREATE TABLE FileBase (id INTEGER PRIMARY KEY AUTOINCREMENT DEFAULT 0, type INTEGER, fileId TEXT, fromUser TEXT, format TEXT, sourceName TEXT, displayName TEXT, size int64 DEFAULT 0, receiveDate int64 DEFAULT 0, downLoadDate int64 DEFAULT 0, isCollect TINYINT, isFolder TINYINT, location TEXT, parentId INTEGER DEFAULT 0, source int DEFAULT 0, remark TEXT)";
        [db executeUpdate:sql];
    }
}



@end
