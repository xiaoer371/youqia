//
//  MCRUKM.m
//  NPushMail
//
//  Created by admin on 5/18/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCRUKM.h"
#import <CommonCrypto/CommonCryptor.h>

static NSString* const kAESKey = @"+Y>)g>37{Eku}3n)}j/_`K`4oh_c&Zwe";

@implementation MCRUKM

+ (NSString *)makeIt:(NSString *)string
{
    if (!string) {
        return nil;
    }
    
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *secureData = [self AES256EncryptData:stringData withKey:kAESKey];
    return [secureData base64EncodedStringWithOptions:0];
}

+ (NSString *)unmakeIt:(NSString *)string
{
    if (!string) {
        return nil;
    }
    
    NSData *secureData = [[NSData alloc] initWithBase64EncodedString:string options:0];
    NSData *stringData = [self AES256DecryptData:secureData withKey:kAESKey];
    return [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
}


+ (NSData *)AES256EncryptData:(NSData *)data withKey:(NSString *)key {
    
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

+ (NSData *)AES256DecryptData:(NSData *)data withKey:(NSString *)key {
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;
}

@end
