//
//  MCIMChatVoicePlayer.m
//  NPushMail
//
//  Created by swhl on 16/4/29.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMChatVoicePlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface MCIMChatVoicePlayer () <AVAudioPlayerDelegate>
{
    AVAudioPlayer *avplayer;
}
@property (nonatomic,strong)AVAudioSession *audioSession;

@end

@implementation MCIMChatVoicePlayer

+ (MCIMChatVoicePlayer *)sharedInstance
{
    static MCIMChatVoicePlayer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.audioSession =[AVAudioSession sharedInstance];
        //添加监听
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorStateChange:)
                                                     name: UIDeviceProximityStateDidChangeNotification
                                                   object:nil];
    }
    return self;
}
//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电）
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];
    }
    else
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];
    }
}

-(void)playSongWithData:(NSData *)songData
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VoicePlayChange" object:nil];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if (avplayer) {
        [avplayer stop];
        avplayer.delegate = nil;
        avplayer = nil;
    }
    NSError *playerError;
    avplayer = [[AVAudioPlayer alloc]initWithData:songData error:&playerError];
    avplayer.volume = 1.0f;
    
    //初始化播放器的时候如下设置
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            sizeof(sessionCategory),
                            &sessionCategory);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride);
    
    
    //默认情况下扬声器播放
    [self.audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];
    
    [self.audioSession setActive:YES error:nil];
    
    avplayer.delegate = self;
    [avplayer play];
    [self.delegate voicePlayerBeiginPlay];
    
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
     [self.delegate voicePlayerDidFinishPlay];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.delegate voicePlayerDidFinishPlay];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}

- (void)stopSound
{
    if (avplayer && avplayer.isPlaying) {
        [avplayer stop];
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    }
}


@end
