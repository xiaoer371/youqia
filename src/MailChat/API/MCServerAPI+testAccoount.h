//
//  MCServerAPI+testAccoount.h
//  NPushMail
//
//  Created by wuwenyu on 16/9/21.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCServerAPI.h"
#import "MCUserInfo.h"
#import "MCAccount.h"

@interface MCServerAPI (testAccoount)

- (void)addMailToUser:(NSString *)user
                  pwd:(NSString *)pwd
                email:(NSString *)email
         withPassword:(NSString *)password
       shouldValidate:(BOOL)shouldValidate
              success:(SuccessBlock)success
              failure:(FailureBlock)failure;

@end
