//
//  MCIFlyMSCHelper.h
//  NPushMail
//
//  Created by wuwenyu on 16/11/8.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iflyMSC/iflyMSC.h"
#import "MCIFlyMSCConfig.h"
#import "MCIFlyMSCDataHelper.h"
typedef NS_ENUM(NSInteger, IFlyLanguageType) {
    CHINESE = 0, //中文
    ENGLISH = 1,//英文
    YUEYU = 2,//粤语
};

typedef void (^FinishedRecognizer)(void);//识别完成回调
typedef void (^VolumeChanged)(int volume);//音量变化回调
typedef void (^RecognizerError)(IFlySpeechError *error);//识别错误回调
typedef void (^RecognizerResults)(NSString *result);//识别结果回调

@interface MCIFlyMSCHelper : NSObject

@property(nonatomic, copy) FinishedRecognizer finishedRecognizerBlock;
@property(nonatomic, copy) VolumeChanged volumeChangedBlock;
@property(nonatomic, copy) RecognizerError speechErrorBlock;
@property(nonatomic, copy) RecognizerResults recognizerResult;
@property (nonatomic, assign, readonly) BOOL isSpeeching;

/**
 *  开始识别
 */
- (void)startRecognizer;
/**
 *  完成识别
 */
- (void)finishedRecognizer;

/**
 设置识别的语言类型

 @param language
 */
- (void)setRecognizerLanguage:(IFlyLanguageType)language;
@end
