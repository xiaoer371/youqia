//
//  MCWeakProxy.h
//  NPushMail
//  Thanks for YYText
//
//  Created by admin on 3/8/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCWeakProxy : NSProxy

/**
 The proxy target.
 */
@property (nullable, nonatomic, weak, readonly) id target;

/**
 Creates a new weak proxy for target.
 
 @param target Target object.
 
 @return A new proxy object.
 */
- (nonnull instancetype)initWithTarget:(nonnull id)target;

/**
 Creates a new weak proxy for target.
 
 @param target Target object.
 
 @return A new proxy object.
 */
+ (nonnull instancetype)proxyWithTarget:(nonnull id)target;

@end
