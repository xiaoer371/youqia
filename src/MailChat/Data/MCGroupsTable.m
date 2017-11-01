//
//  MCGroupsTable.m
//  NPushMail
//
//  Created by wuwenyu on 16/1/15.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCGroupsTable.h"
#import "MCAccount.h"
#import "MCAccountManager.h"
#import "MCGroup.h"
#import "MCUDID.h"

@implementation MCGroupsTable

- (void)addDefaultGroups {
    
    NSArray *accounts = [[MCAccountManager shared] getAllAccounts];
    for (MCAccount *acc in accounts) {
        NSMutableArray *groups = [self getGroups];
        BOOL isSyn = NO;
        for (MCGroup *obj in groups) {
            if (obj.isDefaultGroup) {
                //说明已经添加过默认分组则不再添加(默认分组只添加一次)
                isSyn = YES;
                break;
            }
        }
        
        if (!isSyn) {
            //去添加默认分组,这里添加为key值作为groupName,是考虑到多语言的情况下只需要取到这个key值即可得到默认分组的名称
            NSMutableArray *defaultKeyAry = [NSMutableArray arrayWithCapacity:0];
            [defaultKeyAry addObject:@"PM_Contacts_Type_En"];
            [defaultKeyAry addObject:@"PM_Contacts_Type_YouQia"];
            [defaultKeyAry addObject:@"PM_ContactMessageGroups"];
            for (int i = 0; i < defaultKeyAry.count; i++) {
                MCGroup *groupObj = [[MCGroup alloc] init];
                groupObj.name = [defaultKeyAry objectAtIndex:i];
                groupObj.sortId = [self getGroupMaxSortId];
                groupObj.defaultGroupSortId = i;
                groupObj.groupId = [self getGroupId];
                groupObj.isDefaultGroup = YES;
                [self insertModel:groupObj];
            }
        }
    }
}

- (NSMutableArray *)getGroups {
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:0];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM GroupsInfo";
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            MCGroup *model = [self modelWithResultSet:rs];
            [models addObject:model];
        }
    }];
    return models;
}

- (void)deleteGroupWithGroupId:(NSString *)groupId {
    [self.dbQueue inDatabase:^(FMDatabase * db) {
        [db setShouldCacheStatements:YES];
        NSString *sql =[NSString stringWithFormat:@"DELETE FROM GroupsInfo WHERE group_id = ?"];
        [db executeUpdate:sql, groupId];
    }];
}

- (void)insertModel:(id)model {
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"INSERT OR REPLACE INTO GroupsInfo (group_id, groupName, sort_id, isDefaultGroup, defaultGroupSortId) VALUES (?,?,?,?,?)";
        if ([model isMemberOfClass:[MCGroup class]]) {
            MCGroup *group = (MCGroup *)model;
            [db executeUpdate:sql, group.groupId, group.name, @(group.sortId), @(group.isDefaultGroup), @(group.defaultGroupSortId)];
        }
    }];
}

- (NSString *)getGroupNameWithGroupId:(NSString *)groupId {
    __block NSString* groupName = @"未知分组";
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM GroupsInfo WHERE group_id = ?";
        FMResultSet *dataRs = [db executeQuery:sql, groupId];
        while ([dataRs next]) {
            groupName = [dataRs stringForColumn:@"groupName"];
        }
    }];
    return groupName;
}

- (NSString *)getGroupIdWithGroupName:(NSString *)groupName {
    __block NSString* groupId = @"";
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM GroupsInfo WHERE groupName = ?";
        FMResultSet *dataRs = [db executeQuery:sql, groupName];
        while ([dataRs next]) {
            groupId = [dataRs stringForColumn:@"group_id"];
        }
    }];
    return groupId;
}

- (MCGroup *)modelWithResultSet:(FMResultSet *)rs {
    MCGroup *model = [[MCGroup alloc] init];
    model.groupId = [rs stringForColumn:@"group_id"];
    model.sortId = [rs intForColumn:@"sort_id"];
    model.name = [rs stringForColumn:@"groupName"];
    model.isDefaultGroup = [rs boolForColumn:@"isDefaultGroup"];
    model.defaultGroupSortId = [rs intForColumn:@"defaultGroupSortId"];
    return model;
}

- (int)getGroupMaxSortId {//获取最大sortId
    __block int maxSortId = 0;
    [self.dbQueue inDatabase:^(FMDatabase * db) {
        NSString* sqlQuery = @"SELECT max(sort_id) as sort_id FROM GroupsInfo";
        FMResultSet *dataRs = [db executeQuery:sqlQuery];
        while ([dataRs next]) {
            maxSortId = [dataRs intForColumn:@"sort_id"];
        }
    }];
    return maxSortId + 1;
}

- (NSString *)getGroupId {
    return [MCUDID newUUID];
}


@end
