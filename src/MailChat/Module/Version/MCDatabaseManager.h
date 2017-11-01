//
//  MCDatabaseManager.h
//  NPushMail
//
//  Created by admin on 7/6/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCDatabaseManager : NSObject

/**
 *  是否需要升级
 *
 *  @return YES需要升级，NO不需要
 */
- (BOOL)shouldUpgrade;

- (BOOL)upradeDatabase;

@end
