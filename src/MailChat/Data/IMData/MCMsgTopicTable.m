//
//  MCMsgTopicTable.m
//  NPushMail
//
//  Created by swhl on 16/1/26.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCMsgTopicTable.h"

@implementation MCMsgTopicTable

-(NSInteger)getTopicIdWithTopic:(NSString *)topic
{
    __block NSInteger a = NSNotFound;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT topicId FROM TopicInfo WHERE topic = ?";
        FMResultSet *rs = [db executeQuery:sql,topic];
        if ([rs next]) {
            a=[rs intForColumn:@"topicId"];
        }
    }];
    return a;
}
//test




@end
