//
//  MCAccountConfig.m
//  NPushMail
//
//  Created by wuwenyu on 16/3/23.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCAccountConfig.h"
#import "MCAccountConfigModel.h"
#import "MCAccountConfigTable.h"
#import "MCAppSetting.h"
#import "MCDatabaseHelper.h"
#import "MCAppSetting.h"

static NSString* const kMCAccountConfigCompany = @"enterpriseCompany";
static NSString* const kMCAccountEISSyncTimestamp = @"eisSyncTimeStamp";
static NSString* const kMCAccountConfigIsFirstSynOaUser = @"isFirstSyncOAUser";
static NSString* const kMCIsOaUserFlag = @"isOAUser";
static NSString* const kMCOaUserIs35MailFlag = @"oaUserIs35Mail";
static NSString* const kMCAccountConfigIsWorkspaceUser = @"isWorkspaceUser";
static NSString* const kMCAccountConfigOaProxyServer = @"OAProxyServer";
static NSString* const kMCAccountConfigOaDomin = @"OADomain";
static NSString* const kMCAccountConfigOaUserName = @"OAUserName";
static NSString* const kMCAccountConfigOaPassword = @"OAPassword";
static NSString* const kMCAccountConfigOaUserType = @"OAUserType";
static NSString* const kMCAccountConfigEmailLoginType = @"emailLoginType";
static NSString* const kMCAccountConfigOaAccesstoken = @"OAAccesstoken";
static NSString* const kMCAccountConfigOaAccesstokenCreatetime = @"OAAccesstokenCreatetime";
static NSString* const kMCAccountConfigOaAccesstokenExpireinTime = @"OAAccesstokenExpireinTime";
static NSString* const kMCAccountConfigEisAccesstoken = @"EISAccesstoken";
static NSString* const kMCAccountConfigEisAccesstokenCreatetime = @"EISAccesstokenCreatetime";
static NSString* const kMCAccountConfigEisAccesstokenExpireinTime = @"EISAccesstokenExpireinTime";
static NSString* const kMCAccountConfigEisRouteIpAddress = @"EISRouteIpAddress";
static NSString* const kMCAccountConfigIsBusinessContactDisabled = @"disableBusinessContact";
static NSString* const kMCAccountConfigIsSentMailAnalysised = @"isSentMailAnalysised";
static NSString* const kMCAccountConfigMsgPushFlagKey = @"msgPushFlagKey";
static NSString* const kMCAccountConfigMailPushFlagKey = @"mailPushFlagKey";
static NSString* const kMCAccountConfigOAPushFlagKey = @"OAPushFlagKey";
static NSString* const kMCAccountConfigPushDetailFlagKey = @"pushDetailFlagKey";

static NSString* const kMCAccountConfigCcToSelfKey = @"ccSelfKey";
static NSString* const kMCAccountConfigSentErrorKey = @"sentErrorKey";

@implementation MCAccountConfig {
    MCAccountConfigTable *_db;
    NSMutableDictionary *_configDict;
    NSTimeInterval _eisSyncTimestamp;
    NSString * _company;
    NSString *_oAProxyServer;
    NSString *_oaDomin;
    NSString *_oaUserName;
    NSString *_oaPassword;
    NSString *_oaAccesstoken;
    NSString *_oaAccesstokenCreatetime;
    NSInteger _oaAccesstokenExpireinTime;
    NSString *_eisAccesstoken;
    NSString *_eisAccesstokenCreatetime;
    NSInteger _eisAccesstokenExpireinTime;
    NSString *_eisRouteIpAddress;
    BOOL _isOAUser;
    BOOL _oaUserIs35Mail;
    BOOL _isFirstSyncOAUser;
    BOOL _hasWorkspace;
    BOOL _isBusinessContactDisabled;
    int _oaUserType;
    int _emailLoginType;
    BOOL _msgPushFlag;
    BOOL _mailPushFlag;
    BOOL _oaPushFlag;
    BOOL _pushDetailFlag;
    
    BOOL _ccForYourself;
    BOOL _sentErrorNote;
}

- (instancetype)initWithAccount:(MCAccount *)account
{
    if (self = [super init]) {
        _account = account;
        MCAccountDatabase *accountDb = [[MCDatabaseHelper shared] databaseWithAccount:account];
        _db = [[MCAccountConfigTable alloc] initWithDbQueue:accountDb.dbQueue];
        _configDict = [NSMutableDictionary new];
        NSArray *models = [_db allModels];
        if (models.count > 0) {
            for (MCAccountConfigModel *config in models) {
                [_configDict setObject:config.configValue forKey:config.configKey];
            }
        }
    }
    
    return self;
}

- (void)reset
{
    _company = nil;
    [self commonInit];
}

- (NSString *)company {
    if (_company) {
        return _company;
    }
    return [_configDict objectForKey:kMCAccountConfigCompany];
}

- (NSTimeInterval)eisSyncTimestamp {

    if ([_configDict objectForKey:kMCAccountEISSyncTimestamp] == nil) {
       return 0;
    }
    
    return [[_configDict objectForKey:kMCAccountEISSyncTimestamp] doubleValue];
}

- (void)setEisSyncTimestamp:(NSTimeInterval)eisSyncTimestamp
{
    _eisSyncTimestamp = eisSyncTimestamp;
    [self setModelWithKey:kMCAccountEISSyncTimestamp value:[NSString stringWithFormat:@"%f",_eisSyncTimestamp]];
}


- (void)setCompany:(NSString *)company {
    _company = company;
    [self setModelWithKey:kMCAccountConfigCompany value:company];
}

- (BOOL)isOAUser
{
    id obj = _configDict[kMCIsOaUserFlag];
    if (obj) {
        return [obj boolValue];
    }
    
    return NO;
}

- (void)setOaUserIs35Mail:(BOOL)oaUserIs35Mail {
    _oaUserIs35Mail = oaUserIs35Mail;
    [self setModelWithKey:kMCOaUserIs35MailFlag value:[NSString stringWithFormat:@"%d", oaUserIs35Mail]];
}

- (BOOL)oaUserIs35Mail {
    id obj = _configDict[kMCOaUserIs35MailFlag];
    if (obj) {
        return [obj boolValue];
    }
    //临时改为YES，等新的EIS判断接口弄好再调整
    return YES;
}

- (void)setIsOAUser:(BOOL)isOAUser
{
    _isOAUser = isOAUser;
    [self setModelWithKey:kMCIsOaUserFlag value:[NSString stringWithFormat:@"%d", isOAUser]];
}

- (BOOL)isFirstSyncOAUser
{
    id obj = _configDict[kMCAccountConfigIsFirstSynOaUser];
    if (obj) {
        return [obj boolValue];
    }
    
    return YES;
}

- (void)setIsFirstSyncOAUser:(BOOL)isFirstSyncOAUser
{
    _isFirstSyncOAUser = isFirstSyncOAUser;
    [self setModelWithKey:kMCAccountConfigIsFirstSynOaUser value:[NSString stringWithFormat:@"%d", isFirstSyncOAUser]];
}

- (void)setOAProxyServer:(NSString *)oAProxyServer {
    _oAProxyServer = oAProxyServer;
    [self setModelWithKey:kMCAccountConfigOaProxyServer value:oAProxyServer];
}

- (NSString *)oAProxyServer {
    if (_oAProxyServer) {
        return _oAProxyServer;
    }
    return [_configDict objectForKey:kMCAccountConfigOaProxyServer];
}

- (void)setOaDomin:(NSString *)oaDomin {
    _oaDomin = oaDomin;
    [self setModelWithKey:kMCAccountConfigOaDomin value:oaDomin];
}

- (NSString *)oaDomin {
    if (_oaDomin) {
        return _oaDomin;
    }
    return [_configDict objectForKey:kMCAccountConfigOaDomin];
}

- (void)setOaUserName:(NSString *)oaUserName {
    _oaUserName = oaUserName;
    [self setModelWithKey:kMCAccountConfigOaUserName value:oaUserName];
}

- (NSString *)oaUserName {
    if (_oaUserName) {
        return _oaUserName;
    }
    return [_configDict objectForKey:kMCAccountConfigOaUserName];
}

- (void)setOaPassword:(NSString *)oaPassword {
    if (oaPassword == nil) {
        [self deleteModelWithKey:kMCAccountConfigOaPassword];
        return;
    }
    _oaPassword = oaPassword;
    [self setModelWithKey:kMCAccountConfigOaPassword value:oaPassword];
}

- (NSString *)oaPassword {
    if (_oaPassword) {
        return _oaPassword;
    }
    return [_configDict objectForKey:kMCAccountConfigOaPassword];
}

- (void)setOaAccesstoken:(NSString *)oaAccesstoken {
    _oaAccesstoken = oaAccesstoken;
    if (!oaAccesstoken) {
        [self deleteModelWithKey:kMCAccountConfigOaAccesstoken];
        return;
    }
    [self setModelWithKey:kMCAccountConfigOaAccesstoken value:oaAccesstoken];
}

- (NSString *)oaAccesstoken {
    if (_oaAccesstoken) {
        return _oaAccesstoken;
    }
    return [_configDict objectForKey:kMCAccountConfigOaAccesstoken];
}

- (NSString *)oaAccesstokenCreatetime {
    if (_oaAccesstokenCreatetime) {
        return _oaAccesstokenCreatetime;
    }
    return [_configDict objectForKey:kMCAccountConfigOaAccesstokenCreatetime];
}

- (void)setOaAccesstokenCreatetime:(NSString *)oaAccesstokenCreatetime {
    _oaAccesstokenCreatetime = oaAccesstokenCreatetime;
    [self setModelWithKey:kMCAccountConfigOaAccesstokenCreatetime value:oaAccesstokenCreatetime];
}

- (NSInteger)oaAccesstokenExpireinTime {
    if (_oaAccesstokenExpireinTime == 0) {
        return 7200;
    }
    return [[_configDict objectForKey:kMCAccountConfigOaAccesstokenExpireinTime] integerValue];
}

- (void)setOaAccesstokenExpireinTime:(NSInteger)oaAccesstokenExpireinTime {
    _oaAccesstokenExpireinTime = oaAccesstokenExpireinTime;
    [self setModelWithKey:kMCAccountConfigOaAccesstokenExpireinTime value:[NSString stringWithFormat:@"%ld", (long)oaAccesstokenExpireinTime]];
}

- (void)setOaUserType:(int)oaUserType {
    _oaUserType = oaUserType;
    [self setModelWithKey:kMCAccountConfigOaUserType value:[NSString stringWithFormat:@"%d", oaUserType]];
}

- (int)oaUserType {
    if (_oaUserType) {
        return _oaUserType;
    }
    return [[_configDict objectForKey:kMCAccountConfigOaUserType] intValue];
}

- (int)emailLoginType {
    if (![_configDict objectForKey:kMCAccountConfigEmailLoginType]) {
        return 0;
    }
    return [[_configDict objectForKey:kMCAccountConfigEmailLoginType] intValue];
}

- (void)setEmailLoginType:(int)emailLoginType {
    _emailLoginType = emailLoginType;
    [self setModelWithKey:kMCAccountConfigEmailLoginType value:[NSString stringWithFormat:@"%d", emailLoginType]];
}

- (BOOL)hasWorkspace
{
    id obj = _configDict[kMCAccountConfigIsWorkspaceUser];
    if (obj) {
        return [obj boolValue];
    }
    
    return NO;
}

- (void)setHasWorkspace:(BOOL)hasWorkspace
{
    _hasWorkspace = hasWorkspace;
    [self setModelWithKey:kMCAccountConfigIsWorkspaceUser value:[NSString stringWithFormat:@"%d", hasWorkspace]];
}

- (BOOL)isBusinessContactDisabled
{
    id obj = _configDict[kMCAccountConfigIsBusinessContactDisabled];
    if (obj) {
        return [obj boolValue];
    }
    
    return NO;
}

- (void)setIsBusinessContactDisabled:(BOOL)isBusinessContactDisabled
{
    _isBusinessContactDisabled = isBusinessContactDisabled;
    [self setModelWithKey:kMCAccountConfigIsBusinessContactDisabled value:[NSString stringWithFormat:@"%d", isBusinessContactDisabled]];
}

- (BOOL)isSentMailAnalysised
{
    id obj = _configDict[kMCAccountConfigIsSentMailAnalysised];
    if (obj) {
        return [obj boolValue];
    }
    
    return NO;
}

- (void)setIsSentMailAnalysised:(BOOL)isSentMailAnalysised
{
    [self setModelWithKey:kMCAccountConfigIsSentMailAnalysised value:@(isSentMailAnalysised)];
}


- (id)setModelWithKey:(NSString *)key value:(id)value {
    MCAccountConfigModel *model = [MCAccountConfigModel new];
    model.configKey = key;
    model.configValue = value;
    [[MCAccountConfigTable new] insertModel:model];
    [_configDict setObject:value forKey:key];
    return model.configValue;
}

- (id)valueWihtKey:(NSString *)key {
    MCAccountConfigModel *model = [[MCAccountConfigTable new] getModelWithKey:key];
    return model.configValue;
}

- (void)deleteModelWithKey:(NSString *)key {
    [_configDict removeObjectForKey:key];
    [[MCAccountConfigTable new] delValueWithKey:key];
}

#pragma mark - Private

- (void)commonInit
{
    _db = [MCAccountConfigTable new];
    _configDict = [NSMutableDictionary new];
    NSArray *models = [_db allModels];
    if (models.count > 0) {
        for (MCAccountConfigModel *config in models) {
            [_configDict setObject:config.configValue forKey:config.configKey];
        }
    }
}

- (void)resetOaStatus {
    
    self.isOAUser = NO;
    self.isFirstSyncOAUser = YES;
    
    if ([_configDict objectForKey:kMCAccountConfigOaDomin]) {
        [_configDict removeObjectForKey:kMCAccountConfigOaDomin];
    }
    if ([_configDict objectForKey:kMCAccountConfigOaUserName]) {
        [_configDict removeObjectForKey:kMCAccountConfigOaUserName];
    }
    if ([_configDict objectForKey:kMCAccountConfigOaPassword]) {
        [_configDict removeObjectForKey:kMCAccountConfigOaPassword];
    }
    if ([_configDict objectForKey:kMCAccountConfigOaUserType]) {
        [_configDict removeObjectForKey:kMCAccountConfigOaUserType];
    }
}

#pragma mark - EIS 
- (void)setEisAccessToken:(NSString *)eisAccessToken {
    _eisAccesstoken = eisAccessToken;
    if (!eisAccessToken) {
        [self deleteModelWithKey:kMCAccountConfigEisAccesstoken];
        return;
    }
    [self setModelWithKey:kMCAccountConfigEisAccesstoken value:eisAccessToken];
}

- (NSString *)eisAccessToken {
    if (_eisAccesstoken) {
        return _eisAccesstoken;
    }
    return [_configDict objectForKey:kMCAccountConfigEisAccesstoken];
}

- (void)setEisAccesstokenCreatetime:(NSString *)eisAccesstokenCreatetime {
    _eisAccesstokenCreatetime = eisAccesstokenCreatetime;
    [self setModelWithKey:kMCAccountConfigEisAccesstokenCreatetime value:eisAccesstokenCreatetime];
}

- (NSString *)eisAccesstokenCreatetime {
    if (_eisAccesstokenCreatetime) {
        return _eisAccesstokenCreatetime;
    }
    return [_configDict objectForKey:kMCAccountConfigEisAccesstokenCreatetime];
}

- (void)setEisAccesstokenExpireinTime:(NSInteger )eisAccesstokenExpireinTime {
    _eisAccesstokenExpireinTime = eisAccesstokenExpireinTime;
    [self setModelWithKey:kMCAccountConfigEisAccesstokenExpireinTime value:[NSString stringWithFormat:@"%ld", (long)eisAccesstokenExpireinTime]];
}

- (NSInteger )eisAccesstokenExpireinTime {
    if (_eisAccesstokenExpireinTime == 0) {
        return 7200;
    }
    return [[_configDict objectForKey:kMCAccountConfigEisAccesstokenExpireinTime] integerValue];
}

- (void)setEisRouteIpAddress:(NSString *)eisRouteIpAddress {
    _eisRouteIpAddress = eisRouteIpAddress;
    if (eisRouteIpAddress) {
        [self setModelWithKey:kMCAccountConfigEisRouteIpAddress value:eisRouteIpAddress];
    }
}

- (NSString *)eisRouteIpAddress {
    if (_eisRouteIpAddress) {
        return _eisRouteIpAddress;
    }
    return [_configDict objectForKey:kMCAccountConfigEisRouteIpAddress];
}

#pragma mark - Push
- (BOOL)msgPushFlag {
    id obj = _configDict[kMCAccountConfigMsgPushFlagKey];
    if (obj) {
        return [obj boolValue];
    }
    return YES;
}

- (void)setMsgPushFlag:(BOOL)msgPushFlag {
    _msgPushFlag = msgPushFlag;
    [self setModelWithKey:kMCAccountConfigMsgPushFlagKey value:@(msgPushFlag)];
}

- (BOOL)mailPushFlag {
    id obj = _configDict[kMCAccountConfigMailPushFlagKey];
    if (obj) {
        return [obj boolValue];
    }
    return YES;
}

- (void)setMailPushFlag:(BOOL)mailPushFlag {
    _mailPushFlag = mailPushFlag;
    [self setModelWithKey:kMCAccountConfigMailPushFlagKey value:@(mailPushFlag)];
}

- (BOOL)oaPushFlag {
    id obj = _configDict[kMCAccountConfigOAPushFlagKey];
    if (obj) {
        return [obj boolValue];
    }
    return YES;
}

- (void)setOaPushFlag:(BOOL)oaPushFlag {
    _oaPushFlag = oaPushFlag;
    [self setModelWithKey:kMCAccountConfigOAPushFlagKey value:@(oaPushFlag)];
}

- (BOOL)pushDetailFlag {
    id obj = _configDict[kMCAccountConfigPushDetailFlagKey];
    if (obj) {
        return [obj boolValue];
    }
    return YES;
}

- (void)setPushDetailFlag:(BOOL)pushDetailFlag {
    _pushDetailFlag = pushDetailFlag;
    [self setModelWithKey:kMCAccountConfigPushDetailFlagKey value:@(pushDetailFlag)];
}
#pragma mark mail 

- (BOOL)ccForYourself {
    id obj = _configDict[kMCAccountConfigCcToSelfKey];
    if (!obj) {
      BOOL cc =  [AppSettings getCcForYourSelfKey:self.account.email];
      [self setModelWithKey:kMCAccountConfigCcToSelfKey value:@(cc)];
      return  cc;
    }
    return [obj boolValue];
}

- (void)setCcForYourself:(BOOL)ccForYourself {
    _ccForYourself = ccForYourself;
    [self setModelWithKey:kMCAccountConfigCcToSelfKey value:@(ccForYourself)];
}

- (BOOL)sentErrorNote {
    id obj = _configDict[kMCAccountConfigSentErrorKey];
    if (obj) {
        return [obj boolValue];
    }
    return NO;
}

- (void)setSentErrorNote:(BOOL)sentErrorNote {
    _sentErrorNote = sentErrorNote;
    [self setModelWithKey:kMCAccountConfigSentErrorKey value:@(sentErrorNote)];
}

@end
