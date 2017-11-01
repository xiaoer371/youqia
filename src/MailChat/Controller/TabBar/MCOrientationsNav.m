//
//  MCOrientationsNav.m
//  NPushMail
//
//  Created by swhl on 17/1/16.
//  Copyright © 2017年 sprite. All rights reserved.
//

#import "MCOrientationsNav.h"

@implementation MCOrientationsNav

- (BOOL)shouldAutorotate
{
    return [self.viewControllers.lastObject shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [self.viewControllers.lastObject supportedInterfaceOrientations];
}

@end
