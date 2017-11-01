//
//  MCIMService.h
//  NPushMail
//
//  Created by admin on 3/3/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCIMClient.h"

@interface MCIMService : NSObject

@property (atomic,assign,readonly) BOOL isRunning;
@property (nonatomic,weak) MCIMClient *client;

- (instancetype)initWithAccount:(MCAccount *)account;

- (void)run;
- (void)stop;

@end
