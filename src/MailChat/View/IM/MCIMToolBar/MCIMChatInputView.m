//
//  MCIMChatInputView.m
//  NPushMail
//
//  Created by swhl on 16/2/26.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMChatInputView.h"
#import "MCIMVoiceHUD.h"
#import <AVFoundation/AVFoundation.h>
#import "UITextView+ExtentRange.h"
#import "MCIMChatMoreView.h"
#import "MCIMInputFaceView.h"
//图片多选
#import "QBImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
//file
#import "MCFileManagerViewController.h"
#import "MCBaseNavigationViewController.h"
#import "MCIMChatViewController.h"

#import "VoiceConverter.h"
#import "GTMBase64.h"
#import "MCUDID.h"
#import "MCIMChatFileManager.h"
#import "UIImage+Utility.h"
#import "MCAvailablePhotoViewController.h"
#import "JPSImagePickerController.h"
#import "DNImagePickerController.h"
#import "DNAsset.h"


const static NSInteger   kMailChatWPadding = 8;
const static NSInteger   kMailChatHPadding = 7;
const static NSInteger   kMailChatSizeButton = 36;
const static NSInteger   kMailChatButtonTAG = 100;
const static NSInteger   kMailChatInputViewToolbarHeight  = 50;

const static NSInteger   kMailChatFaceViewHeight = 216;  //表情view 高度
const static NSInteger   kMailChatMoreViewHeight = 103;  //更多view 高度

#define INPUT_HEIGHT 35.0f
@interface MCIMChatInputView ()<UITextViewDelegate,MCIMChatMoreViewDelegate,MCIMInputFaceViewDelegate,QBImagePickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,JPSImagePickerDelegate,DNImagePickerControllerDelegate,AVAudioRecorderDelegate,keyInputTextFieldDelegate>
{
    //录音相关
    NSMutableDictionary   *_recordSetting;
    AVAudioRecorder       *_recorder;
    bool                  _isRecording;
    NSString              *_soundFilePath;
    long                  _recordStartTime;
    NSTimer               *_playTimer;
    NSTimer                *_metersTimer;
    UIPageControl         *_pageControl;
}

@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, strong) UIButton *voiceBtn;
@property (nonatomic, strong) UIButton *recordBtn;
@property (nonatomic, strong) UIButton *faceBtn;
@property (nonatomic, strong) UIButton *moreBtn;
@property (nonatomic, strong) MCIMChatMoreView   *moreView;
@property (nonatomic, strong) MCIMInputFaceView  *faceView;
@property (nonatomic, strong) NSArray *plistFaces;
@property (nonatomic, strong) NSMutableString *sendStr;
@property (nonatomic) CGRect voiceRect;
@property (nonatomic) CGRect keyboardRect;

@end

@implementation MCIMChatInputView

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.inputTextView removeObserver:self forKeyPath:@"contentSize" context:nil];
}

- (instancetype)initWithViewControll:(UIViewController *)viewController
{
    CGRect rect = CGRectMake(0, ScreenHeigth-kMailChatInputViewToolbarHeight-NAVIGATIONBARHIGHT, ScreenWidth, kMailChatInputViewToolbarHeight);
    self = [super initWithFrame:rect];
    if (self) {
        self.exclusiveTouch = YES;
        self.backgroundColor = AppStatus.theme.chatStyle.chatToolBarBackColor;
        self.viewController = viewController;
        self.viewController.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan=NO;
        [self _initSubViews];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];

        
        [self.inputTextView addObserver:self
                             forKeyPath:@"contentSize"
                                options:NSKeyValueObservingOptionNew
                                context:nil];

        self.voiceRect =  rect;
        
    }
    return self;

}
#pragma mark -KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == self.inputTextView && [keyPath isEqualToString:@"contentSize"]) {
        if ([self.delegate respondsToSelector:@selector(layoutAndAnimateMessageInputTextView:)]) {
            [self.delegate layoutAndAnimateMessageInputTextView:object];
            self.voiceRect = self.frame;
        }
    }
}

#pragma mark - KeyBoard 
-(void)keyboardWillChangeFrame:(NSNotification *)notification{
    
    if (![self isCurrentSuperVC] ) return;
    
    CGFloat animationTime = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    _keyboardRect =keyBoardFrame;
    [UIView animateWithDuration:animationTime animations:^{
        
        CGRect rect = self.frame;
        
        if (keyBoardFrame.origin.y == ScreenHeigth) {
//            rect.origin.y = ScreenHeigth-rect.size.height;
//            self.frame = rect;
        }else{
            rect.origin.y = ScreenHeigth-keyBoardFrame.size.height-rect.size.height-NAVIGATIONBARHIGHT;
            self.frame = rect;
        }
    }];
    
}

-(void)keyboardWillShow:(NSNotification *)notification
{
     if (![self isCurrentSuperVC] ) return;
    _faceBtn.selected = NO;
    _moreBtn.selected = NO;
    _faceView.hidden = YES;
    _moreView.hidden = YES;
    
}

-(void)keyboardWillHide:(NSNotification *)notification{

    if (![self isCurrentSuperVC]) return;
    _faceBtn.selected = (_faceView && ![_faceView isHidden])?YES:NO;
    
    if (!_faceBtn.selected && !_moreBtn.selected) {
        if (self.delegate &&[self.delegate respondsToSelector:@selector(inputTextHiddenKeyboard:)]) {
            [self.delegate inputTextHiddenKeyboard:self.inputTextView];
        }
    }
}

#pragma mark - initSubViews
-(void)_initSubViews
{
    self.layer.borderWidth = 1;
    self.layer.borderColor = [[UIColor colorWithHexString:@"d8d8d8"] CGColor];
    
    [self addSubview:self.voiceBtn];
    [self addSubview:self.inputTextView];
    [self addSubview:self.faceBtn];
    [self addSubview:self.moreBtn];
    [self addSubview:self.recordBtn];
    
}

-(void)buttonActions:(UIButton*)sender
{
    sender.selected = !sender.selected;
    switch (sender.tag) {
        case kMailChatButtonTAG:
        {
        
            _inputTextView.hidden =  sender.selected;
            _recordBtn.hidden = !sender.selected;
            if (sender.selected) {
                [_inputTextView resignFirstResponder];
                self.voiceRect = self.frame;
                 [UIView animateWithDuration:0.25 animations:^{
                     self.frame = CGRectMake(0, ScreenHeigth - kMailChatInputViewToolbarHeight -NAVIGATIONBARHIGHT, ScreenWidth, kMailChatInputViewToolbarHeight);
                 }];
                _faceView.hidden = YES;
                _faceView.frame =CGRectMake(0,ScreenHeigth-NAVIGATIONBARHIGHT, ScreenWidth, kMailChatFaceViewHeight);
                _faceBtn.selected = NO;
                _moreView.hidden = YES;
                _moreView.frame = CGRectMake(0, ScreenHeigth-NAVIGATIONBARHIGHT, ScreenWidth, kMailChatMoreViewHeight);
                _moreBtn.selected = NO;
                
            }else{
                [_inputTextView becomeFirstResponder];
                [UIView animateWithDuration:0.25 animations:^{
                    CGRect rect  = self.voiceRect;
                    rect.origin.y = ScreenHeigth-_keyboardRect.size.height-self.voiceRect.size.height-NAVIGATIONBARHIGHT;
                    self.frame = rect;
                }];
            }
        }
            break;
        case kMailChatButtonTAG+1:
        {
            if (!_faceView) {
                [self.viewController.view addSubview:self.faceView];
            }
            _faceView.hidden = !sender.selected;
            _voiceBtn.selected = NO;
            _inputTextView.hidden = NO;
            _recordBtn.hidden = YES;
            _moreBtn.selected = NO;
            _moreView.hidden = YES;
            _moreView.frame = CGRectMake(0, ScreenHeigth-NAVIGATIONBARHIGHT, ScreenWidth, kMailChatMoreViewHeight);
            if (sender.selected) {
                [_inputTextView resignFirstResponder];
                [UIView animateWithDuration:0.25 animations:^{
                    CGRect rect = self.voiceRect;
                    rect.origin.y = ScreenHeigth - kMailChatFaceViewHeight- rect.size.height-NAVIGATIONBARHIGHT;
                    self.frame = rect;
                    _faceView.frame =CGRectMake(0,ScreenHeigth-kMailChatFaceViewHeight-NAVIGATIONBARHIGHT, ScreenWidth, kMailChatFaceViewHeight);
                }];
               
            }else{
                [_inputTextView becomeFirstResponder];
            }
        }
            break;
        case kMailChatButtonTAG+2:
        {
            if (!_moreView) {
                [self.viewController.view addSubview:self.moreView];
            }
            _moreView.hidden = !sender.selected;
            
            if (self.delegate &&[self.delegate respondsToSelector:@selector(didSelectMoreButtonActtion:)]) {
                [self.delegate didSelectMoreButtonActtion:_moreView.hidden];
            }
            _faceView.hidden = YES;
            _faceView.frame =CGRectMake(0,ScreenHeigth-NAVIGATIONBARHIGHT, ScreenWidth, kMailChatFaceViewHeight);
            _voiceBtn.selected = NO;
            _inputTextView.hidden = NO;
            _recordBtn.hidden = YES;
            _faceBtn.selected = NO;
            if (sender.selected) {
                [_inputTextView resignFirstResponder];
                [UIView animateWithDuration:0.25 animations:^{
                    CGRect rect = self.voiceRect;
                    rect.origin.y = ScreenHeigth - kMailChatMoreViewHeight- rect.size.height-NAVIGATIONBARHIGHT;
                    self.frame = rect;
                    _moreView.frame = CGRectMake(0, ScreenHeigth-kMailChatMoreViewHeight-NAVIGATIONBARHIGHT, ScreenWidth, kMailChatMoreViewHeight);
                }];
            }else{
                [_inputTextView becomeFirstResponder];
             }
        }
            break;
        default:
            break;
    }
}
-(void)dismissKeyboardWithscrollSelectItem
{
    [UIView animateWithDuration:0.25 animations:^{
        _faceView.frame =CGRectMake(0,ScreenHeigth-NAVIGATIONBARHIGHT, ScreenWidth, kMailChatFaceViewHeight);
        _moreView.frame = CGRectMake(0, ScreenHeigth-NAVIGATIONBARHIGHT, ScreenWidth, kMailChatMoreViewHeight);

    } completion:^(BOOL finished) {
        if (finished){
            _faceBtn.selected = NO;
            _moreBtn.selected = NO;
            _faceView.hidden = YES;
            _moreView.hidden = YES;
        }
    }];

}

#pragma mark - keyInputTextFieldDelegate
//键盘删除键处理
- (void)deleteBackward
{
    [self deleteEmojiStringActionIsKeyBoard:YES];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        if ([textView.text trim].length == 0) {
            [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_IMChat_NullMessage")];
            return NO;
        }
        if ([textView.text isEqualToString:@""]) {
            return NO;
        }
        NSString *resultStr = [self.inputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([self.delegate respondsToSelector:@selector(chatInputView:sendMessage:)]) {
            [self.delegate chatInputView:self sendMessage:resultStr];
        }
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    //键盘删除键处理
    if ([text isEqualToString:@""]) {
        // [self deleteEmojiStringActionIsKeyBoard:YES];
    }
    return YES;
}
- (void)textViewDidBeginEditing:(MCChatTextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(inputTextViewDidBeginEditing:)]) {
        [self.delegate inputTextViewDidBeginEditing:self.inputTextView];
    }
}

#pragma mark - MCIMChatFaceViewDelegate
-(void)didSelectFaceStr:(NSString*)str
{
    NSRange rang =[self.inputTextView selectedRange];
    [self.sendStr setString:self.inputTextView.text];
    NSRange newRang;
    [self.sendStr insertString:str atIndex:rang.location];
    [self.inputTextView setText:self.sendStr];
    newRang = NSMakeRange(rang.location+ str.length, 0);
    [self.inputTextView setSelectedRange:newRang];
    [self.sendStr setString:@""];
}

-(void)didSendMessage:(id)sender
{
    NSString *resultStr = [self.inputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([resultStr isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:PMLocalizedStringWithKey(@"PM_IMChat_NullMessage")];
        return ;
    }
    
    if ([self.delegate respondsToSelector:@selector(chatInputView:sendMessage:)]) {
        [self.delegate chatInputView:self sendMessage:resultStr];
    }
}

-(void)didDeleteFaceStr:(NSString *)str
{
    [self deleteEmojiStringActionIsKeyBoard:NO];
}

/**
 *  删除表情，
 *  @param keyboard 是否是键盘删除按钮
 */
- (void) deleteEmojiStringActionIsKeyBoard:(BOOL)keyboard {
//    NSString *souceText = self.inputTextView.text;
    NSRange range = [self.inputTextView selectedRange];
    [self.sendStr setString:self.inputTextView.text];
    NSRange delRang;
    
    if (range.location == NSNotFound) {
        range.location = self.inputTextView.text.length;
    }
    
    if (range.length > 0) {
        delRang=NSMakeRange(range.location, 0);
        [self.inputTextView setSelectedRange:delRang];
        return;
    }else{
        //正则匹配要替换的文字的范围
        NSString * pattern = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
        NSError *error = nil;
        NSRegularExpression * re = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        if (!re) {
            DDLogVerbose(@"%@", [error localizedDescription]);
        }
      
        //删除文字判断是否是"]",表情开始
        NSString *handleStr =[self.sendStr substringWithRange:NSMakeRange(0, range.location)];
        BOOL isEmojiStr = NO;
        if (handleStr.length>0) {
            NSString *tempStr = [handleStr substringFromIndex:[handleStr length]-1];
            isEmojiStr = [tempStr isEqualToString:@"]"];
        }
        
        //通过正则表达式来匹配字符串
        NSArray *resultArray = [re matchesInString:self.sendStr options:0 range:NSMakeRange(0,range.location)];
        NSTextCheckingResult *checkingResult = resultArray.lastObject;
       
        for (NSString *faceName in self.plistFaces)
        {
            if ([self.sendStr hasSuffix:@"]"] && isEmojiStr) {
                if ([[self.sendStr substringWithRange:checkingResult.range] isEqualToString:faceName]) {
                    if (keyboard) {
                        [self.sendStr deleteCharactersInRange:NSMakeRange(checkingResult.range.location,checkingResult.range.length-1)];
                    }else{
                        [self.sendStr deleteCharactersInRange:NSMakeRange(checkingResult.range.location,checkingResult.range.length)];
                    }
                    
                    self.inputTextView.text = self.sendStr;
                    if (keyboard) {
                        delRang = NSMakeRange(range.location - checkingResult.range.length+1, 0);
                    }else{
                        delRang = NSMakeRange(range.location - checkingResult.range.length, 0);
                    }
                    [self.inputTextView setSelectedRange:delRang];
                    [self.sendStr setString:@""];
                    return;
                }
            }else{
                if (keyboard) {
                    delRang = NSMakeRange(range.location, 0);
                }else{
                    delRang = NSMakeRange(range.location-1, 0);
                }
                [self.inputTextView setSelectedRange:delRang];
                return;
            }
        }
    }
}

#pragma mark - textview高度变化处理
//动态改变高度,changeInHeight 目标变化的高度
- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight {
    CGRect prevFrame = self.inputTextView.frame;
    self.inputTextView.frame = CGRectMake(prevFrame.origin.x,
                                          prevFrame.origin.y,
                                          prevFrame.size.width,
                                          prevFrame.size.height + changeInHeight);
    self.inputTextView.scrollEnabled = YES;
    
}

//获取根据最大行数和每行高度计算出来的最大显示高度
+ (CGFloat)maxHeight {
    return ([self maxLines] + 1.0f) * [self textViewLineHeight];
}
//设置可输入的最大行数
+ (CGFloat)maxLines {
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 2.0f : 2.0f;
}
+ (CGFloat)textViewLineHeight {
    return INPUT_HEIGHT;  // for fontSize 16.0f
}
#pragma mark - 语音部分
-(void)soundStart
{
    
     _isRecording = YES;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDuckOthers error:&err];
    if(err){
        DDLogVerbose(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err){
        DDLogVerbose(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    if(!_recordSetting){
        _recordSetting = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                         [NSNumber numberWithFloat: 8000.0],AVSampleRateKey, //采样率
                         [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                         [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//采样位数 默认 16
                         [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,//通道的数目
                         //                                   [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,//大端还是小端 是内存的组织方式
                         //                                   [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,//采样信号是整数还是浮点数
                         [NSNumber numberWithInt: AVAudioQualityMin],AVEncoderAudioQualityKey,//音频编码质量
                         nil];
    }
    NSString *voiceName = [MCUDID newUUID];;
    _soundFilePath = [MCIMChatFileManager voicePathWithFileName:[voiceName stringByAppendingFormat:@".wav"]];
    NSURL *url = [NSURL fileURLWithPath:_soundFilePath];
    err = nil;
    _recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:_recordSetting error:&err];
    if(!_recorder){
        DDLogVerbose(@"recorder: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: [err localizedDescription]
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
        return;
    }
    //prepare to record
    [_recorder setDelegate:self];
    [_recorder prepareToRecord];
    _recorder.meteringEnabled = YES;
//    BOOL audioHWAvailable = audioSession.inputIsAvailable;
//    if (! audioHWAvailable) {
//        [self checkAudioHardware];
//        return;
//    }
    [_recorder record];
    
}


/**
 *  inputIsAvailable 检查 录音硬件是否可用  iOS6.0弃用
 */
- (void)checkAudioHardware
{
    UIAlertView *cantRecordAlert =
    [[UIAlertView alloc] initWithTitle: @"Warning"
                               message: @"Audio input hardware not available"
                              delegate: nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil];
    [cantRecordAlert show];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
    if(_recordStartTime >= 1 /*&& timeInterval > 1000 */){
 
    }else{
        NSString* soundFile = _soundFilePath;
        NSError *err;
        NSString* amrFile = [soundFile stringByReplacingOccurrencesOfString:@".wav" withString:@".amr"];
        [[NSFileManager defaultManager] removeItemAtPath:soundFile error:&err];
        [[NSFileManager defaultManager] removeItemAtPath:amrFile error:&err];
        
    }
    _recordStartTime = 0;
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)arecorder error:(NSError *)error
{
    UIAlertView *recorderFailed = [[UIAlertView alloc] initWithTitle:@"" message:@"发生错误"
                                                            delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [recorderFailed show];
}

-(BOOL) saveSoundToAttachment
{
    if(!_soundFilePath){
        return NO;
    }
    //转格式
    NSString* soundFile = _soundFilePath;
    NSString* amrFile = [soundFile stringByReplacingOccurrencesOfString:@".wav" withString:@".amr"];
    if([VoiceConverter wavToAmr:soundFile amrSavePath:amrFile] != 0){
        return NO;
    } else {
        return YES;
    }
}


-(void)recordButtonTouchDown
{
    DDLogVerbose(@"开始 录音");
    if (![self canRecord])
    {
        [self showNoPermission];
        return;
    }

    [self soundStart];
    _recordStartTime = 0;
    _playTimer = nil;
    _playTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(countVoiceTime)
                                                userInfo:nil
                                                 repeats:YES];
    
    [self startTimerWithDetectionVoice:YES];
    
    [MCIMVoiceHUD show];
    
}

- (void)detectionVoice
{
    [_recorder updateMeters];//刷新音量数据
    //获取音量的平均值  [recorder averagePowerForChannel:0];
    //音量的最大值  [recorder peakPowerForChannel:0];
    double lowPassResults = pow(10, (0.05 * [_recorder peakPowerForChannel:0]));
    [MCIMVoiceHUD refreshMeters:lowPassResults];
}

-(void)countVoiceTime
{
    _recordStartTime++;
    if (_recordStartTime >= 60) {
        _recordBtn.selected = NO;
        [self recordButtonTouchUpInside];
    }
}

-(void)recordButtonTouchUpOutside
{
    DDLogVerbose(@"上划 取消录音");
    
    if(_isRecording){
        [_recorder stop];
        _isRecording = NO;
        _recorder = nil;
        [_playTimer invalidate];
        _playTimer = nil;
        [_metersTimer invalidate];
        _metersTimer = nil;
    }
    
    [MCIMVoiceHUD dismissWithError:@"取消"];
    
    //删除文件
    [[NSFileManager defaultManager ] removeItemAtPath:_soundFilePath error:nil];
}

-(void)recordButtonTouchUpInside
{
    DDLogVerbose(@"结束 录音");
    if(_isRecording ){
        [_recorder stop];
        _isRecording = NO;
        _recorder = nil;
        [_playTimer invalidate];
        _playTimer = nil;
        [_metersTimer invalidate];
        _metersTimer = nil;
    }
    
    BOOL recordsuc = [self saveSoundToAttachment];
    if (recordsuc &&  _recordStartTime >= 1) {
        [MCIMVoiceHUD dismissWithError:@"录音 完成"];
        NSString *newFile =[_soundFilePath stringByReplacingOccurrencesOfString:@".wav" withString:@".amr"];
        NSData *voiceData =[NSData dataWithContentsOfFile:newFile];
        
        NSArray *array =[newFile componentsSeparatedByString:@"/"];
        NSString *voiceName =[array lastObject];
        long time = MIN(_recordStartTime+1, 60);
        //设置回调
        if (self.delegate &&[self.delegate respondsToSelector:@selector(chatInputView:sendVoice:time:name:)]) {
            [self.delegate chatInputView:self sendVoice:voiceData time:time name:voiceName];
        }
        _recordStartTime = 0;
        
    }else{
        [MCIMVoiceHUD dismissWithError:@"时间太短,录音失败"];
    }

}

-(void)recordDragOutside
{
    DDLogVerbose(@"手指离开按钮范围");
    [self startTimerWithDetectionVoice:NO];
    [MCIMVoiceHUD changeSubTitle:@"手指松开,取消发送"];
}

-(void)recordDragInside
{
    DDLogVerbose(@"手指回到按钮范围");
     [self startTimerWithDetectionVoice:YES];
    [MCIMVoiceHUD changeSubTitle:@"手指上滑,取消发送"];
}

- (void)startTimerWithDetectionVoice:(BOOL)isDetection
{
    if (_metersTimer){
        [_metersTimer invalidate];
        _metersTimer = nil;
    }
    if (isDetection) {
        _metersTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
    }
}


- (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance] recordPermission];
        switch (permissionStatus) {
            case AVAudioSessionRecordPermissionUndetermined:{
                DDLogVerbose(@"第一次 系统弹框");
                [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                    if (granted) {
                    }
                    else {
                    }
                }];
                break;
            }
            case AVAudioSessionRecordPermissionDenied:
                DDLogVerbose(@"已经拒绝麦克风弹框");
                bCanRecord = NO;
                break;
            case AVAudioSessionRecordPermissionGranted:
                DDLogVerbose(@"已经允许麦克风弹框");
                bCanRecord = YES;
                break;
            default:
                break;
        }
        return bCanRecord;
    }else{
//        iOS 7
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted) {
                    bCanRecord = YES;
                } else {
                    bCanRecord = NO;
                }
            }];
        }
        return bCanRecord;
    }
}

- (void)showNoPermission
{
    [[[UIAlertView alloc] initWithTitle:nil
                                message:@"无麦克风访问权限。\n请启用麦克风-设置/隐私/麦克风"
                               delegate:self
                      cancelButtonTitle:@"取消"
                      otherButtonTitles:@"设置",nil] show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==alertView.cancelButtonIndex) {
        return;
    }
    //跳转到 系统 麦克风设置界面
    if (EGOVersion_iOS10) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=privacy&path=Microphoto"]];
    }
}


-(NSMutableString *)sendStr
{
    if (!_sendStr) {
        _sendStr = [NSMutableString stringWithCapacity:0];
    }
    return _sendStr;
}

#pragma mark - MCIMChatMoreViewDelegate
- (void)didSelectPhotos
{
    [self openQB_imagePickerController];
}

- (void)didSelectTakePhotos
{
    [self addCarema];
}

- (void)didSelectFile
{
    __weak MCIMChatInputView *week = self;
    MCFileManagerViewController *fileManagerViewController = [[MCFileManagerViewController alloc]initWithFromType:MCFileCtrlFromMail selectedFileBlock:^(id models) {
        NSArray*files = (NSArray*)models;
        
        if ([week.delegate respondsToSelector:@selector(chatInputView:sendFiles:)]) {
            [week.delegate chatInputView:self sendFiles:files];
        }
    }];
    MCBaseNavigationViewController *navigationController = [[MCBaseNavigationViewController alloc]initWithRootViewController:fileManagerViewController];
    [self.viewController presentViewController:navigationController animated:YES completion:nil];

}
- (void)didSendLogFileToHelper
{
    if ([self.delegate respondsToSelector:@selector(sendLogToHelper)]) {
        [self.delegate sendLogToHelper];
    }
}

#pragma mark -addCarema   摄像头
-(void)addCarema{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied)
        {
            [self availablePhoto];
            return;
        }
        
        JPSImagePickerController *imagePicker = [[JPSImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.flashlightEnabled = NO;
        [self.viewController presentViewController:imagePicker animated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        }];
        
    }else{
        //如果没有提示用户
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tip" message:@"Your device don't have camera" delegate:nil cancelButtonTitle:PMLocalizedStringWithKey(@"PM_Common_Sure") otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - JPSImagePickerControllerDelegate
- (void)picker:(JPSImagePickerController *)picker didConfirmPicture:(UIImage *)picture {
    
    [SVProgressHUD showWithStatus:PMLocalizedStringWithKey(@"PM_Msg_MessageSending") maskType:SVProgressHUDMaskTypeClear];
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
       
        [SVProgressHUD dismiss];
        //友盟统计
        [MCUmengManager addEventWithKey:mc_im_takePhoto];
        if ([self.delegate respondsToSelector:@selector(chatInputView:sendPictures:)]) {
            [self.delegate chatInputView:self sendPictures:@[picture]];
        }
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [self dismissImagePickerController];
    });
}

- (void)pickerDidCancel:(JPSImagePickerController *)picker {
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissImagePickerController];
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [SVProgressHUD showWithStatus:PMLocalizedStringWithKey(@"PM_Msg_MessageSending") maskType:SVProgressHUDMaskTypeClear];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *editImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            //友盟统计
            [MCUmengManager addEventWithKey:mc_im_takePhoto];
            [self dismissImagePickerController];

            if ([self.delegate respondsToSelector:@selector(chatInputView:sendPictures:)]) {
                [self.delegate chatInputView:self sendPictures:@[editImage]];
            }
        });
    });
}

#pragma mark - openQB_imagePickerController
-(void)openQB_imagePickerController
{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied){
        //无权限
        [self availablePhoto];
    
    }else{
        
        DNImagePickerController *imagePicker = [[DNImagePickerController alloc] init];
        imagePicker.filterType = DNImagePickerFilterTypePhotos;
        imagePicker.imagePickerDelegate = self;
        imagePicker.maxNumber = 9;
        [self.viewController.navigationController presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark - DNImagePickerControllerDelegate

- (void)dnImagePickerController:(DNImagePickerController *)imagePicker
                     sendImages:(NSArray *)imageAssets
                    isFullImage:(BOOL)fullImage
{
    if (imageAssets.count<1){
        return;
    }
    [SVProgressHUD showWithStatus:PMLocalizedStringWithKey(@"PM_Msg_MessageSending") maskType:SVProgressHUDMaskTypeClear];
    __block MCIMChatInputView * weekSelf = self;
    ALAssetsLibrary *lib = [ALAssetsLibrary new];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //
        for (DNAsset *dnAsset in imageAssets) {
            [lib assetForURL:dnAsset.url resultBlock:^(ALAsset *asset){
                if (asset) {
                    [weekSelf assets:@[asset] isFullImage:fullImage];
                } else {
                    // On iOS 8.1 [library assetForUrl] Photo Streams always returns nil. Try to obtain it in an alternative way
                    [lib enumerateGroupsWithTypes:ALAssetsGroupPhotoStream
                                       usingBlock:^(ALAssetsGroup *group, BOOL *stop)
                     {
                         [group enumerateAssetsWithOptions:NSEnumerationReverse
                                                usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                                    
                                                    if([[result valueForProperty:ALAssetPropertyAssetURL] isEqual:dnAsset.url])
                                                    {
                                                        [weekSelf assets:@[result] isFullImage:fullImage];
                                                        *stop = YES;
                                                    }
                                                }];
                        }
                                     failureBlock:^(NSError *error)
                     {
                         [SVProgressHUD dismiss];
                     }];
                }
                
            } failureBlock:^(NSError *error){
                [SVProgressHUD dismiss];
            }];
        }
    });
}

- (void)assets:(NSArray <ALAsset*> *)assets isFullImage:(BOOL)isFull
{
    __block MCIMChatInputView * weekSelf = self;
    NSMutableArray *array =[[NSMutableArray alloc] initWithCapacity:0];
    for (ALAsset *asset in assets) {
        if (!isFull) {
//            UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
           UIImage *image = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
            [array addObject:image];
        }else{
            ALAssetRepresentation *assetRep = [asset defaultRepresentation];
            CGImageRef imgRef = [assetRep fullResolutionImage];   //获取高清图片
            UIImage *selectImage = [UIImage imageWithCGImage:imgRef
                                                       scale:assetRep.scale
                                                 orientation:(UIImageOrientation)assetRep.orientation];
            [array addObject:selectImage];
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            if ([weekSelf.delegate respondsToSelector:@selector(chatInputView:sendPictures:)]) {
                [weekSelf.delegate chatInputView:self sendPictures:array];
            }
            [weekSelf.viewController dismissViewControllerAnimated:YES completion:NULL];
        });
    }
}
- (void)dnImagePickerControllerDidCancel:(DNImagePickerController *)imagePicker
{
    [imagePicker dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - QBImagePickerControllerDelegate
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets{
    
    if (assets.count<1){
        return;
    }
    [SVProgressHUD showWithStatus:PMLocalizedStringWithKey(@"PM_Msg_MessageSending") maskType:SVProgressHUDMaskTypeClear];
    __block MCIMChatInputView * week = self;
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (ALAsset * asset in assets) {
            ALAssetRepresentation *assetRep = [asset defaultRepresentation];
            CGImageRef imgRef = [assetRep fullResolutionImage];   //获取高清图片
            UIImage *selectImage = [UIImage imageWithCGImage:imgRef
                                                       scale:assetRep.scale
                                                 orientation:(UIImageOrientation)assetRep.orientation];
            [array addObject:selectImage];
        }
        //友盟统计
        [MCUmengManager addEventWithKey:mc_im_sendImage];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            if ([week.delegate respondsToSelector:@selector(chatInputView:sendPictures:)]) {
                [week.delegate chatInputView:self sendPictures:array];
            }
            [week dismissImagePickerController];
        });
    });
}
- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController{
    
    [self dismissImagePickerController];
}
-(void)dismissImagePickerController
{
    [self.viewController dismissViewControllerAnimated:YES completion:NULL];
}

-(void)availablePhoto
{
    MCAvailablePhotoViewController* v = [[MCAvailablePhotoViewController alloc] init];
    MCBaseNavigationViewController*navigationController = [[MCBaseNavigationViewController alloc]initWithRootViewController:v];
    [self.viewController presentViewController:navigationController animated:YES completion:^{
    }];
    return;
}

#pragma mark - SubViews
-(UIButton *)voiceBtn
{
    if (!_voiceBtn) {
        _voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _voiceBtn.frame = CGRectMake(kMailChatWPadding, kMailChatHPadding, kMailChatSizeButton, kMailChatSizeButton);
        [_voiceBtn setImage:AppStatus.theme.chatStyle.voiceImage forState:UIControlStateNormal];
        [_voiceBtn setImage:AppStatus.theme.chatStyle.textImage forState:UIControlStateSelected];
        [_voiceBtn addTarget:self action:@selector(buttonActions:) forControlEvents:UIControlEventTouchUpInside];
        _voiceBtn.tag = kMailChatButtonTAG;
    }
    return _voiceBtn;
}

-(MCChatTextView *)inputTextView
{
    if (!_inputTextView) {
        _inputTextView = [[MCChatTextView alloc] initWithFrame:CGRectMake(40+kMailChatWPadding, kMailChatHPadding, ScreenWidth-45*3, 36)];
        _inputTextView.delegate = self;
        _inputTextView.keyInputDelegate = self;
        _inputTextView.placeHolder = PMLocalizedStringWithKey(@"PM_UUInput_placeH");
        _inputTextView.layer.borderWidth = 0.5;
        _inputTextView.layer.borderColor = [[UIColor colorWithHexString:@"d8d8d8"] CGColor];
        _inputTextView.layer.cornerRadius = 8.0;  //圆角
        _inputTextView.enablesReturnKeyAutomatically = YES; //这里设置为无文字就灰色不可点 (return 发送按钮)
        _inputTextView.returnKeyType = UIReturnKeySend;
    }
    return _inputTextView;
}

-(UIButton *)faceBtn
{
    if (!_faceBtn) {
        _faceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _faceBtn.frame = CGRectMake(ScreenWidth-40*2, kMailChatHPadding, kMailChatSizeButton, kMailChatSizeButton);
        [_faceBtn setImage:AppStatus.theme.chatStyle.faceImage forState:UIControlStateNormal];
        [_faceBtn setImage:AppStatus.theme.chatStyle.textImage forState:UIControlStateSelected];
        [_faceBtn addTarget:self action:@selector(buttonActions:) forControlEvents:UIControlEventTouchUpInside];
        _faceBtn.tag = kMailChatButtonTAG+1;
    }
    return _faceBtn;
}

-(UIButton *)moreBtn
{
    if (!_moreBtn) {
        _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreBtn.frame = CGRectMake(ScreenWidth-40, kMailChatHPadding, kMailChatSizeButton, kMailChatSizeButton);
        [_moreBtn setImage:AppStatus.theme.chatStyle.moreImage forState:UIControlStateNormal];
        [_moreBtn setImage:AppStatus.theme.chatStyle.moreImage forState:UIControlStateSelected];
        [_moreBtn addTarget:self action:@selector(buttonActions:) forControlEvents:UIControlEventTouchUpInside];
        _moreBtn.tag = kMailChatButtonTAG+2;
    }
    return _moreBtn;
}

-(MCIMInputFaceView *)faceView
{
    if (!_faceView) {
        _faceView = [[MCIMInputFaceView alloc] initWithFrame:CGRectMake(0, ScreenHeigth-NAVIGATIONBARHIGHT, ScreenWidth, kMailChatFaceViewHeight)];
        _faceView.delegate = self;
        self.plistFaces =[_faceView getPlistFaces];
    }
    return _faceView;
}

-(UIButton *)recordBtn
{
    if (!_recordBtn) {
        _recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _recordBtn.frame = CGRectMake(40+kMailChatWPadding, kMailChatHPadding, ScreenWidth-45*3, 36);
        _recordBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [_recordBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_recordBtn setBackgroundImage:[UIImage imageNamed:@"chat_message_back.png"] forState:UIControlStateNormal];
        [_recordBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_recordBtn setTitleColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        _recordBtn.exclusiveTouch = YES;
        [_recordBtn setTitle:@"按住 说话" forState:UIControlStateNormal];
        [_recordBtn setTitle:@"松开 发送" forState:UIControlStateHighlighted];
        _recordBtn.layer.cornerRadius = 8.0f;
        _recordBtn.hidden = YES;
        [_recordBtn addTarget:self action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
        [_recordBtn addTarget:self action:@selector(recordButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
        [_recordBtn addTarget:self action:@selector(recordButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [_recordBtn addTarget:self action:@selector(recordDragOutside) forControlEvents:UIControlEventTouchDragExit];
        [_recordBtn addTarget:self action:@selector(recordDragInside) forControlEvents:UIControlEventTouchDragEnter];
    }
    return _recordBtn;
}

-(UIView *)moreView
{
    if (!_moreView) {
        _moreView = [[MCIMChatMoreView alloc] initWithFrame:CGRectMake(0, ScreenHeigth-NAVIGATIONBARHIGHT, ScreenWidth, kMailChatMoreViewHeight) isHelperAccount:[self.delegate iSHelperAccount]];
        _moreView.delegate = self;
    }
    return _moreView;
}

#pragma mark - privata
-(BOOL)isCurrentSuperVC
{
    MCIMChatViewController *vc = (MCIMChatViewController*)self.viewController;
    return vc.isCurrentVC;
}

@end
