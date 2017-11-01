//
//  MCFeiBaUnit.h
//  NPushMail
//
//  Created by swhl on 16/12/28.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^successBlock)(NSString *bodyPars);

@interface MCFeiBaUnit : NSObject

@property (nonatomic,copy) successBlock successBlock;

+ (instancetype)shared;

- (void )feibaBodyParsWithsuccessBlock:(successBlock )successBlock;


@end
