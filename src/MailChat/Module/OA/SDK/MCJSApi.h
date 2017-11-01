//
//  MCJSApi.h
//  NPushMail
//
//  Created by admin on 3/24/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^JSSuccessBlock)(NSArray *args);
typedef void(^JSFailureBlock)(id error);

@interface MCJSApi : NSObject

/**
 *  Api 名称，全部小写
 */
@property (nonatomic,strong,readonly) NSString *name;

- (void)processWithParameters:(id)params success:(JSSuccessBlock)success failure:(JSFailureBlock)failure;

@end
