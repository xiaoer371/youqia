//
//  MCThemeManager.h
//  NPushMail
//
//  Created by admin on 1/27/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCTheme.h"

@interface MCThemeManager : NSObject

+ (instancetype)sharedManager;

/**
 *  当前的主题, 没有设置使用默认的主题
 */
@property (nonatomic,readonly) MCTheme *theme;

/**
 *  可选的主题名称
 */
@property (nonatomic,readonly) NSArray *themeNames;


- (void)applyThemeWithName:(NSString *)themeName;

@end
