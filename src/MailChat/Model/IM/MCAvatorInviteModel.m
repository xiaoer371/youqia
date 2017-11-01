//
//  MCAvatorInviteModel.m
//  NPushMail
//
//  Created by swhl on 16/1/27.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAvatorInviteModel.h"

@implementation MCAvatorInviteModel

-(instancetype)initWithResponseDic:(NSDictionary*)responseDic
{
    self = [super init];
    if (self) {
        self.result =[[responseDic objectForKey:@"result"] integerValue];
        self.url =[responseDic objectForKey:@"url"];
        self.email =[responseDic objectForKey:@"email"];
        self.checksum =[responseDic objectForKey:@"checksum"]?:nil;
        NSString *name =[responseDic objectForKey:@"name"];
        if (name.length<1) {
            NSArray *array =[self.email componentsSeparatedByString:@"@"];
            name =array[0];
        }
        self.name = name;
        
        self.c1 =[responseDic objectForKey:@"c1"]?[[responseDic objectForKey:@"c1"] integerValue]:NSNotFound;
        self.c2 =[responseDic objectForKey:@"c2"]?[[responseDic objectForKey:@"c2"] integerValue]:NSNotFound;
        self.c3 =[responseDic objectForKey:@"c3"]?[[responseDic objectForKey:@"c3"] integerValue]:NSNotFound;
        self.c4 =[responseDic objectForKey:@"c4"]?[[responseDic objectForKey:@"c4"] integerValue]:NSNotFound;
        self.invitecode =[responseDic objectForKey:@"invitecode"]?[[responseDic objectForKey:@"invitecode"] integerValue]:NSNotFound;
    }
    return self;
}

@end
