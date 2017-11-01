//
//  MCRefreshView.m
//  NPushMail
//
//  Created by wuwenyu on 16/7/13.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCRefreshHelper.h"

@implementation MCRefreshHelper

+ (SRRefreshView *)createRefreshView {
    SRRefreshView *refreshV = [[SRRefreshView alloc]init];
    refreshV.upInset = 0;
    refreshV.slimeMissWhenGoingBack = YES;
    refreshV.slime.bodyColor = [UIColor colorWithHexString:@"aaafb6"];
    refreshV.slime.skinColor = [UIColor colorWithHexString:@"aaafb6"];
    refreshV.slime.lineWith = 1;
    refreshV.backgroundColor = [UIColor clearColor];
    return refreshV;
}

@end
