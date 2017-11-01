//
//  MCDbVersion6.m
//  NPushMail
//
//  Created by wuwenyu on 16/11/16.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCDbVersion6.h"
#import "MCAppSetting.h"

@implementation MCDbVersion6

- (NSInteger)version
{
    return 6;
}

- (BOOL)upgradeDatabase
{
    AppSettings.jsVersion = 0;
    DDLogInfo(@"MCDbVersion6 = %d",YES);
    
    return YES;
}

@end
