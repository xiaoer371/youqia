//
//  MCAppDelegate.m
//  NPushMail
//
//  Created by zhang on 16/1/18.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <AFNetworking.h>
#import <AFNetworkActivityLogger.h>

#import "MCAppDelegate.h"
#import "MCLoginMainViewController.h"
#import "MCBaseNavigationViewController.h"
#import "MCMailDetailViewController.h"
#import "MCMailComposerViewController.h"
#import "MCTool.h"
#import "MCVersionUpdateView.h"

#import "MCThemeManager.h"
#import "MCContactManager.h"
#import "MCAppSetting.h"
#import "MCServerAPI.h"
#import "MCServerAPI+Account.h"
#import "MCLoginManager.h"
#import "MCAccountManager.h"
#import "MCApnsPush.h"

#import "PCCircleViewConst.h"
#import "MCGestureSetViewController.h"
#import "MCMailNotificationModel.h"
#import "MCAccountManager.h"
#import "MCMailManager.h"
#import "MCModelConversion.h"
#import "MCDatabaseManager.h"
#import "MCNotificationCenter.h"
#import "MCWorkspaceViewController.h"
#import "MCAccountConfig.h"
#import "MobClick.h"
#import "MCUpgradeViewController.h"

#import "MCIMChatInputView.h"
#import "MCIMChatViewController.h"
#import "MCFixSystem.h"

#import "MCGuideViewController.h"
#import "MCFeaturesReleaseManager.h"
#import "iflyMSC/IFlyMSC.h"
#import "MCUDID.h"
#import <UserNotifications/UserNotifications.h>
#import "MCWorkSpaceManager.h"
#import "MCLaunchViewController.h"
#import "MCLaunchManager.h"

#import <BuglyHotfix/Bugly.h>

#define DefaultGuideIndex  1

@interface MCAppDelegate()<UNUserNotificationCenterDelegate,MCLaunchViewControllerDelegate,BuglyDelegate>

@property(strong, nonatomic) NSDictionary *remoteNotification;
@property(nonatomic,assign)BOOL goOnLoginGmail;
@end

@implementation MCAppDelegate{
   __block UIBackgroundTaskIdentifier backgroundTask;   //用来保存后台运行任务的标示符
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self gmailWebSetUp];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    

    // 必要的初始化
    [self setupLog];
    [self setupTheme];
    [self setupStats];
    
    [self addLaunchAnimation];
    
    // 配置 Bugly
    [self setupBugly];
    
    [[MCTool shared] registerRemoteNoticationsWithAppDelegate:self];
    [application cancelAllLocalNotifications];
    [self handleLaunchOptions:launchOptions];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    if ([url.absoluteString containsString:@"com.googleusercontent.apps.675480778826-944drm2gc93mud0p5s31mp6ou0bt6ot5"]) {
        /// 这个是Google 认证
        if ([AppStatus.currentAuthorizationFlow resumeAuthorizationFlowWithURL:url]) {
            AppStatus.currentAuthorizationFlow = nil;
            return YES;
        }
        return [self sharedAttachFromOtherAppForComposerWithUrl:url];
    }else{
        return YES;
    }
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString *, id> *)options {
    // Sends the URL to the current authorization flow (if any) which will process it if it relates to
    // an authorization response.
    if ([AppStatus.currentAuthorizationFlow resumeAuthorizationFlowWithURL:url]) {
        AppStatus.currentAuthorizationFlow = nil;
        return YES;
    }
    return [self sharedAttachFromOtherAppForComposerWithUrl:url];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    //TODO:  每次进后台，把未读数清0
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
   
    UINavigationController *nav  = self.tabBarController.viewControllers[1];
    for (UIViewController *vc in nav.viewControllers) {
        if ([vc isKindOfClass:[MCIMChatViewController class]]) {
            MCIMChatViewController *chatVC = (MCIMChatViewController*)vc;
            [chatVC stopRecording];
        }
    }
}
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window
{
    if (_allowRotation == 1)  {
        return UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft;
    }
    else {
        return (UIInterfaceOrientationMaskPortrait);
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];//讯飞语音需要
//  开启后台任务  [self startBackgroundTask];
    
    if ([AppSettings gesturePasswordFlag]) {
        [AppSettings setIsPassGesturePwd:NO];
    }
    
    if (AppSettings.apnsToken) {
        MCApnsPush *apnsPush = [[MCApnsPush alloc] initWithToken:AppSettings.apnsToken clientId:AppSettings.clientId];
        MCPushSettingModel *pushSettingModel = [apnsPush getPushSettingModelWithEmail:nil];
        [apnsPush updatePushSettingWithPushSettingModel:pushSettingModel success:^(id response) {
            
        } failure:^(NSError *error) {
            
        }];
    }
    
    AppSettings.lastTabbarSelectIndex = self.tabBarController.selectedIndex;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    if ([AppSettings gesturePasswordFlag]) {
        UIView *v = [self findFirstResponder:self.window];
        if (v) {
            [v resignFirstResponder];
        }
        [self getsturePwdCtrl];
    }else {
        if ([AppSettings touchIdFlag]) {
            UIView *v = [self findFirstResponder:self.window];
            if (v) {
                [v resignFirstResponder];
                [self reSetFrameWhenTextResignFirstResponder:v];
            }
            if (_touchWindow) {
                [_touchWindow dismiss];
            }
            self.touchWindow = [[MCTouchIdWindow alloc] initWithFrame:self.window.frame];
            [self.touchWindow show];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString* newToken = [NSString stringWithFormat:@"%@", deviceToken];
    newToken = [newToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    newToken = [newToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    newToken = [newToken lowercaseString];
    DDLogInfo(@"APNS TOKEN = %@", newToken);
    
    AppSettings.apnsToken = newToken;
    MCLoginManager *loginMgr = [MCLoginManager new];
    [loginMgr authenticateUserSuccess:nil failure:nil];
    
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    DDLogVerbose(@"收到推送通知:%@",userInfo);
    _remoteNotification = userInfo;
    
    //当应用程序在后台挂起时接到远程通知，用户进入应用后，会是如下状态
    if (application.applicationState == UIApplicationStateInactive) { //为后台进入前台
        DDLogVerbose(@"后台进入前台");
        [self receiveMessageFromRemoteNotification:self.remoteNotification inApp:NO];
    }else {
        DDLogVerbose(@"正在前台运行,收到推送消息");
        [self receiveMessageFromRemoteNotification:self.remoteNotification inApp:YES];
    }

}

/*
 自定义参数,类似 data =   { i: 220070,
 u: 'qiushzh@35.cn',
 s: 'aaaa',
 f: '邱尚振<qiushzh@35.cn>',
 t: 1423030476950,
 d: 'inbox',
 m: '邮件内容第一行\\n邮件内容第二行' };
 
 i 邮箱UID (i要做空判断),用于从邮局服务器获取这个邮件
 u 收件人邮箱
 s 邮件标题
 f 发件人信息 名称<邮箱>
 t 时间戳（毫秒）
 d 文件夹
 m 内容摘要
 */

//收到消息推送时的处理
- (void)receiveMessageFromRemoteNotification:(NSDictionary*)userInfo inApp:(BOOL)inAppFlag{
    DDLogVerbose(@"receiveMessageFromRemoteNotification:%@",[userInfo description]);
    
    int type = [[userInfo valueForKey:@"type"] intValue];
    NSDictionary *dic    = [userInfo valueForKey:@"data"];
    NSDictionary *info = [dic valueForKey:@"m"];
    if (inAppFlag) {
        //应用内收到推送
    }else {
        //外部收到推送点击进入的
        switch (type) {
            case 1://邮件推送
            {
                MCMailNotificationModel *notifyMailModel = [[MCMailNotificationModel alloc]initModelWith:info];
               BOOL isAccountIn = [self checkAccountWith:notifyMailModel.toMail];
                if (notifyMailModel.mailUid && isAccountIn) {
                    [self pushToViewControllerForApnsType:type object:nil];
                    MCMailModel *mail = [MCMailManager mailForNotification:notifyMailModel];
                    if (mail) {
                        [MCMailManager addMail:mail];
                        //TODO:当收到apns推送邮件 发出通知；
                        [MCNotificationCenter postNotification:MCNotificationDidReceiveApnsMailPush object:mail];
                    }
                }
            }
                break;
            case 2://消息推送
            {
                
            }
                break;
            case 3://OA推送
            {
                
            }
                break;
                
            default:
                break;
        }
        
        
    }
}

//文件分享到写信
- (BOOL)sharedAttachFromOtherAppForComposerWithUrl:(NSURL*)url {
    MCMailAttachment *attchment = [MCModelConversion mailattachmentWithUrl:url];
    if (!attchment) {
        return NO;
    }
    [self popToRootViewController];
    if (self.tabBarController.selectedIndex != 0) {
        self.tabBarController.selectedIndex = 0;
    }
    UINavigationController *mailListNav = self.tabBarController.viewControllers[0];
    MCMailComposerViewController*composerViewController = [[MCMailComposerViewController alloc]initWithContent:attchment composerType:MCMailComposerNew];
    [mailListNav pushViewController:composerViewController animated:NO];
    return YES;
}


- (void)setTabbarWithWorkspaceFlag:(BOOL)flag {
    [self.tabBarController setTabbarWithWorkspaceFlag:flag];
}

#pragma mark - Log

- (void)setupLog
{
    setenv("XcodeColors", "YES", 0);
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console
    [DDLog addLogger:[DDASLLogger sharedInstance] withLevel:DDLogLevelWarning]; // ASL = Apple System Logs
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init]; // File Logger
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger withLevel:DDLogLevelInfo];
    
    // And then enable colors
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    DDColor *pink = DDMakeColor(255, 105, 180);
    [[DDTTYLogger sharedInstance] setForegroundColor:pink backgroundColor:nil forFlag:DDLogFlagDebug];
    
    [[AFNetworkActivityLogger sharedLogger] startLogging];
    [[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelWarn];
    
}

#pragma - Private


- (MCTouchIdWindow *)touchWindow {
    if (_touchWindow) {
        return _touchWindow;
    }
    _touchWindow = [[MCTouchIdWindow alloc] initWithFrame:self.window.frame];
    return _touchWindow;
}

- (MCGestureWindow *)gestureWindow {
    if (_gestureWindow) {
        return _gestureWindow;
    }
    _gestureWindow = [[MCGestureWindow alloc] initWithFrame:self.window.frame];
    return _gestureWindow;
}

#pragma mark Private -
- (MCAccount*)checkAccountWith:(NSString*)email {
    MCAccount* account = [[MCAccountManager shared] accountWithEmail:email];
    if (account && !account.deleted) {
        if (![account isEqual:AppStatus.currentUser]) {
            MCLoginManager *loginManager =  [MCLoginManager new];
            [loginManager loginWithAccount:account];
        }
        return account;
    }
    return  nil;
}

- (void)pushToViewControllerForApnsType:(NSInteger)type object:(id)object{
    
    [self popToRootViewController];
    if (type == 1) {//邮件跳转
        
        if (self.tabBarController.selectedIndex != 0) {
            self.tabBarController.selectedIndex = 0;
        }
        
    } else {//其他跳转
        
        if (self.tabBarController.selectedIndex != 1) {
            self.tabBarController.selectedIndex = 1;
        }
    }
}
//TODO:跳转到最上层页面
- (void)popToRootViewController {
    //初始状态
    NSInteger index = self.tabBarController.selectedIndex;
    UINavigationController *navigationController = self.tabBarController.viewControllers[index];
    [navigationController dismissViewControllerAnimated:NO completion:nil];
    if (navigationController.viewControllers.count  > 1) {
        UIViewController *viewController = [navigationController.viewControllers lastObject];
        [viewController.navigationController popToRootViewControllerAnimated:NO];
    }
}
//手势密码
- (void)getsturePwdCtrl {
    if ([AppSettings gesturePasswordFlag]) {
        if ([PCCircleViewConst getGestureWithKey:gestureFinalSaveKey]) {
            if (![AppSettings isPassGesturePwd]) {
                if (_gestureWindow) {
                    [_gestureWindow dismiss];
                }
                self.gestureWindow = [[MCGestureWindow alloc] initWithFrame:self.window.frame];
                [self.gestureWindow show];
            }
        }
    } else if (_goOnLoginGmail){
        MCLoginMainViewController *loginViewController = [[MCLoginMainViewController alloc]initWithNibName:nil bundle:nil];
        loginViewController.mcLoginPopType = MCLoginPopOptionCanPop;
        MCBaseNavigationViewController *nav = [[MCBaseNavigationViewController alloc]initWithRootViewController:loginViewController];
        [self.tabBarController presentViewController:nav animated:YES completion:nil];
    }
}
- (BOOL)updateDbVersion {
    MCDatabaseManager *dbMGr = [MCDatabaseManager new];
    if ([dbMGr shouldUpgrade]) {
        MCUpgradeViewController *upgradeVC = [[MCUpgradeViewController alloc] init];
        self.window.rootViewController = upgradeVC;
        return YES;
    }
    else {
        return NO;
    }
}

// 更新完数据库后的初始化操作
- (void)doLoginProcess
{
    
    [self loginUser];
    
    //要设置验证手势密码
    [self checkGesturePassword];
    [self showRootViewController];
    
    // Check new version
    [MCVersionUpdateView show:YES];
        
}


//判断是否登录
- (void)showRootViewController
{
    MCLoginManager *loginMgr = [MCLoginManager new];
    if ([loginMgr loginLastUser]) {
        [self displayTabBarViewController];
        
    }else {
        [self displayLoginViewController];
    }

    //获取服务器  启动页
    [MCLaunchManager checkLaunch];
    
}
//主界面
- (void)displayTabBarViewController {
    if (!self.tabBarController) {
        self.tabBarController = [[MCTabBarController alloc]init];
    }
    self.window.rootViewController = self.tabBarController;
    MCAccountConfig *accountConfig = AppStatus.accountData.accountConfig;
    BOOL showWorkspaceFlag = accountConfig.hasWorkspace && AppSettings.isShowWorkspace;
    [self.tabBarController setTabbarWithWorkspaceFlag:showWorkspaceFlag];
    self.tabBarController.selectedIndex = AppSettings.lastTabbarSelectIndex;
    [self getsturePwdCtrl];
    
    //注释 更新红点提醒
//    [MCVersionUpdateView showUpdateBadgeWithWorkPlace:showWorkspaceFlag];
    [MCWorkSpaceManager workSpaceUserCheck];
}
//登录界面
- (void)displayLoginViewController {
    
    MCLoginMainViewController*mcLoginMainViewController = [[MCLoginMainViewController alloc]init];
    self.window.rootViewController = [[MCBaseNavigationViewController alloc]initWithRootViewController:mcLoginMainViewController];
 }

- (void)setupTheme
{
    AppStatus.theme = [MCThemeManager sharedManager].theme;
}

- (void)loginUser
{
    MCLoginManager *loginMgr = [MCLoginManager new];
    if (!AppSettings.user) {
        [loginMgr authenticateNewUserSuccess:nil failure:nil];
    }
}

- (void)checkGesturePassword
{
    if ([AppSettings gesturePasswordFlag]) {
        if ([AppSettings touchIdFlag]) {
            DDLogError(@"错误，手势密码和指纹密码不可同时开启");
        }else {
            [AppSettings setIsPassGesturePwd:NO];
        }
    }
    if ([AppSettings touchIdFlag]) {
        if ([AppSettings gesturePasswordFlag]) {
            DDLogError(@"错误，手势密码和指纹密码不可同时开启");
        }else {
            [self.touchWindow show];
        }
    }
}

- (void)handleLaunchOptions:(NSDictionary *)launchOptions
{
    //启动时，获取消息
    if(launchOptions != nil && !EGOVersion_iOS10)
    {
        NSDictionary* pushNotificationKey = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (pushNotificationKey)
        {
            self.remoteNotification = pushNotificationKey;
            [self receiveMessageFromRemoteNotification:self.remoteNotification inApp:NO];
        }
    }
}

- (void)setupStats
{
#if TARGET_IPHONE_SIMULATOR
#elif TARGET_OS_IPHONE
    //注册友盟统计
    UMAnalyticsConfig *config = [UMAnalyticsConfig sharedInstance];
    config.appKey = @"54bc678bfd98c58e72000bad";
    config.bCrashReportEnabled = NO;
    [MobClick startWithConfigure:config];
#endif
}


- (UIView *)findFirstResponder:(UIView *)baseView {
    if (baseView == nil)
        baseView = self.window;
    
    if (baseView.isFirstResponder)
        return baseView;
    for (UIView *subview in baseView.subviews) {
        UIView *firstResponder = [self findFirstResponder:subview];
        if (firstResponder != nil)
            return firstResponder;
    }
    return nil;
}

- (void)reSetFrameWhenTextResignFirstResponder:(UIView*)v
{
    if ([v isKindOfClass:[MCChatTextView class]]) {
        UIView *view =v.superview;
        if ([view isKindOfClass:[MCIMChatInputView class]]) {
            MCIMChatInputView *tempView = (MCIMChatInputView*)view;
            CGFloat a = CGRectGetMaxY(tempView.frame);
            if (a + NAVIGATIONBARHIGHT == ScreenHeigth) {
                return;
            }
            CGRect rect = tempView.frame;
            CGFloat inputHeight = CGRectGetHeight(tempView.frame);
            rect.origin.y = ScreenHeigth-inputHeight-64;
            tempView.frame = rect;
            [tempView dismissKeyboardWithscrollSelectItem];
        }
    }
}

#pragma mark handleActionWithIdentifier

- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void(^)())completionHandler {
    [self notificationAction:userInfo action:identifier];
    completionHandler();
}


#pragma mark UNNotifitionDelegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    //在没有启动本App时，收到服务器推送消息，
    if ([response.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier]) {
        [self receiveMessageFromRemoteNotification:response.notification.request.content.userInfo inApp:NO];
       
    } else {
        
        [self notificationAction:response.notification.request.content.userInfo action:response.actionIdentifier];
    }
    completionHandler();
}

#pragma mark -notifitionAction
- (void)notificationAction:(NSDictionary*)notiticationInfo action:(NSString*)action {
    
    NSDictionary *dic = [notiticationInfo valueForKey:@"data"];
    NSDictionary *info = [dic valueForKey:@"m"];
    MCMailNotificationModel *notifyMailModel = [[MCMailNotificationModel alloc]initModelWith:info];
    if (notifyMailModel.mailUid != NSNotFound && notifyMailModel.folder) {
        MCMailModel *mail = [MCMailManager mailForNotification:notifyMailModel];
        MCAccount *account = [self checkAccountWith:notifyMailModel.toMail];
        if (account) {
           MCMailManager *mailManager =  [[MCMailManager alloc]initWithAccount:account];
            if ([action isEqualToString:kMCNotificationReadActionIdentity]) {
                [mailManager setReadFlag:YES forMails:@[mail] success:nil failure:nil];
                [MCUmengManager pushEvent:mc_push_mailRead];
            } else if ([action isEqualToString:kMCNotificationDeleteActionIdentity]) {
                MCMailBox *box = [MCMailBox new];
                box.path = mail.folder;
                [mailManager moveMails:@[mail] fromFolder:box toFolder:nil success:nil failure:nil];
                [MCUmengManager pushEvent:mc_push_mailTrash];
            }
        }
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber -= 1;
}


- (void)setupBugly
{
    BuglyConfig * config = [[BuglyConfig alloc] init];
#if DEBUG
    config.debugMode = YES;
#endif
    /**
     * 控制自定义日志上报，默认值为BuglyLogLevelSilent，即关闭日志记录功能。
     * 如果设置为BuglyLogLevelWarn，则在崩溃时会上报Warn、Error接口打印的日志
     */
    config.reportLogLevel = BuglyLogLevelWarn;
    //  卡顿监控开关，默认关闭
    config.blockMonitorEnable = YES;
    //  卡顿监控判断间隔，单位为秒
    config.blockMonitorTimeout = 1.2;
    
    config.delegate = self;
#warning 这个属性用来本地调试js（加载本地main.js文件）， 发布的时候，一定要注释掉。
//    config.hotfixDebugMode = YES;
    [Bugly startWithAppId:BUGLY_APP_ID
#if DEBUG
        developmentDevice:YES
#endif
                   config:config];
    
    [Bugly setUserIdentifier:AppStatus.currentUser?AppStatus.currentUser.email:[UIDevice currentDevice].name];
    
    [Bugly setUserValue:[NSProcessInfo processInfo].processName forKey:@"Process"];
}

#pragma mark - BuglyDelegate
- (NSString *)attachmentForException:(NSException *)exception {
    NSLog(@"(%@:%d) %s %@",[[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__,exception);
    
    return @"This is an attachment";
}

#pragma mark - 升级数据库
- (void)checkUpdateDataBase
{
    MCDatabaseManager *dbMGr = [MCDatabaseManager new];
    if ([dbMGr shouldUpgrade]) {
        MCUpgradeViewController *upgradeVC = [[MCUpgradeViewController alloc] init];
        __weak typeof(self) weakSelf = self;
        upgradeVC.completeBlock = ^{
            [weakSelf doLoginProcess];
        };
        self.window.rootViewController = upgradeVC;
    }
    else {
        // 升级数据库后的操作
        [self doLoginProcess];
    }
}

#pragma mark - 加载启动动画/图片
- (void)addLaunchAnimation
{
    if ([self launchWithValidtime]) {
        MCLaunchViewController *vc = [[MCLaunchViewController alloc] initWithLaunchModel:AppSettings.launchModel];
        vc.delegate = self;
        self.window.rootViewController = vc;
    }else{
        [self checkUpdateDataBase];
    }
}

- (BOOL)launchWithValidtime
{
    CGFloat time = [[NSDate date] timeIntervalSince1970];
    if (AppSettings.launchModel.enable && AppSettings.launchModel.end <time  &&
        AppSettings.launchModel.start >time &&AppSettings.launchModel.isDownLoad) {
        return YES;
    }else return NO;
}

#pragma mark - MCLaunchViewDelegate
- (void)jumpLaunchView:(MCLaunchViewController*)launchView
{
    [self checkUpdateDataBase];
}
/// 测试测试
- (void)gmailWebSetUp{
    ///TODO : WebView 伪装成Safari  修改UserAgent属性
    //**  WebView  UserAgent 缺少 Version/10.0 Safari/602.1 两个字段
    NSDictionary *dictionary = [NSDictionary
                                dictionaryWithObjectsAndKeys:
                                @"Mozilla/5.0 (iPhone; CPU iPhone OS 10_1 like Mac OS X) AppleWebKit/602.2.14 (KHTML, like Gecko) Version/10.0 Mobile/14B72 Safari/602.1",
                                @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    
}
- (void)startBackgroundTask
{
    UIApplication *application = [UIApplication sharedApplication];
    //通知系统, 我们需要后台继续执行一些逻辑
    backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
        //超过系统规定的后台运行时间, 则暂停后台逻辑
        [application endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid;
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //### background task starts
        NSLog(@"Running in the background\n");
        while(TRUE)
        {
            DDLogVerbose(@"beginground test");
            [NSThread sleepForTimeInterval:1 * 60 * 10]; //wait for 10 minutes
        }
        
        //Clean up code. Tell the system that we are done.
        [application endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid;
    });
}

@end
