//
//  MCAppSetting.h
//  NPushMail
//
//  Created by admin on 1/27/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCUserInfo.h"
#import "MCLaunchModel.h"

#define AppSettings [MCAppSetting shared]

@interface MCAppSetting : NSObject

+ (instancetype)shared;

@property (nonatomic,copy) NSString *mqttHost;

@property (nonatomic,assign) NSUInteger mqttPort;
/**
 *  最后更新的版本（弹窗一次即更新本地最后的版本，不管点击是否更新的按钮），若和服务器保持一致，则不再弹窗提醒版本更新。
 */
@property (nonatomic,copy) NSString *lastUpdateVersion;
/**
 *  控制飞巴弹窗提醒
 */
@property (nonatomic,assign) BOOL isShowfeibaRemind;
/**
 *  最后点击设置更新的版本   ps 小红帽消失
 */
@property (nonatomic,copy) NSString *lastSetVersion;

/**
 *  补丁文件本地路径
 */
@property (nonatomic,copy) NSString *jsPath;
/**
 *  补丁文件的版本
 */
@property (nonatomic,assign) NSInteger jsVersion;

/**
 *  API 地址
 */
@property (nonatomic,copy) NSString *apiBaseUrl;

/**
 *  用户的client id
 */
@property (nonatomic,strong,readonly) NSString *clientId;

/**
 *  APNS token
 */
@property (nonatomic,copy) NSString *apnsToken;

/**
 *  新消息提醒开关
 */
@property (nonatomic, assign) BOOL msgPushFlag;
/**
 *  新邮件提醒开关
 */
@property (nonatomic, assign) BOOL mailPushFlag;
/**
 *  oa提醒开关
 */
@property (nonatomic, assign) BOOL oaPushFlag;
/**
 *  通知是否显示详情
 */
@property (nonatomic, assign) BOOL pushDetailFlag;

/**
 *  最后登录的用户id
 */
@property (nonatomic,assign) NSInteger lastAccountId;

/**
 *  当前用户信息
 */
@property (nonatomic,strong) MCUserInfo *user;

/**
 *  启动页信息
 */
@property (nonatomic,strong) MCLaunchModel *launchModel;

#pragma mark - 手势密码
/**
 *  指纹解锁开关
 */
@property (nonatomic,assign) BOOL touchIdFlag;
/**
 *  手势密码开关
 */
@property (nonatomic,assign) BOOL gesturePasswordFlag;
/**
 *  是否验证过手势密码（否则不要每次都弹出登录验证的界面）
 */
@property (nonatomic,assign) BOOL isPassGesturePwd;
/**
 *  是否加载无头像列表
 */

@property (nonatomic,assign) BOOL loadAvatarCellForMailList;

/**
 *  统一签名
 */
@property (nonatomic,strong) NSString *mcMailAllSignature;


/**
 *  是否是测试服务器
 */
@property (nonatomic,assign) BOOL isTestServer;

/**
 *  是否显示联系人权重
 *  Default : NO
 */
@property (nonatomic,assign) BOOL showWeight;

/**
 *  写信抄送自己
 */

- (void)setCcForyourSelfKey:(NSString*)key value:(BOOL)value;
- (BOOL)getCcForYourSelfKey:(NSString*)key;
/**
 *  是否显示工作台
 */
@property (nonatomic,assign) BOOL isShowWorkspace;
/**
 *  邮件列表页面引导
 */
@property (nonatomic,assign) BOOL isFirstShowGuideForMailListContrller;
/**
 *  已编辑页面引导
 */
@property (nonatomic,assign) BOOL isFirstShowGuideForMailDetailEditAgain;
/**
 *  tabbar index 记录 （下次进入app 使用记录的index）
 */
@property (nonatomic,assign) NSInteger lastTabbarSelectIndex;
//第一次加载重要邮件
@property (nonatomic,assign)BOOL isFirstLoadVipMails;

@property (nonatomic,assign) NSUInteger dbVersion;
//欢迎页加载
@property (nonatomic,assign) NSInteger guideViewLoadIndex;
/*
 是否展示重要邮件
 */
@property (nonatomic,assign) BOOL loadImportantMails;
/*
 select  smart box
 */
@property (nonatomic,assign) BOOL smartBoxSelectEnable;

/*吐槽时间记录*/
@property (nonatomic,strong)NSDate *userFeedbackVipMailInfoDate;

//设置是否反馈弹窗
@property (nonatomic,assign)BOOL isShowFeedbackVipMailInfoNote;
//设置是否有更新东西
@property (nonatomic,assign)BOOL isNewSettingUpdate;
//设置问卷调查
@property (nonatomic,assign)BOOL isQuestionnaireNote;

- (void)resetClientId:(NSString *)clientId;

//记录邮件字体大小百分比
@property (nonatomic, strong) NSString  *mailAdjust;

@end
