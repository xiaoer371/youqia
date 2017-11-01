//
//  MCAccountConfigTable.h
//  NPushMail
//
//  Created by admin on 12/25/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import "MCTableBase.h"
#import "MCAccountConfigModel.h"
#import "MCAccountTableBase.h"

@interface MCAccountConfigTable : MCAccountTableBase
/**
 *  更新键值
 *
 *  @param value
 *  @param key
 */
- (void)updateValue:(NSString *)value forKey:(NSString *)key;
/**
 *  根据key得到配置值
 *
 *  @param key
 *
 *  @return
 */
- (id)getModelWithKey:(NSString *)key;
- (void)delValueWithKey:(NSString *)key;
@end
