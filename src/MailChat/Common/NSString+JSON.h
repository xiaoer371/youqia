//
//  NSString+JSON.h
//  NPushMail
//
//  Created by admin on 2/15/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JSON)

- (id)toJson;

+ (NSString *)jsonStringWithObject:(id)jsonObj;

@end
