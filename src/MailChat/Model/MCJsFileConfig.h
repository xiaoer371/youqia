//
//  MCJsFileConfig.h
//  NPushMail
//
//  Created by wuwenyu on 16/10/10.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCJsFileConfig : NSObject

- (instancetype)initWithDictionary:(id)dict;
@property (nonatomic, strong) NSString *jsUrl;
@property (nonatomic, strong) NSString *md5;
@property (nonatomic, assign) NSInteger jsVersion;
@property (nonatomic, assign) BOOL needUpdate;
@property (nonatomic, assign) BOOL needRollBack;

@end
