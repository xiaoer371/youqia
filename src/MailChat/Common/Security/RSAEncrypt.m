//
//  RSAEncrypt.m
//  NPushMail
//
//  Created by wuwenyu on 15/5/11.
//  Copyright (c) 2015年 sprite. All rights reserved.
//

#import "RSAEncrypt.h"
#import "GTMBase64.h"

@implementation RSAEncrypt

//static SecKeyRef _public_key=nil;
// 从公钥证书文件中获取到公钥的SecKeyRef指针
+ (SecKeyRef) getPublicKeyWithRsaCerType:(RSACerType)cerType {
    
    static SecKeyRef oaKeyRef = nil;
    static SecKeyRef mailchatKeyRef = nil;
    
    NSString* filePath = @"";
    switch (cerType) {
        case RSACerOA:
            if (!oaKeyRef) {
                filePath = [[NSBundle mainBundle] pathForResource:@"oa_public_key" ofType:@"der"];
                oaKeyRef = [self pubKeyWithCerFilePath:filePath];
            }
            return oaKeyRef;
            break;
        case RSACerMailChat:
            if (!mailchatKeyRef) {
                filePath = [[NSBundle mainBundle] pathForResource:@"mailchat_public_key" ofType:@"der"];
                mailchatKeyRef = [self pubKeyWithCerFilePath:filePath];
            }
            return mailchatKeyRef;
        default:
            break;
    }
    
    return nil;
    
}


+ (SecKeyRef) pubKeyWithCerFilePath:(NSString *)filePath {
    SecKeyRef _public_key = nil;
    NSData *certificateData = [NSData dataWithContentsOfFile:filePath];
    SecCertificateRef myCertificate =  SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)certificateData);
    if (myCertificate == nil) {
        DDLogError(@"无法读取公钥内容");
        return nil;
    }
    SecPolicyRef myPolicy = SecPolicyCreateBasicX509();
    SecTrustRef myTrust;
    OSStatus status = SecTrustCreateWithCertificates(myCertificate,myPolicy,&myTrust);
    SecTrustResultType trustResult;
    if (status == noErr) {
        status = SecTrustEvaluate(myTrust, &trustResult);
    }else{
        return nil;
    }
    _public_key = SecTrustCopyPublicKey(myTrust);
    CFRelease(myCertificate);
    CFRelease(myPolicy);
    CFRelease(myTrust);
    return _public_key;
}


+ (NSData* )rsaEncryptString:(NSString*)str withType:(RSACerType)rsaCerType {
    NSData* encryptData = [str dataUsingEncoding:NSUTF8StringEncoding];
    SecKeyRef key = [self getPublicKeyWithRsaCerType:rsaCerType];
    if (key == nil) {
        return nil;
    }
    size_t cipherBufferSize = SecKeyGetBlockSize(key);
    uint8_t *cipherBuffer = malloc(cipherBufferSize * sizeof(uint8_t));
    NSData *stringBytes = encryptData;
    size_t blockSize = cipherBufferSize - 11;
    size_t blockCount = (size_t)ceil([stringBytes length] / (double)blockSize);
    NSMutableData *encryptedData = [[NSMutableData alloc] init];
    for (int i=0; i<blockCount; i++) {
        int bufferSize = (int)MIN(blockSize,[stringBytes length] - i * blockSize);
        NSData *buffer = [stringBytes subdataWithRange:NSMakeRange(i * blockSize, bufferSize)];
        OSStatus status = SecKeyEncrypt(key, kSecPaddingPKCS1, (const uint8_t *)[buffer bytes],
                                        [buffer length], cipherBuffer, &cipherBufferSize);
        if (status == noErr){
            NSData *encryptedBytes = [[NSData alloc] initWithBytes:(const void *)cipherBuffer length:cipherBufferSize];
            [encryptedData appendData:encryptedBytes];
        }else{
            if (cipherBuffer) free(cipherBuffer);
            return nil;
        }
    }
    if (cipherBuffer) free(cipherBuffer);
    return encryptedData;
}



@end
