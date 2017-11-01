//
//  MCMailComposerViewComtroller.m
//  NPushMail
//
//  Created by zhang on 15/12/25.
//  Copyright © 2015年 sprite. All rights reserved.
//

#import "MCMailComposerViewController.h"
#import "MCSelectedContactsRootViewController.h"
#import "MCBaseNavigationViewController.h"
#import "MCWebViewController.h"
#import "MCContactInfoViewController.h"
#import "MCPhotoPreviewController.h"
#import "MCAttachPreviewViewcontroller.h"
#import "MCMailViewController.h"
#import "MCMailComposerHeadView.h"
#import "MCMailComposerWebView.h"
#import "MCAddAttachmentView.h"
#import "MCMailComposerExtensionView.h"
#import "NSString+Extension.h"
#import "MCFileCore.h"
#import "MCFileManager.h"
#import "MCAccountConfig.h"
#import "MCModelConversion.h"
#import "MCIMFileModel.h"
#import "MCIMImageModel.h"

#import "QBImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MCAddFileManager.h"
#import "MCStatusBarOverlay.h"

#import "UIActionSheet+Blocks.h"
#import "UIAlertView+Blocks.h"
#import "RIButtonItem.h"
#import "MCIFlyMSCHelper.h"
#import "MCIFlyWaverView.h"
#import "MCViewDisplay.h"
typedef void(^FinishLoadingAttachment) (NSError* error);

@interface MCMailComposerViewController () <MCAddAttachmentViewDelegate,MCMailComposerHeadViewDelegate,UIWebViewDelegate,MCAddFileManagerDelegate,UIScrollViewDelegate>
@property (nonatomic,strong)MCIFlyWaverView *iFlySpeechWaverView;
@property (nonatomic,strong)MCMailComposerHeadView      *mailComposerHeadView;
@property (nonatomic,strong)MCMailComposerWebView       *mailComposerWebView;
@property (nonatomic,strong)MCIFlyMSCHelper            *iFlySpeecHelper;
@property (nonatomic,strong)UIImageView                    *toolView;//工具栏（附件和语音）
@property (nonatomic,strong)UIButton                    *iFlySpeechButton;
@property (nonatomic,assign)CGFloat                      speechVolume;
@property (nonatomic,assign)BOOL isWriteMailViewArea;//是否在写邮件的区域
@property (nonatomic,strong)MCAddAttachmentView         *addAttachmentView;
@property (nonatomic,strong)MCMailComposerExtensionView *extensionView;
@property (nonatomic,strong)UIButton                    *addAttachmentButton;
@property (nonatomic,strong)UILabel                     *attachCountLable;
//datasource
@property (nonatomic,strong)NSMutableArray *toArray;
@property (nonatomic,strong)NSMutableArray *bccArray;
@property (nonatomic,strong)NSMutableArray *ccArray;
@property (nonatomic,strong)NSString       *subject;
@property (nonatomic,strong)NSString       *content;
@property (nonatomic,strong)NSMutableArray *attachments;
@property (nonatomic,strong)NSMutableArray *inlineAttchments;

@property (nonatomic,strong)MCMailModel    *mailModel;
@property (nonatomic,assign)MCMailComposerOptionType mailComposerType;

@property (nonatomic,strong)NSString       *mailSignature;
@property (nonatomic,assign)CGFloat        currentHight;

@property (nonatomic,strong)MCAddFileManager *addFileManager;

@property (nonatomic,strong)id firstRespenderObject;

@property (nonatomic,assign)BOOL loadingContent;

@property (nonatomic,copy)FinishLoadingAttachment finishLoadingAttachment;

@property (nonatomic,assign)BOOL finishAddAttach;
@property (nonatomic,assign)BOOL mcMailAttachMentChange;

//设置语言
@property (nonatomic,assign)MCMailSubjectLanguageType setLanguagetype;
@end

const static CGFloat kMailComposerViewWaverHeight = 200;//波纹视图高度
const static CGFloat kMailComposerViewToolsCount = 2;//工具栏存放个数
const static CGFloat kMailComposerViewAttachButtonWidth    = 24.0;
const static CGFloat kMailComposerViewAttachButtonHight    = 24.0;
const static CGFloat kMailComposerViewSpeechButtonWidth    = 24.0;
const static CGFloat kMailComposerViewToolViewButtonVMargin   = 6.0;
const static CGFloat kMailComposerViewToolViewButtonHMargin   = 20;
const static CGFloat kMailComposerViewToolViewHMargin = 11;
const static CGFloat kMailComposerViewToolViewVMargin = 15;

const static CGFloat kMailComposerViewAttachCountLableSize = 12.0;
const static CGFloat kMailComposerViewAttachCountLableFont = 9.0;
const static NSInteger kMailAttachmentSizeDefautLimit = 50;//附件最大限制50m
static NSString*const kMailComposerViewCameraAuthorityKey  = @"isCamera";

@implementation MCMailComposerViewController

- (instancetype)init {
    _mailModel = [MCMailModel new];
    return [self initWithTo:@[]
                         cc:@[]
                        bcc:@[]
                    subject:@""
                    content:@""
                 attachment:@[]
           inlineAttachment:@[]
               composerType:MCMailComposerNew];
}

- (instancetype)initWithContent:(id)content composerType:(MCMailComposerOptionType)composerType {
    _mailModel = [MCMailModel new];
    NSString * body = @"";
    NSMutableArray * to = [NSMutableArray new];
    NSMutableArray *attachments = [NSMutableArray new];
    if ([content isKindOfClass:[NSString class]] && composerType == MCMailComposerFromMessageText) {
        body = (NSString*)content;
        _mailModel.messageContentHtml = body;
        _mailModel.messageContentString = body;
    } else if ([content isKindOfClass:[MCContactModel class]]) {
        MCMailAddress *address = [MCModelConversion mailAddressWithMCContactModel:(MCContactModel*)content];
        _mailModel.to = @[address];
        [to addObject:address];
    } else if ([content isKindOfClass:[NSArray class]] && composerType == MCMailComposerFromFileLibrary) {
        for (id obj in (NSArray*)content) {
            MCMailAttachment *attachment = [MCModelConversion mailAttachmentWithFileBaseModel:(MCFileBaseModel*)obj];
            [attachments addObject:attachment];
        }
    } else if (composerType == MCMailComposerFromMessageFile) {
        MCMailAttachment *attachment;
        if ([content isKindOfClass:[MCIMFileModel class]]) {
            attachment = [MCModelConversion mailAttachmentWithIMFileModel:(MCIMFileModel*)content];
        } else if ([content isKindOfClass:[MCIMImageModel class]]) {
            attachment = [MCModelConversion mailAttachmentWithIMImageModel:(MCIMImageModel*)content];
        }
        if (attachment) {
            [attachments addObject:attachment];
        }
    } else {
        [attachments addObject:(MCMailAttachment*)content];
    }
    _mailModel.attachments = attachments;
    return [self initWithTo:to
                         cc:@[]
                        bcc:@[]
                    subject:@""
                    content:body
                 attachment:attachments
           inlineAttachment:@[]
               composerType:composerType];
}

- (instancetype)initWithMail:(MCMailModel*)mailModel mailComposerOptionType:(MCMailComposerOptionType)mailComposerOptionType{
    
    self.mailModel = mailModel;
    NSMutableArray *to = [NSMutableArray new];
    NSMutableArray *cc = [NSMutableArray new];
    NSArray *attachments;
    NSString *content;
    if (mailComposerOptionType == MCMailComposerReplyAll) {
        
        [self existUser:to fromArray:mailModel.to];
        [self existUser:to fromArray:@[mailModel.from]];
        [self existUser:cc fromArray:mailModel.cc];
        if (mailModel.replyTo && mailModel.replyTo.count > 0) {
            for (MCMailAddress *ad in mailModel.replyTo) {
                if (![to containsObject:ad]) {
                    [to addObject:ad];
                }
            }
        }
    } else if (mailComposerOptionType == MCMailComposerReplySingle){
        if (mailModel.replyTo && mailModel.replyTo.count > 0) {
            [to addObjectsFromArray:mailModel.replyTo];
        } else if (mailModel.from.email) {
            if (mailModel.from.email) {
               [to addObject:mailModel.from];
            }
        }
    } else if (mailComposerOptionType == MCMailComposerFromDraft||
              mailComposerOptionType == MCMailComposerFromPending) {
        [to addObjectsFromArray:mailModel.to];
        [cc addObjectsFromArray:mailModel.cc];
    }
    
    if (mailComposerOptionType == MCMailComposerForward ||
        mailComposerOptionType == MCMailComposerFromDraft ||
        mailComposerOptionType == MCMailComposerFromPending) {
        attachments = mailModel.attachments;
    }
    
    if (mailComposerOptionType == MCMailComposerForward |
        mailComposerOptionType == MCMailComposerReplySingle|
        mailComposerOptionType == MCMailComposerReplyAll) {
        self.setLanguagetype = [mailModel.subject stringLanguage];
        content = [NSString stringWithFormat:@"%@%@",[self composerHeaderMessageWithMail:mailModel],mailModel.messageContentHtml];
        
    } else {
        content = mailModel.messageContentHtml;
    }
    
    return  [self initWithTo:to
                          cc:cc
                         bcc:mailModel.bcc
                     subject:mailModel.subject
                     content:content
                  attachment:attachments
            inlineAttachment:mailModel.inlineAttachments
                composerType:mailComposerOptionType];
}

- (instancetype)initWithTo:(NSArray*)to
                        cc:(NSArray*)cc
                       bcc:(NSArray*)bcc
                   subject:(NSString*)subject
                   content:(NSString*)content
                attachment:(NSArray*)attachments
          inlineAttachment:(NSArray*)inlineAttachments
              composerType:(MCMailComposerOptionType)composerType{
    self = [super init];
    if (self) {
        if (!attachments) {
            attachments = @[];
        }
        NSMutableString *subjectString = [NSMutableString stringWithString:subject?subject:@""];
        if (composerType == MCMailComposerForward) {
            [subjectString insertString:@":" atIndex:0];
            
            if (self.setLanguagetype == MCMailSubjectLanguageEnglish) {
                [subjectString insertString:@"Fwd" atIndex:0];
            } else if (self.setLanguagetype == MCMailSubjectLanguageTraditionalChinese){
                [subjectString insertString:@"轉發"atIndex:0];
            } else {
                [subjectString insertString:PMLocalizedStringWithKey(@"PM_Mail_EditOptionForward") atIndex:0];
            }
            
        } else if (composerType == MCMailComposerReplyAll ||
                   composerType == MCMailComposerReplySingle) {
            [subjectString insertString:@":" atIndex:0];
            if (self.setLanguagetype == MCMailSubjectLanguageEnglish) {
                [subjectString insertString:@"Re" atIndex:0];
            } else if (self.setLanguagetype == MCMailSubjectLanguageTraditionalChinese){
                [subjectString insertString:@"回復"atIndex:0];
            } else {
                [subjectString insertString:PMLocalizedStringWithKey(@"PM_Mail_EditOptionrReply") atIndex:0];
            }
        }
        _addFileManager = [[MCAddFileManager alloc]initManagerWithDelegate:self];
        self.toArray  = [to mutableCopy];
        self.ccArray  = [cc mutableCopy];
        self.bccArray = bcc?[bcc mutableCopy]:[NSMutableArray new];
        self.subject  = subjectString;
        self.content  = content;
        self.attachments = [attachments mutableCopy];
        self.inlineAttchments = [inlineAttachments mutableCopy];
        self.mailComposerType = composerType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //TODO:链接发件服务器；
    [self.mailManager smtpConnectSuccess:^(id response) {
        DDLogDebug(@"链接发件服务器成功");
    } failure:^(NSError *error) {
        DDLogDebug(@"%@",error);
    }];
    
    [self loadViews];
    [self registKeyboardNotifications];
    [self toLoadAttachmentsWithAttach:self.attachments];
    //    [self loadMailComtent];
    
    self.mailComposerHeadView.to  = self.toArray;
    self.mailComposerHeadView.cc  = self.ccArray;
    self.mailComposerHeadView.bcc = self.bccArray;
    self.mailComposerHeadView.subject = self.subject;
    //是否是回复或回复全部，
    if (self.mailComposerType != MCMailComposerReplyAll&&
        self.mailComposerType != MCMailComposerReplySingle) {
        [self.mailComposerHeadView.toTokenField becomeFirstResponder];
    }
    _speechVolume = 0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    if ([AppStatus.touchIdWindow isShow] || [AppStatus.gestureWindow isShow]) {
        [self.view endEditing:YES];
    };
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_iFlySpeechWaverView) {
        [_iFlySpeechWaverView stopUpdate];
        [_iFlySpeechButton setImage:[UIImage imageNamed:@"mailSpeechEnableIcon.png"] forState:UIControlStateNormal];
    }
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}
- (void)loadViews{
    
    self.viewTitle = PMLocalizedStringWithKey(@"PM_Mail_MailEdit");
    self.rightNavigationBarButtonItem.title = PMLocalizedStringWithKey(@"PM_Mail_SendMail");
    [self.view addSubview:self.mailComposerWebView];
    [self.view addSubview:self.addAttachmentView];
    [self.view addSubview:self.iFlySpeechWaverView];
    
    _toolView = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - kMailComposerViewAttachButtonWidth - kMailComposerViewSpeechButtonWidth - kMailComposerViewToolViewButtonHMargin*(kMailComposerViewToolsCount +1) - kMailComposerViewToolViewHMargin, ScreenHeigth - kMailComposerViewAttachButtonHight - kMailComposerViewToolViewButtonVMargin*kMailComposerViewToolsCount - NAVIGATIONBARHIGHT - kMailComposerViewToolViewVMargin, kMailComposerViewAttachButtonWidth + kMailComposerViewSpeechButtonWidth + kMailComposerViewToolViewButtonHMargin*(kMailComposerViewToolsCount +1), kMailComposerViewAttachButtonHight + kMailComposerViewToolViewButtonVMargin * kMailComposerViewToolsCount)];
    _toolView.userInteractionEnabled = YES;
    _toolView.image = [[UIImage imageNamed:@"composerToolViewBg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 20, 10, 20) resizingMode:UIImageResizingModeStretch];
    
    _iFlySpeechButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _iFlySpeechButton.frame = CGRectMake(kMailComposerViewToolViewButtonHMargin, kMailComposerViewToolViewButtonVMargin, kMailComposerViewSpeechButtonWidth, kMailComposerViewAttachButtonHight);
    [_iFlySpeechButton addTarget:self action:@selector(startRecognizer) forControlEvents:UIControlEventTouchUpInside];
    [_iFlySpeechButton setImage:[UIImage imageNamed:@"mailSpeechDisabledIcon.png"] forState:UIControlStateNormal];
    [_iFlySpeechButton setImage:[UIImage imageNamed:@"mailSpeechEnableIcon.png"] forState:UIControlStateHighlighted];
    
    _addAttachmentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _addAttachmentButton.frame = CGRectMake(CGRectGetMaxX(_iFlySpeechButton.frame) + kMailComposerViewToolViewButtonHMargin, CGRectGetMinY(_iFlySpeechButton.frame), kMailComposerViewAttachButtonWidth, kMailComposerViewAttachButtonHight);
    [_addAttachmentButton addTarget:self action:@selector(addAttachmentFiles:) forControlEvents:UIControlEventTouchUpInside];
    [_addAttachmentButton setImage:[UIImage imageNamed:@"writeMailAttachment.png"] forState:UIControlStateNormal];
    
    [_toolView addSubview:_iFlySpeechButton];
    [_toolView addSubview:_addAttachmentButton];
    [self.view addSubview:_toolView];
    
    _attachCountLable = [[UILabel alloc]initWithFrame:CGRectMake(kMailComposerViewAttachButtonWidth, kMailComposerViewAttachButtonHight - kMailComposerViewAttachCountLableSize , kMailComposerViewAttachCountLableSize, kMailComposerViewAttachCountLableSize)];
    _attachCountLable.font = [UIFont systemFontOfSize:kMailComposerViewAttachCountLableFont];
    _attachCountLable.backgroundColor = [UIColor clearColor];
    _attachCountLable.textColor = AppStatus.theme.tintColor;
    [_addAttachmentButton addSubview:_attachCountLable];
    
}
//加载编辑邮件
- (void)loadMailComtent{
    _loadingContent = NO;
    NSString *mailContent = @"";
    self.mailSignature = [AppStatus.currentUser.signature toHtmlSpaceAndLine];
    if (self.mailComposerType == MCMailComposerFromMessageText) {
        mailContent = [NSString stringWithFormat:@"<br><br>%@<br><br>%@<br><br><br><br><br><br>",self.content,self.mailSignature];
    } else if (self.mailComposerType == MCMailComposerFromDraft ||
               self.mailComposerType == MCMailComposerFromPending) {
        mailContent =  [NSString stringWithFormat:@"<br>%@<br><br><br><br><br><br>",self.content];
    } else if (self.mailComposerType == MCMailComposerNew){
        mailContent = [NSString stringWithFormat:@"<br><br>%@<br><br><br><br><br><br>",self.mailSignature];
    } else {
        mailContent = [NSString stringWithFormat:@"<br><br>%@<br><br>%@<br><br><br><br><br><br>",self.mailSignature,self.content];
    }
    NSString*path = [[NSBundle mainBundle] pathForResource:@"Composer" ofType:@"html"] ;
    NSString*composerStyle = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    
    [self.mailComposerWebView loadHTMLString:[NSString stringWithFormat:composerStyle,mailContent] baseURL:nil];
    [self.mailComposerWebView setUserInteractionEnabled:YES];
}
//注册键盘通知
- (void)registKeyboardNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardwillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardwillShow:) name:UIKeyboardWillShowNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboarddidShow:) name:UIKeyboardDidShowNotification object:nil];
}
//manager
- (MCMailManager*)mailManager {
    if (!_mailManager) {
        _mailManager = [[MCMailManager alloc]initWithAccount:AppStatus.currentUser];
    }
    return _mailManager;
}

- (MCIFlyMSCHelper *)iFlySpeecHelper {
    if (_iFlySpeecHelper) {
        return _iFlySpeecHelper;
    }
    __weak MCMailComposerViewController *weakSelf = self;
    _iFlySpeecHelper = [[MCIFlyMSCHelper alloc] init];
    _iFlySpeecHelper.finishedRecognizerBlock = ^{
        //完成识别
        [weakSelf.iFlySpeechWaverView pauseUpdate];
        [weakSelf.iFlySpeechButton setEnabled:YES];
        [weakSelf.iFlySpeechButton setImage:[UIImage imageNamed:@"mailSpeechEnableIcon.png"] forState:UIControlStateNormal];
    };
    _iFlySpeecHelper.volumeChangedBlock = ^(int volume) {
        //音量变化
        weakSelf.speechVolume = volume;
        weakSelf.iFlySpeechWaverView.volume = volume;
    };
    _iFlySpeecHelper.speechErrorBlock = ^(IFlySpeechError *error){
        //听写错误
        [weakSelf eventSendStatus:NO];
        NSString *errorTtext = [NSString stringWithFormat:@"讯飞识别发生错误：%d %@", error.errorCode,error.errorDesc];
        [weakSelf.iFlySpeechButton setEnabled:YES];
        [weakSelf.iFlySpeechButton setImage:[UIImage imageNamed:@"mailSpeechEnableIcon.png"] forState:UIControlStateNormal];
        DDLogError(@"%@", errorTtext);
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@\n%@",error.errorDesc,PMLocalizedStringWithKey(@"PM_Mail_UnableToPhoneticWriting")]];
    };
    _iFlySpeecHelper.recognizerResult = ^(NSString *result) {
        DDLogVerbose(@"邮件内容识别结果%@", result);
        [weakSelf eventSendStatus:YES];
        [weakSelf.mailComposerWebView insertText:result];
    };
    return _iFlySpeecHelper;
}

- (void)eventSendStatus:(BOOL)success
{
    NSString *value = success ? @"success" : @"failure";
    [MCUmengManager addEventWithKey:mc_mail_write attributes:@{@"iFlySpeech" : value}];
}

#pragma mark - Views
- (MCMailComposerWebView*)mailComposerWebView{
    if (!_mailComposerWebView) {
        _mailComposerWebView = [[MCMailComposerWebView alloc]init];
        _mailComposerWebView.headerView = self.mailComposerHeadView;
        _mailComposerWebView.delegate = self;
        _mailComposerWebView.scrollView.delegate = self;
    }
    return _mailComposerWebView;
}

- (MCMailComposerHeadView*)mailComposerHeadView{
    if (!_mailComposerHeadView) {
        _mailComposerHeadView = [[MCMailComposerHeadView alloc]init];
        _mailComposerHeadView.delegate = self;
    }
    return _mailComposerHeadView;
}

- (MCAddAttachmentView*)addAttachmentView{
    if (!_addAttachmentView) {
        _addAttachmentView = [[MCAddAttachmentView alloc]initWithMailAttachments:self.attachments];
        _addAttachmentView.delegate = self;
    }
    return _addAttachmentView;
}

- (MCIFlyWaverView *)iFlySpeechWaverView {
    if (_iFlySpeechWaverView) {
        return _iFlySpeechWaverView;
    }
    __weak MCMailComposerViewController *weakSelf = self;
    _iFlySpeechWaverView = [[MCIFlyWaverView alloc] initWithFrame:CGRectMake(0, ScreenHeigth, ScreenWidth, kMailComposerViewWaverHeight)];
    _iFlySpeechWaverView.speechEndBlock = ^{
        if (weakSelf.iFlySpeecHelper.isSpeeching) {
            [weakSelf.iFlySpeechWaverView pauseUpdate];
            [weakSelf.iFlySpeecHelper finishedRecognizer];
        }else{
            [weakSelf.iFlySpeechWaverView startUpdate];
            [weakSelf.iFlySpeecHelper startRecognizer];
        }
    };
    _iFlySpeechWaverView.volume = self.speechVolume;
    return _iFlySpeechWaverView;
}

- (void)startRecognizer {
    
    if (![self canRecord]) {
        [self showNoPermission];
        return;
    }
    
    BOOL isVoiceViewShown = self.iFlySpeechWaverView.frame.origin.y < ScreenHeigth - NAVIGATIONBARHIGHT;
    if (isVoiceViewShown) {
        DDLogVerbose(@"isVoiceViewShown = true");
        [_iFlySpeecHelper finishedRecognizer];
        [_iFlySpeechWaverView stopUpdate];
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rect2 = self.toolView.frame;
            _iFlySpeechWaverView.frame = CGRectMake(0, ScreenHeigth- NAVIGATIONBARHIGHT, ScreenWidth, kMailComposerViewWaverHeight);
            rect2.origin.y = CGRectGetMinY(self.iFlySpeechWaverView.frame) - kMailComposerViewToolViewVMargin - rect2.size.height;
            self.toolView.frame = rect2;
        }];
        
        return;
    }
    
    DDLogVerbose(@"isVoiceViewShown = false");
    // 开始识别
    [self.mailComposerWebView resignFirstResponder];
    [_iFlySpeechWaverView startUpdate];
    [self.iFlySpeecHelper startRecognizer];

    // 弹出语音窗口 附件view消失
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.addAttachmentView.frame;
        if (rect.origin.y < ScreenHeigth - NAVIGATIONBARHIGHT) {
            //附件view消失
            rect.origin.y = ScreenHeigth - NAVIGATIONBARHIGHT;
        }
        //波纹界面升起
        self.iFlySpeechWaverView.frame = CGRectMake(0, ScreenHeigth - kMailComposerViewWaverHeight - NAVIGATIONBARHIGHT, ScreenWidth, kMailComposerViewWaverHeight);
        CGRect rect2 = self.toolView.frame;
        rect2.origin.y = CGRectGetMinY(self.iFlySpeechWaverView.frame) - kMailComposerViewToolViewVMargin - rect2.size.height;
        self.toolView.frame = rect2;
        self.addAttachmentView.frame = rect;
    }];
    
    _firstRespenderObject = nil;
    [self.view endEditing:YES];
    
}

#pragma mark add Attachment
- (void)addAttachmentFiles:(UIButton*)sender{
    if (_iFlySpeecHelper.isSpeeching) {
        [_iFlySpeecHelper finishedRecognizer];
    }
    if (_isWriteMailViewArea) {
        [_iFlySpeechButton setImage:[UIImage imageNamed:@"mailSpeechEnableIcon.png"] forState:UIControlStateNormal];
    }else {
        [_iFlySpeechButton setImage:[UIImage imageNamed:@"mailSpeechDisabledIcon.png"] forState:UIControlStateNormal];
    }
    [self.iFlySpeechWaverView stopUpdate];
    //todo 波纹界面消失（对应的逻辑修改，话筒变回灰色状态，语音听写需终止），调整toolview的位置
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.addAttachmentView.frame;
        CGRect rect2 = self.toolView.frame;
        _iFlySpeechWaverView.frame = CGRectMake(0, ScreenHeigth  - NAVIGATIONBARHIGHT, ScreenWidth, kMailComposerViewWaverHeight);
        if (rect.origin.y >= ScreenHeigth - NAVIGATIONBARHIGHT) {
            rect.origin.y -= rect.size.height;
            rect2.origin.y = ScreenHeigth  - NAVIGATIONBARHIGHT - rect.size.height - rect2.size.height - kMailComposerViewToolViewVMargin;
            
        } else {
            rect.origin.y  = ScreenHeigth - NAVIGATIONBARHIGHT;
            rect2.origin.y = ScreenHeigth - NAVIGATIONBARHIGHT -  rect2.size.height - kMailComposerViewToolViewVMargin;
        }
        self.addAttachmentView.frame = rect;
        self.toolView.frame = rect2;
    }];
    _firstRespenderObject = nil;
    [self.view endEditing:YES];
}

#pragma mark keboardHide  or show
- (void)keyboardwillHide:(NSNotification*)info {
    
    CGFloat duration = [[[info userInfo]
                         objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    if (!self.iFlySpeecHelper.isSpeeching) {
        [UIView animateWithDuration:duration animations:^{
            CGRect rect = self.toolView.frame;
            //todo 语音和附件工具栏位置调整。
            if (self.addAttachmentView.frame.origin.y < ScreenHeigth - NAVIGATIONBARHIGHT) {
                rect.origin.y = self.addAttachmentView.frame.origin.y - rect.size.height - kMailComposerViewToolViewVMargin;
            } else {
                rect.origin.y = ScreenHeigth - NAVIGATIONBARHIGHT - rect.size.height - kMailComposerViewToolViewVMargin;
            }
            self.toolView.frame = rect;
        }];
        
        self.currentHight = 0.0;
    }
}


- (void)keyboarddidShow:(NSNotification*)info {
    
    //控制语音按钮是否可点击，只有写邮件的时候可以点击语音按钮，然后波纹界面消失，语音听写终止。
    /**
     * WebView 的 isFirstResponder 里面有一段js代码注入(判断是否在编辑)，iOS8 之前要放在键盘did show  操作。（不然返回结果都是false） 
    */
    if ([self.mailComposerWebView isFirstResponder]) {
        _isWriteMailViewArea = YES;
        [_iFlySpeechButton setEnabled:YES];
        [_iFlySpeechButton setImage:[UIImage imageNamed:@"mailSpeechEnableIcon.png"] forState:UIControlStateNormal];
    }else {
        _isWriteMailViewArea = NO;
        [_iFlySpeechButton setEnabled:NO];
        [_iFlySpeechButton setImage:[UIImage imageNamed:@"mailSpeechDisabledIcon.png"] forState:UIControlStateNormal];
    }
    [_iFlySpeecHelper finishedRecognizer];
    [self.iFlySpeechWaverView stopUpdate];
    
    _iFlySpeechWaverView.frame = CGRectMake(0, ScreenHeigth  - NAVIGATIONBARHIGHT, ScreenWidth, kMailComposerViewWaverHeight);
    
}


- (void)keyboardwillShow:(NSNotification*)info {
    
    NSValue *animationDurationValue = [info.userInfo
                                       objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    //获取到键盘frame变化之后的frame
    NSValue *keyboardEndBounds = [[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect endRect = [keyboardEndBounds CGRectValue];
    CGFloat keyBoardHeight = CGRectGetHeight(endRect);
    
    // 得到变化时间
    CGFloat duration = [[[info userInfo]
                         objectForKey:UIKeyboardAnimationDurationUserInfoKey]
                        floatValue];
    [UIView animateWithDuration:duration animations:^{
        CGRect rect = self.toolView.frame;
        rect.origin.y = ScreenHeigth - keyBoardHeight - rect.size.height - kMailComposerViewToolViewVMargin - NAVIGATIONBARHIGHT;
        self.toolView.frame = rect;
        
        rect = self.addAttachmentView.frame;
        rect.origin.y = ScreenHeigth - NAVIGATIONBARHIGHT;
        self.addAttachmentView.frame = rect;
    }];
    self.currentHight = keyBoardHeight;
    
}

#pragma mark -MCMailComposerHeadViewDelegate
//tokenField frame 改变时调用
- (void)composerHeadView:(MCMailComposerHeadView*)headView tokenFieldFrameWillChange:(TITokenField*)tokenField {
    
}

//tokenField 开始编辑时调用
- (BOOL)composerHeadView:(MCMailComposerHeadView*)headView tokenFieldDidBeginEditing:(TITokenField*)tokenField {
    _firstRespenderObject = tokenField;
    return YES;
}

//tokenField 编辑过程 调用
- (void)composerHeadView:(MCMailComposerHeadView*)headView tokenFieldTextDidChange:(id)field {
    
    if ([field isKindOfClass:[TITokenField class]]) {
        
        TITokenField*tokenfield = (TITokenField*)field;
        CGFloat offset = tokenfield.frame.size.height - 50 + tokenfield.frame.origin.y;
        __block  NSMutableArray *currentAddressArray = [self arrayWithTokenField:tokenfield];
        
        self.mailComposerWebView.scrollView.contentOffset = CGPointMake(0, offset);
        // 检索页面
        if (tokenfield.text.length > 1) {
            if (!_extensionView) {
                _extensionView = [[MCMailComposerExtensionView alloc]initWithFrame:CGRectMake(0,50, ScreenWidth, ScreenHeigth - NAVIGATIONBARHIGHT - 50 - self.currentHight)];
                _extensionView.backgroundColor = [UIColor whiteColor];
                [self.view addSubview:self.extensionView];
            } else {
                _extensionView.hidden = NO;
            }
            _extensionView.searchString = tokenfield.text;
            __block MCMailComposerExtensionView *weekExtesionView = _extensionView;
            _extensionView.searchCompleteCallBack = ^(MCMailAddress* mailAddress){
                
                if (![currentAddressArray containsObject:mailAddress]) {
                    //                    [currentAddressArray addObject:mailAddress];
                    [tokenfield addTokenWithTitle:mailAddress.name representedObject:mailAddress];
                } else {
                    tokenfield.text = @"";
                }
                weekExtesionView.hidden = YES;
            };
            _extensionView.hidden = _extensionView.resultContacts.count > 0?NO:YES;
            
        } else {
            _extensionView.hidden = YES;;
        }
    } else {
        
        UITextField*textField = (UITextField*)field;
        self.subject = textField.text;
    }
}

//tokenField 添加token 时调用

- (void)composerHeadView:(MCMailComposerHeadView *)headView tokenField:(TITokenField *)tokenField willAddToken:(TIToken *)token {
    
    if (!token.representedObject) {
        MCMailAddress *ad = [MCMailAddress new];
        if ([token.title isEmail]) {
            MCContactModel *model = [[MCContactManager sharedInstance] getOrCreateContactWithEmail:token.title name:token.title];
            ad = [MCModelConversion mailAddressWithMCContactModel:model];
        }else {
            ad.name = token.title;
            ad.email = token.title;
        }
        token.title = ad.name;
        token.representedObject = ad;
    }
}

- (void)composerHeadView:(MCMailComposerHeadView*)headView tokenField:(TITokenField *)tokenField didAddToken:(TIToken *)token {
    NSMutableArray *currentAddressArray = [self arrayWithTokenField:tokenField];
    MCMailAddress *ad = (MCMailAddress*)token.representedObject;
    if (![currentAddressArray containsObject:ad]) {
        [currentAddressArray addObject:ad];
    }
}
//tokenField 移除token时调用
- (void)composerHeadView:(MCMailComposerHeadView*)headView tokenField:(TITokenField *)tokenField willRemoveToken:(TIToken *)token {
    NSMutableArray *currentAddressArray = [self arrayWithTokenField:tokenField];
    MCMailAddress *ad = (MCMailAddress*)token.representedObject;
    if ([currentAddressArray containsObject:ad]) {
        [currentAddressArray removeObject:ad];
    }
}
//tokenField token被点击时调用
- (void)composerHeadView:(MCMailComposerHeadView*)headView tokenField:(TITokenField *)tokenField didTouchUpInsideToken:(TIToken *)token {
    
    if (token.representedObject) {
        MCMailAddress *mailAddress = (MCMailAddress*)token.representedObject;
        //TODO:进入联系人详情；
        if (![mailAddress.email isEmail]) {
            return;
        }
        MCContactModel *model = [MCModelConversion contactModelWithMailAddress:mailAddress];
        MCContactInfoViewController *contactInfoViewController = [[MCContactInfoViewController alloc]initFromType: fromReadMail contactModel:model canEditable:NO isEnterprise:model.isCompanyUser];
        [self.navigationController pushViewController:contactInfoViewController animated:YES];
    }
}

- (void)composerHeadView:(MCMailComposerHeadView*)headView didChangeFrame:(CGFloat)height {
    self.mailComposerWebView.changeHeight = height;
}

- (void)composerHeadView:(MCMailComposerHeadView *)headView selectContactForTokenField:(TITokenField *)tokenField {
    __block NSMutableArray *addresses = [self arrayWithTokenField:tokenField];
    
    NSMutableArray *contacts = [NSMutableArray new];
    for (MCMailAddress *ad in addresses) {
        MCContactModel *ct = [MCModelConversion contactModelWithMailAddress:ad];
        [contacts addObject:ct];
    }
    MCSelectedContactsRootViewController *selectedContactsViewCottroller = [[MCSelectedContactsRootViewController alloc]initWithSelectedModelsBlock:^(id models) {
        if (_firstRespenderObject) {
            [_firstRespenderObject becomeFirstResponder];
        }
        NSArray*contacts = (NSArray*)models;
        for (MCContactModel *contactModel in contacts) {
            MCMailAddress *ad = [MCModelConversion mailAddressWithMCContactModel:contactModel];
            if (![addresses containsObject:ad]) {
                [addresses addObject:ad];
                [tokenField addTokenWithTitle:ad.name representedObject:ad];
            }
        }
    } selectedMsgGroupModelBlock:nil formCtrlType:SelectedContactFromWriteMail alreadyExistsModels:contacts];
    
    MCBaseNavigationViewController *navigationController = [[MCBaseNavigationViewController alloc]initWithRootViewController:selectedContactsViewCottroller];
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - MCAddAttachmentViewDelegate
- (void)addAttachmentView:(MCAddAttachmentView*)addAttachmentView didSelectImagePickerSourceType:(NSInteger)imagePickerSourceType{
    _addFileManager.addFileSource = (MCAddFileSourceType)imagePickerSourceType;
    [_addFileManager sourceShow];
}

- (void)didDeleteAttachment:(MCMailAttachment*)mailAttachment index:(NSInteger)index {
    _mcMailAttachMentChange = YES;
    [self refreshAttachmentCount];
}

- (void)addAttachmentView:(MCAddAttachmentView *)addAttachmentView didSelectAttach:(MCMailAttachment *)attachment imageAttachs:(NSArray *)attachments index:(NSInteger)index{
    if (!attachment.isImage) {
        MCAttachPreviewViewcontroller *attachPreviewViewController = [[MCAttachPreviewViewcontroller alloc] initWithFile:attachment manager:self.mailManager fileSourceFrom:MCFileSourceFromMail];
        attachPreviewViewController.deleteAttachComplete = ^{
            [_attachments removeObject:attachment];
            self.addAttachmentView.mailAttachments = self.attachments;
            [self refreshAttachmentCount];
        };
        [self.navigationController pushViewController:attachPreviewViewController animated:YES];
    } else {
        MCPhotoPreviewController * photoPreviewController = [[MCPhotoPreviewController alloc]initWithImageAttachments:attachments didSelectIndex:index];
        photoPreviewController.deleteImageCallBack = ^(MCMailAttachment*attach) {
            if (attach) {
                [_attachments removeObject:attach];
                [self refreshAttachmentCount];
            }
            [self.addAttachmentView reload];
        };
        [self presentViewController:photoPreviewController animated:YES completion:nil];
    }
}

#pragma mark MCAddFileManagerDelegate
- (void)manager:(MCAddFileManager *)mcAddFileManager didAddFiles:(NSArray *)files finish:(BOOL)finish{
    _mcMailAttachMentChange = YES;
    _finishAddAttach = finish;
    [self.attachments addObjectsFromArray:files];
    self.addAttachmentView.mailAttachments = self.attachments;
    [self refreshAttachmentCount];
    
    if (finish && _finishLoadingAttachment) {
        _finishLoadingAttachment(nil);
    }
}

#pragma  mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSURL *url = [request URL];
        if ([[[[NSString stringWithFormat:@"%@",url] componentsSeparatedByString:@":"] lastObject] isEmail]){
            
        } else if ([[[[NSString stringWithFormat:@"%@",url] componentsSeparatedByString:@":"] lastObject] isPureInt]){
            NSString *phoneNumber = [[[NSString stringWithFormat:@"%@",url] componentsSeparatedByString:@":"] lastObject];
            RIButtonItem *doButtonItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Mail_PhoneCall") action:^{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNumber]]];
            }];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:phoneNumber message:nil cancelButtonItem:[RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Cancel") ] otherButtonItems:doButtonItem, nil];
            [alertView show];
            
        } else if ([[UIApplication sharedApplication]canOpenURL:url]) {
            MCWebViewController *webController = [[MCWebViewController alloc] initWithUrl:url];
            [self.navigationController pushViewController:webController animated:YES];
        }
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    //去除webView点击编辑黑色背景
    [webView stringByEvaluatingJavaScriptFromString:
     @"var tagHead =document.documentElement.firstChild;"
     "var tagStyle = document.createElement(\"style\");"
     "tagStyle.setAttribute(\"type\", \"text/css\");"
     "tagStyle.appendChild(document.createTextNode(\"BODY{ -webkit-tap-highlight-color:rgba(0,0,0,0);background-color: transparent;}\"));"
     "var tagHeadAdd = tagHead.appendChild(tagStyle);"];
    __weak typeof(webView)weakWebView = webView;
    [self.mailManager loadInlineAttachment:_mailModel.inlineAttachments success:^(id response) {
        NSString*jsString = (NSString*)response;
        [weakWebView stringByEvaluatingJavaScriptFromString:jsString];
    } failure:nil];
    
    if (self.mailComposerType == MCMailComposerReplyAll|
        self.mailComposerType == MCMailComposerReplySingle) {
        double delayInSeconds = 1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if ([webView respondsToSelector:@selector(setKeyboardDisplayRequiresUserAction:)]) {
                webView.keyboardDisplayRequiresUserAction = NO;
            }
            [webView becomeFirstResponder];
        });
    }
}

#pragma mark - 加载附件
- (void)toLoadAttachmentsWithAttach:(NSArray*)attachments {
    _finishAddAttach = YES;
    
    [self loadMailComtent];
    
    if (attachments.count == 0) {
        return;
    }
    _loadingContent = YES;
    [self refreshAttachmentCount];
    __weak typeof(self) weekSelf = self;
    __block NSError *errorNote = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_group_t group = dispatch_group_create();
        for (MCMailAttachment * attachment in attachments) {
            if (attachment.data) {
                continue;
            }
            dispatch_group_enter(group);
            [self.mailManager getAttachmentDataInfo:attachment progress:nil success:^(id response) {
                dispatch_group_leave(group);
            } failure:^(NSError *error) {
                errorNote = error;
                dispatch_group_leave(group);
            }];
        }
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_main_queue(), ^{
            weekSelf.loadingContent = NO;
            [weekSelf.addAttachmentView reload];
            if (weekSelf.finishLoadingAttachment) {
                weekSelf.finishLoadingAttachment(errorNote);
            }
        });
    });
}

#pragma mark - navigationBarButton action

- (void)leftNavigationBarButtonItemAction:(id)sender {
    MCMailModel *mailmodel = [self mailWithTo:self.toArray
                                           cc:self.ccArray
                                          bcc:self.bccArray
                                      subject:self.subject
                                      attachs:self.attachments
                             inlineAttachment:self.inlineAttchments];
    
    [self.view endEditing:YES];
    BOOL isToDraft = [self.mailModel isEqualToDraftModel:mailmodel];
    DDLogDebug(@"是否需要保存草稿 == %d",isToDraft);
    if (!isToDraft || _mcMailAttachMentChange) {
        __weak MCMailComposerViewController *weakSelf = self;
        RIButtonItem *cancolItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Cancel")];
        RIButtonItem *saveDraftItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Mail_SaVeDraft") action:^{
            //保存草稿；
            [weakSelf.mailManager saveDraftWithMail:mailmodel success:^(id response) {
                
            } failure:^(NSError *error) {
                
            }];
            [weakSelf pop];
            if (_mailDraftManagerCallback) {
                _mailDraftManagerCallback(MCMailDraftManagerTypeNew,mailmodel);
            }
        }];
        //放弃草稿
        RIButtonItem *forgoItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Mail_NotSaveDraft") action:^{
            [weakSelf pop];
        }];
        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:PMLocalizedStringWithKey(@"PM_Mail_SaveDraftOrNO") cancelButtonItem:cancolItem destructiveButtonItem:forgoItem otherButtonItems:saveDraftItem, nil];
        [sheet showInView:self.view];
    } else {
        
        [self pop];
    }
}

- (void)rightNavigationBarButtonItemAction:(id)sender {
    
    [self.view endEditing:YES];
    if (self.toArray.count == 0 && self.ccArray.count == 0 && self.bccArray.count == 0 ) {
        //TODO:添加联系人
        [SVProgressHUD showInfoWithStatus:PMLocalizedStringWithKey(@"PM_Mail_AddContactNote")];
        return;
    }
    //TODO:验证收件人账号是否有误 避免发送失败
    NSMutableArray*mailAddress = [NSMutableArray new];
    [mailAddress addObjectsFromArray:self.toArray];
    [mailAddress addObjectsFromArray:self.ccArray];
    [mailAddress addObjectsFromArray:self.bccArray];
    for (MCMailAddress *address in mailAddress) {
        if (![[address email] isEmail]) {
            UIAlertView*alert = [[UIAlertView alloc]initWithTitle:PMLocalizedStringWithKey(@"PM_Msg_EmailErrInfo") message:[NSString stringWithFormat:@"“%@”%@",address.name,PMLocalizedStringWithKey(@"PM_MailAccontCKNote")] delegate:self cancelButtonTitle:PMLocalizedStringWithKey(@"PM_Common_Sure") otherButtonTitles: nil];
            [alert show];
            return;
        }
    }
    //TODO:是否有主题
    if ([_subject trim].length == 0) {
        RIButtonItem *sureItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Mail_SendMail") action:^{
            [self sentMail];
        }];
        RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Cancel") action:^{
            [_mailComposerHeadView.subjectField becomeFirstResponder];
        }];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:PMLocalizedStringWithKey(@"PM_Mail_SubjectNote") message:PMLocalizedStringWithKey(@"PM_Mail_IsSending") cancelButtonItem:cancelItem otherButtonItems:sureItem, nil];
        [alertView show];
        return;
    }
    
    //TODO:是否写信抄送自己
    BOOL ccSelf = AppStatus.accountData.accountConfig.ccForYourself;
    if (ccSelf) {
        MCMailAddress *mailAddress = [MCMailAddress new];
        mailAddress.name = AppStatus.currentUser.displayName;
        mailAddress.email = AppStatus.currentUser.email;
        if (![self.ccArray containsObject:mailAddress]) {
            [self.ccArray addObject:mailAddress];
        }
        DDLogDebug(@"抄送自己已开启--%@",AppStatus.currentUser.email);
    }
    
    //附件限制大小50
    if ([self attachmentsMoreThanLimit])return;
    //TODO:是否正在加载附件
    if (_loadingContent || !_finishAddAttach) {
        UIViewController *viewController = [MCViewDisplay getRootViewController];
        [viewController.navigationController showMCProgress:0.2];
        __weak typeof(self)weak = self;
        _finishLoadingAttachment = ^(NSError*error) {
            if (_loadingContent || !_finishAddAttach) {
                return ;
            }
            [weak sendEmailOfterLoadAttachWithError:error];
        };
        [self popToRootViewController];
        return;
    }
    
    [self sentMail];
}
//TODO:发送邮件
- (void)sentMail {
    
    MCMailModel *mailModel = [self mailWithTo:self.toArray
                                           cc:self.ccArray
                                          bcc:self.bccArray
                                      subject:self.subject
                                      attachs:self.attachments
                             inlineAttachment:self.inlineAttchments];
    [self sendEmailWithMail:mailModel];
    [self popToRootViewController];
}

//加载附件中
- (void)sendEmailOfterLoadAttachWithError:(NSError*)error {
    
    MCMailModel *mail = [self mailWithTo:self.toArray
                                      cc:self.ccArray
                                     bcc:self.bccArray
                                 subject:self.subject
                                 attachs:self.attachments
                        inlineAttachment:self.inlineAttchments];
    
    if (_mailDraftManagerCallback) {
        _mailDraftManagerCallback(MCMailDraftManagerTypeSent,mail);
    }
    if (error) {
        NSString*message = error.userInfo[@"MCOSMTPResponseKey"];
        if (message) {
            mail.messageContentString = message;
        } else {
            mail.messageContentString = PMLocalizedStringWithKey(@"PM_Mail_SendFailure");
        }
        [self.mailManager savePendingMail:mail];
        if (self.mailDraftManagerCallback) {
            self.mailDraftManagerCallback(MCMailDraftManagerTypeNew,mail);
        }
        UIViewController *currentViewController = [MCViewDisplay getCurrentViewController];
        if (self.mailComposerType != MCMailComposerFromPending) {
            [MCNotificationCenter postNotification:MCNotificationSentMailFailure object:@(NO)];
        }
        UIViewController *viewController = [MCViewDisplay getRootViewController];
        [viewController.navigationController dismissMCProgress];
        if (![currentViewController isKindOfClass:[MCMailViewController class]]) {
            [currentViewController.view showErrorNote];
        }
        //触发本地推送
        [self sentMailFailureTriggerLocalNotification];
    } else {
        [self sendEmailWithMail:mail];
    }
}

//发送邮件
- (void)sendEmailWithMail:(MCMailModel*)mailModel{
    
    if (_mailDraftManagerCallback) {
        _mailDraftManagerCallback(MCMailDraftManagerTypeSent,mailModel);
    }
    __weak typeof(self)weakSelf = self;
    UIViewController *viewController = [MCViewDisplay getRootViewController];
    
    [self.mailManager sendEmailWithMail:mailModel success:^(id response) {
        
        [weakSelf setWeight:0 mailAds:mailModel.to];
        [weakSelf setWeight:kMailChatContactWeightCc mailAds:mailModel.cc];
        [weakSelf setWeight:kMailChatContactWeightBcc mailAds:mailModel.bcc];
        
        if (weakSelf.mailComposerType == MCMailComposerReplyAll
            || weakSelf.mailComposerType == MCMailComposerReplySingle) {
            if (weakSelf.mailModel.folder) {
                [self.mailManager setAnswerFlag:YES forMail:weakSelf.mailModel success:^{
                    
                } failure:nil];
            }
        }
        
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (weakSelf.mailDraftManagerCallback) {
                weakSelf.mailDraftManagerCallback(MCMailDraftManagerTypeNew,mailModel);
            }
            UIViewController *currentViewController = [MCViewDisplay getCurrentViewController];
            if (self.mailComposerType != MCMailComposerFromPending) {
                [MCNotificationCenter postNotification:MCNotificationSentMailFailure object:@(NO)];
            }
            
            [viewController.navigationController dismissMCProgress];
            if (![currentViewController isKindOfClass:[MCMailViewController class]]) {
                [currentViewController.view showErrorNote];
            }
            //触发本地推送
            [weakSelf sentMailFailureTriggerLocalNotification];
        });
        
    } progress:^(NSInteger progress, NSInteger maxmim) {
        CGFloat pro = progress/(CGFloat)maxmim;
        pro = pro < 0.3?0.3:pro;
        [viewController.navigationController showMCProgress:pro];
    }];
    //default
    [viewController.navigationController showMCProgress:0.2];
}

//private
- (MCMailModel*)mailWithTo:(NSArray*)to
                        cc:(NSArray*)cc
                       bcc:(NSArray*)bcc
                   subject:(NSString*)subject
                   attachs:(NSArray*)attachments
          inlineAttachment:(NSArray*)inlineAttachments {
    MCMailModel *mailModel = [MCMailModel new];
    MCMailAddress *from = [MCMailAddress new];
    from.email = AppStatus.currentUser.email;
    from.name = AppStatus.currentUser.displayName;
    mailModel.from = from;
    mailModel.to = to;
    mailModel.cc = cc;
    mailModel.bcc = bcc;
    mailModel.subject = subject;
    mailModel.boxId = self.mailModel.boxId;
    mailModel.uid  = self.mailModel.uid;
    mailModel.messageUid = self.mailModel.messageUid;
    mailModel.references = self.mailModel.references;
    mailModel.inReplyTo = self.mailModel.inReplyTo;
    mailModel.messageId = self.mailModel.messageId;
    if (mailModel.messageUid == 0) {
        mailModel.messageUid = [[NSDate date] timeIntervalSince1970];
    }
    mailModel.messageContentHtml = [self htmlContent];
    mailModel.messageContentString = self.mailComposerWebView.textContent;
    mailModel.attachments = attachments;
    mailModel.inlineAttachments = inlineAttachments;
    mailModel.customMarkId = self.mailModel.customMarkId;
    if (attachments.count > 0) {
        mailModel.hasAttachment = YES;
    }
    return mailModel;
}

- (NSString*)htmlContent {
    //TODO:内嵌图片本地Path 替换cid后发送
    NSString *html = self.mailComposerWebView.htmlContent;
    for (MCMailAttachment *attachment in _mailModel.inlineAttachments) {
        if (!attachment.localPath) {
            continue;
        }
        NSString*fullPath = [[[MCFileCore sharedInstance] getFileModule] getFileFullPathWithShortPath:attachment.localPath];
        fullPath = [NSString stringWithFormat:@"file://%@",fullPath];
        NSRange range = [html rangeOfString:fullPath];
        if (range.location != NSNotFound) {
            html = [html stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"cid:%@",attachment.cid]];
        }
    }
    return html;
}

- (NSMutableArray*)arrayWithTokenField:(TITokenField*)tokenField {
    
    if (tokenField.tag == ToTokenFieldTag) {
        return self.toArray;
    } else if (tokenField.tag == CcTokenFieldTag) {
        return self.ccArray;
    } else if (tokenField.tag == BcTokenFieldTag) {
        return  self.bccArray;
    }
    return [NSMutableArray new];
}

- (void)pop {
    [self.navigationController popViewControllerAnimated:YES];
}
//转发回复 返回主界面
- (void)popToRootViewController {
    if (self.mailComposerType == MCMailComposerForward ||
        self.mailComposerType == MCMailComposerReplyAll ||
        self.mailComposerType == MCMailComposerReplySingle) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)refreshAttachmentCount {
    if (_attachments.count > 0) {
        _attachCountLable.text = [NSString stringWithFormat:@"%ld",(long)_attachments.count];
    } else {
        _attachCountLable.text = nil;
    }
}

- (BOOL)attachmentsMoreThanLimit {
    if (self.attachments.count == 0) {
        return NO;
    }
    NSInteger totalSize = 0;
    for (MCMailAttachment *att in self.attachments) {
        if (att.size != 0 || att.size != NSNotFound) {
            totalSize += att.size;
        } else if (att.data){
            totalSize += att.data.length;
        }
    }
    if (totalSize/1024/1024 > kMailAttachmentSizeDefautLimit) {
        RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:PMLocalizedStringWithKey(@"PM_Common_Sure")];
        UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:PMLocalizedStringWithKey(@"PM_Common_Notice") message:@"附件太大无法发送" cancelButtonItem:cancelItem otherButtonItems: nil];
        [alertView show];
        return YES;
    }
    return NO;
}

//转发回复header
- (NSString *)composerHeaderMessageWithMail:(MCMailModel*)mail {
    
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *date = [NSString stringWithFormat:@"%@<br>",[dateFormatter stringFromDate:mail.receivedDate]];
    NSString *from = mail.from?[NSString stringWithFormat:@"%@: %@<br>",self.setLanguagetype == MCMailSubjectLanguageEnglish?@"from":self.setLanguagetype == MCMailSubjectLanguageTraditionalChinese?@"寄件者":PMLocalizedStringWithKey(@"PM_Mail_MailFrom"),[MCModelConversion stringWithMailAddresses:@[mail.from]]]:@"";
    NSString *to = mail.to?[NSString stringWithFormat:@"%@: %@<br>",self.setLanguagetype == MCMailSubjectLanguageEnglish?@"To":self.setLanguagetype == MCMailSubjectLanguageTraditionalChinese?@"收件人":PMLocalizedStringWithKey(@"PM_Mail_MailTo"),[MCModelConversion stringWithMailAddresses:mail.to]]:@"";
    NSString *cc = mail.cc.count > 0?[NSString stringWithFormat:@"%@: %@<br>",self.setLanguagetype == MCMailSubjectLanguageEnglish?@"Cc":self.setLanguagetype == MCMailSubjectLanguageTraditionalChinese?@"抄送人":PMLocalizedStringWithKey(@"PM_Mail_MailDetailCc"),[MCModelConversion stringWithMailAddresses:mail.cc]]:@"";
    NSString *subject = [NSString stringWithFormat:@"%@: %@<br>",self.setLanguagetype == MCMailSubjectLanguageEnglish?@"Subject":self.setLanguagetype == MCMailSubjectLanguageTraditionalChinese?@"主題":PMLocalizedStringWithKey(@"PM_Mail_MailSubject"),mail.subject];
    //    NSString *title = @"<div style=\"border-bottom:1px dashed\"></div></td><td style=\"width:85.000000px;text-align:center\">原始邮件</td><td><div style=\"border-bottom:1px dashed\"></div>";
    
    NSString *header = [NSString stringWithFormat: @"</br><div style= \"background-color:#DDDDDD;padding-top:6px;padding-bottom:6px;border-radius:3px;-moz-border-radius: 3px;-webkit-border-radius: 3px;margin-bottom:20px;margin-top:4px;word-break:break-all;\"> <div style=\"margin-left:10px;margin-right:10px\"><font size = \"2\" color = \"#6C6C6C\">%@%@%@%@%@</font></td></div></div>",from,to,cc,date,subject];
    return header;
}
//联系人权重

- (void)setWeight:(NSInteger)weight mailAds:(NSArray*)ads {
    
    if (weight == 0) {
        if (self.mailComposerType == MCMailComposerForward) {
            weight = kMailChatContactWeightForward;
        } else if (self.mailComposerType == MCMailComposerReplyAll ||self.mailComposerType == MCMailComposerReplySingle) {
            weight = kMailChatContactWeightReply;
        } else {
            weight = kMailChatContactWeightNewMail;
        }
    }
    for (MCMailAddress *ad in ads) {
        MCContactModel *model = [MCModelConversion contactModelWithMailAddress:ad];
        [[MCContactManager sharedInstance] addWeight:weight toContact:model];
    }
}

//private
- (void)existUser:(NSMutableArray*)toArray fromArray:(NSArray*)fromArray {
    
    for (MCMailAddress *ad in fromArray) {
        if ([ad.email isEqualToString:AppStatus.currentUser.email] ||[toArray containsObject:ad]) {
            continue;
        }
        [toArray addObject:ad];
    }
}

//失败发送本地推送
//发送邮件失败 发起本地通知
- (void)sentMailFailureTriggerLocalNotification{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    // 设置触发通知的时间
    NSDate *fireDate = [NSDate date];
    
    notification.fireDate = fireDate;
    // 时区
    notification.timeZone = [NSTimeZone defaultTimeZone];
    // 设置重复的间隔
    notification.repeatInterval = 0;
    // 通知内容
    notification.alertBody =  PMLocalizedStringWithKey(@"PM_Mail_SendFailureNote");
    notification.applicationIconBadgeNumber = 1;
    // 通知被触发时播放的声音
    notification.soundName = UILocalNotificationDefaultSoundName;
    // 通知参数
    NSDictionary *userDict = [NSDictionary dictionaryWithObject:PMLocalizedStringWithKey(@"PM_Mail_SendFailureNote") forKey:@"key"];
    notification.userInfo = userDict;
    // 执行通知注册
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}
//dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    _mailComposerWebView = nil;
}

- (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
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
}

- (void)showNoPermission
{
    [[[UIAlertView alloc] initWithTitle:nil
                                message:@"麦克风权限被关闭"   //@"无麦克风访问权限。\n请启用麦克风-设置/隐私/麦克风"
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

@end
