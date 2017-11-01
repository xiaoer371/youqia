//
//  OpenUDID+MCMQTTClientId.h
//  NPushMail
//
//  Created by swhl on 16/7/21.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <OpenUDID/OpenUDID.h>

@interface OpenUDID (MCMQTTClientId)

+ (NSString *) getSysUDID;
+ (NSString *) uuidThatDifferentEvery;

@end
