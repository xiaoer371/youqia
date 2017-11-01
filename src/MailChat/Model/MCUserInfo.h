//
//  MCUserInfo.h
//  NPushMail
//
//  Created by admin on 3/25/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  用户信息，一个用户下面可以有多个邮箱账号
 */
@interface MCUserInfo : NSObject

- (instancetype)initWithJson:(id)json;

/**
 *  用户在服务器上的id
 */
@property (nonatomic,copy) NSString *serverId;

/**
 *  用户编号，目前此值为deviceId
 */
@property (nonatomic,copy) NSString *userId;

@property (nonatomic,copy) NSString *userName;

@property (nonatomic,copy) NSString *password;

@property (nonatomic,assign) CGFloat createDate;

@property (nonatomic,assign) CGFloat registerDate;

- (NSDictionary *)toJson;

@end
