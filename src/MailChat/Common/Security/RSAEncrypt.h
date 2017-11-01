//
//  RSAEncrypt.h
//  NPushMail
//
//  Created by wuwenyu on 15/5/11.
//  Copyright (c) 2015年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

//RSA类型
typedef NS_ENUM(NSInteger, RSACerType) {
    RSACerOA = 0,
    RSACerMailChat = 1,
};

@interface RSAEncrypt : NSObject

+ (NSData* )rsaEncryptString:(NSString*)str withType:(RSACerType)rsaCerType;


// 从公钥证书文件中获取到公钥的SecKeyRef指针
//+ (SecKeyRef)PublicKeyWithString:(NSString *)key;
//使用公钥 key 加密字符串，并使用指定的SecPadding
//+ (NSString *) RSAEncrypt:(NSString*)original publicKey:(NSString *)key secPadding:(SecPadding)padding;
//使用公钥 key 加密字符串,不使用SecPadding
//+ (NSString *) RSAEncrypt:(NSString*)original publicKey:(NSString *)key;

@end
