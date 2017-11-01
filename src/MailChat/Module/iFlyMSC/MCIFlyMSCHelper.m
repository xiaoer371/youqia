//
//  MCIFlyMSCHelper.m
//  NPushMail
//
//  Created by wuwenyu on 16/11/8.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIFlyMSCHelper.h"


@interface MCIFlyMSCHelper()<IFlySpeechRecognizerDelegate>
/**
 *  不带界面的识别对象
 */
@property (nonatomic,strong) IFlySpeechRecognizer *iFlySpeechRecognizer;
/**
 *  录音器，用于音频流识别的数据传入
 */
@property (nonatomic,strong) IFlyPcmRecorder *pcmRecorder;
/**
 *  识别结果
 */
@property (nonatomic,strong) NSString * result;
/**
 *  是否返回BeginOfSpeech回调
 */
@property (nonatomic,assign) BOOL isBeginOfSpeech;

@end

@implementation MCIFlyMSCHelper

- (id)init {
    self  = [super init];
    if (self) {
        //初始化识别对象
        [self initRecognizer];
    }
    return self;
}

- (void)dealloc
{
    if (self.iFlySpeechRecognizer) {
        [self.iFlySpeechRecognizer cancel];
        [self.iFlySpeechRecognizer destroy];
        self.iFlySpeechRecognizer.delegate = nil;
    }
    
    if (self.pcmRecorder) {
        [self.pcmRecorder stop];
    }
}

- (void)initRecognizer {
    DDLogVerbose(@"%s",__func__);
    
    // 初始化语音设置
    [MCIFlyMSCConfig setup];
    
    //无界面
    if ([MCIFlyMSCConfig sharedInstance].haveView == NO) {
        //单例模式，无UI的实例
        if (_iFlySpeechRecognizer == nil) {
            _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
            [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
            //设置听写模式
            [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        }
        _iFlySpeechRecognizer.delegate = self;
        if (_iFlySpeechRecognizer != nil) {
            MCIFlyMSCConfig *instance = [MCIFlyMSCConfig sharedInstance];
            //设置最长录音时间
            [_iFlySpeechRecognizer setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
            //设置后端点
            [_iFlySpeechRecognizer setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
            //设置前端点
            [_iFlySpeechRecognizer setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
            //网络等待时间
            [_iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
            
            //设置采样率，推荐使用16K
            [_iFlySpeechRecognizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
            
            if ([instance.language isEqualToString:[MCIFlyMSCConfig chinese]]) {
                //设置语言
                [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
                //设置方言
                [_iFlySpeechRecognizer setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
            }else if ([instance.language isEqualToString:[MCIFlyMSCConfig english]]) {
                [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            }
            //设置是否返回标点符号
            [_iFlySpeechRecognizer setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
        }
        
        //初始化录音器
        if (_pcmRecorder == nil) {
            _pcmRecorder = [IFlyPcmRecorder sharedInstance];
        }
        [_pcmRecorder setSample:[MCIFlyMSCConfig sharedInstance].sampleRate];
        //不保存录音文件
        [_pcmRecorder setSaveAudioPath:nil];
    }
}

- (void)startRecognizer {
    DDLogVerbose(@"%s[IN]",__func__);
    _isSpeeching = YES;
    if ([MCIFlyMSCConfig sharedInstance].haveView == NO) {//无界面
        if(_iFlySpeechRecognizer == nil) {
            [self initRecognizer];
        }
        [_iFlySpeechRecognizer cancel];
        //设置音频来源为麦克风
        [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
        //设置听写结果格式为json
        [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
        //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
        [_iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        [_iFlySpeechRecognizer setDelegate:self];
        
        BOOL ret = [_iFlySpeechRecognizer startListening];
        if (ret) {
            DDLogVerbose(@"讯飞识别启动成功");
        }else{
            DDLogVerbose(@"讯飞识别启动服务失败，请稍后重试");
        }
    }
}

- (void)finishedRecognizer {
    _isSpeeching = NO;
    DDLogVerbose(@"%s",__func__);
    [_pcmRecorder stop];
    [_iFlySpeechRecognizer stopListening];
}

#pragma mark - IFlySpeechRecognizerDelegate
/**
 音量回调函数
 volume 0－30
 ****/
- (void) onVolumeChanged: (int)volume {
    if (self.volumeChangedBlock) {
        self.volumeChangedBlock(volume);
    }
}

/**
 开始识别回调
 ****/
- (void) onBeginOfSpeech {
    self.isBeginOfSpeech = YES;
    //正在录音
}

/**
 停止录音回调
 ****/
- (void) onEndOfSpeech {
    [_pcmRecorder stop];
    //停止录音
}

/**
 听写结束回调（注：无论听写是否正确都会回调）
 error.errorCode =
 0     听写正确
 other 听写出错
 ****/
- (void) onError:(IFlySpeechError *) error {
    [self finishedRecognizer];
    if ([MCIFlyMSCConfig sharedInstance].haveView == NO ) {
        NSString *text ;
        if (error.errorCode == 0 ) {
            if (_result.length == 0) {
                text = @"无识别结果";
            }else {
                text = @"识别成功";
                //清空识别结果
                _result = nil;
            }
        }else {
            text = [NSString stringWithFormat:@"讯飞识别发生错误：%d %@", error.errorCode,error.errorDesc];
            if (self.speechErrorBlock) {
                self.speechErrorBlock(error);
            }
        }
        DDLogVerbose(@"%@", text);
    }
}

/**
 无界面，听写结果回调
 results：听写结果
 isLast：表示最后一次
 ****/
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast {
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    NSString *resultFromJson =  [MCIFlyMSCDataHelper stringFromJson:resultString];
    if (self.recognizerResult) {
        self.recognizerResult(resultFromJson);
    }
    if (!_result) {
        _result = @"";
    }
    _result =[NSString stringWithFormat:@"%@%@", _result, resultFromJson];
    if (isLast) {
        [self finishedRecognizer];
        if (self.finishedRecognizerBlock) {
            self.finishedRecognizerBlock();
        }
        DDLogVerbose(@"识别结束%@", _result);
        if (self.volumeChangedBlock) {
            self.volumeChangedBlock(0);
        }
    }
}

- (void)setRecognizerLanguage:(IFlyLanguageType)language {
    NSString *languageValue = @"zh_cn";
    NSString *accent = @"mandarin";
    switch (language) {
        case CHINESE:{
            languageValue = [IFlySpeechConstant LANGUAGE_CHINESE];
            accent = [IFlySpeechConstant ACCENT_MANDARIN];
            break;
        }
        case YUEYU: {
            languageValue = [IFlySpeechConstant LANGUAGE_CHINESE];
            accent = [IFlySpeechConstant ACCENT_CANTONESE];
            break;
        }
        case ENGLISH: {
            languageValue = [IFlySpeechConstant LANGUAGE_ENGLISH];
            accent = [IFlySpeechConstant ACCENT_CANTONESE];
            break;
        }
        default:
            break;
    }
    //设置语言
    [_iFlySpeechRecognizer setParameter:languageValue forKey:[IFlySpeechConstant LANGUAGE]];
    if (language != ENGLISH) {
        //设置方言
        [_iFlySpeechRecognizer setParameter:accent forKey:[IFlySpeechConstant ACCENT]];
    }
}

@end
