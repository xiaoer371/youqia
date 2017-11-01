//
//  MCOABindingMailConfig.h
//  NPushMail
//
//  Created by wuwenyu on 16/11/23.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCOABindingMailConfig : NSObject

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *errorMsg;
@property (nonatomic, assign) int errorCode;
- (instancetype)initWithDictionary:(id)dict;

@end
