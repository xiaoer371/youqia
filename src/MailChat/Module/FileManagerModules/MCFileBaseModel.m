//
//  MCFileBaseModel.m
//  NPushMail
//
//  Created by wuwenyu on 15/12/29.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import "MCFileBaseModel.h"
#import "MCFileCore.h"
#import "MCFileManager.h"

@implementation MCFileBaseModel

- (NSString *)fullPath
{
    return [[[MCFileCore sharedInstance] getFileModule] getFileFullPathWithShortPath:self.location];
}

@end
