//
//  MCMailMoveViewController.h
//  NPushMail
//
//  Created by zhang on 16/3/29.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCBaseSubViewController.h"
#import "MCMailBox.h"
#import "MCMailManager.h"

@interface MCMailMoveViewController : MCBaseSubViewController

@property (nonatomic,copy)dispatch_block_t selectBoxCallBack;

- (id)initWithCurrentMailBox:(MCMailBox*)mailBox manager:(MCMailManager *)mailManager moveComplete:(void(^)(MCMailBox*))moveComplete;

@end
