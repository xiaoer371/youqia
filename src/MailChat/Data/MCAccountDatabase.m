//
//  MCAccountDatabase.m
//  NPushMail
//
//  Created by admin on 3/11/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCAccountDatabase.h"

static NSString* const kMailChatAccountDbName = @"mcaccount.db";

@implementation MCAccountDatabase

- (instancetype)initWithAccount:(MCAccount *)account
{
    if (self = [super init]) {
        [self commonInitWithAccount:account];
    }
    
    return self;
}

- (void)createTables
{
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [self createContactTable:db];
        [self createEnterpriseBranchTable:db];
        [self createEnterpriseBranchEmplyoeesInfoTable:db];
        [self createAccountConfigTable:db];
        [self createGroupInfoTable:db];
        
        [self createConversationTable:db];
        [self createMessageTable:db];
        [self createGroupTable:db];
        [self createGroupMemberTable:db];
    }];
}

- (void)commonInitWithAccount:(MCAccount *)account
{
    DDLogInfo(@"Account email = %@",account.email);
    NSString *dbPath = [account.dataFolder stringByAppendingPathComponent:kMailChatAccountDbName];
    DDLogDebug(@"account db path = %@",dbPath);
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    [self createTables];
}

#pragma mark - 配置表

- (void)createAccountConfigTable:(FMDatabase *)db
{
    if (![db tableExists:@"AccountConfig"]){
        NSString*sqlStr = @"CREATE TABLE AccountConfig (id INTEGER PRIMARY KEY  AUTOINCREMENT  DEFAULT 0, configKey TEXT NOT NULL, configValue TEXT NOT NULL );"
        "CREATE UNIQUE INDEX IF NOT EXISTS configKey_index ON AccountConfig(configKey);";
        [db executeStatements:sqlStr];
    }
}

#pragma mark - 联系人

/**
 *  联系人表
 *
 *  @param db
 */
- (void)createContactTable:(FMDatabase *)db {
    if (![db tableExists:@"Contact"]) {
        /**
         *
         *  @param email        email
         *  @param firstChar    拼音首字母
         *  @param displayName  昵称
         *  @param headUrl      头像URL
         *  @param pinYin       昵称拼音
         *  @param avatorDefaultColor 头像默认颜色值
         *  @param weights      联系人权重
         *  @param isImportant  是否常用联系人
         *  @param youqiaUser   是否邮洽用户
         *  @param deleteFlag   是否已删除
         *  @param isCompanyUser  是否企业联系人
         *  @param isLeader     是否领导
         *  @param company      公司名称
         *  @param position     职位
         *  @param note         备注描述
         *  @param phone        电话
         *  @param groupId      所在分组的ID
         *  @param notePhoneNumbers  备注电话号码(以逗号分割)
         *  @param noteDisplayName   备注姓名
         *  @param enterpriseUserName 组织架构中的昵称
         *  @param youqiaNickName 在邮洽中设置的昵称
         *  @param emailNickName  邮件信息中的昵称
         *  @param enterpriseMobile_phone   组织架构中移动电话号码
         *  @param enterpriseWork_phone     组织架构中工作电话号码
         *  @param enterpriseHome_phone     组织架构中家庭电话号码
         *  @param enterpriseBirthday       组织架构中生日
         *  @param last_update_time         表最后更新时间
         *  @param enterprise_sortId        企业员工排序
         ＊ @param enterprise_topId          企业员工置顶序号
         *  @param reserved                 备用字段
         */
        
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE Contact (\
                         id INTEGER PRIMARY KEY AUTOINCREMENT DEFAULT 0,\
                         email TEXT ,\
                         firstChar TEXT,\
                         displayName TEXT,\
                         headChecksum TEXT,\
                         pinYin TEXT,\
                         avatorDefaultColor TEXT,\
                         weights int DEFAULT 0,\
                         isImportant TINYINT DEFAULT 0,\
                         youqiaUser TINYINT DEFAULT 0,\
                         deleteFlag TINYINT DEFAULT 0,\
                         isCompanyUser TINYINT(1) DEFAULT 0,\
                         isLeader TINYINT(1) DEFAULT 0,\
                         company TEXT,\
                         position TEXT,\
                         note TEXT,\
                         phone TEXT,\
                         groupId CHAR(32) DEFAULT 0,\
                         notePhoneNumbers TEXT,\
                         noteDisplayName TEXT,\
                         enterpriseUserName TEXT,\
                         youqiaNickName TEXT,\
                         emailNickName TEXT,\
                         enterpriseMobile_phone varchar(50),\
                         enterpriseWork_phone varchar(50),\
                         enterpriseHome_phone varchar(50),\
                         enterpriseBirthday varchar(50),\
                         last_update_time int64 DEFAULT 0,\
                         enterprise_sortId int32 DEFAULT 1,\
                         enterprise_topId int32 DEFAULT 1,\
                         reserved1 varchar(200),\
                         reserved2 varchar(200),\
                         reserved3 varchar(200)\
                         )"];
        NSString *createIndexSql = @"CREATE UNIQUE INDEX IF NOT EXISTS email_index ON Contact(email)";
        [db executeUpdate:sql];
        [db executeUpdate:createIndexSql];
    }
}

/**
 *  企业部门表
 *
 *  @param db
 */
- (void)createEnterpriseBranchTable:(FMDatabase *)db {
    if (![db tableExists:@"EnterpriseBranch"]) {
        /**
         *  @param branch_id        部门编号
         *  @param name             部门名称
         *  @param parent_id        上级部门ID（顶级为0）
         *  @param sort_id          排序ID
         *  @param emplyoeesCnt     员工数量
         *  @param last_update_time 表最后更新的时间
         *  @param reserved         备用字段
         */
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' (\
                         branch_id char(32) NOT NULL,\
                         name varchar(255) NOT NULL,\
                         parent_id char(32),\
                         sort_id int(11),\
                         employeesCnt int(11),\
                         subBranchCnt int(11),\
                         delete_flag tinyint(1) DEFAULT 0,\
                         last_update_time int64 DEFAULT 0,\
                         reserved1 varchar(200),\
                         reserved2 varchar(200),\
                         CONSTRAINT sqlite_autoindex_branch_info PRIMARY KEY (branch_id))", @"EnterpriseBranch"];
        [db executeUpdate:sql];
    }
}

/**
 *  部门员工关系表
 *
 *  @param db
 */
- (void)createEnterpriseBranchEmplyoeesInfoTable:(FMDatabase *)db {
    if (![db tableExists:@"EnterpriseBranchEmployeesInfo"]) {
        /**
         *
         *  @param branch_id        部门编号
         *  @param email            员工邮箱
         *  @param is_leader        是否为领导（存储为BOOL值）
         *  @param delete_flag      是否被移除
         *  @param last_update_time 表最后更新的时间
         *  @param reserved         备用字段
         */
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' (\
                         branch_id char(32) NOT NULL,\
                         email varchar(32) NOT NULL,\
                         is_leader tinyint(1) DEFAULT 0,\
                         delete_flag tinyint(1) DEFAULT 0,\
                         last_update_time int64 DEFAULT 0,\
                         reserved1 varchar(200),\
                         reserved2 varchar(200),\
                         reserved3 varchar(200),\
                         CONSTRAINT sqlite_autoindex_branch_emplyoees_info PRIMARY KEY (branch_id, email)\
                         )", @"EnterpriseBranchEmployeesInfo"];
        [db executeUpdate:sql];
    }
}

/**
 *  分组表
 *
 *  @param db
 */
- (void)createGroupInfoTable:(FMDatabase *)db {
    if (![db tableExists:@"GroupsInfo"]) {
        /**
         *
         *  @param groupId          分组ID
         *  @param groupName        分组名称
         *  @param sortId           分组排序
         *  @param isDefaultGroup   是否默认分组
         *  @param defaultGroupSortId  默认分组的排序(从小到大排序)
         *  @param delete_flag      是否被移除
         *  @param last_update_time 表最后更新的时间
         *  @param reserved         备用字段
         */
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' (\
                         group_id char(32) NOT NULL,\
                         groupName varchar(255) NOT NULL,\
                         sort_id int DEFAULT 0,\
                         isDefaultGroup tinyint(1) DEFAULT 0,\
                         defaultGroupSortId int DEFAULT 0,\
                         delete_flag tinyint(1) DEFAULT 0,\
                         last_update_time int64 DEFAULT 0,\
                         reserved1 varchar(200),\
                         reserved2 varchar(200),\
                         reserved3 varchar(200),\
                         CONSTRAINT sqlite_autoindex_groupsinfo PRIMARY KEY (group_id)\
                         )", @"GroupsInfo"];
        [db executeUpdate:sql];
    }
}

#pragma mark - IM

- (void)createIMTables
{
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [self createConversationTable:db];
        [self createMessageTable:db];
        [self createGroupTable:db];
        [self createGroupMemberTable:db];
    }];
}



//存放消息的会话表：ConversationInfo
-(void)createConversationTable:(FMDatabase *)db
{
    /**
     *  @param accountId  对应账号id
     *  @param topicId  对应频道id
     *  @param content  会话内容
     *  @param time  会话时间
     *  @param headCol  会话颜色
     *  @param fromEmail  来自谁的会话
     *  @param fromDisPlayName  来自谁的备注
     *  @param type  会话类型
     *  @param draft  会话草稿
     *  @param index accountId    索引
     */
    if (![db tableExists:@"IMConversation"]) {
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IMConversation(\
                         id INTEGER PRIMARY KEY AUTOINCREMENT  DEFAULT 0,\
                         peerId varchar(128) NOT NULL,\
                         content text,\
                         draft TEXT,\
                         lastMsgTime REAL,\
                         type INTEGER DEFAULT 0,\
                         unreadCount INTEGER DEFAULT 0,\
                         isShield INTEGER DEFAULT 0,\
                         onTopTime REAL DEFAULT 0,\
                         state INTEGER DEFAULT 0)"];
        [db executeUpdate:sql];
    }
}

//存放消息内容的表：MessageInfo
-(void)createMessageTable:(FMDatabase *)db
{
    if (![db tableExists:@"IMMessage"]) {
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IMMessage(\
                         id INTEGER PRIMARY KEY AUTOINCREMENT  DEFAULT 0,\
                         messageId  varchar(64),\
                         conversationId INTEGER NOT NULL DEFAULT 0,\
                         conversationType INTEGER NOT NULL DEFAULT 0,\
                         type INTEGER NOT NULL DEFAULT 0,\
                         fromUserId varchar(64),\
                         toId varchar(64),\
                         content text,\
                         time REAL,\
                         state INTEGER NOT NULL DEFAULT 0,\
                         isRead INTEGER DEFAULT 0,\
                         isSender INTEGER DEFAULT 0,\
                         sendMsgId INTEGER DEFAULT 0)"];
        [db executeUpdate:sql];
    }
    
}

//存放消息群组信息的表：MsgGroupInfo
-(void)createGroupTable:(FMDatabase*)db
{
    /**
     *  @param id  群id
     *  @param accountId  账号对应id
     *  @param topicId  频道对应Id
     *  @param time  建群时间
     *  @param name  群名
     *  @param accountId  索引
     */
    if (![db tableExists:@"IMGroup"]) {
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IMGroup(\
                         id INTEGER PRIMARY KEY AUTOINCREMENT  DEFAULT 0,\
                         groupId varchar(64),\
                         name varchar(128),\
                         isSaved tinyint(1),\
                         state INTEGER NOT NULL DEFAULT 0,\
                         avatar text)"];
        [db executeUpdate:sql];
    }
}

//存放群成员的表：MemberInfo
-(void)createGroupMemberTable:(FMDatabase *)db
{
    /**
     *  @param topicId  群对应topicId
     *  @param email  成员email
     *  @param isOwner  是否群主
     *  @param isjion  是否加入 （状态）
     */
    if (![db tableExists:@"IMGroupMember"]) {
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IMGroupMember(\
                         id INTEGER PRIMARY KEY AUTOINCREMENT  DEFAULT 0,\
                         groupId  INTEGER NOT NULL,\
                         userId varchar(64),\
                         nickName varchar(64),\
                         isOwner tinyint(1) DEFAULT 0,\
                         joinState int NOT NULL DEFAULT 0)"];
        [db executeUpdate:sql];
    }
}

@end
