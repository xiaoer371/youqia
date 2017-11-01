//
//  MCIMChatTextBubbleView.m
//  NPushMail
//
//  Created by swhl on 16/2/23.
//  Copyright © 2016年 sprite. All rights reserved.
//
#import <CoreText/CoreText.h>
#import "MCIMChatTextBubbleView.h"
#import "NSString+Extension.h"
#import "MCIMChatBubbleTool.h"
#import "UIView+MCExpand.h"
#import "MCIMChatBubbleTool.h"

#define TEXTLABEL_MAX_WIDTH (ScreenWidth-130) // textLaebl 最大宽度

NSString *const kRouterEventTextURLTapEventName = @"kRouterEventTextURLTapEventName";
NSString *const kRouterEventTextNumTapEventName = @"kRouterEventTextNUMTapEventName";

static const CGFloat MCChatTextTextFont     = 16.0;
static const CGFloat MCChatEmojiWidth       = 24.0;  //26
static const CGFloat MCChatEmojiHeight      = 24.0;  //25
static const CGFloat MCChatTextTextSpacing  = 0.5; // 字间距
static const CGFloat MCChatTextLineSpacing  = 2.0; // 行间距

static const CGFloat MCChatTextPadingLeft   = 5.0;
static const CGFloat MCChatTextInset        = 8.0;


@interface MCIMChatTextBubbleView ()<TYAttributedLabelDelegate>
{
    TYTextContainer      *_textContainer;
}
@end

@implementation MCIMChatTextBubbleView

- (id)initWithFrame:(CGRect)frame
{
    CGRect rect = frame;
    if (frame.size.height ==0 || frame.size.width ==0) {
        rect = CGRectMake(0, 0, 1, 1);
    }
    if (self = [super initWithFrame:rect]) {
         [self addAtrribuedLabel];
        self.userInteractionEnabled =YES;
    }
    return self;
}


- (void)addAtrribuedLabel
{
    _textLabel = [[TYAttributedLabel alloc]initWithFrame:CGRectMake(0, 0, 1, 1)];
    _textLabel.backgroundColor = [UIColor clearColor];
    _textLabel.numberOfLines = 0;
    _textLabel.delegate = self;
    _textLabel.isWidthToFit = YES;
    _textLabel.userInteractionEnabled = YES;
    _textLabel.verticalAlignment = TYVerticalAlignmentCenter;
    
    [self addSubview:_textLabel];
}


#pragma mark - setter

- (void)setModel:(MCIMMessageModel *)model
{
    [super setModel:model];

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _textContainer = [weakSelf textContainerWithMsgModel:model];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.textLabel.textContainer =_textContainer;
            [weakSelf reSetSubViewsFrame];
            [weakSelf.delegate reSetFrameAutoSuperView];
        });
    });
}

- (void)reSetSubViewsFrame
{
    CGFloat s_width  = MAX(41, _textContainer.textWidth+MCChatTextInset*2+BUBBLE_ARROW_WIDTH+MCChatTextPadingLeft+4);
    CGFloat s_height = MAX(41, _textContainer.textHeight+5+MCChatTextInset*2);

    self.mc_size = CGSizeMake(s_width,s_height);

    CGRect frame = self.bounds;
    frame.size.width = frame.size.width- BUBBLE_ARROW_WIDTH - MCChatTextPadingLeft;
    frame.size.height -=(MCChatTextInset*2);
    frame.size.width  -=(MCChatTextInset*2);
    CGFloat height =_textContainer.textHeight; //[_textContainer getHeightWithFramesetter:nil width:frame.size.width];
    //    单行文本要特殊处理下。
    if (height <= 30) {
        frame.size.height = 38;
        _textLabel.verticalAlignment = TYVerticalAlignmentCenter;
    }else if (height <= 40 && height>30){
        frame.size.height = 46;
        _textLabel.verticalAlignment = TYVerticalAlignmentTop;
    }else{
        _textLabel.verticalAlignment = TYVerticalAlignmentTop;
    }
    frame.origin.y = 4.0f;
    
    if (self.model.isSender) {
        frame.origin.x = BUBBLE_VIEW_PADDING + 5;
    }else{
        frame.origin.x = BUBBLE_VIEW_PADDING+MCChatTextPadingLeft + BUBBLE_ARROW_WIDTH + 2;
    }
    self.textLabel.frame = frame;

}

#pragma mark - TYAttributedLabelDelegate
- (void)attributedLabel:(TYAttributedLabel *)attributedLabel textStorageClicked:(id<TYTextStorageProtocol>)TextRun atPoint:(CGPoint)point
{
    if ([TextRun isKindOfClass:[TYLinkTextStorage class]]) {
        id linkStr = ((TYLinkTextStorage*)TextRun).linkData;
        if ([linkStr isKindOfClass:[NSString class]]) {
            NSString *link = (NSString *)linkStr;
            //  if ([link isPhone]) {
            [self routerEventWithName:kRouterEventTextNumTapEventName userInfo:@{KMESSAGEKEY:self.model, @"link":link}];
        }else{
            NSURL *url = (NSURL*)linkStr;
            [self routerEventWithName:kRouterEventTextURLTapEventName userInfo:@{KMESSAGEKEY:self.model, @"link":url}];
        }
    }else if ([TextRun isKindOfClass:[TYImageStorage class]]) {
        
    }
}

- (void)onLongTap:(id)sender
{
    UILongPressGestureRecognizer *tap = (UILongPressGestureRecognizer *)sender;

    if(tap.state == UIGestureRecognizerStateBegan){
        [self becomeFirstResponder];
        UIMenuItem *flag1 = [[UIMenuItem alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_FORWARD_Forward") action:@selector(forward:)];
        UIMenuItem *flag2 = [[UIMenuItem alloc] initWithTitle:PMLocalizedStringWithKey(@"PM_IMChat_MessageDelete") action:@selector(customDelete:)];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:[NSArray arrayWithObjects:flag1,flag2, nil]];
        [menu setTargetRect:self.textLabel.frame inView:self];
        [menu setMenuVisible:YES animated:YES];
    }
}

- (void)customDelete:(id)sender
{
    [self routerEventWithName:kRouterEventChatCellDeleteEvent userInfo:@{KMESSAGEKEY:self.model}];
}

- (void)forward:(id)sender
{
     [self routerEventWithName:kRouterEventChatCellForwordEvent userInfo:@{KMESSAGEKEY:self.model}];
}

- (void)copy:(id)sender
{
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string =  self.model.content;
}

+(CGFloat)heightForBubbleWithObject:(MCIMMessageModel *)object
{
    TYTextContainer *textContainer = [self textContainerWithMsgModel:object];
    CGFloat height = object.isSender?0:20;
    return textContainer.textHeight+15+MCChatTextInset*2+height;
}

- (TYTextContainer *)textContainerWithMsgModel:(MCIMMessageModel *)model
{
    TYTextContainer *textContainer = [[TYTextContainer alloc]init];
    textContainer.text = model.content;
    textContainer.linesSpacing = MCChatTextLineSpacing;
    //TODO:  适配pc端换行消息
    if ([model.content mcContainsString:@"\r\n"]) {
        textContainer.lineBreakMode = NSLineBreakByClipping;
        
        NSArray * array = [model.content componentsSeparatedByString:@"\r\n"];
        for (NSString * str  in array) {
            if (ScreenWidth<321) {
                if (str.length >=13) {
                    textContainer.lineBreakMode = kCTLineBreakByWordWrapping;
                    break;
                }
            }
            if (str.length >=17) {
                textContainer.lineBreakMode = kCTLineBreakByWordWrapping;
                break;
            }
        }
    }else{
        textContainer.lineBreakMode = kCTLineBreakByWordWrapping;
    }
    
    textContainer.characterSpacing = MCChatTextTextSpacing;
    if (model.isSender) {
        textContainer.textColor = [UIColor whiteColor];
    }else{
        textContainer.textColor = [UIColor darkTextColor];
    }
    textContainer.isWidthToFit = YES;
    textContainer.font =[UIFont systemFontOfSize:MCChatTextTextFont];
    NSMutableArray *tmpArray = [NSMutableArray array];
    // 正则匹配图片信息
    NSArray* matchEmoji;
    if ([MCIMChatBubbleTool  sharedInstance].emojiMatches[model.messageId]) {
        matchEmoji = [MCIMChatBubbleTool  sharedInstance].emojiMatches[model.messageId];
    }else{
        matchEmoji =[[MCIMChatBubbleTool  sharedInstance] getEmojiMatchsWithContent:model.content];
        if (matchEmoji.count==0) {
            matchEmoji =@[];
        }
        [[MCIMChatBubbleTool  sharedInstance].emojiMatches setObject:matchEmoji forKey:model.messageId];
    }
    if (matchEmoji.count != 0)
    {
        for (NSTextCheckingResult *matc in matchEmoji)
        {
            NSRange range = [matc range];
            NSString * imageName =[MCIMChatBubbleTool sharedInstance].mapper[[model.content substringWithRange:range]];
            if (!imageName) {
                continue;
            }
            TYImageStorage *imageStorage = [[TYImageStorage alloc]init];
            imageStorage.cacheImageOnMemory = YES;
            imageStorage.imageName = imageName;
            imageStorage.range =range;
            imageStorage.size = CGSizeMake(MCChatEmojiWidth, MCChatEmojiHeight);
            [tmpArray addObject:imageStorage];
        }
    }
    NSArray* matchs;
    if ([MCIMChatBubbleTool  sharedInstance].PhoneMatches[model.messageId]) {
        matchs = [MCIMChatBubbleTool  sharedInstance].PhoneMatches[model.messageId];
    }else{
        matchs =[[MCIMChatBubbleTool  sharedInstance] getPhoneAndLinkMatchsWithContent:model.content];
        if (matchs.count==0) {
            matchs =@[];
        }
        [[MCIMChatBubbleTool  sharedInstance].PhoneMatches setObject:matchs forKey:model.messageId];
    }
    if (matchs.count != 0)
    {
        for (NSTextCheckingResult *match in matchs)
        {
            NSRange range = [match range];
            
            if ([match resultType] == NSTextCheckingTypeLink) {
                [textContainer addLinkWithLinkData:match.URL linkColor:[UIColor blueColor]
                                    underLineStyle:kCTUnderlineStyleSingle range:range];
            }
            if ([match resultType] == NSTextCheckingTypePhoneNumber) {
                
                [textContainer addLinkWithLinkData:match.phoneNumber linkColor:[UIColor blueColor]
                                    underLineStyle:kCTUnderlineStyleNone range:range];
            }
        }
    }
    // 添加图片信息数组到label
    [textContainer addTextStorageArray:tmpArray];
    textContainer = [textContainer createTextContainerWithContentSize:CGSizeMake(TEXTLABEL_MAX_WIDTH, MAX(40, [textContainer getHeightWithFramesetter:nil width:TEXTLABEL_MAX_WIDTH]))];
    
    return textContainer;
}


+ (TYTextContainer *)textContainerWithMsgModel:(MCIMMessageModel *)model
{
    TYTextContainer *textContainer = [[TYTextContainer alloc]init];
    textContainer.text = model.content;
    //TODO:  适配pc端换行消息
    if ([model.content mcContainsString:@"\r\n"]) {
        textContainer.lineBreakMode = NSLineBreakByClipping;
        
        NSArray * array = [model.content componentsSeparatedByString:@"\r\n"];
        for (NSString * str  in array) {
            if (ScreenWidth<321) {
                if (str.length >=13) {
                    textContainer.lineBreakMode = kCTLineBreakByWordWrapping;
                    break;
                }
            }
            if (str.length >=17) {
                textContainer.lineBreakMode = kCTLineBreakByWordWrapping;
                break;
            }
        }
    }else{
        textContainer.lineBreakMode = kCTLineBreakByWordWrapping;
    }
    
    textContainer.linesSpacing = MCChatTextLineSpacing;
    textContainer.characterSpacing = MCChatTextTextSpacing;
    if (model.isSender) {
        textContainer.textColor = [UIColor whiteColor];
    }else{
        textContainer.textColor = [UIColor darkTextColor];
    }
    textContainer.font =[UIFont systemFontOfSize:MCChatTextTextFont];
    NSMutableArray *tmpArray = [NSMutableArray array];
    // 正则匹配图片信息
    NSArray* matchEmoji;
    if ([MCIMChatBubbleTool  sharedInstance].emojiMatches[model.messageId]) {
        matchEmoji = [MCIMChatBubbleTool  sharedInstance].emojiMatches[model.messageId];
    }else{
        matchEmoji =[[MCIMChatBubbleTool  sharedInstance] getEmojiMatchsWithContent:model.content];
        if (matchEmoji.count==0) {
            matchEmoji =@[];
        }
        [[MCIMChatBubbleTool  sharedInstance].emojiMatches setObject:matchEmoji forKey:model.messageId];
    }
    if (matchEmoji.count != 0)
    {
        for (NSTextCheckingResult *matc in matchEmoji)
        {
            NSRange range = [matc range];
            NSString *imageName = [MCIMChatBubbleTool sharedInstance].mapper[[model.content substringWithRange:range]];
            if (!imageName) {
                continue;
            }
            TYImageStorage *imageStorage = [[TYImageStorage alloc]init];
            imageStorage.cacheImageOnMemory = YES;
            imageStorage.imageName = imageName;
            imageStorage.range =range;
            imageStorage.size = CGSizeMake(MCChatEmojiWidth, MCChatEmojiHeight);
            [tmpArray addObject:imageStorage];
        }
    }
    // 添加图片信息数组到label
    [textContainer addTextStorageArray:tmpArray];
    textContainer = [textContainer createTextContainerWithContentSize:CGSizeMake(TEXTLABEL_MAX_WIDTH, MAX(40, [textContainer getHeightWithFramesetter:nil width:TEXTLABEL_MAX_WIDTH]))];
    return textContainer;
}

@end
