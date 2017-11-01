//
//  MCAppSetting.m
//  NPushMail
//
//  Created by admin on 1/27/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCAppSetting.h"
#import "MCAppConfigTable.h"
#import "MCUDID.h"
#import "NSString+JSON.h"
#import "NSDate+Category.h"
//默认时间（小时）
static NSInteger const kMDefaultDateForShowFeedbackNote = 48;
static NSInteger const kMDefaultFeedbackIndex = 1;

static NSInteger const kMDefaultNewSettingUpdate = 1;//每次递增1；
//测试服务器
static NSString* const kMailChatMQTTTestHost = @"bbs.mailchat.cn";
static NSUInteger const kMailChatMQTTTestPort = 8088;
static NSString* const kMailChatHttpTestBaseUrl = @"https://debug.mailchat.cn/";

//正式服务器
static NSString*  const kMailChatMQTTDefaultHost = @"im.mailchat.cn";
static NSUInteger const kMailChatMQTTDefaultPort = 80;
static NSString*  const kMailChatHttpBaseUrl = @"https://a.mailchat.cn/";

//内网测试服务器
//static NSString* const kMailChatMQTTDefaultHost = @"test1.mailchat.cn";
//static NSUInteger const kMailChatMQTTDefaultPort = 8080;
//static NSString* const kMailChatHttpBaseUrl = @"https://test1.mailchat.cn/";

static NSString* const kMCAppSettingOldConfigPlist = @"preference.plist";


static NSString* const kMCAppSettingClientId = @"client-id";
static NSString* const kMCAppSettingAPNSToken = @"apns-token";
static NSString* const kMCAppSettingMQTTHostKey = @"mqtt-host";
static NSString* const kMCAppSettingMQTTPortKey = @"mqtt-port";
static NSString* const kMCAppSettingUserKey = @"api-user";
static NSString* const kMCAppSettingLastAccountIdKey = @"last-account-id";
static NSString* const kMCAppSettingLastUpdateVersionKey = @"lastUpdateVersion";
static NSString* const kMCAppSettingLastSetVersionKey = @"lastSetVersion";
static NSString* const kMCAppSettingJsPathKey = @"jsPath";
static NSString* const kMCAppSettingJsUpdateVersionKey = @"jsUpdateVersion";
static NSString* const kMCAppSettingApiUrlKey = @"api-base-url";
static NSString* const kMCGesturePwdFlagKey = @"gesturePwdFlagKey";
static NSString* const kMCTouchIdFlagKey = @"touchIdFlagKey";
static NSString* const kMCIsShowWorkspaceKey = @"isShowWorkspaceKey";
static NSString* const kMCIsShowGuidesForMailListKey = @"isShowGuidesForMailListKey";
static NSString* const kMCIsShowGuidesForMailEditAgainKey = @"isShowGuidesForMailEditAgainKey";
static NSString* const kMCIsPassGesturePwdFlagKey = @"isPassGesturePwdFlagKey";
static NSString* const kMCMsgPushFlagKey = @"msgPushFlagKey";
static NSString* const kMCMailPushFlagKey = @"mailPushFlagKey";
static NSString* const kMCOAPushFlagKey = @"OAPushFlagKey";
static NSString* const kMCPushDetailFlagKey = @"pushDetailFlagKey";
static NSString* const kMCAllSignatureSetKey = @"allSignatureSetKey";
static NSString* const kMCLoadAvatarForMailListKey = @"loadAvatarForMailListKey";
static NSString* const kMCServerStateKey = @"serverStateKey";
static NSString* const kMCLastTabbarSelectIndexKey = @"lastTabbarSelectindexKey";
static NSString* const kMCDatabaseVersionKey = @"dbVersionKey";
static NSString* const kMCFirstLoadVipMails = @"firstLoadVipMails";
static NSString* const kMCGuideViewLoadingKey = @"guideViewLoadingKey";
static NSString* const kMCLoadImportantMailsKey = @"loadImportantMailsKey";
static NSString* const kMCSmartBoxSelectEnableKey = @"smartBoxSelectEnableKey";
static NSString* const kMCDebugAccountWeight = @"debugAccountWeight";
static NSString* const kMCUserFeedbackVipMailDateKey = @"userFeedbackVipMailDateKey";
static NSString* const kMCUserFeedbackIndexKey = @"userFeedbackIndexKey";
static NSString* const kMCNewSettingUpdate = @"newSettingUpdate";
static NSString* const kMCQuestionnaireNoteKey = @"questionnaireNoteKey";
static NSString* const kMCMailAdjustKey = @"mailAdjustKey";
static NSString* const kMCMailFeibaRemind = @"mailChatFeibaRemind";
static NSString* const kMCAppSettingLaunchKey = @"api-launch";

@implementation MCAppSetting
{
    MCAppConfigTable *_db;
    NSMutableDictionary *_configDict;
    
    NSString *_lastUpdateVersion;
    NSString *_lastSetVersion;
    BOOL _isShowfeibaRemind;
    NSString *_jsPath;
    NSInteger _jsVersion;
    NSString *_apiBaseUrl;
    NSString *_apnsToken;
    NSString *_clientId;
    NSInteger _lastAccountId;
    NSInteger _apnsVersion;
    BOOL _gesturePasswordFlag;
    BOOL _touchIdFlag;
    BOOL _isPassGesturePasswordFlag;
    BOOL _msgPushFlag;
    BOOL _mailPushFlag;
    BOOL _oaPushFlag;
    BOOL _pushDetailFlag;
    BOOL _loadAvatarCellForMailList;
    BOOL _isTestServer;
    BOOL _showWeight;
    NSString * _mcMailAllSignature;
    MCUserInfo *_user;
    MCLaunchModel *_launchModel;
    NSUInteger _dbVersion;
    NSInteger _lastTabbarSelectIndex;
    BOOL _isFirstLoadVipMails;
    NSInteger _guideLoadIndex;
    BOOL _loadImportantMails;
    BOOL _smartBoxSelectEnable;
    BOOL _isNewSettingUpdate;
    
    BOOL _isQuestionnaireNote;
    NSString *_mailAdjust;
}

+ (instancetype)shared
{
    static id instance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [MCAppSetting new];
    });
    
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _db = [[MCAppConfigTable alloc] init];
        [self setup];
    }
    
    return self;
}

- (NSString *)clientId
{
    if (_clientId) {
        return _clientId;
    }
    
    _clientId = _configDict[kMCAppSettingClientId];
    if (!_clientId) {
        _clientId = [MCUDID newUUID];
        [self setConfigValue:_clientId forKey:kMCAppSettingClientId];
    }
    return _clientId;
}

- (NSString *)apnsToken
{
    if (_apnsToken) {
        return _apnsToken;
    }
    
    _apnsToken = [_configDict objectForKey:kMCAppSettingAPNSToken];
    return _apnsToken;
}

- (void)setApnsToken:(NSString *)apnsToken
{
    _apnsToken = apnsToken;
    [self setConfigValue:apnsToken forKey:kMCAppSettingAPNSToken];
}

-(BOOL)isShowfeibaRemind
{
    if (![_configDict objectForKey:kMCMailFeibaRemind]) {
        return NO;
    }
    return [[_configDict objectForKey:kMCMailFeibaRemind] boolValue];
}

- (void)setIsShowfeibaRemind:(BOOL)isShowfeibaRemind
{
    _isShowfeibaRemind = isShowfeibaRemind;
    [self setConfigValue:[NSString stringWithFormat:@"%d",isShowfeibaRemind] forKey:kMCMailFeibaRemind];

}

- (NSString *)mqttHost
{
    if (_mqttHost) {
        return _mqttHost;
    }
    
    _mqttHost = _configDict[kMCAppSettingMQTTHostKey];
    if (!_mqttHost) {
        _mqttHost = kMailChatMQTTDefaultHost;
//        _mqttHost = kMailChatMQTTTestHost;
        [self setConfigValue:_mqttHost forKey:kMCAppSettingMQTTHostKey];
    }
    
    return _mqttHost;
}


- (NSString *)lastUpdateVersion {
    if (_lastUpdateVersion) {
        return _lastUpdateVersion;
    }
    return _configDict[kMCAppSettingLastUpdateVersionKey];
}

- (void)setLastUpdateVersion:(NSString *)lastUpdateVersion {
    _lastUpdateVersion = lastUpdateVersion;
    [self setConfigValue:lastUpdateVersion forKey:kMCAppSettingLastUpdateVersionKey];
}

- (NSString *)lastSetVersion
{
    if (_lastSetVersion) {
        return _lastSetVersion;
    }
    return _configDict[kMCAppSettingLastSetVersionKey];
}

- (void)setLastSetVersion:(NSString *)lastSetVersion
{
    _lastSetVersion = lastSetVersion;
    [self setConfigValue:lastSetVersion forKey:kMCAppSettingLastSetVersionKey];
}

- (NSString *)jsPath {
    if (_jsPath) {
        return _jsPath;
    }
    return _configDict[kMCAppSettingJsPathKey];
}

- (void)setJsPath:(NSString *)jsPath {
    _jsPath = jsPath;
    [self setConfigValue:jsPath forKey:kMCAppSettingJsPathKey];
}

- (NSInteger)jsVersion {
    if ([_configDict objectForKey:kMCAppSettingJsUpdateVersionKey] == nil) {
        return 0;
    }
    return [[_configDict objectForKey:kMCAppSettingJsUpdateVersionKey] integerValue];
}

- (void)setJsVersion:(NSInteger)jsVersion {
    _jsVersion = jsVersion;
    [self setConfigValue:[NSString stringWithFormat:@"%ld", (long)jsVersion] forKey:kMCAppSettingJsUpdateVersionKey];
}

- (NSString *)apiBaseUrl
{
    if (_apiBaseUrl) {
        return _apiBaseUrl;
    }
    
    _apiBaseUrl = _configDict[kMCAppSettingApiUrlKey];
    if (!_apiBaseUrl) {
        _apiBaseUrl = kMailChatHttpBaseUrl;
//        _apiBaseUrl = kMailChatHttpTestBaseUrl;
        [self setConfigValue:_apiBaseUrl forKey:kMCAppSettingApiUrlKey];
    }
    
    return _apiBaseUrl;
}

- (NSUInteger)mqttPort
{
    if (_mqttPort > 0) {
        return _mqttPort;
    }
    id portObj = _configDict[kMCAppSettingMQTTPortKey];
    if (portObj) {
        _mqttPort = [portObj integerValue];
        return _mqttPort;
    }
    _mqttPort = kMailChatMQTTDefaultPort;
//    _mqttPort = kMailChatMQTTTestPort;
    [self setConfigValue:[NSString stringWithFormat:@"%ld",_mqttPort] forKey:kMCAppSettingMQTTPortKey];
    
    return _mqttPort;
}

- (MCUserInfo *)user
{
    if (!_user) {
        NSString *jsonStr = _configDict[kMCAppSettingUserKey];
        if (jsonStr) {
            NSDictionary *json = [jsonStr toJson];
            _user = [[MCUserInfo alloc] initWithJson:json];
        }
    }
    
    return _user;
}

- (void)setUser:(MCUserInfo *)user
{
    _user = user;
    
    NSString *jsonStr = nil;
    if (_user) {
        NSDictionary *json = [_user toJson];
        jsonStr = [NSString jsonStringWithObject:json];
    }
    
    [self setConfigValue:jsonStr forKey:kMCAppSettingUserKey];
}

- (MCLaunchModel *)launchModel{
    if (!_launchModel) {
        NSString *jsonStr = _configDict[kMCAppSettingLaunchKey];
        if (jsonStr) {
            NSDictionary *json = [jsonStr toJson];
            _launchModel = [[MCLaunchModel alloc] initWithDictionary:json];
        }
    }
    
    return _launchModel;
}

- (void)setLaunchModel:(MCLaunchModel *)launchModel
{
    _launchModel = launchModel;
    NSString *jsonStr = nil;
    if (_launchModel) {
        NSDictionary *json = [_launchModel toJson];
        jsonStr = [NSString jsonStringWithObject:json];
    }
    [self setConfigValue:jsonStr forKey:kMCAppSettingLaunchKey];
}


- (NSInteger)lastAccountId
{
    if (_lastAccountId != 0) {
        return _lastAccountId;
    }
    
    id obj = _configDict[kMCAppSettingLastAccountIdKey];
    if (obj) {
        _lastAccountId = [obj integerValue];
    }
    return _lastAccountId;
}

- (void)setLastAccountId:(NSInteger)lastAccountId
{
    _lastAccountId = lastAccountId;
    [self setConfigValue:[NSString stringWithFormat:@"%ld",(long)_lastAccountId] forKey:kMCAppSettingLastAccountIdKey];
}

- (NSUInteger)dbVersion
{
    if (_dbVersion != 0) {
        return _dbVersion;
    }
    
    id obj = _configDict[kMCDatabaseVersionKey];
    if (obj) {
        _dbVersion = [obj integerValue];
    }
    return _dbVersion;
}

- (void)setDbVersion:(NSUInteger)dbVersion
{
    _dbVersion = dbVersion;
    [self setConfigValue:[NSString stringWithFormat:@"%ld",(long)_dbVersion] forKey:kMCDatabaseVersionKey];
}

#pragma mark - 手势密码/指纹解锁

- (BOOL)touchIdFlag {
    if ([_configDict objectForKey:kMCTouchIdFlagKey] == nil) {
        return NO;
    }
    
    return [[_configDict objectForKey:kMCTouchIdFlagKey] boolValue];

}

- (void)setTouchIdFlag:(BOOL)touchIdFlag {
    _touchIdFlag = touchIdFlag;
    [self setConfigValue:[NSString stringWithFormat:@"%d", touchIdFlag] forKey:kMCTouchIdFlagKey];
}

- (BOOL)gesturePasswordFlag {
    if ([_configDict objectForKey:kMCGesturePwdFlagKey] == nil) {
        return NO;
    }
    
    return [[_configDict objectForKey:kMCGesturePwdFlagKey] boolValue];
}

- (void)setGesturePasswordFlag:(BOOL)gesturePasswordFlag {
    _gesturePasswordFlag = gesturePasswordFlag;
    [self setConfigValue:[NSString stringWithFormat:@"%d", gesturePasswordFlag] forKey:kMCGesturePwdFlagKey];
}

- (BOOL)isPassGesturePwd {
    if ([_configDict objectForKey:kMCIsPassGesturePwdFlagKey] == nil) {
        return YES;
    }
    
    return [[_configDict objectForKey:kMCIsPassGesturePwdFlagKey] boolValue];
}

- (void)setIsPassGesturePwd:(BOOL)isPassGesturePwd {
    _isPassGesturePasswordFlag = isPassGesturePwd;
    [self setConfigValue:[NSString stringWithFormat:@"%d", isPassGesturePwd] forKey:kMCIsPassGesturePwdFlagKey];
}

//TODO:开关加载头像
- (BOOL)loadAvatarCellForMailList {
    if (![_configDict objectForKey:kMCLoadAvatarForMailListKey]) {
        return YES;
    }
    return [[_configDict objectForKey:kMCLoadAvatarForMailListKey] boolValue];
}
- (void)setLoadAvatarCellForMailList:(BOOL)loadAvatarCellForMailList {
    
    _loadAvatarCellForMailList = loadAvatarCellForMailList;
    [self setConfigValue:[NSString stringWithFormat:@"%d",loadAvatarCellForMailList] forKey:kMCLoadAvatarForMailListKey];
}

//   服务器状态：正式服务器、测试服务器

- (BOOL)isTestServer
{
    if (![_configDict objectForKey:kMCServerStateKey]) {
        [self setConfigValue:[NSString stringWithFormat:@"1"] forKey:kMCServerStateKey];
        return YES;
    }
    return [[_configDict objectForKey:kMCServerStateKey] boolValue];
}

- (void)setIsTestServer:(BOOL)isTestServer
{
    _isTestServer = isTestServer;
    
    if (isTestServer) {
        
        _mqttHost = kMailChatMQTTDefaultHost;
        [self setConfigValue:_mqttHost forKey:kMCAppSettingMQTTHostKey];
        
        _mqttPort = kMailChatMQTTDefaultPort;
        [self setConfigValue:[NSString stringWithFormat:@"%ld",_mqttPort] forKey:kMCAppSettingMQTTPortKey];
        
        _apiBaseUrl = kMailChatHttpBaseUrl;
        [self setConfigValue:_apiBaseUrl forKey:kMCAppSettingApiUrlKey];
        
    }else{
        _mqttHost = kMailChatMQTTTestHost;
        [self setConfigValue:_mqttHost forKey:kMCAppSettingMQTTHostKey];
        
        _mqttPort = kMailChatMQTTTestPort;
        [self setConfigValue:[NSString stringWithFormat:@"%ld",_mqttPort] forKey:kMCAppSettingMQTTPortKey];
        
        _apiBaseUrl = kMailChatHttpTestBaseUrl;
        [self setConfigValue:_apiBaseUrl forKey:kMCAppSettingApiUrlKey];
        
    }
    [self setConfigValue:[NSString stringWithFormat:@"%d",isTestServer] forKey:kMCServerStateKey];
}

//是否显示联系人权重
-(BOOL)showWeight
{
    if (![_configDict objectForKey:kMCDebugAccountWeight]) {
        [self setConfigValue:[NSString stringWithFormat:@"0"] forKey:kMCDebugAccountWeight];
        return NO;
    }
    return [[_configDict objectForKey:kMCDebugAccountWeight] boolValue];
}
- (void)setShowWeight:(BOOL)showWeight
{
    _showWeight = showWeight;
    [self setConfigValue:[NSString stringWithFormat:@"%d", showWeight] forKey:kMCDebugAccountWeight];
}

- (NSString *)mailAdjust
{
    if (![_configDict objectForKey:kMCMailAdjustKey]) {
        [self setConfigValue:@"100%" forKey:kMCMailAdjustKey];
         return @"100%";
    }
    return [_configDict objectForKey:kMCMailAdjustKey];
}

- (void)setMailAdjust:(NSString *)mailAdjust
{
    _mailAdjust = mailAdjust;
    [self setConfigValue:_mailAdjust forKey:kMCMailAdjustKey];
}

#pragma mark - apns

- (void)setResetApnsPushStateVersion:(NSInteger)resetApnsPushStateVersion {
   
}

- (BOOL)msgPushFlag {
    if ([_configDict objectForKey:kMCMsgPushFlagKey] == nil) {
        return YES;
    }
    
    return [[_configDict objectForKey:kMCMsgPushFlagKey] boolValue];
}

- (void)setMsgPushFlag:(BOOL)msgPushFlag {
    _msgPushFlag = msgPushFlag;
    [self setConfigValue:[NSString stringWithFormat:@"%d", msgPushFlag] forKey:kMCMsgPushFlagKey];
}

- (BOOL)mailPushFlag {
    if ([_configDict objectForKey:kMCMailPushFlagKey] == nil) {
        return YES;
    }
    
    return [[_configDict objectForKey:kMCMailPushFlagKey] boolValue];
}

- (void)setMailPushFlag:(BOOL)mailPushFlag {
    _mailPushFlag = mailPushFlag;
    [self setConfigValue:[NSString stringWithFormat:@"%d", mailPushFlag] forKey:kMCMailPushFlagKey];
}

- (BOOL)oaPushFlag {
    if ([_configDict objectForKey:kMCOAPushFlagKey] == nil) {
        return YES;
    }
    
    return [[_configDict objectForKey:kMCOAPushFlagKey] boolValue];
}

- (void)setOaPushFlag:(BOOL)oaPushFlag {
    _oaPushFlag = oaPushFlag;
    [self setConfigValue:[NSString stringWithFormat:@"%d", oaPushFlag] forKey:kMCOAPushFlagKey];
}

- (BOOL)pushDetailFlag {
    if ([_configDict objectForKey:kMCPushDetailFlagKey] == nil) {
        return YES;
    }
    
    return [[_configDict objectForKey:kMCPushDetailFlagKey] boolValue];
}

- (void)setPushDetailFlag:(BOOL)pushDetailFlag {
    _pushDetailFlag = pushDetailFlag;
    [self setConfigValue:[NSString stringWithFormat:@"%d", pushDetailFlag] forKey:kMCPushDetailFlagKey];
}

//TODO:统一签名设置
- (NSString*)mcMailAllSignature {
    
    if (![_configDict objectForKey:kMCAllSignatureSetKey]) {
        return @"发自邮洽";
    }
    return [_configDict objectForKey:kMCAllSignatureSetKey];
}

- (void)setMcMailAllSignature:(NSString *)mcMailAllSignature {
    _mcMailAllSignature = mcMailAllSignature;
    [self setConfigValue:mcMailAllSignature forKey:kMCAllSignatureSetKey];
}
//TODO:写信抄送自己
- (void)setCcForyourSelfKey:(NSString*)key value:(BOOL)value{
    [self setConfigValue:[NSString stringWithFormat:@"%d", value] forKey:key];
}
- (BOOL)getCcForYourSelfKey:(NSString*)key{
    
    if ([_configDict objectForKey:key] == nil) {
        
        NSDictionary *dic = [self getoldSettingConfig];
        if (dic) {
            NSNumber *nub = [dic valueForKey:key];
            BOOL cc = [nub boolValue];
            [self setCcForyourSelfKey:key value:cc];
            return  cc;
        }
         [self setCcForyourSelfKey:key value:NO];
        return NO;
    }
    return [[_configDict objectForKey:key] boolValue];
}

/**
 *  是否企业联系人信息
 */
- (void)setEnterpriseDisableFlag:(NSString *)key value:(BOOL)value {
     [self setConfigValue:[NSString stringWithFormat:@"%d", value] forKey:[NSString stringWithFormat:@"%@_%@",@"EnterpriseDisable", key]];
}

- (BOOL)getEnterpriseDisableFlag:(NSString *)key {
    NSString *realKey = [NSString stringWithFormat:@"%@_%@",@"EnterpriseDisable", key];
    if ([_configDict objectForKey:realKey] == nil) {
        return NO;
    }
    return [[_configDict objectForKey:realKey] boolValue];
}

//设置最后tabBar Index
- (NSInteger)lastTabbarSelectIndex {
    
    if (![_configDict objectForKey:kMCLastTabbarSelectIndexKey]) {
        return 0;
    }
    id obj = [_configDict objectForKey:kMCLastTabbarSelectIndexKey];
    
    if ([obj integerValue] != 1) {
        return 0;
    }
    return 1;
}

- (void)setLastTabbarSelectIndex:(NSInteger)lastTabbarSelectIndex {
    [self setConfigValue:[NSString stringWithFormat:@"%ld",(long)lastTabbarSelectIndex] forKey:kMCLastTabbarSelectIndexKey];
}
//firstLoadVipMails
- (BOOL)isFirstLoadVipMails {
    if (![_configDict objectForKey:kMCFirstLoadVipMails]) {
        return YES;
    }
    return [[_configDict objectForKey:kMCFirstLoadVipMails] boolValue];
}
- (void)setIsFirstLoadVipMails:(BOOL)isFirstLoadVipMails {
    [self setConfigValue:[NSString stringWithFormat:@"%ld",(long)isFirstLoadVipMails] forKey:kMCFirstLoadVipMails];
}

- (void)resetClientId:(NSString *)clientId
{
    [self setConfigValue:clientId forKey:kMCAppSettingClientId];
}

#pragma mark - 工作台设置
- (void)setIsShowWorkspace:(BOOL)isShowWorkspace {
    [self setConfigValue:[NSString stringWithFormat:@"%d", isShowWorkspace] forKey:kMCIsShowWorkspaceKey];
}

- (BOOL)isShowWorkspace {
    if ([_configDict objectForKey:kMCIsShowWorkspaceKey] == nil) {
        return YES;
    }
    return [[_configDict objectForKey:kMCIsShowWorkspaceKey] boolValue];
}

#pragma mark - 引导功能相关设置

- (void)setIsFirstShowGuideForMailListContrller:(BOOL)isFirstShowGuideForMailListContrller {
    [self setConfigValue:[NSString stringWithFormat:@"%d", isFirstShowGuideForMailListContrller] forKey:kMCIsShowGuidesForMailListKey];
}

- (BOOL)isFirstShowGuideForMailListContrller {
    if ([_configDict objectForKey:kMCIsShowGuidesForMailListKey] == nil) {
        return YES;
    }
    return [[_configDict objectForKey:kMCIsShowGuidesForMailListKey] boolValue];
}

- (void)setIsFirstShowGuideForMailDetailEditAgain:(BOOL)isFirstShowGuideForMailDetailEditAgain {
    [self setConfigValue:[NSString stringWithFormat:@"%d", isFirstShowGuideForMailDetailEditAgain] forKey:kMCIsShowGuidesForMailEditAgainKey];
}

- (BOOL)isFirstShowGuideForMailDetailEditAgain {
    if ([_configDict objectForKey:kMCIsShowGuidesForMailEditAgainKey] == nil) {
        return YES;
    }
    return [[_configDict objectForKey:kMCIsShowGuidesForMailEditAgainKey] boolValue];
}
//TODO:setguideViewLoadIndex

- (void)setGuideViewLoadIndex:(NSInteger)guideViewLoadIndex {
    [self setConfigValue:[NSString stringWithFormat:@"%ld",(long)guideViewLoadIndex] forKey:kMCGuideViewLoadingKey];
}

- (NSInteger)guideViewLoadIndex {
    if ([_configDict objectForKey:kMCGuideViewLoadingKey] == nil) {
        return 0;
    }
    return [[_configDict objectForKey:kMCGuideViewLoadingKey] integerValue];
}

//loadImportMails

- (void)setLoadImportantMails:(BOOL)loadImportantMails {
    [self setConfigValue:[NSString stringWithFormat:@"%d",loadImportantMails] forKey:kMCLoadImportantMailsKey];
}

- (BOOL)loadImportantMails {
    if ([_configDict objectForKey:kMCLoadImportantMailsKey] == nil) {
        return YES;
    }
    return [[_configDict objectForKey:kMCLoadImportantMailsKey] integerValue] > 0 ?YES:NO;
}

- (void)setSmartBoxSelectEnable:(BOOL)smartBoxSelectEnable {
    [self setConfigValue:[NSString stringWithFormat:@"%d",smartBoxSelectEnable] forKey:kMCSmartBoxSelectEnableKey];
}

- (BOOL)smartBoxSelectEnable {
    if ([_configDict objectForKey:kMCSmartBoxSelectEnableKey] == nil) {
        return YES;
    }
    return [[_configDict objectForKey:kMCSmartBoxSelectEnableKey] boolValue];
}

- (void)setUserFeedbackVipMailInfoDate:(NSDate *)userFeedbackVipMailInfoDate {
    
    NSString *dateString = [NSString stringWithFormat:@"%f",userFeedbackVipMailInfoDate.timeIntervalSince1970];
    [self setConfigValue:dateString forKey:kMCUserFeedbackVipMailDateKey];
}

- (BOOL)isShowFeedbackVipMailInfoNote {
    
    NSInteger index = 0;
    if ([_configDict objectForKey:kMCUserFeedbackIndexKey] == nil) {
        index = 0;
    } else {
        index = [[_configDict objectForKey:kMCUserFeedbackIndexKey] integerValue];
    }
    if (index < kMDefaultFeedbackIndex) {
        [self setUserFeedbackVipMailInfoDate:[NSDate date]];
        [self setConfigValue:[NSString stringWithFormat:@"%ld",(long)kMDefaultFeedbackIndex] forKey:kMCUserFeedbackIndexKey];
    }
    NSString *dateString = [_configDict objectForKey:kMCUserFeedbackVipMailDateKey];
    NSDate *oldDate = [NSDate dateWithTimeIntervalSince1970:[dateString floatValue]];
    NSInteger hours = [oldDate hoursBeforeDate:[NSDate date]];
    if (hours > kMDefaultDateForShowFeedbackNote && self.loadImportantMails) {
        [self setUserFeedbackVipMailInfoDate:[NSDate dateWithTimeIntervalSinceNow:1000000000]];
        return YES;
    }
    return NO;
}

//new Setting update
- (void)setIsNewSettingUpdate:(BOOL)isNewSettingUpdate {
    if (isNewSettingUpdate == NO) {
        [self setConfigValue:[NSString stringWithFormat:@"%ld",(long)kMDefaultNewSettingUpdate] forKey:kMCNewSettingUpdate];
    }
}

- (BOOL)isNewSettingUpdate {
    NSInteger times = 0;
    if ([_configDict valueForKey:kMCNewSettingUpdate] == nil) {
        times = 0;
    } else {
        times = [[_configDict valueForKey:kMCNewSettingUpdate] integerValue];
    }
    if (times < kMDefaultNewSettingUpdate) {
        return YES;
    }
    return  NO;
}
- (void)setIsQuestionnaireNote:(BOOL)isQuestionnaireNote {
    [self setConfigValue:[NSString stringWithFormat:@"%d",isQuestionnaireNote] forKey:kMCQuestionnaireNoteKey];
}

- (BOOL)isQuestionnaireNote {
    if ([_configDict valueForKey:kMCQuestionnaireNoteKey] == nil) {
        return  YES;
    }
    return [[_configDict valueForKey:kMCQuestionnaireNoteKey] boolValue];
}

#pragma mark - Private

- (void)setup
{
    NSArray *models = [_db allModels];
    _configDict = [NSMutableDictionary new];
    if (models.count > 0) {
        for (MCAppConfigModel *config in models) {
            [_configDict setObject:config.configValue forKey:config.configKey];
        }
    }
}

- (void)setConfigValue:(NSString *)value forKey:(NSString *)key
{
    if ([[_configDict allKeys] containsObject:key]) {
        [_configDict setObject:value forKey:key];
        [_db updateValue:value forKey:key];
    }
    else{
        [_configDict setObject:value forKey:key];
        MCAppConfigModel *config = [MCAppConfigModel new];
        config.configKey = key;
        config.configValue = value;
        [_db insertModel:config];
    }
    
}

//private
- (NSDictionary*)getoldSettingConfig {
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentPath = [paths objectAtIndex:0];
    NSString* filename = [documentPath stringByAppendingPathComponent:kMCAppSettingOldConfigPlist];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filename];
    return dic;
}
@end
