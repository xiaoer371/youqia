//
//  MailboxTable.h
//  NPushMail
//
//  Created by admin on 12/10/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCTableBase.h"
#import "MCMailBox.h"

@interface MCMailboxTable : MCTableBase

- (NSArray *)getModelsForUser:(NSInteger)accountId;
- (MCMailBox *)getMailBoxWithAccount:(NSInteger)accountId path:(NSString *)boxPath;
- (MCMailBox *)getMailBoxWithAccount:(NSInteger)accountId type:(MCMailFolderType)type;
- (MCMailBox *)getMailBoxWithAccount:(NSInteger)accountId name:(NSString *)name level:(NSInteger)level;
@end
