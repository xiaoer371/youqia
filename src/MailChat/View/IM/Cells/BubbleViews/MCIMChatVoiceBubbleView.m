//
//  MCIMChatVoiceBubbleView.m
//  NPushMail
//
//  Created by swhl on 16/2/23.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMChatVoiceBubbleView.h"
#import "MCIMChatVoicePlayer.h"
#import "MCIMChatFileManager.h"
#import "VoiceConverter.h"


NSString *const kRouterEventAudioBubbleTapEventName = @"kRouterEventAudioBubbleTapEventName";
NSString *const kRouterEventAudioBubblePlayNext = @"kRouterEventAudioBubblePlayNext";

@interface MCIMChatVoiceBubbleView ()<MCIMChatVoicePlayerDelegate>
{
    NSArray *_senderAnimationImages;
    NSArray *_recevierAnimationImages;
    UIImageView    *_isReadView;
    MCIMChatVoicePlayer *_audio;
}

@end

@implementation MCIMChatVoiceBubbleView

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ANIMATION_IMAGEVIEW_SIZEW, ANIMATION_IMAGEVIEW_SIZEH)];
        _animationImageView.animationDuration = ANIMATION_IMAGEVIEW_SPEED;
        [self addSubview:_animationImageView];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ANIMATION_TIME_LABEL_WIDHT, ANIMATION_TIME_LABEL_HEIGHT)];
        _timeLabel.font = [UIFont boldSystemFontOfSize:ANIMATION_TIME_LABEL_FONT_SIZE];
        _timeLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_timeLabel];
        
        _isReadView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _isReadView.layer.cornerRadius = 5;
        [_isReadView setClipsToBounds:YES];
        [_isReadView setBackgroundColor:[UIColor redColor]];
        [self addSubview:_isReadView];
        
        _senderAnimationImages = @[AppStatus.theme.outgoingBubbleStyle.voiceMini1,
                                   AppStatus.theme.outgoingBubbleStyle.voiceMini2,
                                   AppStatus.theme.outgoingBubbleStyle.voiceMini3];
        
        _recevierAnimationImages = @[AppStatus.theme.incomingBubbleStyle.voiceMini1,
                                     AppStatus.theme.incomingBubbleStyle.voiceMini2,
                                     AppStatus.theme.incomingBubbleStyle.voiceMini3];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VoicePlayChange) name:@"VoicePlayChange" object:nil];
       
    }
    return self;
}

//-(CGSize)sizeThatFits:(CGSize)size
//{
//    CGFloat height = 40;
//    MCIMVoiceModel *voiceModel = (MCIMVoiceModel*)self.model;
//    
//    CGFloat wf = MAX(50+voiceModel.seconds*5, 60);
//    CGFloat  width = wf>200?200:wf;
//    return CGSizeMake(width, height);
//}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = _timeLabel.frame;
    if (self.model.isSender) {
        frame.origin.x = self.frame.size.width - frame.size.width -14;
        frame.origin.y = self.frame.size.height / 2 - frame.size.height / 2;
        _timeLabel.frame = frame;
        
        frame = _animationImageView.frame;
        frame.origin.x = CGRectGetMinX(self.backImageView.frame)+10;
        frame.origin.y = _timeLabel.center.y - frame.size.height / 2;
        _animationImageView.frame = frame;
        
    }
    else {
        _animationImageView.image =  AppStatus.theme.incomingBubbleStyle.voiceMini3;
        
        frame.origin.x = 14;
        frame.origin.y = self.frame.size.height / 2 - frame.size.height / 2;
        _timeLabel.frame = frame;
        
        frame = _animationImageView.frame;
        frame.origin.x = CGRectGetMaxX(self.backImageView.frame) - 25;
        frame.origin.y = _timeLabel.center.y - frame.size.height / 2;
        _animationImageView.frame = frame;
        
        
        frame.origin.x = CGRectGetMaxX(self.backImageView.frame)+10;
        frame.origin.y = CGRectGetMidY(self.backImageView.frame)-3;
        frame.size = _isReadView.frame.size;
        _isReadView.frame = frame;
    }
}

#pragma mark - setter

- (void)setModel:(MCIMMessageModel *)model
{
    [super setModel:model];
    MCIMVoiceModel *voiceModel = (MCIMVoiceModel*)model;
    _timeLabel.text = [NSString stringWithFormat:@"%.f\"",voiceModel.seconds];
    
    if (self.model.isSender) {
        [_isReadView setHidden:YES];
        _animationImageView.image =  AppStatus.theme.outgoingBubbleStyle.voiceMini3;
        _animationImageView.animationImages = _senderAnimationImages;
        _timeLabel.textColor =[UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentRight;

    }
    else{
        if (model.isRead) {
            [_isReadView setHidden:YES];
        }else{
            [_isReadView setHidden:NO];
        }
        
        _timeLabel.textColor =[UIColor lightGrayColor];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        _animationImageView.image =  AppStatus.theme.incomingBubbleStyle.voiceMini3;
        _animationImageView.animationImages = _recevierAnimationImages;
    }

    [self reSetSubViewsFrame];
    
}
- (void)reSetSubViewsFrame
{
    CGFloat height = 40;
    MCIMVoiceModel *voiceModel = (MCIMVoiceModel*)self.model;
    CGFloat wf = MAX(50+voiceModel.seconds*5, 60);
    CGFloat  width = wf>200?200:wf;
    self.mc_size = CGSizeMake(width, height);

}

//#pragma mark - public
//- (void)onLongTap:(id)sender
//{
//    // 重写父类   不实现
//}

-(void)bubbleViewPressed:(id)sender
{
    [self routerEventWithName:kRouterEventAudioBubbleTapEventName userInfo:@{KMESSAGEKEY:self.model}];
    
    if ([_animationImageView isAnimating]) {
       [[MCIMChatVoicePlayer sharedInstance] stopSound];
        [self stopAudioAnimation];
        return;
    }
    
    [_isReadView setHidden:YES];
    MCIMVoiceModel *model = (MCIMVoiceModel *)self.model;
    
    if(!model.data){
        model.data = [MCIMChatFileManager wavDataWithFileName:model.localPath];
    }
    
    _audio = [MCIMChatVoicePlayer sharedInstance];
    _audio.delegate = self;
    [_audio playSongWithData:model.data];
}

#pragma mark - UUAVAudioplayer
- (void)voicePlayerBeiginLoadVoice
{
    [self startAudioAnimation];
}

- (void)voicePlayerBeiginPlay
{
    [self startAudioAnimation];
}

- (void)voicePlayerDidFinishPlay
{
    [self stopAudioAnimation];
    [[MCIMChatVoicePlayer sharedInstance] stopSound];

    [self routerEventWithName:kRouterEventAudioBubblePlayNext userInfo:@{KMESSAGEKEY:self.model}];
}

- (void)VoicePlayChange
{
    [self stopAudioAnimation];
    [[MCIMChatVoicePlayer sharedInstance] stopSound];
}

+(CGFloat)heightForBubbleWithObject:(MCIMMessageModel *)object
{
    CGFloat height = object.isSender?0:20;
    return 52 + height;
}

-(void)startAudioAnimation
{
    [_animationImageView startAnimating];
}

-(void)stopAudioAnimation
{
    [_animationImageView stopAnimating];
}


@end
