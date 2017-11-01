//
//  MCIMInvitationModel.m
//  NPushMail
//
//  Created by admin on 3/28/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCIMInvitationModel.h"

@implementation MCIMInvitationModel

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    } else if (![other isKindOfClass:self.class]) {
        return NO;
    } else {
        MCIMInvitationModel *otherModel = (MCIMInvitationModel *)other;
        return [otherModel.groupId isEqual:self.groupId];
    }
}

- (NSUInteger)hash
{
    return [self.groupId hash];
}

@end
