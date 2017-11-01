//
//  MCContactTable.m
//  NPushMail
//
//  Created by wuwenyu on 16/1/7.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCContactTable.h"
#import "MCContactModel.h"
#import "MCDatabaseHelper.h"
#import "MCBranchInfo.h"
#import "MCBranchEmplyoeeInfo.h"
#import "MCTool.h"

@implementation MCContactTable

- (void)insertOrReplaceContact:(MCContactModel *)model {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"INSERT OR REPLACE INTO Contact (email, firstChar, displayName, headChecksum, pinYin, weights, avatorDefaultColor, isImportant, youqiaUser, deleteFlag, isCompanyUser, isLeader, company, position, note, phone, groupId, notePhoneNumbers, noteDisplayName, enterpriseUserName, youqiaNickName, emailNickName, enterpriseMobile_phone, enterpriseWork_phone, enterpriseHome_phone, enterpriseBirthday, last_update_time, enterprise_sortId, enterprise_topId) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        [db executeUpdate:sql, model.account, model.pinyinFirstChar, model.displayName, model.headChecksum, model.pinyin, @(model.weights), model.headDefaultColorStr, @(model.importantFlag), @(model.youqiaFlag), @(model.deleteFlag), @(model.isCompanyUser), @(model.isLeader), model.company, model.position, model.note, model.phoneNumbers, model.groupId, model.notePhoneNumbers, model.noteDisplayName, model.enterpriseUserName, model.youqiaNickName, model.emailNickName, model.enterpriseMobile_phone, model.enterpriseWork_phone, model.enterpriseHome_phone, model.enterpriseBirthday, @(model.lastUpdateTime),@(model.enterpriseSortId), @(model.enterpriseTopId)];
        if (model.uid == 0) {
            model.uid = (NSInteger)db.lastInsertRowId;
        }
    }];
}

- (void)insertContact:(MCContactModel *)model {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"INSERT OR IGNORE INTO Contact (email, firstChar, displayName, headChecksum, pinYin, weights, avatorDefaultColor, isImportant, youqiaUser, deleteFlag, isCompanyUser, isLeader, company, position, note, phone, groupId, notePhoneNumbers, noteDisplayName, enterpriseUserName, youqiaNickName, emailNickName, enterpriseMobile_phone, enterpriseWork_phone, enterpriseHome_phone, enterpriseBirthday, last_update_time, enterprise_sortId, enterprise_topId) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        [db executeUpdate:sql, model.account, model.pinyinFirstChar, model.displayName, model.headChecksum, model.pinyin, @(model.weights), model.headDefaultColorStr, @(model.importantFlag), @(model.youqiaFlag), @(model.deleteFlag), @(model.isCompanyUser), @(model.isLeader), model.company, model.position, model.note, model.phoneNumbers, model.groupId, model.notePhoneNumbers, model.noteDisplayName, model.enterpriseUserName, model.youqiaNickName, model.emailNickName, model.enterpriseMobile_phone, model.enterpriseWork_phone, model.enterpriseHome_phone, model.enterpriseBirthday, @(model.lastUpdateTime),@(model.enterpriseSortId), @(model.enterpriseTopId)];
        model.uid = (NSInteger)db.lastInsertRowId;
    }];
}

- (void)insertContacts:(NSArray *)contacts
{
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = @"INSERT OR REPLACE INTO Contact (email, firstChar, displayName, headChecksum, pinYin, weights, avatorDefaultColor, isImportant, youqiaUser, deleteFlag, isCompanyUser, isLeader, company, position, note, phone, groupId, notePhoneNumbers, noteDisplayName, enterpriseUserName, youqiaNickName, emailNickName, enterpriseMobile_phone, enterpriseWork_phone, enterpriseHome_phone, enterpriseBirthday, last_update_time, enterprise_sortId, enterprise_topId) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        for (MCContactModel *model in contacts) {
            [db executeUpdate:sql, model.account, model.pinyinFirstChar, model.displayName, model.headChecksum, model.pinyin, @(model.weights), model.headDefaultColorStr, @(model.importantFlag), @(model.youqiaFlag), @(model.deleteFlag), @(model.isCompanyUser), @(model.isLeader), model.company, model.position, model.note, model.phoneNumbers, model.groupId, model.notePhoneNumbers, model.noteDisplayName, model.enterpriseUserName, model.youqiaNickName, model.emailNickName, model.enterpriseMobile_phone, model.enterpriseWork_phone, model.enterpriseHome_phone, model.enterpriseBirthday, @(model.lastUpdateTime), @(model.enterpriseSortId), @(model.enterpriseTopId)];
            model.uid = (NSInteger)db.lastInsertRowId;
        }
        
    }];
}

- (void)updateModel:(id)model {
    MCContactModel *updateModel = (MCContactModel *)model;
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = @"UPDATE Contact SET headChecksum = ?, company = ?, isCompanyUser = ?, enterpriseUserName = ?, youqiaNickName = ?, youqiaUser = ?, enterpriseMobile_phone = ?, enterpriseWork_phone = ?, enterpriseHome_phone = ?, last_update_time = ?, pinYin = ?, firstChar = ?, weights = ?, enterprise_sortId = ?, enterprise_topId = ? WHERE email = ?";
        [db executeUpdate:sql, updateModel.headChecksum, updateModel.company, @(updateModel.isCompanyUser), updateModel.enterpriseUserName, updateModel.youqiaNickName, @(updateModel.youqiaFlag), updateModel.enterpriseMobile_phone, updateModel.enterpriseWork_phone, updateModel.enterpriseHome_phone, @(updateModel.lastUpdateTime), updateModel.pinyin, updateModel.pinyinFirstChar, @(updateModel.weights), @(updateModel.enterpriseSortId), @(updateModel.enterpriseTopId), updateModel.account];
    }];
}

- (void)updateWeight:(MCContactModel *)model
{
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = @"UPDATE Contact SET weights =  ? WHERE email = ?";
        [db executeUpdate:sql, @(model.weights), model.account];
    }];
}

- (void)deleteContacts:(NSArray *)contacts
{
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = @"UPDATE Contact SET deleteFlag = ?, isImportant = ?, weights =  ?, notePhoneNumbers = ?, noteDisplayName = ?, phone = ? WHERE email = ?";
        for (MCContactModel *model in contacts) {
            [db executeUpdate:sql, @(YES), @(NO), @(0), nil, nil, nil, model.account];
        }
    }];
}

- (void)updateContacts:(NSArray *)contacts
{
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = @"UPDATE Contact SET headChecksum = ?, company = ?, isCompanyUser = ?, enterpriseUserName = ?, youqiaNickName = ?, youqiaUser = ?, enterpriseMobile_phone = ?, enterpriseWork_phone = ?, enterpriseHome_phone = ?, pinYin = ?, firstChar = ?, weights = ?, enterprise_sortId = ?, enterprise_topId = ? WHERE email = ?";
        for (MCContactModel *updateModel in contacts) {
            [db executeUpdate:sql, updateModel.headChecksum, updateModel.company, @(updateModel.isCompanyUser), updateModel.enterpriseUserName, updateModel.youqiaNickName, @(updateModel.youqiaFlag), updateModel.enterpriseMobile_phone, updateModel.enterpriseWork_phone, updateModel.enterpriseHome_phone, updateModel.pinyin, updateModel.pinyinFirstChar,@(updateModel.weights), @(updateModel.enterpriseSortId), @(updateModel.enterpriseTopId), updateModel.account];
        }
    }];
}

- (NSMutableArray *)getContacts {
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:0];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM Contact";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            MCContactModel *model = [self modelWithResultSet:rs];
            [models addObject:model];
        }
    }];
    return models;
}

-(NSArray *)getWeightContacts {
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:0];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM Contact WHERE weights > 0 ORDER BY weights DESC LIMIT 100";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            MCContactModel *model = [self modelWithResultSet:rs];
            [models addObject:model];
        }
    }];
    return models;
}

- (NSArray *)getOfftenCommunicationContacts {
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:0];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM Contact WHERE isCompanyUser = ?";
        FMResultSet *rs = [db executeQuery:sql, @NO];
        while ([rs next]) {
            MCContactModel *model = [self modelWithResultSet:rs];
            [models addObject:model];
        }
    }];
    return models;
}

- (NSMutableArray *)getImportantContactsWithImportFlag:(BOOL)importFlag {
    NSMutableArray *models = [NSMutableArray new];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM Contact WHERE isImportant = ?";
        FMResultSet *rs = [db executeQuery:sql, @(importFlag)];
        while ([rs next]) {
            MCContactModel *model = [self modelWithResultSet:rs];
            [models addObject:model];
        }
    }];
    return models;
}

- (MCContactModel *)getContactModelWithEmail:(NSString *)email {
    __block MCContactModel *model = nil;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM Contact WHERE email = ?";
        FMResultSet *rs = [db executeQuery:sql, email];
        while ([rs next]) {
           model = [self modelWithResultSet:rs];
        }
    }];
    return model;
}

- (void)updateImportFlagWithEmail:(NSString *)email importFlag:(BOOL)importFlag {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"UPDATE Contact SET isImportant = ? , deleteFlag = ? where email = ?";
        [db executeUpdate:sql, @(importFlag), @(NO), email];
    }];
}

- (void)updateYouQiaFlag:(BOOL)youQiaFlag email:(NSString *)email {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"UPDATE Contact SET youqiaUser = ? where email = ?";
        [db executeUpdate:sql, @(youQiaFlag),email];
    }];
}

- (void)updateContactDisplayName:(NSString *)name email:(NSString *)email {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"UPDATE Contact SET displayName = ? where email = ?";
        [db executeUpdate:sql, name, email];
    }];
}

- (void)updateContactEmailNickName:(NSString *)name email:(NSString *)email {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"UPDATE Contact SET emailNickName = ? where email = ?";
        [db executeUpdate:sql, name, email];
    }];
}

- (void)updateContactWithNoteInfo:(MCContactModel *)model {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"UPDATE Contact SET email = ? , isImportant = ? , weights = ?, notePhoneNumbers = ? , noteDisplayName = ? , pinYin = ?, firstChar = ?, deleteFlag = ? where id = ?";
        [db executeUpdate:sql, model.account, @(model.importantFlag), @(model.weights), model.notePhoneNumbers, model.noteDisplayName, model.pinyin, model.pinyinFirstChar, @(NO), @(model.uid)];
    }];
}

- (void)updateContactInfoWithEmail:(NSString*)email groupId:(NSString*)groupId important:(BOOL)important notePhoneNumbers:(NSString*)phoneNumbers deleteFlag:(BOOL)delFlag note:(NSString*)note {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"UPDATE Contact SET groupId = ?, isImportant = ?, notePhoneNumbers, deleteFlag = ?, note = ?  where email = ?";
        [db executeUpdate:sql, email];
    }];
}

- (void)synContactsInfoWithContacts:(NSArray *)contacts {
    if ([contacts isEqual:[NSNull null]]) {
        return;
    }
    if (!contacts || contacts.count == 0) {
        return;
    }
    for (MCContactModel *obj in contacts) {
        MCContactModel *model = [self getContactModelWithEmail:obj.account];
        if (model) {
            model.youqiaNickName = obj.youqiaNickName;
            model.company = obj.company;
            model.position = obj.position;
            model.enterpriseDepartMent = obj.enterpriseDepartMent;
            model.headChecksum = obj.headChecksum;
        }else {
            model = obj;
        }
        NSString *pinyinFirstChar = [MCContactModel getPinYinFirstCharWith:model.displayName];
        model.pinyinFirstChar = pinyinFirstChar;
        model.youqiaFlag = YES;
        [self insertOrReplaceContact:model];
    }
}

- (MCContactModel *)modelWithResultSet:(FMResultSet *)rs {
    MCContactModel * model = [[MCContactModel alloc] init];
    model.uid = [rs intForColumn:@"id"];
    model.account = [rs stringForColumn:@"email"];
    model.pinyinFirstChar = [rs stringForColumn:@"firstChar"];
    model.noteDisplayName = [rs stringForColumn:@"noteDisplayName"];
    model.enterpriseUserName = [rs stringForColumn:@"enterpriseUserName"];
    model.youqiaNickName = [rs stringForColumn:@"youqiaNickName"];
    model.emailNickName = [rs stringForColumn:@"emailNickName"];
    model.headChecksum = [rs stringForColumn:@"headChecksum"];
    model.pinyin = [rs stringForColumn:@"pinYin"];
    model.weights = [rs intForColumn:@"weights"];
    model.enterpriseSortId = [rs intForColumn:@"enterprise_sortId"];
    model.enterpriseTopId = [rs intForColumn:@"enterprise_topId"];
    model.headDefaultColorStr = [rs stringForColumn:@"avatorDefaultColor"];
    model.importantFlag = [rs boolForColumn:@"isImportant"];
    model.youqiaFlag = [rs boolForColumn:@"youqiaUser"];
    model.deleteFlag = [rs boolForColumn:@"deleteFlag"];
    model.isCompanyUser = [rs boolForColumn:@"isCompanyUser"];
    model.isLeader = [rs boolForColumn:@"isLeader"];
    model.company = [rs stringForColumn:@"company"];
    model.position = [rs stringForColumn:@"position"];
    model.note = [rs stringForColumn:@"note"];
    model.phoneNumbers = [rs stringForColumn:@"phone"];
    model.groupId = [rs stringForColumn:@"groupId"];
    model.notePhoneNumbers = [rs stringForColumn:@"notePhoneNumbers"];
    model.enterpriseMobile_phone = [rs stringForColumn:@"enterpriseMobile_phone"];
    model.enterpriseWork_phone = [rs stringForColumn:@"enterpriseWork_phone"];
    model.enterpriseHome_phone = [rs stringForColumn:@"enterpriseHome_phone"];
    model.enterpriseBirthday = [rs stringForColumn:@"enterpriseBirthday"];
    return model;
}

- (void)updateBranchWithBranchList:(NSArray *)branchInfos {
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (MCBranchInfo *branchObj in branchInfos) {
            NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO EnterpriseBranch (branch_id, name, parent_id, sort_id, employeesCnt, subBranchCnt) VALUES (?,?,?,?,?,?)"];
            BOOL result = [db executeUpdate:sql, branchObj.branchId, branchObj.name, branchObj.parentId, [NSNumber numberWithInt:branchObj.sortId], [NSNumber numberWithInt:branchObj.emplyoeesCnt], @(branchObj.subBranchCnt)];
            if (!result) {
                *rollback = YES;
                break;
            }
        }
    }];
}

- (void)updateBranchEmployeeWithBranchEmplyoeeList:(NSArray *)branchEmplyoeeInfos {
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (MCBranchEmplyoeeInfo *obj in branchEmplyoeeInfos) {
            NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO EnterpriseBranchEmployeesInfo (branch_id, email, is_leader) VALUES (?,?,?)"];
            BOOL result = [db executeUpdate:sql, obj.branch_id, obj.email, [NSNumber numberWithBool:obj.isLeader]];
            if (!result) {
                *rollback = YES;
                break;
            }
        }
    }];
}

// 获取同部门的领导
- (MCBranchEmplyoeeInfo *)getLeaderWithEmail:(NSString *)email
{
    __block MCBranchEmplyoeeInfo *branchEmployee = nil;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"Select * from EnterpriseBranchEmployeesInfo WHERE is_leader = 1 AND branch_id IN ( SELECT branch_id from EnterpriseBranchEmployeesInfo where email = ? )";
        FMResultSet *rs = [db executeQuery:sql,email];
        while ([rs next]) {
            branchEmployee = [self branchEmplyoeeInfoWithResultSet:rs];
        }
    }];
    
    return branchEmployee;
    
}

- (NSArray *)getAllEnterpriseBranch {
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:0];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM EnterpriseBranch";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            MCBranchInfo *model = [self branchInfoWithResultSet:rs];
            [models addObject:model];
        }
    }];
    return [models copy];
}

- (int)getBranchEmplyoeesCountWithBranchId:(NSString *)branchId {
    __block int count = 0;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString* sql = @"select count(*) from EnterpriseBranchEmployeesInfo where branch_id = ?";
        count = [db intForQuery:sql,branchId];
    }];
    return count;
}

- (NSArray *)getAllEnterpriseEmplyoees {
    NSMutableArray *models = [NSMutableArray new];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM Contact WHERE isCompanyUser = ?";
        FMResultSet *rs = [db executeQuery:sql, @YES];
        while ([rs next]) {
            MCContactModel *model = [self modelWithResultSet:rs];
            [models addObject:model];
        }
    }];
    return models;
}

- (NSArray *)getAllEnterpriseBranchEmplyoeeInfo {
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:0];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM EnterpriseBranchEmployeesInfo";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            MCBranchEmplyoeeInfo *model = [self branchEmplyoeeInfoWithResultSet:rs];
            [models addObject:model];
        }
    }];
    return [models copy];
}

- (NSArray *)getEnterpriseBranchEmployeeInfosByBranchId:(NSString*)branchId {
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:0];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM EnterpriseBranchEmployeesInfo WHERE branch_id = ?";
        FMResultSet *rs = [db executeQuery:sql,branchId];
        while ([rs next]) {
            MCBranchEmplyoeeInfo *model = [self branchEmplyoeeInfoWithResultSet:rs];
            [models addObject:model];
        }
    }];
    return [models copy];
}

- (NSArray *)getSameDominContactInfoByDomin:(NSString *)domin {
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:0];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM Contact";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            MCContactModel *model = [self modelWithResultSet:rs];
            NSString* currentEmail = model.account;
            NSRange range = [currentEmail rangeOfString:@"@"];
            NSString* domin1 = [currentEmail substringFromIndex:(range.location + 1)];
            if ([domin1 isEqualToString:domin]) {
                [models addObject:model];
            }
        }
    }];
    return [models copy];
}

- (MCBranchInfo *)getEnterpriseBranchInfoWithBranchId:(NSString *)branchId {
    __block MCBranchInfo* model = nil;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString*sqlstr = @"select * from EnterpriseBranch where branch_id = ?";
        FMResultSet *dataRs = [db executeQuery:sqlstr, branchId];
        while ([dataRs next])
        {
            model = [self branchInfoWithResultSet:dataRs];
        }
    }];
    return model;
}

- (void)deleteEnterpriseData {
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString* sql2 = @"DELETE FROM EnterpriseBranch";
        NSString* sql3 = @"DELETE FROM EnterpriseBranchEmployeesInfo";
        [db executeUpdate:sql2];
        [db executeUpdate:sql3];
    }];
}

-(int64_t) getContactLastUpdateTimeWithEmail:(NSString *)email {
    __block int64_t lastUpdateTime = 0;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"select * from Contact where email = ?";
        FMResultSet *dataRs = [db executeQuery:sql, email];
        while ([dataRs next])
        {
            lastUpdateTime = [dataRs doubleForColumn:@"last_update_time"];
        }
    }];
    return lastUpdateTime;
}

- (BOOL)getEnterpriseEmplyoeeIsLeaderWithEmail:(NSString *)email {
    __block BOOL isLeader = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString* sql = [NSString stringWithFormat:@"select * from EnterpriseBranchEmployeesInfo where email = \"%@\"",  email];
        FMResultSet *dataRs = [db executeQuery:sql];
        while ([dataRs next])
        {
            isLeader = [dataRs boolForColumn:@"is_leader"];
        }
    }];
    return isLeader;
}

- (MCBranchInfo *)branchInfoWithResultSet:(FMResultSet *)rs {
    MCBranchInfo *obj = [[MCBranchInfo alloc] init];
    obj.branchId = [rs stringForColumn:@"branch_id"];
    obj.name = [rs stringForColumn:@"name"];
    obj.parentId = [rs stringForColumn:@"parent_id"];
    obj.sortId = [rs intForColumn:@"sort_id"];
    obj.emplyoeesCnt = [rs intForColumn:@"employeesCnt"];
    obj.subBranchCnt = [rs intForColumn:@"subBranchCnt"];
    return obj;
}

- (MCBranchEmplyoeeInfo *)branchEmplyoeeInfoWithResultSet:(FMResultSet *)rs {
    MCBranchEmplyoeeInfo *obj = [[MCBranchEmplyoeeInfo alloc] init];
    obj.branch_id = [rs stringForColumn:@"branch_id"];
    obj.email = [rs stringForColumn:@"email"];
    obj.isLeader = [rs boolForColumn:@"is_leader"];
    return obj;
}

@end
