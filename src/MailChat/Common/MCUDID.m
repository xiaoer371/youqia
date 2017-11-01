//
//  MCUDID.m
//  NPushMail
//
//  Created by admin on 2/2/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCUDID.h"

@implementation MCUDID

+ (NSString *)newUUID {
    return [[NSUUID UUID] UUIDString];
}

@end
