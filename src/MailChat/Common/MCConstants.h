//
//  MCConstants.h
//  NPushMail
//
//  Created by admin on 2/2/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#ifndef MCConstants_h
#define MCConstants_h

#define PMLocalizeFormatStringWithKey(strKey, ...) [NSString stringWithFormat:NSLocalizedStringFromTable(strKey, @"LocalizableStrings", nil), __VA_ARGS__]
#define PMLocalizedStringWithKey(strKey) NSLocalizedStringFromTable(strKey, @"LocalizableStrings", nil)

#define ScreenWidth [[UIScreen mainScreen] bounds].size.width
#define ScreenHeigth [[UIScreen mainScreen] bounds].size.height
#define iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
//toolbar高度
#define NAVIGATIONBARHIGHT    64
#define TOOLBAR_HEIGHT        49
#define TABLEBARHIGHT         20
//TitleView
#define TITLEVIEW_HEIGHT ([[UIDevice currentDevice].systemVersion doubleValue]>=7.0 ?64 : 44)

//rgb
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

//#define ISCONNECTAVAILABLE AppStatus.networkStatus != NotReachable


//判断版本是否是7.0及以上
#define EGOVersion_iOS7 ([[UIDevice currentDevice].systemVersion doubleValue] >= 7.0)
//判断版本是否是8.0及以上
#define EGOVersion_iOS8 ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0)
//判断版本是否是9.0及以上
#define EGOVersion_iOS9 ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0)
//判断版本是否是10.0及以上
#define EGOVersion_iOS10 ([[UIDevice currentDevice].systemVersion doubleValue] >= 10.0)

#ifdef DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
static const DDLogLevel ddLogLevel = DDLogLevelInfo;
#endif

typedef void(^ActionBlock)();
typedef void(^SuccessBlock)(id response);
typedef void(^FinishBlock) (id response ,BOOL finish);
typedef void(^FailureBlock)(NSError *error);
typedef void(^ProgressBlock)(NSInteger currentBytes, NSInteger totalBytes);

static NSString* const kMailChatHelper = @"help@mailchat.cn";
static NSString* const kMailChatHelperAndroid = @"fb@mailchat.cn";
static NSString* const kMailChatOA = @"oa@35.cn";
static NSString* const kMailChatFeiBa = @"FeiBa@35.cn";
static NSString* const kMailChatWeiYa = @"Event_weiya@35.cn";
static NSString* const kMailChatWeiYa1 = @"Event_weiya1@35.cn";

static NSString *const kIssuer = @"https://accounts.google.com";
static NSString *const kClientID = @"675480778826-944drm2gc93mud0p5s31mp6ou0bt6ot5.apps.googleusercontent.com";
static NSString *const kRedirectURI =@"com.googleusercontent.apps.675480778826-944drm2gc93mud0p5s31mp6ou0bt6ot5:/oauthredirect";
static NSString *const kServerClientID = @"675480778826-ab081pvckkgf4q5tuqgs2pbllq424c93.apps.googleusercontent.com";

#ifdef DEBUG
#define Debug_Flag 1
#else
#define Debug_Flag 0
#endif

#endif /* MCConstants_h */
