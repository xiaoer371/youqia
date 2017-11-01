//
//  MCIMTopicManager.m
//  NPushMail
//
//  Created by admin on 3/30/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCIMTopicManager.h"

@interface MCIMTopicManager ()

@end

@implementation MCIMTopicManager

- (instancetype)initWithAccount:(MCAccount *)account
{
    if (self = [super init]) {
        _account = account;
        [self commonInit];
    }
    return self;
}

- (void)updateTopicsSuccess:(SuccessBlock)success failure:(FailureBlock)failure
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *topics = [[NSMutableArray alloc] initWithArray:self.privateTopics];
        
        __block NSError *lastError = nil;
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_enter(group);
        
        [[MCIMGroupManager shared] getInvitationsSuccess:^(NSArray *invitations) {
            for (MCIMInvitationModel *invite in invitations) {
                [self.inviteTopics addObject:invite.groupId];
                [topics addObject:invite.groupId];
            }
            dispatch_group_leave(group);
        } failure:^(NSError *error) {
            dispatch_group_leave(group);
            lastError = error;
            DDLogError(@"get invitation error = %@",error);
        }];
        
        dispatch_group_enter(group);
        [[MCIMGroupManager shared] updateUserGroupsSuccess:^(NSArray *response) {
            NSArray *groups = (NSArray *)response;
            for (MCIMGroupModel *group in groups) {
                [topics addObject:group.groupId];
            }
            dispatch_group_leave(group);
        } failure:^(NSError *error) {
            dispatch_group_leave(group);
            lastError = error;
            DDLogError(@"[updateUserGroupsSuccess] error = %@",error);
        }];
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        if (lastError) {
            failure(lastError);
        }
        else{
            if (success) {
                success(topics);
            }
        }
        
    });
}

#pragma mark - Private

- (void)commonInit
{
    _inviteTopics = [NSMutableArray new];
    
    NSString *email = self.account.email;
    NSString *selfTopic = [NSString stringWithFormat:@"%@/1",email];
    NSString *sysTopic = [NSString stringWithFormat:@"%@/s",email];
    NSString *oaTopic = [NSString stringWithFormat:@"%@/a",email];
    _privateTopics = @[selfTopic,sysTopic,oaTopic];
}

@end
