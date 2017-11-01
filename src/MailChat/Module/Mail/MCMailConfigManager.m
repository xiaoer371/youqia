//
//  MCMailConfigManager.m
//  NPushMail
//
//  Created by admin on 1/7/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCMailConfigManager.h"
#import "NSString+Extension.h"
#import "MCServerAPI+Account.h"

static NSString* const kMCAccountManagerMailProviderPrefix = @"com.mailchat.mailprovider.";
static NSString* const kMCMailCofigManagerSetOriginal = @"kMCMailCofigManagerSetOriginal";

@implementation MCMailConfigManager

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (instancetype)shared
{
    static id instance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[MCMailConfigManager alloc] init];
    });
    
    return instance;
}

- (void)findMailConfigWithEmail:(NSString *)email
                    forceUpdate:(BOOL)forceUpdate
                        success:(SuccessBlock)success
                        failure:(FailureBlock)failure
{
    [ServerAPI getMailConfigWithEmail:email forceUpdate:forceUpdate success:^(id response) {
        if (success) {
            success(response);
        }
    } failure:^(NSError *error) {
        DDLogError(@"[findMailConfigWithEmail] error = %@",error);
        if (failure) {
            failure(error);
        }
    }];
}

- (void)saveMailConfig:(MCMailConfig *)config forMail:(NSString *)email success:(SuccessBlock)success failure:(FailureBlock)failure
{
    //保存到本地
    [self storeConfig:config forMail:email];
    //保存到服务器
    [ServerAPI updateMailConfig:config withEmail:email success:success failure:failure];
}

+ (MCMailConfig *)defaultConfigForMail:(NSString *)mail ssl:(BOOL)ssl
{
    NSString *domain = [mail mailDomain];
    
    MCMailConfig *config = [MCMailConfig new];
    config.imap = [[MCMailConfigItem alloc] init];
    config.imap.hostName = [NSString stringWithFormat:@"imap.%@",domain];
    config.imap.port = ssl?993:143;
    config.imap.ssl = ssl?MCMailEncryptSSL:MCMailEncryptNone;
    
    config.smtp = [[MCMailConfigItem alloc] init];
    config.smtp.hostName = [NSString stringWithFormat:@"smtp.%@",domain];
    config.smtp.port = ssl?465:25;
    config.smtp.ssl = ssl?MCMailEncryptSSL:MCMailEncryptNone;
    //默认取后缀作为邮箱类型
    config.mailTypeKey = domain;
    return config;
}

#pragma mark - Private

- (MCMailConfig *)getConfigForMail:(NSString *)email
{
    NSString *domain = [email mailDomain];
    NSString *key = [NSString stringWithFormat:@"%@%@",kMCAccountManagerMailProviderPrefix, domain];
    NSDictionary *configObj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if (!configObj) {
        return nil;
    }
    
    MCMailConfig *config = [[MCMailConfig alloc] initWithDictionary:configObj];
    return config;
}

- (void)storeConfig:(MCMailConfig *)config forMail:(NSString *)mail
{
    NSString *domain = [mail mailDomain];
    NSString *key = [NSString stringWithFormat:@"%@%@",kMCAccountManagerMailProviderPrefix, domain];
    NSDictionary *configObj = [config toDictionary];
    [[NSUserDefaults standardUserDefaults] setObject:configObj forKey:key];
}


//private
+ (NSDictionary *)getOldMailConfigs
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [paths objectAtIndex:0];
    NSString* filePath = [documentPath stringByAppendingPathComponent:@"mailHost.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return nil;
    }
    
    NSDictionary* dic = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    return [self convertOldDictionaryToConfigs:dic];
}

+ (NSDictionary*)convertOldDictionaryToConfigs:(NSDictionary *)oldDictionary {
    
    NSArray *domains = [oldDictionary allKeys];
    NSArray *configArray = [oldDictionary allValues];
    
    NSMutableDictionary *oldMailConfigDic = [NSMutableDictionary new];
    for (NSString*domain in domains) {
        NSInteger index = [domains indexOfObject:domain];
        NSDictionary *cofigDic = configArray[index];
        NSDictionary *imapDic = [cofigDic valueForKey:@"imap"];
        NSDictionary *smtpDic = [cofigDic valueForKey:@"smtp"];
        MCMailConfig *config = [MCMailConfig new];
        config.imap = [[MCMailConfigItem alloc]init];
        config.imap.hostName = [imapDic valueForKey:@"host"];
        BOOL ssl = [[imapDic valueForKey:@"connectionSSL"] boolValue];
        config.imap.port = ssl?[[imapDic valueForKey:@"SSLPort"] integerValue]:[[imapDic valueForKey:@"port"] integerValue];
        config.imap.ssl  = ssl?MCMailEncryptSSL:MCMailEncryptNone;
        
        config.smtp = [[MCMailConfigItem alloc]init];
        config.smtp.hostName = [smtpDic valueForKey:@"host"];
        BOOL smtpSsl = [[smtpDic valueForKey:@"connectionSSL"] boolValue];
        config.smtp.port = smtpSsl?[[smtpDic valueForKey:@"SSLPort"] integerValue]:[[smtpDic valueForKey:@"port"] integerValue];
        config.smtp.ssl  = smtpSsl?MCMailEncryptSSL:MCMailEncryptNone;
        config.mailTypeKey = domain;
        
        [oldMailConfigDic setObject:config forKey:domain];
    }
    return oldMailConfigDic;
}

//获取内置配置
+ (NSDictionary*)getOriginalImapConfig {
    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"mailServerSet" ofType:@"plist"];
    NSDictionary *dic = [[NSDictionary alloc]initWithContentsOfFile:filePath];
    return dic;
}
@end
