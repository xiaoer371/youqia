//
//  MCIMChatBaseBubbleView.m
//  NPushMail
//
//  Created by swhl on 16/2/23.
//  Copyright © 2016年 sprite. All rights reserved.
//

#import "MCIMChatBaseBubbleView.h"

//NSString *const kRouterEventChatCellBubbleTapEventName = @"kRouterEventChatCellBubbleTapEventName";

NSString *const kRouterEventChatCellForwordEvent = @"kRouterEventChatCellForwordEvent";
NSString *const kRouterEventChatCellDeleteEvent  = @"kRouterEventChatCellDeleteEvent";


@interface MCIMChatBaseBubbleView ()

@end

@implementation MCIMChatBaseBubbleView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        _backImageView.userInteractionEnabled = YES;
        _backImageView.multipleTouchEnabled = YES;
        _backImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_backImageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewPressed:)];
        [self addGestureRecognizer:tap];
        tap.cancelsTouchesInView = NO;
        self.backgroundColor = [UIColor clearColor];
        
        UILongPressGestureRecognizer  *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongTap:)];
        longTap.cancelsTouchesInView = NO;
        longTap.minimumPressDuration = 0.5;
        [self addGestureRecognizer:longTap];

    }
    return self;
}


#pragma mark - setter

- (void)setModel:(MCIMMessageModel*)model
{
    _model =  model;
    
    BOOL isReceiver = _model.isSender;
    UIImage *bubbleImage;
    switch (model.type) {
        case IMMessageTypeText:
        case IMMessageTypeImage:
        case IMMessageTypeVoice:
            bubbleImage = isReceiver ? AppStatus.theme.outgoingBubbleStyle.bubbleWithText: AppStatus.theme.incomingBubbleStyle.bubbleWithText;
            break;
        case IMMessageTypeFile:
            bubbleImage = isReceiver ? AppStatus.theme.outgoingBubbleStyle.bubbleWithFile: AppStatus.theme.incomingBubbleStyle.bubbleWithFile;
            break;
        default:
            break;
    }
    
    NSInteger leftCapWidth = isReceiver ? AppStatus.theme.outgoingBubbleStyle.capInsetWidth : AppStatus.theme.incomingBubbleStyle.capInsetWidth;
    NSInteger rightcapwidth =  isReceiver ? AppStatus.theme.outgoingBubbleStyle.capInsetHeight : AppStatus.theme.incomingBubbleStyle.capInsetHeight;
    //上  左  下 右
    self.backImageView.image =  [bubbleImage resizableImageWithCapInsets:UIEdgeInsetsMake(34, leftCapWidth,4, rightcapwidth)];
}

#pragma mark - public

+ (CGFloat)heightForBubbleWithObject:(MCIMMessageModel *)object
{
    return 30;
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
        [menu setTargetRect:self.backImageView.frame inView:self];
        [menu setMenuVisible:YES animated:YES];
    }
}

//添加
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    
    if (action == @selector(copy:)) {
        if (self.model.type ==IMMessageTypeText ) {
            return YES;
        }else return NO;
    }
    else if(action == @selector(forward:))
    {
        switch (self.model.type) {
            case IMMessageTypeText:
            case IMMessageTypeImage:
            case IMMessageTypeFile:
                 return YES;
                break;
                
            default:
                return NO;
                break;
        }
    }else if(action == @selector(customDelete:)){
       return YES;
    }else
    {
         return NO;
    }
}

-(void)copy:(id)sender
{
    
}

-(void)customDelete:(id)sender
{
    [self routerEventWithName:kRouterEventChatCellDeleteEvent userInfo:@{KMESSAGEKEY:self.model}];
}

-(void)forward:(id)sender
{
    [self routerEventWithName:kRouterEventChatCellForwordEvent userInfo:@{KMESSAGEKEY:self.model}];
}

- (void)bubbleViewPressed:(id)sender
{
//    [self routerEventWithName:kRouterEventChatCellBubbleTapEventName userInfo:@{KMESSAGEKEY:self.model}];
}

@end
