//
//  MCIMNewMailModel.h
//  NPushMail
//
//  Created by admin on 3/9/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCIMDataModel.h"
#import "MCMailNotificationModel.h"

@interface MCIMNewMailModel : MCIMDataModel

@property (nonatomic,strong) MCMailNotificationModel *mailInfo;

@end
