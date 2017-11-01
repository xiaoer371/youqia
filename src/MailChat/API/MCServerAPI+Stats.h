//
//  MCServerAPI+Stats.h
//  NPushMail
//
//  Created by admin on 8/10/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCServerAPI.h"

@interface MCServerAPI (Stats)

- (void)reportLoginStatus:(BOOL)isSuccess
                withEmail:(NSString *)email
                    error:(NSError *)error
                  success:(ActionBlock)success
                  failure:(FailureBlock)failure;

@end
