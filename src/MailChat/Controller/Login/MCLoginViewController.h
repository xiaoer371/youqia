//
//  MCLoginViewController.h
//  NPushMail
//
//  Created by zhang on 2016/11/25.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseLoginViewController.h"

@interface MCLoginViewController : MCBaseLoginViewController

@property (nonatomic,assign)  MCMailType emailType;

- (void)loginAccountEmail:(NSString*)email passWord:(NSString*)passWord success:(SuccessBlock)success failure:(FailureBlock)failure;

- (void)loginGmailEmail:(NSString*)email;

//help
- (void)connectHelp;
@end
