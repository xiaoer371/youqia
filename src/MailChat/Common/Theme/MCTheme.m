//
//  MCTheme.m
//  NPushMail
//
//  Created by admin on 1/27/16.
//  Copyright © 2016 sprite. All rights reserved.
//

#import "MCTheme.h"
#import "UIColor+Hex.h"

@interface MCTheme ()

@property (nonatomic,strong) NSDictionary *styles;
@property (nonatomic,strong) NSBundle *bundle;

@end

@implementation MCTheme

- (instancetype)initWithName:(NSString *)themeName
{
    if (self = [super init]) {
        _name = themeName;
        [self initTheme];
    }
    
    return self;
}

#pragma mark - Private

- (void)initTheme
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:_name ofType:@"bundle"];
    self.bundle = [NSBundle bundleWithPath:bundlePath];
    
    NSString *plistPath = [self.bundle pathForResource:@"Theme" ofType:@"plist"];
    _styles = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    _tintColor = [self colorForKey:@"TintColor"];
    _tintWeakColor = [self colorForKey:@"TintWeakColor"];
    _darkBackgroundColor = [self colorForKey:@"DarkBackgroundColor"];
    _darkBorderColor = [self colorForKey:@"DarkBorderColor"];
    _fontTintColor = [self colorForKey:@"FontTintColor"];
    _titleTextColor = [self colorForKey:@"TitleTextColor"];
    _backgroundColor = [self colorForKey:@"BackgroundColor"];
    _navgationBarTitleTextColor = [self colorForKey:@"navgationBarTitleColor"];
    _toolBarBackgroundColor = [self colorForKey:@"toolBarBackgroundColor"];
    _toolBarSeparatorColor = [self colorForKey:@"toolBarSeparatorColor"];
    _borderColor = [self colorForKey:@"BorderColor"];
    _tableViewSeparatorColor = [self colorForKey:@"tableViewSeparatorColor"];
    
    _accountImage = [self imageForKey:@"logindetail_account"];
    _passwordImage = [self imageForKey:@"logindetail_password"];
    _passwordHidImage = [self imageForKey:@"logindetail_password_hid"];
    _passwordShowImage = [self imageForKey:@"logindetail_password_show"];
    _accountClearImage = [self imageForKey:@"logindetail_account_del"];
    
    _commonBackImage = [self imageForKey:@"Common_nav_back"];
    _selectStateImage = [self imageForKey:@"Common_select_state"];
    _unselectStateImage = [self imageForKey:@"Common_deselect_state"];
    _cantEditStateImage = [self imageForKey:@"Common_cantEditStateImage"];
    
    _mailBoxStyle = [self setMailBoxIconStyle];
    _mailStyle = [self setMailStyle];
    _chatStyle = [self setChatStyle];
    _profileStyle = [self setMCProfleStyle];
    
    _outgoingBubbleStyle = [self setBubbleStyleSenderOrResive:YES];
    _incomingBubbleStyle = [self setBubbleStyleSenderOrResive:NO];
    
    _tabBarImages = [self tabBarImagesWithKey:@"TabBar"];
    _tabBarHightlightImages = [self tabBarImagesWithKey:@"TabBarHightlight"];
    
    _navbarBgImage = [self imageForKey:@"Navbar_bg_image"];
}
//tabBar
- (NSArray*)tabBarImagesWithKey:(NSString*)key{
    NSMutableArray*images = [NSMutableArray new];
    for (int i = 0; i < 5; i ++) {
        NSString* imageKey = [NSString stringWithFormat:@"%@_%d",key,i];
        UIImage *image = [self imageForKey:imageKey];
        [images addObject:image];
    }
    return images;
}

//邮件样式
- (MCMailStyle*)setMailStyle {
    
    MCMailStyle*mailStyle = [MCMailStyle new];
    mailStyle.mailListLeftImage = [[self imageForKey:@"MailListvc_nav_left"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    mailStyle.mailListRightImage = [[self imageForKey:@"MailListvc_nav_write"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    mailStyle.mailListSearchImage = [[self imageForKey:@"MailListvc_nav_search"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    mailStyle.mailDetailRightDeSelectImage = [[self imageForKey:@"Maildetailvc_nav_star"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    mailStyle.mailDetailRightSelectImage = [[self imageForKey:@"Maildetailvc_nav_stard"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    mailStyle.mailAttachCellBackgroundColor = [self colorForKey:@"MailAttachCellBackgroundColor"];
    mailStyle.attachmentShareImage = [self imageForKey:@"attachmentShare"];
    return mailStyle;
}

- (MCMailBoxIconStyle*)setMailBoxIconStyle {
    
    MCMailBoxIconStyle *mailBoxIconStyle = [MCMailBoxIconStyle new];
    mailBoxIconStyle.inboxIcon = [self imageForKey:@"MailBox_inbox"];
    mailBoxIconStyle.trashBoxIcon = [self imageForKey:@"MailBox_trash"];
    mailBoxIconStyle.pendingBoxIcon = [self imageForKey:@"MailBox_pending"];
    mailBoxIconStyle.sentBoxIcon = [self imageForKey:@"MailBox_sent"];
    mailBoxIconStyle.draftsBoxIcon = [self imageForKey:@"MailBox_draft"];
    mailBoxIconStyle.starBoxIcon = [self imageForKey:@"MailBox_stard"];
    mailBoxIconStyle.otherBoxIcon = [self imageForKey:@"MailBox_other"];
    mailBoxIconStyle.spamBoxIcon = [self imageForKey:@"MailBox_spam"];
    mailBoxIconStyle.backgroundImage = [self imageForKey:@"MailboxList_background"];
    return mailBoxIconStyle;
}

//聊天界面样式
-(MCIMChatStyle *)setChatStyle
{
    MCIMChatStyle *imChatStyle = [[MCIMChatStyle alloc] init];
    imChatStyle.messageNavRightImage = [[self imageForKey:@"Messagevc_nav_right"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    imChatStyle.chatNavRightImage = [[self imageForKey:@"Chatvc_nav_right"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    imChatStyle.chatToolBarBackColor = [self colorForKey:@"ChatInput_backColor"];
    
    imChatStyle.voiceImage = [self imageForKey:@"ChatInput_voice"];
    imChatStyle.textImage  = [self imageForKey:@"ChatInput_text"];
    imChatStyle.faceImage  = [self imageForKey:@"ChatInput_face"];
    imChatStyle.moreImage  = [self imageForKey:@"ChatInput_more"];
    
    imChatStyle.morePhothImage = [self imageForKey:@"mc_imchat_morephoto"];
    imChatStyle.moreTakeImage  = [self imageForKey:@"mc_imchat_moretakephoto"];
    imChatStyle.moreFileImage  = [self imageForKey:@"mc_imchat_morefile"];

    imChatStyle.chatInfoContactAddImage = [self imageForKey:@"chatinfovc_contact_add"];
    imChatStyle.chatInfoContactdelImage = [self imageForKey:@"chatinfovc_contact_del"];;
    
    imChatStyle.faceViewBackGroundColor = [UIColor whiteColor]; //[self colorForKey:@""];
    imChatStyle.moreViewBackGroundColor = [self colorForKey:@"moreViewBackground"];
    

    return imChatStyle;
}

-(MCIMBubbleStyle*)setBubbleStyleSenderOrResive:(BOOL)isSender
{
    MCIMBubbleStyle *bubbleStyle = [[MCIMBubbleStyle alloc] init];
    if (isSender) {
        
        bubbleStyle.bubbleWithText = [self imageForKey:@"bubble_text_sender"];
        bubbleStyle.bubbleWithFile = [self imageForKey:@"bubble_file_sender"];
        bubbleStyle.voiceMini1 = [self imageForKey:@"voice_blue1"];
        bubbleStyle.voiceMini2 = [self imageForKey:@"voice_blue2"];
        bubbleStyle.voiceMini3 = [self imageForKey:@"voice_blue3"];
        bubbleStyle.voiceDefaul = [self imageForKey:@"voice_blue3"];
        bubbleStyle.capInsetWidth = [[self valueNumForKey:@"capInset_sender_width"] integerValue];
        bubbleStyle.capInsetHeight = [[self valueNumForKey:@"capInset_sender_height"] integerValue];;
    }else{
        
        bubbleStyle.bubbleWithText = [self imageForKey:@"bubble_text_resiver"];
        bubbleStyle.bubbleWithFile = [self imageForKey:@"bubble_file_resiver"];
        bubbleStyle.voiceMini1 = [self imageForKey:@"voice_gray1"];
        bubbleStyle.voiceMini2 = [self imageForKey:@"voice_gray2"];
        bubbleStyle.voiceMini3 = [self imageForKey:@"voice_gray3"];
        bubbleStyle.voiceDefaul = [self imageForKey:@"voice_gray3"];
        bubbleStyle.capInsetWidth = [[self valueNumForKey:@"capInset_resiver_width"] integerValue];
        bubbleStyle.capInsetHeight = [[self valueNumForKey:@"capInset_resiver_height"] integerValue];;
    }
    
    return bubbleStyle;
}

- (MCProfileStyle*)setMCProfleStyle {
    MCProfileStyle *mCProfileStyle = [MCProfileStyle new];
    
    mCProfileStyle.mCUserNoteImage = [self imageForKey:@"setCurrentUser"];
    mCProfileStyle.mCAddAccountImage = [self imageForKey:@"setAddAccount"];
    mCProfileStyle.mCUsrInfoImage = [self imageForKey:@"setUserDetail"];
    
    return mCProfileStyle;
}

- (UIColor *)colorForKey:(NSString *)key
{
    id value = _styles[key];
    if (!value) {
        DDLogError(@"No key (%@) in theme: %@", key, _name);
        return nil;
    }
    
    return [UIColor colorWithHexString:value];
}

- (UIImage *)imageForKey:(NSString *)key
{
    id value = _styles[key];
    if (!value) {
        DDLogError(@"No key (%@) in theme: %@", key, _name);
        return nil;
    }
    NSString *imagePath = [NSString stringWithFormat:@"%@.bundle/Images/%@",self.name,value];
    return [UIImage imageNamed:imagePath];
}

-(NSNumber *)valueNumForKey:(NSString *)key
{
    id value = _styles[key];
    if (!value) {
        DDLogError(@"No key (%@) in theme: %@", key, _name);
        return nil;
    }
    return value;
}


@end
