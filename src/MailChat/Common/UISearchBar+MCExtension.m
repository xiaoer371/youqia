//
//  UISearchBar+MCExtension.m
//  NPushMail
//
//  Created by wuwenyu on 16/3/17.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "UISearchBar+MCExtension.h"

@implementation UISearchBar (MCExtension)

- (void)settingActiveTintStyle {
    self.backgroundColor = [UIColor clearColor];
    self.barTintColor = [UIColor clearColor];
//    self.translucent = NO;
    UITextField *searchField = [self valueForKey:@"searchField"];
    if (searchField) {
        [searchField setTintColor:AppStatus.theme.tintColor];
    }
    [self setBackgroundImage:AppStatus.theme.navbarBgImage forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
    self.scopeBarBackgroundImage = AppStatus.theme.navbarBgImage;
    self.tintColor = [UIColor whiteColor];
}

- (void)settingPlainTintStyle {
    self.backgroundColor = [UIColor clearColor];
    self.barTintColor = [UIColor clearColor];
    self.translucent = NO;
    UIImage *img = [UIImage imageNamed:@"searchBarBgImage.png"];
    [self setBackgroundImage:img forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    self.scopeBarBackgroundImage = img;
    self.tintColor = [UIColor whiteColor];
}

@end
