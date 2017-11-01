//
//  MCAvatorInviteModel.h
//  NPushMail
//
//  Created by swhl on 16/1/27.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCAvatorInviteModel : NSObject

@property (nonatomic,strong)NSString *email;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *url;
@property (nonatomic,strong)NSString *checksum;

@property (nonatomic,assign)NSUInteger invitecode;
@property (nonatomic,assign)NSUInteger c1;
@property (nonatomic,assign)NSUInteger c2;
@property (nonatomic,assign)NSUInteger c3;
@property (nonatomic,assign)NSUInteger c4;
@property (nonatomic,assign)NSUInteger result;

-(instancetype)initWithResponseDic:(NSDictionary*)responseDic;

@end
