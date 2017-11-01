//
//  MCGmailAuth.h
//  NPushMail
//
//  Created by admin on 9/30/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppAuth.h"

@interface MCGmailAuth : NSObject

+ (void)requestAccountWithAuthState:(OIDAuthState *)state success:(SuccessBlock)success failure:(FailureBlock)failure;

@end
