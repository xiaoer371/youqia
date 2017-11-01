//
//  MCMailAddress.h
//  NPushMail
//
//  Created by admin on 2/14/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCMailAddress : NSObject

@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *email;

- (instancetype)initWithJsonString:(NSString *)jsonStr;
- (instancetype)initWithJsonObject:(NSDictionary *)obj;
- (NSDictionary *)toDictionary;
- (NSString *)toJsonString;

@end
