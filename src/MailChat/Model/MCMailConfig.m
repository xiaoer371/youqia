//
//  MCMailConfig.m
//  NPushMail
//
//  Created by admin on 1/4/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCMailConfig.h"

@implementation MCMailConfigItem

- (instancetype)initWithDictionary:(id)dict
{
    if (self = [super init]) {
        _hostName = dict[@"host"];
        _ssl = [dict[@"ssl"] integerValue];
        _port = [dict[@"port"] integerValue];
    }
    
    return self;
}

- (id)toDictionary
{
    return @{@"host" : self.hostName,
             @"port" : @(self.port),
             @"ssl" : @(self.ssl)
             };
}

- (id)copy
{
    MCMailConfigItem *copyItem = [MCMailConfigItem new];
    copyItem.hostName = [self.hostName copy];
    copyItem.ssl = self.ssl;
    copyItem.port = self.port;
    
    return copyItem;
}

@end

@implementation MCMailConfig

- (instancetype)initWithDictionary:(id)dict
{
    if (self = [super init]) {
        _imap = [[MCMailConfigItem alloc] initWithDictionary:dict[@"imap"]];
        if (_imap.port == 0) {
            _imap.port = _imap.ssl == MCMailEncryptSSL ? 993 : 143;
        }
        _smtp = [[MCMailConfigItem alloc] initWithDictionary:dict[@"smtp"]];
        if (_smtp.port == 0) {
            _smtp.port = _smtp.ssl == MCMailEncryptSSL ? 465 : 25;
        }
        _mailTypeKey = [dict[@"type"] copy];
        _mailType = [self mailTypeWithTypeKey:_mailTypeKey];
    }
    return self;
}

- (BOOL)is35Mail
{
    return self.mailType == MCMailType35_30 || self.mailType == MCMailType35_20;
}

- (id)toDictionary
{
    if (self.imap) {
        
        return @{@"imap" : [self.imap toDictionary],
                 @"smtp" : [self.smtp toDictionary],
                 @"type" : self.mailTypeKey
                 };
    }
    else{
        return nil;
    }
}

- (MCMailType)mailTypeWithTypeKey:(NSString *)typeKey
{
    MCMailType type = MCMailTypeOthers;
    
    static NSDictionary *mailTypeMappings = nil;
    if (!mailTypeMappings) {
        mailTypeMappings = @{@"cn4e" : @(MCMailType35_30),
                             @"35" : @(MCMailType35_30),
                             @"qq" : @(MCMailTypeQQ),
                             @"163" : @(MCMailType163),
                             @"dns" : @(MCMailTypeDNS),
                             @"ali" : @(MCMailTypeAli),
                             @"sina" : @(MCMailTypeSina),
                             @"263" : @(MCMailType263),
                             @"chinaemail" : @(MCMailTypeChinaEmail),
                             @"google" : @(MCMailTypeGmail),
                             @"gmail" : @(MCMailTypeGmail),
                             @"21cn" : @(MCMailType21CN),
                             @"coremail" : @(MCMailTypeCoreMail),
                             @"mailru" : @(MCMailTypeMailRu),
                             @"sohu" : @(MCMailTypeSohu),
                             @"zmail" : @(MCMailTypeZmail),
                             @"netvigator" : @(MCMailTypeNetvigator),
                             @"chinacmail" : @(MCMailTypeChinacMail)
                             };
    }
    
    id typeObj = [mailTypeMappings objectForKey:typeKey];
    if (typeObj) {
        type = [typeObj integerValue];
    }
    
    return type;
}

- (id)copy
{
    MCMailConfig *copyConfig = [[MCMailConfig alloc] init];
    copyConfig.imap = [self.imap copy];
    copyConfig.smtp = [self.smtp copy];
    copyConfig.mailType = self.mailType;
    copyConfig.mailTypeKey = [self.mailTypeKey copy];
    
    return copyConfig;
}

@end
