//
//  RSADataSigner.h
//  feiba
//
//  Created by fangj on 16-4-11.
//  Copyright 2016 fangj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSADataSigner : NSObject 

- (id)initWithPrivateKey:(NSString *)privateKey;

- (NSString *)signString:(NSString *)string;

@end
