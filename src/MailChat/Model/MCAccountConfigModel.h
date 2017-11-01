//
//  MCAccountConfigModel.h
//  NPushMail
//
//  Created by admin on 12/25/15.
//  Copyright © 2015 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCAccountConfigModel : NSObject

@property (nonatomic,assign) NSInteger uid;
@property (nonatomic,assign) NSInteger accountId;
@property (nonatomic,strong) NSString *configKey;
@property (nonatomic,strong) NSString *configValue;

@end
