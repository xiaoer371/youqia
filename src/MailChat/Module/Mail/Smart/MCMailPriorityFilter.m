//
//  MCMailPriorityFilter.m
//  NPushMail
//
//  Created by admin on 9/22/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCMailPriorityFilter.h"

@implementation MCMailPriorityFilter

- (BOOL)isImportantMail:(MCMailModel *)mail
{
    return mail.xPriority == 1;
}

@end
