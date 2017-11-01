//
//  MCIMGroupModel.m
//  NPushMail
//
//  Created by swhl on 16/1/27.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMGroupModel.h"


@implementation MCIMGroupModel

- (NSString *)peerName
{
    return self.groupName;
}

-(void)setPeerName:(NSString *)peerName
{
    _groupName =peerName;
}

- (UIImage *)avatarPlaceHolder
{
    return [UIImage imageNamed:@"group_default.png"];
}

@end

@implementation MCIMGroupMember

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    }
    
    if (![other isKindOfClass:self.class]) {
        return NO;
    }
    
    return [self.userId isEqualToString:[other userId]];
    
}

- (NSUInteger)hash
{
    return [self.userId hash];
}

+ (NSSet *)keyPathsForValuesAffectingPeerName
{
    return [NSSet setWithObject:NSStringFromSelector(@selector(groupName))];
}

@end
