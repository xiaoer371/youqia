//
//  MCWorkSpaceManager.h
//  NPushMail
//
//  Created by wuwenyu on 2017/2/9.
//  Copyright © 2017年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCEisWorkSpaceManager.h"
#import "MCOAWorkSpaceManager.h"

@interface MCWorkSpaceManager : NSObject

+ (void)workSpaceUserCheck;
+ (void)resetWorkSpaceStatusWithAccount:(MCAccount *)act;

@end
