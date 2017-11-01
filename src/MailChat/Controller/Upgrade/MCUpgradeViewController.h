//
//  MCUpgradeViewController.h
//  NPushMail
//
//  Created by admin on 8/4/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCLoginViewController.h"
@class Person;
typedef void(^upgradeOaResult)(BOOL result, Person *act, MCAccountConfig *accountConfig);

@interface MCUpgradeViewController : MCLoginViewController

// 数据库升级回调
@property (nonatomic,copy) ActionBlock completeBlock;

@end
