//
//  MCThemeManager.m
//  NPushMail
//
//  Created by admin on 1/27/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCThemeManager.h"

static NSString* const kMailChatThemeKey = @"com.mailchat.theme";

@implementation MCThemeManager

- (instancetype)init
{
    if (self = [super init]) {
        [self setup];
    }
    
    return self;
}

+ (instancetype)sharedManager
{
    static id instance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [MCThemeManager new];
    });
    
    return instance;
}

- (void)applyThemeWithName:(NSString *)themeName
{
    if ([themeName isEqualToString:self.theme.name]) {
        return;
    }
    
    MCTheme *theme = [[MCTheme alloc] initWithName:themeName];
    [self applyTheme:theme];
}

#pragma mark - Private

- (void)setup
{
    NSString *themeName = [[NSUserDefaults standardUserDefaults] stringForKey:kMailChatThemeKey];
    if (!themeName) {
        themeName = @"DefaultTheme";
    }
    _theme = [[MCTheme alloc] initWithName:themeName];
    [self applyTheme:_theme];
}

- (void)applyTheme:(MCTheme *)theme
{
    _theme = theme;
    [[NSUserDefaults standardUserDefaults] setObject:theme.name forKey:kMailChatThemeKey];
    
    [[UINavigationBar appearance] setBackgroundImage:theme.navbarBgImage forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [[UITabBar appearance] setTintColor:theme.tintColor];
    [[UITabBar appearance] setBarTintColor:theme.toolBarBackgroundColor];
    
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
}

@end
