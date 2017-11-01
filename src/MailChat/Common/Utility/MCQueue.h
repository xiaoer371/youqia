//
//  MCQueue.h
//  NPushMail
//
//  Created by admin on 3/17/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  A thead safe queue
 */
@interface MCQueue : NSObject

- (void)enqueue:(id)obj;
- (id)dequeue;

@end
