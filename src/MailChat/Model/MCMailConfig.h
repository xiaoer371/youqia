//
//  MCMailConfig.h
//  NPushMail
//
//  Created by admin on 1/4/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    MCMailEncryptNone = 0,
    MCMailEncryptTLS = 1,
    MCMailEncryptSSL = 2
} MCMailEncryptType;

typedef enum : NSUInteger {
    MCMailTypeUnknown = 0,
    MCMailTypeOthers = 1,
    MCMailType35_20 = 2,
    MCMailType35_30 = 3,
    MCMailType163 = 4,
    MCMailTypeQQ = 5,
    MCMailTypeDNS = 6,
    MCMailTypeAli = 7,
    MCMailTypeSina = 8,
    MCMailType263 = 9,
    MCMailTypeChinaEmail = 10,
    MCMailTypeGmail = 11,
    MCMailType21CN = 12,
    MCMailTypeCoreMail = 13,
    MCMailTypeMailRu = 14,
    MCMailTypeSohu = 15,
    MCMailTypeZmail = 16,
    MCMailTypeNetvigator = 17,
    MCMailTypeChinacMail = 18,
    MCMailTypeOutlook = 19,
    MCMailTypeOALogin = 20,
} MCMailType;

@interface MCMailConfigItem : NSObject

@property (nonatomic,copy) NSString *hostName;
@property (nonatomic,assign) NSInteger port;
@property (nonatomic,assign) MCMailEncryptType ssl;

- (instancetype)initWithDictionary:(id)dict;
/**
 *  返回JSON对象
 *
 */
- (id)toDictionary;

@end

@interface MCMailConfig : NSObject

@property (nonatomic,strong) MCMailConfigItem *imap;
@property (nonatomic,strong) MCMailConfigItem *smtp;
@property (nonatomic,assign,readonly) BOOL is35Mail;
@property (nonatomic,assign) MCMailType mailType;
@property (nonatomic,strong) NSString *mailTypeKey;

- (instancetype)initWithDictionary:(id)dict;

/**
 *  返回JSON对象
 *
 *  @return JSON对象
 */
- (id)toDictionary;

@end
