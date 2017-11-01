//
//  MCIMProcessor.h
//  NPushMail
//
//  Created by admin on 3/17/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCIMProcessor : NSObject

- (void)processData:(NSData *)data ofTopic:(NSString *)topic;

@end
