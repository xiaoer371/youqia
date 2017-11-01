//
//  MCIFlyMSCConfig.m
//  NPushMail
//
//  Created by wuwenyu on 16/11/8.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIFlyMSCConfig.h"
#import "iflyMSC/IFlyMSC.h"

#define PUTONGHUA   @"mandarin"
#define YUEYU       @"cantonese"
#define HENANHUA    @"henanese"
#define ENGLISH     @"en_us"
#define CHINESE     @"zh_cn";

@implementation MCIFlyMSCConfig

-(id)init {
    self  = [super init];
    if (self) {
        [self defaultSetting];
        return  self;
    }
    return nil;
}


+(MCIFlyMSCConfig *)sharedInstance {
    static MCIFlyMSCConfig  * instance = nil;
    static dispatch_once_t predict;
    dispatch_once(&predict, ^{
        instance = [[MCIFlyMSCConfig alloc] init];
    });
    return instance;
}

+ (void)setup
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //设置sdk的log等级，log保存在下面设置的工作路径中
        [IFlySetting setLogFile:LVL_DETAIL];
        //打开输出在console的log开关
        [IFlySetting showLogcat:NO];
        //设置sdk的工作路径
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachePath = [paths objectAtIndex:0];
        [IFlySetting setLogFilePath:cachePath];
        //创建语音配置,appid必须要传入，仅执行一次则可
        NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@", @"58194c39"];
        //所有服务启动前，需要确保执行createUtility
        [IFlySpeechUtility createUtility:initString];
    });
}


-(void)defaultSetting {
    _speechTimeout = @"30000";
    _vadEos = @"3000";  //后断点检测: 后端点静音检测时间,即用户停止说话多长时间内即认为不再输入
    _vadBos = @"5000";  //前端点检测: 静音超时时间，即用户多长时间不说话则当做超时处理； 单位：ms
    _dot = @"1";
    _sampleRate = @"16000";
    _language = CHINESE;
    _accent = PUTONGHUA;
    _haveView = NO;//默认是不dai界面的
    _accentNickName = [[NSArray alloc] initWithObjects:@"粤语",@"普通话",@"河南话",@"英文", nil];
    
}


+(NSString *)mandarin {
    return PUTONGHUA;
}
+(NSString *)cantonese {
    return YUEYU;
}
+(NSString *)henanese {
    return HENANHUA;
}
+(NSString *)chinese {
    return CHINESE;
}
+(NSString *)english {
    return ENGLISH;
}

+(NSString *)lowSampleRate {
    return @"8000";
}

+(NSString *)highSampleRate {
    return @"16000";
}

+(NSString *)isDot {
    return @"1";
}

+(NSString *)noDot {
    return @"0";
}

@end
