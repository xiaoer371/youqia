//
//  MCFixSystem.h
//  NPushMail
//
//  Created by wuwenyu on 16/10/9.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^JsUpdateCompliteBlock)(BOOL needRun, NSString *jsPath);
typedef void(^JsUpdateFailBlock)(void);

@interface MCFixSystem : NSObject

+ (MCFixSystem *)shared;
- (void)checkUpdateJsFileSuccess:(JsUpdateCompliteBlock)compliteBlock failure:(JsUpdateFailBlock)failBlcok;

@end
