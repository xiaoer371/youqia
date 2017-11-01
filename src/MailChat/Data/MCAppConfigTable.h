//
//  MCAppConfig.h
//  NPushMail
//
//  Created by admin on 12/25/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import "MCTableBase.h"
#import "MCAppConfigModel.h"

@interface MCAppConfigTable : MCTableBase

- (void)updateValue:(NSString *)value forKey:(NSString *)key;

@end
