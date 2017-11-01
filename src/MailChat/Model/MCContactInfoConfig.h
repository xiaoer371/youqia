//
//  MCContactInfoConfig.h
//  NPushMail
//
//  Created by wuwenyu on 16/3/23.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCContactInfoConfig : NSObject

@property (nonatomic, strong) NSArray *infos;
- (instancetype)initWithDictionary:(id)dict;

@end
