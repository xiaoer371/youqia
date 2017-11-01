//
//  MCAccountTable.h
//  NPushMail
//
//  Created by admin on 12/25/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import "MCTableBase.h"
#import "MCAccount.h"

@interface MCAccountTable : MCTableBase

- (MCAccount *)getAccountByEmail:(NSString *)email;

@end
